# para_20_elastic_01: 没有弹性能，同性， 没有算完
# para_20_elastic_02: 加载1.0%，同性
# para_20_elastic_03: 加载0.5%，同性
# para_20_ElasticGB_04: 加载0.5%，异性（0.5-0.5）
# para_20_ElasticGB_05: 加载0.0%，异性（0.9/0.1 0.5/0.5） 20倍可以
# para_20_ElasticGB_06: 加载0.0%，异性（0.9/0.1 0.750/0.25） 40倍不行，演化到后面不稳定
# para_20_ElasticGB_07: 加载0.0%，异性（0.9/0.1 0.60/0.40） 25倍可以，演化到188.22比较慢，晶界保持稳定
# para_20_ElasticGB_08: 加载0.0%，异性（1.9/0.1 0.60/0.40） 50倍不可以，演化到35.12出现奇怪的晶界， bnd_max = 1.2
# para_60_ElasticGB_09: 加载0.5%，异性（0.9/0.1 0.60/0.40） 25倍不可以，晶界形态极度奇异， bnd_max = 1.5
# para_60_ElasticGB_10: 加载0.5%，异性（0.6/0.4 0.60/0.40） 6.25倍 mob0 = 5.0e-12
# para_60_ElasticGB_11: 加载0.5%，异性（0.6/0.4 0.60/0.40） 6.25倍 mob0 = 3.0e-12
# para_400_ElasticGB_11: 加载0.5%，异性（0.6/0.4 0.60/0.40） 6.25倍 mob0 = 5.0e-12

my_filename = 'para_400_ElasticGB_11'
my_interval = 5
my_num_adaptivity = 3
my_end_time = 500

my_length_scale = 1e-8 # 10 nm
my_time_scale = 1 # 0.1 s
my_GBmob0 = 5.0e-12 # 2.5e-11 6.6383e-14 2.5e-11
my_wGB = 20
my_rate1_HABvsLAB_mob = 0.60
my_rate2_HABvsLAB_mob = 0.40
my_rate1_HABvsLAB_sigma = 0.60
my_rate2_HABvsLAB_sigma = 0.40
my_connecting_threshold = 0.05

my_load = 26.6 # 75.20 # 2%

my_nx = 133
my_ny = 133 # 40 # 30 94
my_max_x = 5320 # 2060 #1200 # 400 # 1200 3760-(200) 1600-(36) 5320-(400)
my_max_y = 5320 # 2060 #1200

my_grain_num = 400 # 20
my_rand_seed = 800 # 40
# tar -jcvf 4type_GBElastic_200_048exodus.tar.bz2 ./4type_GBElastic_200/*.e-s???[048]*

[Mesh]
  # Mesh block.  Meshes can be read in or automatically generated
  type = GeneratedMesh
  dim = 2 # Problem dimension
  nx = ${my_nx} # Number of elements in the x-direction
  ny = ${my_ny} # Number of elements in the y-direction
  xmin = 0    # minimum x-coordinate of the mesh
  xmax = ${my_max_x} # 1000 maximum x-coordinate of the mesh 2000-400 400 1600
  ymin = 0    # minimum y-coordinate of the mesh
  ymax = ${my_max_y} # 1000 maximum y-coordinate of the mesh
  elem_type = QUAD4  # Type of elements used in the mesh
  uniform_refine = 0 # Initial uniform refinement of the mesh

  # parallel_type = distributed # Periodic BCs distributed replicated
[]


[GlobalParams]
  # Parameters used by several kernels that are defined globally to simplify input file
  op_num = 16 # Number of order parameters used
  grain_num = ${my_grain_num}
  var_name_base = gr # Base name of grains
  length_scale = ${my_length_scale}
  time_scale = ${my_time_scale}
[]

[Variables]
  # Variable block, where all variables in the simulation are declared
  [./PolycrystalVariables]
  [../]
  [./disp_x]
    order = FIRST
    family = LAGRANGE
  [../]
  [./disp_y]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[UserObjects]
  [./euler_angle_file]
    type = EulerAngleFileReader
    file_name =  grn_400_testure1_2D.tex #grn_20_testure_2D.tex grn_36_rand_2D.tex
  [../]
  [./voronoi]
    type = PolycrystalVoronoi
    rand_seed = ${my_rand_seed}
    coloring_algorithm = jp # 保持序参数对应唯一的晶粒
    int_width = ${my_wGB}
  [../]
  # [./grain_tracker]
  #   type = GrainTracker # Note: FauxGrainTracker only used for testing purposes. Use GrainTracker when using GrainTextureVectorPostprocessor.
  #   connecting_threshold = 0.02
  #   compute_var_to_feature_map = true
  #   flood_entity_type = ELEMENTAL
  #   execute_on = 'initial timestep_begin'
  #   outputs = none
  # [../]
  [./grain_tracker]
    type = GrainTrackerElasticity 
    connecting_threshold = ${my_connecting_threshold}
    compute_var_to_feature_map = true
    flood_entity_type = ELEMENTAL
    execute_on = 'initial timestep_begin'
    outputs = none
    C_ijkl = '1.27e5 0.708e5 0.708e5 1.27e5 0.708e5 1.27e5 0.7355e5 0.7355e5 0.7355e5'
    fill_method = symmetric9
    euler_angle_provider = euler_angle_file
  [../]
[]

[ICs]
  [./PolycrystalICs]
    [./PolycrystalColoringIC]
      polycrystal_ic_uo = voronoi
    [../]
  [../]
[]


[AuxVariables]
  [./bnds]
    order = FIRST
    family = LAGRANGE
  [../]
  # Dependent variables
  # [./local_energy]
  #   order = CONSTANT
  #   family = MONOMIAL
  # [../]
  [./elastic_strain11]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./elastic_strain22]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./elastic_strain12]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./elastic_stress11] 
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./elastic_stress22]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./elastic_stress12]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./vonmises_stress]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./C1111]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./unique_grains]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./var_indices]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./euler_angle]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
  # Kernel block, where the kernels defining the residual equations are set up.
  [./PolycrystalKernel]
  [../]
  [./PolycrystalElasticDrivingForce]
  [../]
  [./TensorMechanics]
    use_displaced_mesh = true
    displacements = 'disp_x disp_y'
  [../]
[]

[AuxKernels]
  # AuxKernel block, defining the equations used to calculate the auxvars
  [./BndsCalc]
    type = BndsCalcAux
    variable = bnds
    execute_on = timestep_end
  [../]
  [./elastic_strain11]
    type = RankTwoAux
    variable = elastic_strain11
    rank_two_tensor = elastic_strain
    index_i = 0
    index_j = 0
    execute_on = timestep_end
  [../]
  [./elastic_strain22]
    type = RankTwoAux
    variable = elastic_strain22
    rank_two_tensor = elastic_strain
    index_i = 1
    index_j = 1
    execute_on = timestep_end
  [../]
  [./elastic_strain12]
    type = RankTwoAux
    variable = elastic_strain12
    rank_two_tensor = elastic_strain
    index_i = 0
    index_j = 1
    execute_on = timestep_end
  [../]
  [./elastic_stress11]
    type = RankTwoAux
    variable = elastic_stress11
    rank_two_tensor = stress
    index_i = 0
    index_j = 0
    execute_on = timestep_end
  [../]
  [./elastic_stress22]
    type = RankTwoAux
    variable = elastic_stress22
    rank_two_tensor = stress
    index_i = 1
    index_j = 1
    execute_on = timestep_end
  [../]
  [./elastic_stress12]
    type = RankTwoAux
    variable = elastic_stress12
    rank_two_tensor = stress
    index_i = 0
    index_j = 1
    execute_on = timestep_end
  [../]
  [./C1111]
    type = RankFourAux
    variable = C1111
    rank_four_tensor = elasticity_tensor
    index_l = 0
    index_j = 0
    index_k = 0
    index_i = 0
    execute_on = timestep_end
  [../]
  [./vonmises_stress]
    type = RankTwoScalarAux
    variable = vonmises_stress
    rank_two_tensor = stress
    scalar_type = VonMisesStress
    execute_on = timestep_end
  [../]
  [./unique_grains]
    type = FeatureFloodCountAux
    variable = unique_grains
    execute_on = timestep_end
    flood_counter = grain_tracker
    field_display = UNIQUE_REGION
  [../]
  [./var_indices]
    type = FeatureFloodCountAux
    variable = var_indices
    execute_on = timestep_end
    flood_counter = grain_tracker
    field_display = VARIABLE_COLORING
  [../]
  [./euler_angle]
    type = OutputEulerAngles
    variable = euler_angle
    euler_angle_provider = euler_angle_file
    grain_tracker = grain_tracker
    output_euler_angle = 'phi1'
    #  phi1, Phi, phi2
    execute_on = 'initial timestep_end'
  [../]
[]

[BCs]
  # Boundary Condition block
  [./Periodic]
    [./top_bottom]
      auto_direction = 'x y' # Makes problem periodic in the x and y directions
      variable = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9 gr10 gr11 gr12 gr13 gr14 gr15'
    [../]
  [../]
  [./top_displacement]
    type = DirichletBC
    variable = disp_y
    boundary = top
    value = ${my_load}
  [../]
  [./x_anchor]
    type = DirichletBC
    variable = disp_x
    boundary = 'left right'
    value = 0.0
  [../]
  [./y_anchor]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value = 0.0
  [../]
[]



[Materials]
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
    rate1_HABvsLAB_mob = ${my_rate1_HABvsLAB_mob} # rate_HABvsLAB + 1
    rate2_HABvsLAB_mob = ${my_rate2_HABvsLAB_mob}
    rate1_HABvsLAB_sigma = ${my_rate1_HABvsLAB_sigma} # rate_HABvsLAB + 1
    rate2_HABvsLAB_sigma = ${my_rate2_HABvsLAB_sigma}
    wGB = ${my_wGB}
    output_properties = 'kappa_op L mu gamma_asymm'
    outputs = my_exodus
  [../]
  # [./Copper]
  #   type = GBEvolution
  #   block = 0
  #   T = 450 # K
  #   GBmob0 = ${my_GBmob0} # 2.5e-6 #m^4/(Js) from Schoenfelder 1997
  #   Q = 0.23 #Migration energy in eV
  #   GBenergy = 0.708 #GB energy in J/m^2
  #   wGB = ${my_wGB}
  #   # output_properties = 'kappa_op L mu gamma_asymm'
  #   # outputs = my_exodus
  # [../]
  [./ElasticityTensor]
    type = ComputePolycrystalElasticityTensor
    grain_tracker = grain_tracker
  [../]
  [./strain]
    type = ComputeSmallStrain
    block = 0
    displacements = 'disp_x disp_y'
  [../]
  [./stress]
    type = ComputeLinearElasticStress
    block = 0
  [../]
  # [./elastic_free_energy_e]
  #   type = ElasticEnergyMaterial
  #   f_name = f_el
  #   derivative_order = 2
  #   args = 'gr0 gr5'
  #   # output_properties = 'f_el'
  #   outputs = my_exodus
  # [../]
  # [./free_energy]
  #   type = DerivativeParsedMaterial
  #   f_name= F_loc
  #   args = 'gr0 gr5'
  #   material_property_names = 'mu gamma_asymm'
  #   function = 'mu*( gr0^4/4.0 - gr0^2/2.0 + gr5^4/4.0 - gr5^2/2.0 + gamma_asymm*gr0^2*gr5^2 + 1.0/4.0)'
  #   derivative_order = 2
  #   enable_jit = true
  #   outputs = my_exodus
  # [../]
[]

[VectorPostprocessors]
  [./grain_volumes] 
    type = FeatureVolumeVectorPostprocessor 
    flood_counter = grain_tracker # The FeatureFloodCount UserObject to get values from.
    execute_on = 'initial timestep_end'
    output_centroids = true
  [../]
[]

[Postprocessors]
  # Scalar postprocessors
  [./dt]
    # Outputs the current time step
    type = TimestepSize
  [../]
  [./dofs]
    type = NumDOFs
  [../]
  [./run_time]
    type = PerfGraphData
    section_name = "Root"
    data_type = total
  [../]
  [./ngrains]
    type = FeatureFloodCount
    variable = bnds
    threshold = 0.7
  [../]
  [./avg_grain_volumes]
    type = AverageGrainVolume
    feature_counter = grain_tracker
    execute_on = 'initial timestep_end'
  [../]
[]


[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -pc_hypre_boomeramg_strong_threshold'
  petsc_options_value = 'hypre boomeramg 31 0.7'

  dtmin = 1e-5
  l_max_its = 30 # Max number of linear iterations
  l_tol = 1e-4 # Relative tolerance for linear solves
  nl_max_its = 10 # Max number of nonlinear iterations
  nl_abs_tol = 1e-11 # Relative tolerance for nonlinear solves
  nl_rel_tol = 1e-7 # Absolute tolerance for nonlinear solves

  start_time = 0.0
  end_time = ${my_end_time}
  # num_steps = 3
  dtmax = 2.2
  automatic_scaling = true # Whether to use automatic scaling for the variables.
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.7 # 1238-iso # 400-0.7
    growth_factor = 1.2
    cutback_factor = 0.8
    optimal_iterations = 8
  [../]
  [./Adaptivity]
    # Block that turns on mesh adaptivity. Note that mesh will never coarsen beyond initial mesh (before uniform refinement)
    initial_adaptivity = ${my_num_adaptivity} # Number of times mesh is adapted to initial condition
    refine_fraction = 0.7 # Fraction of high error that will be refined
    coarsen_fraction = 0.1 # Fraction of low error that will coarsened
    max_h_level = ${my_num_adaptivity} # Max number of refinements used, starting from initial mesh (before uniform refinement)
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    coupled_groups = 'disp_x,disp_y'
  [../]
[]

[Outputs]
  file_base = ./${my_filename}/out_${my_filename}
  print_linear_residuals = false # false true
  [./my_exodus]
    type = Nemesis # Exodus Nemesis VTK
    interval = ${my_interval} # The interval at which time steps are output
    # sync_times = '10 50 100 500 1000 5000 10000 50000 100000'
    # sync_only = true
    # sequence = true
  [../]
  csv = true
  [pgraph]
    type = PerfGraphOutput
    execute_on = 'timestep_end final'  # Default is "final" initial
    level = 1                  # Default is 1
    heaviest_branch = true        # Default is false
    heaviest_sections = 5     # Default is 0 7 
  []
  # [./my_checkpoint]
  #   type = Checkpoint
  #   num_files = 10
  #   interval = ${my_interval}
  # [../]
  [./console]
    type = Console
    output_nonlinear = true
  [../]
[]