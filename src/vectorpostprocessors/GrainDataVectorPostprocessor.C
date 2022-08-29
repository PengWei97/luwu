#include "GrainDataVectorPostprocessor.h"

registerMooseObject("luwuApp", GrainDataVectorPostprocessor);

InputParameters
GrainDataVectorPostprocessor::validParams()
{
  InputParameters params = FeatureVolumeVectorPostprocessor::validParams();

   params.addClassDescription("This object is designed for grain feature data");

   return params;
}

GrainDataVectorPostprocessor::GrainDataVectorPostprocessor(
    const InputParameters & parameters)
  : FeatureVolumeVectorPostprocessor(parameters),
    _gb_energy(declareVector("gb_energy")),
    _gb_mobility(declareVector("gb_mobility"))
{
}


void
GrainDataVectorPostprocessor::initialize()
{
}

void
GrainDataVectorPostprocessor::execute()
{
  FeatureVolumeVectorPostprocessor::execute();
}

void
GrainDataVectorPostprocessor::finalize()
{
  FeatureVolumeVectorPostprocessor::finalize();
  // 在finalize中才能得到_feature_volumes
  const auto num_features = _feature_volumes.size(); // 当前step中最大的晶粒ID+1

  std::cout << "num_features " << num_features << std::endl;

  _gb_energy.assign(num_features, 0); // grain energy
  _gb_mobility.assign(num_features,-1); // grain mobility
  // // std::cout << "the size of num_feature is " << num_feature << std::endl;

  // 获取上一步中晶粒的体积
  const VectorPostprocessorValue & _feature_volumes_old = getVectorPostprocessorValueOldByName("grain_volumes", "feature_volumes"); // std::vector<Real>

  const VectorPostprocessorValue & _gb_energy_old = getVectorPostprocessorValueOldByName("grain_volumes", "gb_energy");

  Real low_gb_energy = 0.25;
  Real high_gb_energy = 0.54;
  const Real & critical_size = 3141592.0; //1.9635e5; //1.9635e5; // 785398.15; // 1.9635e5 for r_cr = 250 25 nm 3140000 for r_cr = 1000 100nm 463429.97058955 y < 6e3

  for (MooseIndex(num_features) feature_num = 0; feature_num < num_features; ++feature_num)
  {
    // init 初始的时候晶界能确定，直到长大到临界尺寸才突变； 没有考虑晶粒长大过程晶界能长大的情况
    auto i = feature_num;
    if (_feature_volumes[i] <= critical_size && (_feature_volumes[i] - _feature_volumes_old[i]) == 0) // init 且小于临界晶粒尺寸
      _gb_energy[i] = grainSize2GBEnergy(_feature_volumes[i]); //init
    else if (_feature_volumes[i] > critical_size && (_feature_volumes[i] - _feature_volumes_old[i]) == 0) //init 大于临界晶粒尺寸
       _gb_energy[i] = high_gb_energy;
    // else if ( _feature_volumes[i] > critical_size  && _feature_volumes_old[i] <= critical_size) //如果小晶粒开始长大超过临界尺寸 _gb_energy_old[i] < high_gb_energy && 
    //   _gb_energy[i] = high_gb_energy;
    else
      _gb_energy[i] = _gb_energy_old[i];
  }
}

Real
GrainDataVectorPostprocessor::grainSize2GBEnergy(const Real & grain_volumes)
{
  Real d_grain = 0;
  Real pi = 3.1415926;

  if (grain_volumes > 0)
    d_grain = std::pow(grain_volumes/pi,0.5)*2/10;  // Grain Diameter

  Real p1 = 1.557e-09;
  Real p2 = -8.484e-07;
  Real p3 = 0.0001459;
  Real p4 = -0.006507;
  Real p5 = 0.2969;

  Real gbEnergy = p1*std::pow(d_grain,4) + p2*std::pow(d_grain,3) + p3*std::pow(d_grain,2) + p4*d_grain + p5;
  // std::cout << "the value gbEnergy and d_grain " << gbEnergy << ", " << d_grain << std::endl;
  
  return gbEnergy;
}
