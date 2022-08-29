//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "Material.h"
#include "EulerAngleProvider.h"
#include "GrainTracker.h"
#include "FeatureVolumeVectorPostprocessor.h"
// Forward Declarations

/**
 * Function[kappa, gamma, m, L] = parameters (sigma, mob, w_GB, sigma0)
 * Parameter determination method is elaborated in Phys. Rev. B, 78(2), 024113, 2008, by N. Moelans
 * Thanks to Prof. Moelans for the explanation of her paper.
 */
class GBAnisotropyGrainGrowth : public Material
{
public:
  static InputParameters validParams();

  GBAnisotropyGrainGrowth(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

  virtual void computeGBParamaterByMisorientaion();

  virtual Real calculateMisorientaion(const RealVectorValue & Euler1, const RealVectorValue & Euler2);

  virtual void computeGBParamater();

  const unsigned int _mesh_dimension;

  const Real _length_scale;
  const Real _time_scale;
  const Real _delta_sigma; 
  const Real _delta_mob;
  const Real _GBsigma_HAB; // 高角度晶界的晶界能
  const Real _GBmob_HAB; // 高角度晶界的晶界迁移率
  const Real _GBQ_HAB; // 高角度晶界的激活能
  const Real _rate1_HABvsLAB_mob; // a_{mu,1}
  const Real _rate2_HABvsLAB_mob; // a_{mu,2}
  const Real _rate1_HABvsLAB_sigma; // a_{sigma,1}
  const Real _rate2_HABvsLAB_sigma; // a_{sigma,2}
  const std::string _type_crystalline; // hcp or cubic

  const bool _inclination_anisotropy;
  const bool _gbEnergy_anisotropy;
  const bool _gbMobility_anisotropy;

  const VariableValue & _T; // temperature

  const Real _wGB;

  std::vector<std::vector<Real>> _sigma;
  std::vector<std::vector<Real>> _mob;
  std::vector<std::vector<Real>> _Q;
  std::vector<std::vector<Real>> _kappa_gamma;
  std::vector<std::vector<Real>> _a_g2;

  MaterialProperty<Real> & _kappa;
  MaterialProperty<Real> & _gamma;
  MaterialProperty<Real> & _L;
  MaterialProperty<Real> & _mu;
  MaterialProperty<Real> & _delta_theta; // misorientation between grains
  
  const Real _kb;
  const Real _JtoeV;
  Real _mu_qp; //

  const unsigned int _op_num;

  const std::vector<const VariableValue *> _vals;
  const std::vector<const VariableGradient *> _grad_vals;

  /// Grain tracker object
  const GrainTracker & _grain_tracker;

  // / get the grain orientation based on Euler angels
  const EulerAngleProvider & _euler; 
};

