#include "luwuApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
luwuApp::validParams()
{
  InputParameters params = MooseApp::validParams();

  // Do not use legacy material output, i.e., output properties on INITIAL as well as TIMESTEP_END
  params.set<bool>("use_legacy_material_output") = false;

  return params;
}

luwuApp::luwuApp(InputParameters parameters) : MooseApp(parameters)
{
  luwuApp::registerAll(_factory, _action_factory, _syntax);
}

luwuApp::~luwuApp() {}

void
luwuApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAll(f, af, syntax);
  Registry::registerObjectsTo(f, {"luwuApp"});
  Registry::registerActionsTo(af, {"luwuApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
luwuApp::registerApps()
{
  registerApp(luwuApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
luwuApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  luwuApp::registerAll(f, af, s);
}
extern "C" void
luwuApp__registerApps()
{
  luwuApp::registerApps();
}
