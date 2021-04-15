//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
// crystal.i

#pragma once

#include "ComputeElasticityTensor.h"
#include "ElementPropertyReadFile.h"
#include "RankTwoTensor.h"
#include "RotationTensor.h"

/**
 * ComputeElasticityTensorCPPW defines an elasticity tensor material object for crystal plasticity.
 */
class ComputeElasticityTensorCPPW : public ComputeElasticityTensor
{
public:
  static InputParameters validParams();

  ComputeElasticityTensorCPPW(const InputParameters & parameters);

protected:
  virtual void computeQpElasticityTensor() override;
  // 主要是用于覆盖掉基类中

  virtual void assignEulerAngles();

  /**
   * Element property read user object
   * Presently used to read Euler angles -  see test
   */
  const ElementPropertyReadFile * const _read_prop_user_object;

  MaterialProperty<RealVectorValue> & _Euler_angles_mat_prop;

  /// Crystal Rotation Matrix
  MaterialProperty<RankTwoTensor> & _crysrot;

  /// Rotation matrix
  RotationTensor _R;
};
