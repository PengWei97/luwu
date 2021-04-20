//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ComputeElasticityTensorCPPWX.h"
#include "RotationTensor.h"

registerMooseObject("TensorMechanicsApp", ComputeElasticityTensorCPPWX);

InputParameters
ComputeElasticityTensorCPPWX::validParams()
{
  InputParameters params = ComputeElasticityTensor::validParams();
  params.addClassDescription("Compute an elasticity tensor for crystal plasticity.");
  params.addRequiredParam<UserObjectName>(
      "grain_tracker", "Name of GrainTracker user object that provides RankFourTensors");
  params.addRequiredParam<UserObjectName>(
      "grain_tracker_euler", "Name of GrainTracker user object that provides RankFourTensors");
  params.addParam<Real>("length_scale", 1.0e-9, "Length scale of the problem, in meters");
  params.addParam<Real>("pressure_scale", 1.0e6, "Pressure scale of the problem, in pa");
  params.addRequiredCoupledVarWithAutoBuild(
      "v", "var_name_base", "op_num", "Array of coupled variables");
  return params;
}

ComputeElasticityTensorCPPWX::ComputeElasticityTensorCPPWX(const InputParameters & parameters)
  : ComputeElasticityTensor(parameters),
    _length_scale(getParam<Real>("length_scale")),
    _pressure_scale(getParam<Real>("pressure_scale")),
    _grain_tracker(getUserObject<GrainDataTracker<RankFourTensor>>("grain_tracker")),
    _grain_tracker_euler(getUserObject<GrainDataTracker<RankTwoTensor>>("grain_tracker_euler")),
    _op_num(coupledComponents("v")),
    // coupledComponents:number of components this variable has (usually 1)
    _vals(coupledValues("v")),
    // Vector of VariableValue pointers for each component of var_name
    _D_elastic_tensor(_op_num),
    _crysrot(declareProperty<RankTwoTensor>("crysrot")),
    _JtoeV(6.24150974e18),
    _crysrot(declareProperty<RankTwoTensor>("crysrot")),
    // _R(_Euler_angles)
    // Obtain the rotation matrix by Euler angles
{
  // the base class guarantees constant in time, but in this derived class the
  // tensor will rotate over time once plastic deformation sets in
  revokeGuarantee(_elasticity_tensor_name, Guarantee::CONSTANT_IN_TIME);
  // 这句话是否表示弹性张量随时间没有变化

  // // the base class performs a passive rotation, but the crystal plasticity
  // // materials use active rotation: recover unrotated _Cijkl here
  // _Cijkl.rotate(_R.transpose());
  // // 返回没有旋转的弹性模量

    // Loop over variables (ops)
  for (MooseIndex(_op_num) op_index = 0; op_index < _op_num; ++op_index)
  {
    // declare elasticity tensor derivative properties
    _D_elastic_tensor[op_index] = &declarePropertyDerivative<RankFourTensor>(
        _elasticity_tensor_name, getVar("v", op_index)->name());
        // delastic_tensor/dgr0,delastic_tensor/dgr1
  }
}

// void
// ComputeElasticityTensorCPPWX::assignEulerAngles()
// {
//   if (_read_prop_user_object)
//   {
//     _Euler_angles_mat_prop[_qp](0) = _read_prop_user_object->getData(_current_elem, 0);
//     _Euler_angles_mat_prop[_qp](1) = _read_prop_user_object->getData(_current_elem, 1);
//     _Euler_angles_mat_prop[_qp](2) = _read_prop_user_object->getData(_current_elem, 2);
//   }
//   else
//     _Euler_angles_mat_prop[_qp] = _Euler_angles;
// }

// void
ComputeElasticityTensorCPPWX::computeQpElasticityTensor()
{

     // Get list of active order parameters from grain tracker
  const auto & op_to_grains = _grain_tracker.getVarToFeatureVector(_current_elem->id());
  // Returns a list of active unique feature ids for a particular element.
  // op_to_grains = 2

  // Calculate elasticity tensor
  _elasticity_tensor[_qp].zero();
  _crysrot[_qp].zero();
  Real sum_h = 0.0;
  for (MooseIndex(op_to_grains) op_index = 0; op_index < op_to_grains.size(); ++op_index)
  {
    auto grain_id = op_to_grains[op_index];
    if (grain_id == FeatureFloodCount::invalid_id)
      continue;

    // Interpolation factor for elasticity tensors
    Real h = (1.0 + std::sin(libMesh::pi * ((*_vals[op_index])[_qp] - 0.5))) / 2.0;
    // if _val = 1, h = 1
    // if _val = 0.5, h = 0.5
    // if _val = 0, h = 0

    // Sum all rotated elasticity tensors
    _elasticity_tensor[_qp] += _grain_tracker.getData(grain_id) * h;
    _crysrot[_qp] += _grain_tracker_euler.getData(grain_id) * h;
    // Used to transition the elastic tensor at the grain boundary
    sum_h += h;
  } 
  const Real tol = 1.0e-10;
  sum_h = std::max(sum_h, tol);
  _elasticity_tensor[_qp] /= sum_h;
  _crysrot[_qp] /= sum_h;

// Calculate elasticity tensor derivative: Cderiv = dhdopi/sum_h * (Cop - _Cijkl)
  for (MooseIndex(_op_num) op_index = 0; op_index < _op_num; ++op_index)
    (*_D_elastic_tensor[op_index])[_qp].zero();

  for (MooseIndex(op_to_grains) op_index = 0; op_index < op_to_grains.size(); ++op_index)
  {
    auto grain_id = op_to_grains[op_index];
    if (grain_id == FeatureFloodCount::invalid_id)
      continue;

    Real dhdopi = libMesh::pi * std::cos(libMesh::pi * ((*_vals[op_index])[_qp] - 0.5)) / 2.0;
    RankFourTensor & C_deriv = (*_D_elastic_tensor[op_index])[_qp];

    C_deriv = (_grain_tracker.getData(grain_id) - _elasticity_tensor[_qp]) * dhdopi / sum_h;

    // Convert from XPa to eV/(xm)^3, where X is pressure scale and x is length scale;
    C_deriv *= _JtoeV * (_length_scale * _length_scale * _length_scale) * _pressure_scale;
  }
}
