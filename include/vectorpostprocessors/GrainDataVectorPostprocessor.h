#pragma once

# include "FeatureVolumeVectorPostprocessor.h"

class FeatureFloodCount;

class GrainDataVectorPostprocessor : public FeatureVolumeVectorPostprocessor
{
public:
  static InputParameters validParams();

  GrainDataVectorPostprocessor(const InputParameters & parameters);
  
  virtual void initialize() override;
  virtual void execute() override;
  virtual void finalize() override;

  Real grainSize2GBEnergy(const Real & feature_volumes);
protected:

  VectorPostprocessorValue & _gb_energy;

  VectorPostprocessorValue & _gb_mobility;
};