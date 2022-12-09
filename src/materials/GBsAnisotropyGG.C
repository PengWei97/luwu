//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "GBsAnisotropyGG.h"
#include "RotationTensor.h"
#include "MooseMesh.h"
#include <cmath>

registerMooseObject("luwuApp", GBsAnisotropyGG);

InputParameters
GBsAnisotropyGG::validParams()
{
  InputParameters params = Material::validParams();
  params.addCoupledVar("T", 700.0, "Temperature in Kelvin");
  params.addRequiredParam<UserObjectName>(
      "grain_tracker", "Name of GrainTracker user object that provides Grain ID according to element ID");
  params.addRequiredParam<UserObjectName>("euler_angle_provider",
                                          "Name of Euler angle provider user object");
  params.addRequiredParam<std::vector<Real>>("misorientation_angle",
                                            "the vector of the misorientation between grains for a piecewise function's independent varivable");
  params.addRequiredParam<std::vector<Real>>("gb_energy",
                                            "the vector of grain energy for a piecewise function's dependent varivable"); 
  params.addRequiredParam<Real>("wGB", "Diffuse GB width in nm");
  params.addParam<Real>("matrix_sigma", 0.1, "initial value of gb energy, J/m^2"); 
  params.addParam<Real>("matrix_mob", 2.5e-12, "initial value of gb mob");
  params.addParam<Real>("length_scale", 1.0e-9, "Length scale in m, where default is nm");
  params.addParam<Real>("time_scale", 1.0e-9, "Time scale in s, where default is ns");
  params.addParam<Real>(
      "delta_sigma", 0.1, "factor determining inclination dependence of GB energy");
  params.addParam<Real>(
      "delta_mob", 0.1, "factor determining inclination dependence of GB mobility");
  params.addRequiredParam<bool>("inclination_anisotropy",
                                "The GB anisotropy inclination would be considered if true");
  params.addRequiredParam<bool>("gbEnergy_anisotropy",
                                "The GB energy anisotropy would be considered if true");                   
  params.addRequiredCoupledVarWithAutoBuild(
      "v", "var_name_base", "op_num", "Array of coupled variables");
  return params;
}

GBsAnisotropyGG::GBsAnisotropyGG(const InputParameters & parameters)
  : Material(parameters),
    _grain_tracker(getUserObject<GrainTracker>("grain_tracker")),
    _euler(getUserObject<EulerAngleProvider>("euler_angle_provider")),
    _piecewise_func_sigma(getParam<std::vector<Real>>("misorientation_angle"),
                          getParam<std::vector<Real>>("gb_energy")),
    _mesh_dimension(_mesh.dimension()),
    _is_primary(processor_id() == 0),
    _length_scale(getParam<Real>("length_scale")),
    _time_scale(getParam<Real>("time_scale")),
    _matrix_sigma(getParam<Real>("matrix_sigma")), // matrix gb energy 
    _matrix_mob(getParam<Real>("matrix_mob")), // matrix gb mobility  
    _delta_sigma(getParam<Real>("delta_sigma")),
    _delta_mob(getParam<Real>("delta_mob")),
    _inclination_anisotropy(getParam<bool>("inclination_anisotropy")),
    _gbEnergy_anisotropy(getParam<bool>("gbEnergy_anisotropy")),
    _T(coupledValue("T")),
    _kappa(declareProperty<Real>("kappa_op")),
    _gamma(declareProperty<Real>("gamma_asymm")),
    _L(declareProperty<Real>("L")),
    _mu(declareProperty<Real>("mu")),
    _misori(declareProperty<Real>("misori")),
    _kb(8.617343e-5),      // Boltzmann constant in eV/K
    _JtoeV(6.24150974e18), // Joule to eV conversion
    _mu_qp(0.0),
    _op_num(coupledComponents("v")),
    _vals(coupledValues("v")),
    _grad_vals(coupledGradients("v")),
    _wGB(getParam<Real>("wGB"))
{
  // reshape vectors
  _sigma.resize(_op_num);
  _mob.resize(_op_num);
  _Q.resize(_op_num);
  _kappa_gamma.resize(_op_num);
  _a_g2.resize(_op_num);

  for (unsigned int op = 0; op < _op_num; ++op)
  {
    _sigma[op].resize(_op_num);
    _mob[op].resize(_op_num);
    _Q[op].resize(_op_num);
    _kappa_gamma[op].resize(_op_num);
    _a_g2[op].resize(_op_num);
  }
}

void
GBsAnisotropyGG::computeQpProperties()
{
  computerGBParameter(); // calculate GB energy matrix and GB mobility matrix based on misorientation

  computerPhaseFieldParameter(); // f(L, kappa, gamma, mu) = f(sigma_ij, mob_ij)

  Real sum_kappa = 0.0;
  Real sum_gamma = 0.0;
  Real sum_L = 0.0;
  Real Val = 0.0;
  Real sum_val = 0.0;
  Real f_sigma = 1.0;
  Real f_mob = 1.0;
  Real gamma_value = 0.0;

  for (unsigned int m = 0; m < _op_num - 1; ++m)
  {
    for (unsigned int n = m + 1; n < _op_num; ++n) // m<n
    {
      gamma_value = _kappa_gamma[n][m];

      if (_inclination_anisotropy)
      {
        if (_mesh_dimension == 3)
          mooseError("This material doesn't support inclination dependence for 3D for now!");

        Real phi_ave = libMesh::pi * n / (2.0 * _op_num);
        Real sin_phi = std::sin(2.0 * phi_ave);
        Real cos_phi = std::cos(2.0 * phi_ave);

        Real a = (*_grad_vals[m])[_qp](0) - (*_grad_vals[n])[_qp](0);
        Real b = (*_grad_vals[m])[_qp](1) - (*_grad_vals[n])[_qp](1);
        Real ab = a * a + b * b + 1.0e-7; // for the sake of numerical convergence, the smaller the
                                          // more accurate, but more difficult to converge

        Real cos_2phi = cos_phi * (a * a - b * b) / ab + sin_phi * 2.0 * a * b / ab;
        Real cos_4phi = 2.0 * cos_2phi * cos_2phi - 1.0;

        f_sigma = 1.0 + _delta_sigma * cos_4phi;
        f_mob = 1.0 + _delta_mob * cos_4phi;

        Real g2 = _a_g2[n][m] * f_sigma;
        Real y = -5.288 * g2 * g2 * g2 * g2 - 0.09364 * g2 * g2 * g2 + 9.965 * g2 * g2 -
                 8.183 * g2 + 2.007;
        gamma_value = 1.0 / y;
      }

      Val = (100000.0 * ((*_vals[m])[_qp]) * ((*_vals[m])[_qp]) + 0.01) *
            (100000.0 * ((*_vals[n])[_qp]) * ((*_vals[n])[_qp]) + 0.01);

      sum_val += Val;
      sum_kappa += _kappa_gamma[m][n] * f_sigma * Val;
      sum_gamma += gamma_value * Val;
      // Following comes from substituting Eq. (36c) from the paper into (36b)
      sum_L += Val * _mob[m][n] * std::exp(-_Q[m][n] / (_kb * _T[_qp])) * f_mob * _mu_qp *
               _a_g2[n][m] / _sigma[m][n];
    }
  }

  _kappa[_qp] = sum_kappa / sum_val;
  _gamma[_qp] = sum_gamma / sum_val;
  _L[_qp] = sum_L / sum_val;
  _mu[_qp] = _mu_qp;
}

void
GBsAnisotropyGG::computerGBParameter()
{
  Real _sigma_base = _matrix_sigma;
  Real _mob_base = _matrix_mob;
  Real _Q_base = 0.23;

  for (unsigned int i = 0; i < _op_num; ++i)
  {
    std::vector<Real> row_sigma;
    std::vector<Real> row_mob;
    std::vector<Real> row_Q;

    for (unsigned int j = 0; j < _op_num; ++j)
    {
        row_sigma.push_back(_sigma_base);
        row_mob.push_back(_mob_base);
        row_Q.push_back(_Q_base);
    }

    _sigma[i] = row_sigma; // unit: J/m^2 GB energy
    _mob[i] = row_mob; // unit: m^4/(J*s) GB mobility
    _Q[i] = row_Q; // unit: eV
  }

  // get the grain boundary location based on the grainTracker in the quadrature point
  const auto & op_to_grains = _grain_tracker.getVarToFeatureVector(_current_elem->id());
  std::vector<unsigned int> orderParameterIndex; // Create a vector of order parameter indices
  std::vector<unsigned int> grainIDIndex; // Create a vector of grain IDs
  for (MooseIndex(op_to_grains) op_index = 0; op_index < op_to_grains.size(); ++op_index)
  {
    auto grain_id = op_to_grains[op_index]; // grain id

    if (grain_id == FeatureFloodCount::invalid_id)
      continue;

    orderParameterIndex.push_back(op_index);
    grainIDIndex.push_back(grain_id);
  }
  _misori[_qp] = -1;

  if (grainIDIndex.size() == 2)
  {
    auto angles_i = _euler.getEulerAngles(grainIDIndex[0]);
    auto angles_j = _euler.getEulerAngles(grainIDIndex[1]); // EulerAngles
    _misori[_qp] = calculateMisorientaion(angles_i, angles_j);
  }

  Real delta_euler = 0.0;
  if (_gbEnergy_anisotropy && grainIDIndex.size() > 1) // at gb boundary or junction
  {
    for (unsigned int i = 0; i < grainIDIndex.size() - 1; ++i)
    {
      for (unsigned int j = i+1; j < grainIDIndex.size(); ++j)
        {
          auto angles_i = _euler.getEulerAngles(grainIDIndex[i]);
          auto angles_j = _euler.getEulerAngles(grainIDIndex[j]); // EulerAngles
          delta_euler = calculateMisorientaion(angles_i, angles_j);

          _sigma[orderParameterIndex[i]][orderParameterIndex[j]] = _piecewise_func_sigma.sample(delta_euler);
          _sigma[orderParameterIndex[j]][orderParameterIndex[i]] = _piecewise_func_sigma.sample(delta_euler);
        }
    }
  }
}

void
GBsAnisotropyGG::computerPhaseFieldParameter()
{
  Real sigma_init;
  Real g2 = 0.0;
  Real f_interf = 0.0;
  Real a_0 = 0.75;
  Real a_star = 0.0;
  Real kappa_star = 0.0;
  Real gamma_star = 0.0;
  Real y = 0.0; // 1/gamma
  Real yyy = 0.0;

  Real sigma_big = 0.0;
  Real sigma_small = 0.0;

  for (unsigned int m = 0; m < _op_num - 1; ++m)
    for (unsigned int n = m + 1; n < _op_num; ++n)
    {
      // Convert units of mobility and energy
      _sigma[m][n] *= _JtoeV * (_length_scale * _length_scale); // eV/nm^2

      _mob[m][n] *= _time_scale / (_JtoeV * (_length_scale * _length_scale * _length_scale *
                                             _length_scale)); // Convert to nm^4/(eV*ns);

      if (m == 0 && n == 1)
      {
        sigma_big = _sigma[m][n];
        sigma_small = sigma_big;
      }

      else if (_sigma[m][n] > sigma_big)
        sigma_big = _sigma[m][n];

      else if (_sigma[m][n] < sigma_small)
        sigma_small = _sigma[m][n];
    }

  sigma_init = (sigma_big + sigma_small) / 2.0;
  _mu_qp = 6.0 * sigma_init / _wGB;

  for (unsigned int m = 0; m < _op_num - 1; ++m)
    for (unsigned int n = m + 1; n < _op_num; ++n) // m<n
    {

      a_star = a_0;
      a_0 = 0.0;

      while (std::abs(a_0 - a_star) > 1.0e-9)
      {
        a_0 = a_star;
        kappa_star = a_0 * _wGB * _sigma[m][n];
        g2 = _sigma[m][n] * _sigma[m][n] / (kappa_star * _mu_qp);
        y = -5.288 * g2 * g2 * g2 * g2 - 0.09364 * g2 * g2 * g2 + 9.965 * g2 * g2 - 8.183 * g2 +
            2.007;
        gamma_star = 1 / y;
        yyy = y * y * y;
        f_interf = 0.05676 * yyy * yyy - 0.2924 * yyy * y * y + 0.6367 * yyy * y - 0.7749 * yyy +
                   0.6107 * y * y - 0.4324 * y + 0.2792;
        a_star = std::sqrt(f_interf / g2);
      }

      _kappa_gamma[m][n] = kappa_star; // upper triangle stores the discrete set of kappa values
      _kappa_gamma[n][m] = gamma_star; // lower triangle stores the discrete set of gamma values

      _a_g2[m][n] = a_star; // upper triangle stores "a" data.
      _a_g2[n][m] = g2;     // lower triangle stores "g2" data.
    }    
}

Real
GBsAnisotropyGG::calculateMisorientaion(const EulerAngles & Euler1, const EulerAngles & Euler2)
{
  auto R1 = RotationTensor(Euler1);
  auto R2 = RotationTensor(Euler2);
  std::vector<std::vector<Real>> eulerAngle_symm = {
    {0.0,   0.0,   0.0},
    {120.0, 0.0,   0.0},
    {240.0, 0.0,   0.0},
    {60.0,  0.0,   0.0},
    {180.0, 0.0,   0.0},
    {300.0, 0.0,   0.0},
    {240.0, 180.0, 0.0},
    {0.0,   180.0, 0.0},
    {120.0, 180.0, 0.0},
    {60.0,  180.0, 0.0},
    {180.0, 180.0, 0.0},
    {300.0, 180.0, 0.0}
  }; // symmetry matrix for HCP system 

  auto symm_size = eulerAngle_symm.size();
  std::vector<Real> theta(symm_size, 0);
  RankTwoTensor M_misori;
  EulerAngles s_ang; // Real phi1, Phi, phi2

  for (unsigned int i = 0; i < symm_size; ++i)
  {
    s_ang.phi1 = eulerAngle_symm[i][0];
    s_ang.Phi = eulerAngle_symm[i][1];
    s_ang.phi2 = eulerAngle_symm[i][2];
    
    M_misori = (RotationTensor(s_ang)*R1).inverse()*R2;

    Real t1 = M_misori(0,0);
    Real t2 = M_misori(1,1);
    Real t3 = M_misori(2,2);

    theta[i] = std::acos(0.5*(t1+t2+t3-1.0)); // ??
    M_misori.zero();
  }

  // return the minmum of theta, or misorientation for 
  return *std::min_element(theta.begin(), theta.end())*180/3.14;
}