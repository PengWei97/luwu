# 1. Goals
> to build a material class considering the anisotropy of grain boundary energy and grain boundary mobility based on the misorienation between grains

# Supplement materials

## Paper
[1] N. Moelans, B. Blanpain, P. Wollants, Quantitative Phase-Field Approach for Simulating Grain Growth in Anisotropic Systems with Arbitrary Inclination and Misorientation Dependence, Phys. Rev. Lett. 101 (2008) 025502. https://doi.org/10.1103/PhysRevLett.101.025502.
[2] N. Moelans, B. Blanpain, P. Wollants, Quantitative analysis of grain boundary properties in a generalized phase field model for grain growth in anisotropic systems, Phys. Rev. B. 78 (2008) 024113. https://doi.org/10.1103/PhysRevB.78.024113.

## Code
1. GBEvolution
2. GBEvolutionBase
3. GBAnisotropy
4. GBAnisotropyBase

***** 
# 2. Problems

## 2.1. Pr-1: Ring boundary instability and kinetic mismatch when high grain boundary energy is assigned to the grain boundary position

### Details
1. [bicrystal_isotropy_sigma](./inputFile/bicrystal_isotropy_sigma.i)
   1. ex_1：采用 `GBAnisotropy` 进行双晶模拟，设置整个计算域中的晶界能为0.5，获得起动力学和形态学数据;
   2. ex_2: 采用 `GBAnisotropy` 进行双晶模拟，设置整个计算域中的晶界能为0.9，获得起动力学和形态学数据;
2. [bicrystal_anisotropy_sigma](./inputFile/bicrystal_anisotropy_sigma.i)
   1. ex_3: 采用 `GBAnisotropyGrowthGrowth`


