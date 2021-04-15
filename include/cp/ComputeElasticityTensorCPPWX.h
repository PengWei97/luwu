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
#include "GrainDataTracker.h"
#include "RankTwoTensor.h"
#include "RotationTensor.h"

// Forward Declarations
class EulerAngleProvider;

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

  Real _length_scale;
  Real _pressure_scale;

  /// Grain tracker object
  const GrainDataTracker<RankFourTensor> & _grain_tracker;
  // 定义四阶张量

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
  /// Crystal Rotation Matrix
  MaterialProperty<RankTwoTensor> & _crysrot;

  /// Rotation matrix
  RotationTensor _R;
};
