//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "luwuTestApp.h"
#include "luwuApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

InputParameters
luwuTestApp::validParams()
{
  InputParameters params = luwuApp::validParams();
  return params;
}

luwuTestApp::luwuTestApp(InputParameters parameters) : MooseApp(parameters)
{
  luwuTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

luwuTestApp::~luwuTestApp() {}

void
luwuTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  luwuApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"luwuTestApp"});
    Registry::registerActionsTo(af, {"luwuTestApp"});
  }
}

void
luwuTestApp::registerApps()
{
  registerApp(luwuApp);
  registerApp(luwuTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
luwuTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  luwuTestApp::registerAll(f, af, s);
}
extern "C" void
luwuTestApp__registerApps()
{
  luwuTestApp::registerApps();
}
