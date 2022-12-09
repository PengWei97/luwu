//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "GrainTracker.h"

class GrainTrackerGG : public GrainTracker
{
public:
  static InputParameters validParams();

  GrainTrackerGG(const InputParameters & parameters);
  virtual ~GrainTrackerGG();

  // virtual void meshChanged() override;
  virtual void initialize() override;
  virtual void execute() override;
  virtual void finalize() override;

  // protected:, private:
};