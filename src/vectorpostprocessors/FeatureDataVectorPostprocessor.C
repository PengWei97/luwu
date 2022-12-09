//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FeatureDataVectorPostprocessor.h"
#include "FeatureFloodCount.h"

registerMooseObject("luwuApp", FeatureDataVectorPostprocessor);

InputParameters
FeatureDataVectorPostprocessor::validParams()
{
  InputParameters params = FeatureVolumeVectorPostprocessor::validParams();
  params.addClassDescription("This object is designed to pull information from the data structures "
                             "of a \"FeatureFloodCount\" or derived object (e.g. individual "
                             "feature volumes)");
  return params;
}

FeatureDataVectorPostprocessor::FeatureDataVectorPostprocessor(
    const InputParameters & parameters)
  : FeatureVolumeVectorPostprocessor(parameters),
    _feature_id(declareVector("feature_id")),
    _adjacent_num(declareVector("adjacent_num"))
{
}

void
FeatureDataVectorPostprocessor::getCSVData(const std::size_t & num_features)
{
  // Reset the variable index and intersect bounds vectors
  _var_num.assign(num_features, -1);
  _feature_id.assign(num_features, -1);
  _adjacent_num.assign(num_features, 0);

  for (MooseIndex(num_features) feature_num = 0; feature_num < num_features; ++feature_num)
  {
    auto var_num = _feature_counter.getFeatureVar(feature_num);

    if (var_num == FeatureFloodCount::invalid_id)
      continue;

    _var_num[feature_num] = var_num;
    _feature_id[feature_num] = _feature_counter.getFeatureID(feature_num);
    _adjacent_num[feature_num] = _feature_counter.getFeatureVar(feature_num);
  }
}