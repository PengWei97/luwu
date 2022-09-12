//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "DeformedGrainMaterialGG.h"
#include "GrainTrackerInterface.h"

registerMooseObject("luwuApp", DeformedGrainMaterialGG);

InputParameters
DeformedGrainMaterialGG::validParams()
{
  InputParameters params = Material::validParams();
  params.addRequiredCoupledVarWithAutoBuild(
      "v", "var_name_base", "op_num", "Array of coupled variables");
  params.addRequiredParam<unsigned int>("deformed_grain_num",
                                        "Number of OP representing deformed grains");
  params.addRequiredParam<UserObjectName>("ebsd_reader", "The EBSDReader GeneralUserObject");
  MooseEnum field_types = EBSDAccessFunctors::getPointDataFieldType();        
  params.addRequiredParam<MooseEnum>("data_name", field_types, "The data to be extracted from the EBSD data by");        
  params.addRequiredParam<std::string>("type_crystalline", "Type named of crystalline structure");                        
  params.addParam<Real>("length_scale", 1.0e-9, "Length scale in m, where default is nm");
  params.addParam<Real>("Disloc_Den", 9.0e15, "Dislocation Density in m^-2");
  params.addParam<Real>("Elas_Mod", 2.50e10, "Elastic Modulus in J/m^3"); // 弹性模量
  params.addParam<Real>("Burg_vec", 3.0e-10, "Length of Burger Vector in m"); // 伯氏矢量
  params.addRequiredParam<UserObjectName>("grain_tracker",
                                          "The GrainTracker UserObject to get values from.");
  return params;
}

DeformedGrainMaterialGG::DeformedGrainMaterialGG(const InputParameters & parameters)
  : Material(parameters),
    _op_num(coupledComponents("v")),
    _vals(coupledValues("v")),
    _ebsd_reader(getUserObject<EBSDReader>("ebsd_reader")),
    _data_name(getParam<MooseEnum>("data_name")),
    _length_scale(getParam<Real>("length_scale")),
    _Disloc_Den(getParam<Real>("Disloc_Den")),
    _Elas_Mod(getParam<Real>("Elas_Mod")),
    _Burg_vec(getParam<Real>("Burg_vec")),
    _num_op_valid(declareProperty<Real>("num_op_valid")),
    _num_op_valid_old(getMaterialPropertyOld<Real>("num_op_valid")),
    _beta(declareProperty<Real>("beta")),
    _Disloc_Den_i(declareProperty<Real>("Disloc_Den_i")),
    _Disloc_Den_i_old(getMaterialPropertyOld<Real>("Disloc_Den_i")),
    _rho_eff(declareProperty<Real>("rho_eff")),
    _Def_Eng(declareProperty<Real>("Def_Eng")),
    _deformed_grain_num(getParam<unsigned int>("deformed_grain_num")),
    _grain_tracker(getUserObject<GrainTrackerInterface>("grain_tracker")),
    _JtoeV(6.24150974e18) // Joule to eV conversion
{
  if (_op_num == 0)
    paramError("op_num", "Model requires op_num > 0");
}

void
DeformedGrainMaterialGG::initQpStatefulProperties()
{
  const auto & op_to_grains = _grain_tracker.getVarToFeatureVector(_current_elem->id());

  auto _val_a = _ebsd_reader.getPointDataAccessFunctor(_data_name);
  Point p = _current_elem->vertex_average();

  _Disloc_Den_i[_qp] = (*_val_a)(_ebsd_reader.getData(p));

  _num_op_valid[_qp] = 0;
  for (MooseIndex(op_to_grains) op_index = 0; op_index < op_to_grains.size(); ++op_index)
  {
    auto grain_id = op_to_grains[op_index];
    if (grain_id == FeatureFloodCount::invalid_id)
      continue;

    _num_op_valid[_qp] = _num_op_valid[_qp] + 1;
  }

  // std::cout << "the init of DeformedGrainMaterialGG " << std::endl;
  // init the diffusivity propert
}

void
DeformedGrainMaterialGG::computeQpProperties()
{
  // std::cout << "the done of DeformedGrainMaterialGG " << std::endl;

  _Disloc_Den_i[_qp] = _Disloc_Den * (_length_scale * _length_scale);

  Real rho_i;
  Real rho0 = 0.0;
  Real SumEtai2 = 0.0;
  _num_op_valid[_qp] = 0;
  
  for (unsigned int i = 0; i < _op_num; ++i)
    SumEtai2 += (*_vals[i])[_qp] * (*_vals[i])[_qp];

  // calculate effective dislocation density and assign zero dislocation densities to undeformed grains
  const auto & op_to_grains = _grain_tracker.getVarToFeatureVector(_current_elem->id());

  // op_to_grains: std::vector<unsigned int>, op_to_grains.size() = the number of the order para number

  // loop over active OPs
  bool one_active = false;
  for (MooseIndex(op_to_grains) op_index = 0; op_index < op_to_grains.size(); ++op_index)
  {
    if (op_to_grains[op_index] == FeatureFloodCount::invalid_id)
      continue;

    _num_op_valid[_qp] = _num_op_valid[_qp] + 1;

    one_active = true; // bool
    auto grain_id = op_to_grains[op_index]; // grain id

    if (grain_id >= _deformed_grain_num)
      rho_i = 0.0; // 如果晶粒的id号 >= 赋予形变晶粒的数目则位错密度为 0
    else
      rho_i = _Disloc_Den_i[_qp];
      
    rho0 += rho_i * (*_vals[op_index])[_qp] * (*_vals[op_index])[_qp];
    // 插值方案：{\sum_{j=1}^N{\rho _{dis,i}}\eta _{i}^{2}}，分母
  }

  // if (!one_active && _t_step > 0)
  //   mooseError("No active order parameters");

  _rho_eff[_qp] = rho0 / SumEtai2;
  // 插值方案：\rho _{dis,eff}=\frac{\sum_{j=1}^N{\rho _{dis,i}}\eta _{i}^{2}}{\sum_{i=1}^N{\eta ^2}}

  if (_rho_eff[_qp] < 1e-9)
  {
    _rho_eff[_qp] = 0.0;
    _Disloc_Den_i[_qp] = 0.0;
  }

  _beta[_qp] = 0.5 * _Elas_Mod * _Burg_vec * _Burg_vec * _JtoeV * _length_scale; // 0.5*b^2*rho_{dis,eff}

  // Compute the deformation energy
  _Def_Eng[_qp] = _beta[_qp] * _rho_eff[_qp];

  if (_num_op_valid_old[_qp] > 1.0 && _num_op_valid[_qp] == 1.0 )
    _Disloc_Den_i[_qp] = 0.0;
  else
    _Disloc_Den_i[_qp] = _Disloc_Den_i_old[_qp];

}
