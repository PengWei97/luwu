# Goal
1. 基于 `GBAnisotropy`
2. 管理与取向差相关的材料参数
   1. including: GB energy - $\sigma_{GB}$, GB mobility - $m_{GB}$
   2. Function[kappa, gamma, m, L] = parameters (sigma, mob, w_GB, sigma0)


# theory
/home/pengwei/projects/luwu/src/materials/GBAnisotropyGrainGrowth.C
/home/pengwei/projects/luwu/include/materials/GBAnisotropyGrainGrowth.h
## 取向差相关的晶界能与晶界迁移率
1. 晶界能

$$
\sigma _{ij}(\Delta \Phi _{ij})=\sigma _{HAB}\left\{ a_{\sigma ,1}\frac{\Delta \Phi _{ij}}{\Delta \Phi _{HAB}}\left[ 1-\ln \left( \frac{\Delta \Phi _{ij}}{\Delta \Phi _{HAB}} \right) \right] +a_{\sigma ,2} \right\} 
$$

----
2. 晶界迁移率

$$
\mu _{ij}(\Delta \Phi _{ij})=\mu _{HAB}\left\{ a_{\mu ,1}\left( 1-\exp \left[ -B\left( \frac{\Delta \Phi _{ij}}{\Delta \Phi _{HAB}} \right) ^n \right] \right) +a_{\mu ,2} \right\} 
$$

## how to get two sets of Euler angles for two adjacent grains
1. 通过 `Grain tracker object` 获取一系列的序参数，对于每一个element id
2. 创建GrainID并通过 `op_to_grains` 储存每个序参数对应的 `Grain ID`
   1. std::vector<unsigned int> _empty_var_to_features;
      1. initial: _empty_var_to_features.resize(_n_vars, invalid_id);
   2. const auto pos = _entity_var_to_features.find(elem_id);
      1. std::map<dof_id_type, std::vector<unsigned int>> _entity_var_to_features;
         1. element id -- feature id
   3. 

# code
```c++
    _grain_tracker(getUserObject<GrainTracker>("grain_tracker")),
    _euler(getUserObject<EulerAngleProvider>("euler_angle_provider")),

   // /home/pengwei/projects/moose/modules/phase_field/src/postprocessors/FeatureFloodCount.C
      std::vector<unsigned int> _empty_var_to_features;
      // Loop over the entity ids of this feature and update our local map
      for (auto entity : feature._local_ids)
      {
         _feature_maps[map_index][entity] = static_cast<int>(feature._id);

         if (_var_index_mode)
         _var_index_maps[map_index][entity] = feature._var_index;

         // Fill in the data structure that keeps track of all features per elem
         if (_compute_var_to_feature_map)
         {
         auto insert_pair = moose_try_emplace(
               _entity_var_to_features, entity, std::vector<unsigned int>(_n_vars, invalid_id));
         auto & vec_ref = insert_pair.first->second;
         vec_ref[feature._var_index] = feature._id; // An ID for this feature
         }
      }
```

- 借鉴
```c++
  RankFourTensor C_ijkl = _C_ijkl;
  C_ijkl.rotate(RotationTensor(RealVectorValue(angles)));
  
```
1. `GBAnisotropyGrainGrowth::computeQpProperties()` -- calculate kappa, gamma, L, mu based on gb energy, gb mobility and activate energy;
2. `computeGBParamaterByMisorientaion()` -- calculate gb energy, gb mobility and activate energy based on misorientation
3. 

# input 

```bash
my_rate1_HABvsLAB_mob = 0.9
my_rate2_HABvsLAB_mob = 0.1
my_rate1_HABvsLAB_sigma = 0.5
my_rate2_HABvsLAB_sigma = 0.5
my_connecting_threshold = 0.05

[UserObjects]
  [./euler_angle_file]
    type = EulerAngleFileReader
    file_name = grn_100_testure_2D.tex
  [../]
[]

[materials]
  [./CuGrGranisotropic]
    type = GBAnisotropyGrainGrowth # 
    grain_tracker = grain_tracker
    euler_angle_provider = euler_angle_file 
    T = 450 # K
    inclination_anisotropy = false # true
    gbEnergy_anisotropy = true # true false
    gbMobility_anisotropy = true
    GBmob_HAB = ${my_GBmob0} # 2.5e-6
    GBsigma_HAB = 0.708
    GBQ_HAB = 0.23
    rate1_HABvsLAB_mob = ${my_rate1_HABvsLAB_mob} # 0.9
    rate2_HABvsLAB_mob = ${my_rate2_HABvsLAB_mob} # 0.1
    rate1_HABvsLAB_sigma = ${my_rate1_HABvsLAB_sigma} # 0.5
    rate2_HABvsLAB_sigma = ${my_rate2_HABvsLAB_sigma} # 0.5
    wGB = ${my_wGB}
    output_properties = 'kappa_op L mu gamma_asymm'
    outputs = my_exodus
  [../]
[]
```
---
grn_100_testure_2D.tex
```csv
Texture File

File generated from MATLAB
B 100
   43.00   0.00   0.00   1.00
   45.00   0.00   0.00   1.00
   44.00   0.00   0.00   1.00
   45.00   0.00   0.00   1.00
   90.00   0.00   0.00   1.00
   45.00   0.00   0.00   1.00
...
```

# tensor 2nd

   * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~{.cpp}
   * RankTwoTensor A(1, 2, 3, 4, 5, 6, 7, 8, 9);
   * RealVectorValue col = A.column(1);
   * // col = [ 4
   * //         5
   * //         6 ]
   * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   */


     * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~{.cpp}
   * RankTwoTensor A(1, 2, 3, 4, 5, 6, 7, 8, 9);
   * // A = [ 1 2 3
   * //       2 4 6
   * //       3 6 9 ]
   * RankTwoTensor B(9, 8, 7, 6, 5, 4, 3, 2, 1);
   * // B = [ 9 6 3
   * //       8 5 2
   * //       7 4 1 ]
   * A *= B;
   * // A = [ 90  54 18
   * //       114 69 24
   * //       138 84 30 ]
   * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

