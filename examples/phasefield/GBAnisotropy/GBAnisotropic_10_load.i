my_filename = 'gbAnisotropyGrainGrowth_24'
# my_interval = 2
my_num_adaptivity = 3
my_rate1_HABvsLAB = 0.5
my_rate2_HABvsLAB = 0.5
my_end_time = 1e5
my_load = 8

[Mesh]
  # Mesh block.  Meshes can be read in or automatically generated
  type = GeneratedMesh
  dim = 2 # Problem dimension
  nx = 40 # Number of elements in the x-direction
  ny = 40 # Number of elements in the y-direction
  xmin = 0    # minimum x-coordinate of the mesh
  xmax = 400 # 1000 maximum x-coordinate of the mesh 2000-400 400 1600
  ymin = 0    # minimum y-coordinate of the mesh
  ymax = 400 # 1000 maximum y-coordinate of the mesh
  elem_type = QUAD4  # Type of elements used in the mesh
  uniform_refine = 0 # Initial uniform refinement of the mesh

  # parallel_type = distributed # Periodic BCs distributed replicated
[]

[GlobalParams]
  # Parameters used by several kernels that are defined globally to simplify input file
  op_num = 10 # Number of order parameters used
  var_name_base = gr # Base name of grains
  grain_num = 10 #Number of grains
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
    file_name = grn_100_testure_2D.tex
  [../]
  [./voronoi]
    type = PolycrystalVoronoi
    rand_seed = 20
    coloring_algorithm = bt # 保持序参数对应唯一的晶粒
  [../]
  [./grain_tracker]
    type = GrainTrackerElasticity # Note: FauxGrainTracker only used for testing purposes. Use GrainTracker when using GrainTextureVectorPostprocessor.
    connecting_threshold = 0.2
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
  # Dependent variables
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
    # Custom action creating all necessary kernels for grain growth.  All input parameters are up in GlobalParams
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
  # [./Periodic]
  #   [./All]
  #     auto_direction = 'x'
  #     variable = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7'
  #   [../]
  # [../]
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
    type = GBAnisotropyGrainGrowth
    grain_tracker = grain_tracker
    euler_angle_provider = euler_angle_file 
    T = 450 # K
    wGB = 14 # Width of the diffuse GB nm
    inclination_anisotropy = false # true
    gbEnergy_anisotropy = true # true false
    gbMobility_anisotropy = true
    GBmob_HAB = 2.5e-6 # 
    GBsigma_HAB = 0.708
    GBQ_HAB = 0.23
    rate1_HABvsLAB = ${my_rate1_HABvsLAB} # rate_HABvsLAB + 1
    rate2_HABvsLAB = ${my_rate2_HABvsLAB}
    outputs = my_exodus
  [../]
  # [./CuGrGr]
  #   # Material properties
  #   type = GBEvolution
  #   block = 0
  #   T = 450 # Constant temperature of the simulation (for mobility calculation)
  #   wGB = 14 # Width of the diffuse GB
  #   GBmob0 = 2.5e-6 #m^4(Js) for copper from Schoenfelder1997
  #   Q = 0.23 #eV for copper from Schoenfelder1997
  #   GBenergy = 0.708 #J/m^2 from Schoenfelder1997
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

[Preconditioning]
  [./SMP]
    type = SMP
    coupled_groups = 'disp_x,disp_y'
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -pc_hypre_boomeramg_strong_threshold'
  petsc_options_value = 'hypre boomeramg 31 0.7'

  l_max_its = 30 # Max number of linear iterations
  l_tol = 1e-4 # Relative tolerance for linear solves
  nl_max_its = 40 # Max number of nonlinear iterations
  nl_abs_tol = 1e-11 # Relative tolerance for nonlinear solves
  nl_rel_tol = 1e-10 # Absolute tolerance for nonlinear solves
  start_time = 0.0
  end_time = ${my_end_time}
  # num_steps = 10

  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.1
    growth_factor = 1.2
    cutback_factor = 0.8
    optimal_iterations = 8
  [../]
  [./Adaptivity]
    # Block that turns on mesh adaptivity. Note that mesh will never coarsen beyond initial mesh (before uniform refinement)
    initial_adaptivity = ${my_num_adaptivity} # Number of times mesh is adapted to initial condition
    refine_fraction = 0.7 # Fraction of high error that will be refined
    coarsen_fraction = 0.1 # Fraction of low error that will coarsened
    max_h_level = 3 # Max number of refinements used, starting from initial mesh (before uniform refinement)
  [../]
[]

[Outputs]
  file_base = ./${my_filename}/out_${my_filename}
  print_linear_residuals = false
  [./my_exodus]
    type = Exodus # Exodus Nemesis
    # interval = ${my_interval} # The interval at which time steps are output
    # sync_times = '10 50 100 500 1000 5000 10000 50000 100000'
    # sync_only = true
    sequence = true
  [../]
  csv = true
[]