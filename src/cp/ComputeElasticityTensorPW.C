//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ComputeElasticityTensorPW.h"
#include "RotationTensor.h"

registerMooseObject("TensorMechanicsApp", ComputeElasticityTensorPW);
registerMooseObject("TensorMechanicsApp", ADComputeElasticityTensorPW);

template <bool is_ad>
InputParameters
ComputeElasticityTensorPWTempl<is_ad>::validParams()
{
  InputParameters params = ComputeRotatedElasticityTensorBaseTempl<is_ad>::validParams();
  params.addClassDescription("Compute an elasticity tensor.");
  // params.addRequiredParam<std::vector<Real>>("C_ijkl", "Stiffness tensor for material");
  params.addParam<MooseEnum>(
      "fill_method", RankFourTensor::fillMethodEnum() = "symmetric9", "The fill method");
  return params;
}

template <bool is_ad>
ComputeElasticityTensorPWTempl<is_ad>::ComputeElasticityTensorPWTempl(
    const InputParameters & parameters)
  : ComputeRotatedElasticityTensorBaseTempl<is_ad>(parameters)
    // _Cijkl(this->template getParam<std::vector<Real>>("C_ijkl"),
    //        (RankFourTensor::FillMethod)(int)this->template getParam<MooseEnum>("fill_method"))
{
  if (!isParamValid("elasticity_tensor_prefactor"))
    issueGuarantee(_elasticity_tensor_name, Guarantee::CONSTANT_IN_TIME);

  // if (_Cijkl.isIsotropic())
  //   issueGuarantee(_elasticity_tensor_name, Guarantee::ISOTROPIC);
  // else
  // {
  //   // Use user-provided rotation matrix if given
  //   if (parameters.isParamValid("rotation_matrix"))
  //     _Cijkl.rotate(_rotation_matrix);
  //   else
  //   {
  //     // Define a rotation according to Euler angle parameters
  //     RotationTensor R(_Euler_angles); // R type: RealTensorValue

  //     // rotate elasticity tensor
  //     _Cijkl.rotate(R);
  //   }
  // }
}

template <bool is_ad>
void
ComputeElasticityTensorPWTempl<is_ad>::computeQpElasticityTensor()
{
  // Assign elasticity tensor at a given quad point
  // _elasticity_tensor[_qp] = _Cijkl;
}

template class ComputeElasticityTensorPWTempl<false>;
template class ComputeElasticityTensorPWTempl<true>;
