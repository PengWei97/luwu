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
#include "RotationTensor.h"

registerMooseObject("PhaseFieldApp", GrainTrackerElasticityPW);

InputParameters
GrainTrackerElasticityPW::validParams()
{
  InputParameters params = GrainTracker::validParams();
  // params.addParam<bool>("random_rotations",
  //                       true,
  //                       "Generate random rotations when the Euler Angle "
  //                       "provider runs out of data (otherwise error "
  //                       "out)");
  params.addRequiredParam<std::vector<Real>>("C_ijkl", "Unrotated stiffness tensor");
  params.addParam<MooseEnum>(
      "fill_method", RankFourTensor::fillMethodEnum() = "symmetric9", "The fill method");
  params.addRequiredParam<UserObjectName>("euler_angle_provider",
                                          "Name of Euler angle provider user object");
  return params;
}
// 定义InputParameters对象

GrainTrackerElasticityPW::GrainTrackerElasticityPW(const InputParameters & parameters)
  : GrainDataTracker<RankFourTensor>(parameters),
    GrainDataTracker<RankTwoTensor>(parameters),
    _random_rotations(getParam<bool>("random_rotations")),
    _C_ijkl(getParam<std::vector<Real>>("C_ijkl"),
            getParam<MooseEnum>("fill_method").getEnum<RankFourTensor::FillMethod>()),
    // _euler(getUserObject<EulerAngleProvider>("euler_angle_provider"))
{
}
// 构造函数

RankFourTensor
GrainTrackerElasticityPW::newGrain(unsigned int new_grain_id)
{
  EulerAngles angles;
  // Public Member Functions
  // return RealVectorValue(phi1, Phi, phi2)

  if (new_grain_id < _euler.getGrainNum())
    angles = _euler.getEulerAngles(new_grain_id);
    // _angle.size(); // The number of elements that can currently be stored in the array.
    // 若为bicrystal,则_euler,getGrainNum()=2,
      // angles = _euler.getEulerAngles(0);
      // 赋予三个欧拉角给angles
  else
  {
    if (_random_rotations)
      angles.random();
    else
      mooseError("GrainTrackerElasticityPW has run out of grain rotation data.");
  }

  RankFourTensor C_ijkl = _C_ijkl;
  C_ijkl.rotate(RotationTensor(RealVectorValue(angles)));

  return C_ijkl;
}

RankTwoTensor
GrainTrackerElasticityPW::newGrain(unsigned int new_grain_id)
{
  EulerAngles angles;
  // Public Member Functions
  // return RealVectorValue(phi1, Phi, phi2)

  RankTwoTensor crysrot = RotationTensor(RealVectorValue(angles));
  

  return crysrot;
}
