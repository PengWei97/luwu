//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ComputeElasticityTensorCPPW.h"
#include "RotationTensor.h"

registerMooseObject("TensorMechanicsApp", ComputeElasticityTensorCPPW);

InputParameters
ComputeElasticityTensorCPPW::validParams()
{
  InputParameters params = ComputeElasticityTensor::validParams();
  params.addClassDescription("Compute an elasticity tensor for crystal plasticity.");
  params.addRequiredParam<UserObjectName>(
      "grain_tracker", "Name of GrainTracker user object that provides RankFourTensors");
  params.addParam<Real>("length_scale", 1.0e-9, "Length scale of the problem, in meters");
  params.addParam<Real>("pressure_scale", 1.0e6, "Pressure scale of the problem, in pa");
  params.addRequiredCoupledVarWithAutoBuild(
      "v", "var_name_base", "op_num", "Array of coupled variables");
      // These methods add a coupled variable name pair.
      // This version of the method will build a vector if the given 
      // the base_name and num_name parameters exist in the input file
      // var_name_base = gr op_num = 2
      // (gr0,r1)
  return params;
}

ComputeElasticityTensorCPPW::ComputeElasticityTensorCPPW(const InputParameters & parameters)
  : ComputeElasticityTensor(parameters),
    _length_scale(getParam<Real>("length_scale")),
    _pressure_scale(getParam<Real>("pressure_scale")),
    _grain_tracker(getUserObject<GrainDataTracker<RankFourTensor>>("grain_tracker")),
    _op_num(coupledComponents("v")),
    // coupledComponents:number of components this variable has (usually 1)
    _vals(coupledValues("v")),
    // Vector of VariableValue pointers for each component of var_name
    _D_elastic_tensor(_op_num),
    _JtoeV(6.24150974e18)    
    _crysrot(declareProperty<RankTwoTensor>("crysrot")),
    _R(_Euler_angles)
    // Obtain the rotation matrix by Euler angles
    // 关键如何从_grain_tracker数据中获取欧拉角
{
  // the base class guarantees constant in time, but in this derived class the
  // tensor will rotate over time once plastic deformation sets in
  revokeGuarantee(_elasticity_tensor_name, Guarantee::CONSTANT_IN_TIME);
  // 这句话是否表示弹性张量随时间没有变化

  // the base class performs a passive rotation, but the crystal plasticity
  // materials use active rotation: recover unrotated _Cijkl here
  _Cijkl.rotate(_R.transpose());
  // 返回没有旋转的弹性模量

  // Loop over variables (ops)
  for (MooseIndex(_op_num) op_index = 0; op_index < _op_num; ++op_index)
  {
    // declare elasticity tensor derivative properties
    _D_elastic_tensor[op_index] = &declarePropertyDerivative<RankFourTensor>(
        _elasticity_tensor_name, getVar("v", op_index)->name());
        // delastic_tensor/dgr0,delastic_tensor/dgr1
  }
}

void
ComputeElasticityTensorCPPW::assignEulerAngles()
{
  if (_read_prop_user_object)
  {
    _Euler_angles_mat_prop[_qp](0) = _read_prop_user_object->getData(_current_elem, 0);
    _Euler_angles_mat_prop[_qp](1) = _read_prop_user_object->getData(_current_elem, 1);
    _Euler_angles_mat_prop[_qp](2) = _read_prop_user_object->getData(_current_elem, 2);
  }
  else
    _Euler_angles_mat_prop[_qp] = _Euler_angles;
}

void
ComputeElasticityTensorCPPW::computeQpElasticityTensor()
{
  // Properties assigned at the beginning of every call to material calculation
  assignEulerAngles();

  _R.update(_Euler_angles_mat_prop[_qp]);

  _crysrot[_qp] = _R.transpose();
  _elasticity_tensor[_qp] = _Cijkl;
  _elasticity_tensor[_qp].rotate(_crysrot[_qp]);
}
