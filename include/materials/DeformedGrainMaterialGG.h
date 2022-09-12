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
#include "EBSDReader.h"
#include "typeinfo"
// Forward Declarations
class GrainTrackerInterface;

/**
 * Calculates The Deformation Energy associated with a specific dislocation density.
 * The rest of parameters are the same as in the grain growth model
 */
class DeformedGrainMaterialGG : public Material
{
public:
  static InputParameters validParams();

  DeformedGrainMaterialGG(const InputParameters & parameters);

protected:
  virtual void initQpStatefulProperties() override;

  virtual void computeQpProperties() override;

  /// total number of grains 
  const unsigned int _op_num; 

  /// order parameter values
  const std::vector<const VariableValue *> _vals; 

  const Real _length_scale; 

  /// the average dislocation density
  const Real _Disloc_Den; 

  /// the elastic modulus
  const Real _Elas_Mod; 

  /// the Length of Burger's Vector
  const Real _Burg_vec; 

  // const std::string _type_crystalline; // hcp or cubic

  /// number of the order paramaters in vaild
  MaterialProperty<Real> & _num_op_valid;

  /// Old value of _num_op_valid
  const MaterialProperty<Real> & _num_op_valid_old;

  /// the prefactor needed to calculate the deformation energy from dislocation density
  MaterialProperty<Real> & _beta; 

  /// dislocation density in grain i
  // Stateful Material Properties
  MaterialProperty<Real> & _Disloc_Den_i; 

  const MaterialProperty<Real> & _Disloc_Den_i_old; 

  /// the average/effective dislocation density
  MaterialProperty<Real> & _rho_eff; 

  /// the deformation energy
  MaterialProperty<Real> & _Def_Eng; 

  // Constants

  /// number of deformed grains
  const unsigned int _deformed_grain_num; 

  /// Grain tracker object
  const GrainTrackerInterface & _grain_tracker; 
  const Real _JtoeV; 

  /// get the dislocation density on ebsd_reader
  const EBSDReader & _ebsd_reader;

  MooseEnum _data_name;
};
