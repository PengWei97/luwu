//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "GrainTrackerRotation.h"
#include "EulerAngleProvider.h"
#include "RotationTensor.h"

registerMooseObject("PhaseFieldApp", GrainTrackerRotation);

InputParameters
GrainTrackerRotation::validParams()
{
  InputParameters params = GrainTracker::validParams();
  params.addParam<bool>("random_rotations",
                        true,
                        "Generate random rotations when the Euler Angle "
                        "provider runs out of data (otherwise error "
                        "out)");
  params.addRequiredParam<UserObjectName>("euler_angle_provider",
                                          "Name of Euler angle provider user object");

  return params;
}
// 定义InputParameters对象

GrainTrackerRotation::GrainTrackerRotation(const InputParameters & parameters)
  : GrainDataTracker<RankTwoTensor>(parameters),
    _random_rotations(getParam<bool>("random_rotations")),
    _euler_rot(getUserObject<EulerAngleProvider>("euler_angle_provider"))
{
}
// 初始化构造函数
// 成员初始值设定项列表


RankTwoTensor
GrainTrackerRotation::newGrain(unsigned int new_grain_id)
{
  EulerAngles angles;
  // Public Member Functions
  // return RealVectorValue(phi1, Phi, phi2)

  if (new_grain_id < _euler_rot.getGrainNum())
    angles = _euler_rot.getEulerAngles(new_grain_id);
  else
  {
    if (_random_rotations)
      angles.random();
    else
      mooseError("GrainTrackerElasticity has run out of grain rotation data.");
  }
  angles = _euler_rot.getEulerAngles(new_grain_id);

  RankTwoTensor crysrot = RotationTensor(RealVectorValue(angles));
  
  return crysrot;
}
