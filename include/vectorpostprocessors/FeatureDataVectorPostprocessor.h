//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

// FeatureVolumeVectorPostprocessor.C
#pragma once

#include "FeatureVolumeVectorPostprocessor.h"

class FeatureDataVectorPostprocessor : public FeatureVolumeVectorPostprocessor
{
public:
  static InputParameters validParams();

  FeatureDataVectorPostprocessor(const InputParameters & parameters);

  virtual void getCSVData(const std::size_t & num_features) override;

protected:
  VectorPostprocessorValue & _feature_id; // by weipeng
  VectorPostprocessorValue & _adjacent_num; // by weipeng
};