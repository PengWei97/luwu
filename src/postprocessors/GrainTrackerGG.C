//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "GrainTrackerGG.h"

registerMooseObject("luwuApp", GrainTrackerGG);

InputParameters
GrainTrackerGG::validParams()
{
  InputParameters params = GrainTracker::validParams();
  
  params.addClassDescription("Grain Tracker considering re-merge grains by misorientation angle from Euler angle.");
  return params;                        
}

GrainTrackerGG::GrainTrackerGG(const InputParameters & parameters)
  : GrainTracker(parameters)
{ 
}

GrainTrackerGG::~GrainTrackerGG() {}

void 
GrainTrackerGG::initialize()
{
  GrainTracker::initialize();
}

void 
GrainTrackerGG::execute()
{
  GrainTracker::execute();
}

void 
GrainTrackerGG::finalize()
{
  GrainTracker::finalize();
}