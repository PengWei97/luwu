//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "GrainTrackerElasticityPW.h"
#include "EulerAngleProvider.h"

registerMooseObject("PhaseFieldApp", GrainTrackerElasticityPW);

InputParameters
GrainTrackerElasticityPW::validParams()
{
  InputParameters params = GrainTracker::validParams();
  params.addRequiredParam<UserObjectName>("euler_angle_provider",
                                          "Name of Euler angle provider user object");
  return params;
}
// 定义InputParameters对象

GrainTrackerElasticityPW::GrainTrackerElasticityPW(const InputParameters & parameters)
  : GrainDataTracker<RankTwoTensor>(parameters),
    _euler(getUserObject<EulerAngleProvider>("euler_angle_provider"))
{
}
// 初始化构造函数
// 成员初始值设定项列表


RankTwoTensor
GrainTrackerElasticityPW::newGrain(unsigned int new_grain_id)
{
  EulerAngles angles;
  // Public Member Functions
  // return RealVectorValue(phi1, Phi, phi2)

  angles = _euler.getEulerAngles(new_grain_id);

  RankTwoTensor crysrot = RotationTensor(RealVectorValue(angles));
  
  return crysrot;
}
