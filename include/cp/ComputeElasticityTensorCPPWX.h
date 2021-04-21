//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "ComputeElasticityTensorPW.h"
#include "RankTwoTensor.h"
#include "RotationTensor.h"
#include "GrainDataTracker.h"


/**
 * ComputeElasticityTensorCPPWX defines an elasticity tensor material object for crystal plasticity.
 */
class ComputeElasticityTensorCPPWX : public ComputeElasticityTensorPW
{
public:
  static InputParameters validParams();

  ComputeElasticityTensorCPPWX(const InputParameters & parameters);

protected:
  virtual void computeQpElasticityTensor() override;

  // virtual void assignEulerAngles();

  Real _length_scale;
  Real _pressure_scale;

  /**
   * Element property read user object
   * Presently used to read Euler angles -  see test
   */
  /// Grain tracker object
  const GrainDataTracker<RankFourTensor> & _grain_tracker;
  // 定义四阶张量

  const GrainDataTracker<RankTwoTensor> & _grain_tracker_euler;

  /// Number of order parameters
  const unsigned int _op_num;

  /// Order parameters
  const std::vector<const VariableValue *> _vals;
  // gr0,gr1

  /// vector of elasticity tensor material properties
  std::vector<MaterialProperty<RankFourTensor> *> _D_elastic_tensor;
  // _D_elastic_tensor = dElasticity_Tensor/dgr0_ijkl,dElasticity_Tensor/dgr2_ijkl

  /// Conversion factor from J to eV
  const Real _JtoeV;

  // RankFourTensor _Cijkl; // Input from Input.i
  // const ElementPropertyReadFile * const _read_prop_user_object;

  // MaterialProperty<RealVectorValue> & _Euler_angles_mat_prop;

  /// Crystal Rotation Matrix
  MaterialProperty<RankTwoTensor> & _crysrot;

  /// Rotation matrix
  // RotationTensor _R;
};
