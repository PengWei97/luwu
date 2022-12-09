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
#include "LinearInterpolation.h"
#include "CalculateMisorientationAngle.h"

// typedef Eigen::Quaternion<Real> quatReal;
// struct misoriAngle_isTwining{ Real misor; bool isTwinning; std::string twinType;};
// Forward Declarations

/**
 * Function[kappa, gamma, m, L] = parameters (sigma, mob, w_GB, sigma0)
 * Parameter determination method is elaborated in Phys. Rev. B, 78(2), 024113, 2008, by N. Moelans
 */
class GBsAnisotropyGGQuater : public Material
{
public:
  static InputParameters validParams();

  GBsAnisotropyGGQuater(const InputParameters & parameters);

protected:
  virtual void computeQpProperties();

  virtual void computerGBParameter();

  virtual void computerPhaseFieldParameter();

  // used to store orientation structure, including misorientation angle, istwinnig, twinning type;
  misoriAngle_isTwining _s_misoriTwin; 

  // // function 1: input Euler1 and Euler2, output s
  // misoriAngle_isTwining calculateMisorientaion(const EulerAngles & Euler1, const EulerAngles & Euler2, misoriAngle_isTwining & s);  

  // // function 2: Obtaining the key orientation using quaternion, including twinning, CS, SS
  // std::vector<quatReal> getKeyQuat(std::string QuatType);

  // // function 3.1: computer the scalar dot product using quaternion
  // Real dotQuaternion(const quatReal & o1, const quatReal & o2, 
  //                    const std::vector<quatReal> & qcs, 
  //                    const std::vector<quatReal> & qss);

  // // function 3.2: computes inv(o1) .* o2 usig quaternion
  // quatReal itimesQuaternion(const quatReal & q1, const quatReal & q2);

  // // function 3.3: computes outer inner product between two quaternions
  // Real dotOuterQuaternion(const quatReal & rot1, const std::vector<quatReal> & rot2);

  // // function 3.4: X*Y is the matrix product of X and Y. ~twice~
  // Real mtimes2Quaternion(const quatReal & q1, const std::vector<quatReal> & q2, const quatReal & qTwin) ;                     

  const unsigned int _mesh_dimension;

  const Real _length_scale;
  const Real _time_scale;
  const Real _delta_sigma;
  const Real _delta_mob;
  const Real _matrix_sigma;
  const Real _TT1_sigma;
  const Real _CT1_sigma;
  const Real _matrix_mob;

  const bool _inclination_anisotropy;
  const bool _gbEnergy_anisotropy;
  const bool _tbEnergy_anisotropy;

  const VariableValue & _T;

  std::vector<std::vector<Real>> _sigma;
  std::vector<std::vector<Real>> _mob;
  std::vector<std::vector<Real>> _Q;
  std::vector<std::vector<Real>> _kappa_gamma;
  std::vector<std::vector<Real>> _a_g2;

  MaterialProperty<Real> & _kappa;
  MaterialProperty<Real> & _gamma;
  MaterialProperty<Real> & _L;
  MaterialProperty<Real> & _mu;
  MaterialProperty<Real> & _misori;
  MaterialProperty<Real> & _vaild_OPNum;
  MaterialProperty<Real> & _twin_type;

  const Real _kb;
  const Real _JtoeV;
  const Real _degree;
  Real _mu_qp;

  const unsigned int _op_num;

  const std::vector<const VariableValue *> _vals;
  const std::vector<const VariableGradient *> _grad_vals;

  const Real _wGB;

  const GrainTracker & _grain_tracker;

  const EulerAngleProvider & _euler; 

  bool _is_primary;

  LinearInterpolation _piecewise_func_sigma;
};