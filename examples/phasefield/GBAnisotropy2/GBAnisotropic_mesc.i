<<<<<<< HEAD
my_filename = 'para_80_1'
my_interval = 5
my_num_adaptivity = 3
my_rate1_HABvsLAB = 1
my_rate2_HABvsLAB = 1
=======
my_filename = '4type_GBAnisotrpic_200'
my_interval = 5
my_num_adaptivity = 3
my_rate1_HABvsLAB = 0.25 # 前置因子
my_rate2_HABvsLAB = 0.5 # 后置因子
>>>>>>> bee4aea458b5b1e0f20e80f1f488ab5c196134b7
my_end_time = 1e5

my_length_scale = 1e-8 # 10 nm
my_time_scale = 1e-1 # 0.1 s

my_GBmob0 = 2.5e-11 # m^4/(J·s) 2.5e-6
my_GBsigma_HAB = 0.708 # J/m^2
my_wGB = 20

my_nx = 60 # 30 60 94
my_max = 2378 # 1200 2378 3760
my_grain_num = 80 # 20 80 200
my_rand_seed = 160 # 40 160 400

# my_max = pow(150*150*3.1415926*80,0.5)
# tar -cvf - para_80_1/out_para_80_1.e-s???[0369]* | pigz -9 -p 20 > para_80_1_1exodus.tgz
# tar -jcvf para_80_1_1exodus.tgz para_80_1/out_para_80_1.e-s???[0369]*
[Mesh]
  # Mesh block.  Meshes can be read in or automatically generated
  type = GeneratedMesh
  dim = 2 # Problem dimension
  nx = ${my_nx} # Number of elements in the x-direction
  ny = ${my_nx} # Number of elements in the y-direction
  xmin = 0    # minimum x-coordinate of the mesh
  xmax = ${my_max} # 1000 maximum x-coordinate of the mesh 2000-400 400 1600
  ymin = 0    # minimum y-coordinate of the mesh
  ymax = ${my_max} # 1000 maximum y-coordinate of the mesh
  elem_type = QUAD4  # Type of elements used in the mesh
  uniform_refine = 0 # Initial uniform refinement of the mesh

  # parallel_type = distributed # Periodic BCs distributed replicated
[]


[GlobalParams]
  # Parameters used by several kernels that are defined globally to simplify input file
  op_num = 12 # Number of order parameters used
  var_name_base = gr # Base name of grains
  grain_num = ${my_grain_num} #Number of grains
  length_scale = ${my_length_scale}
  time_scale = ${my_time_scale}
[]

[Variables]
  # Variable block, where all variables in the simulation are declared
  [./PolycrystalVariables]
  [../]
[]

[UserObjects]
  [./euler_angle_file]
    type = EulerAngleFileReader
    file_name = grn_200_testure_2D.tex
  [../]
  [./voronoi]
    type = PolycrystalVoronoi
    rand_seed = ${my_rand_seed}
    coloring_algorithm = jp # 保持序参数对应唯一的晶粒
    int_width = ${my_wGB}
  [../]
  # [./grain_tracker]
  #   type = GrainTrackerElasticity # Note: FauxGrainTracker only used for testing purposes. Use GrainTracker when using GrainTextureVectorPostprocessor.
  #   connecting_threshold = 0.2
  #   compute_var_to_feature_map = true
  #   flood_entity_type = ELEMENTAL
  #   execute_on = 'initial timestep_begin'
  #   outputs = none
  #   C_ijkl = '1.27e5 0.708e5 0.708e5 1.27e5 0.708e5 1.27e5 0.7355e5 0.7355e5 0.7355e5'
  #   fill_method = symmetric9
  #   euler_angle_provider = euler_angle_file
  # [../]
  [./grain_tracker]
    type = GrainTracker # Note: FauxGrainTracker only used for testing purposes. Use GrainTracker when using GrainTextureVectorPostprocessor.
    connecting_threshold = 0.2
    compute_var_to_feature_map = true
    flood_entity_type = ELEMENTAL
    execute_on = 'initial timestep_begin'
    outputs = none
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
[]

[AuxKernels]
  # AuxKernel block, defining the equations used to calculate the auxvars
  [./BndsCalc]
    type = BndsCalcAux
    variable = bnds
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
      variable = 'gr0 gr1 gr2 gr3 gr4 gr5 gr6 gr7 gr8 gr9 gr10 gr11'
    [../]
  [../]
[]



[Materials]
  [./CuGrGranisotropic]
    type = GBAnisotropyGrainGrowth
    grain_tracker = grain_tracker
    euler_angle_provider = euler_angle_file 
    T = 450 # K
    wGB = ${my_wGB} # Width of the diffuse GB nm # 0.14 miu m
    inclination_anisotropy = false # true
<<<<<<< HEAD
    gbEnergy_anisotropy = true # true false
    gbMobility_anisotropy = true
=======
    gbEnergy_anisotropy = false # true false
    gbMobility_anisotropy = false
>>>>>>> 33d23280851440a845efbd15dd6c7ab7c31899f0
    GBmob_HAB = ${my_GBmob0} # 2.5e-6
    GBsigma_HAB = ${my_GBsigma_HAB} # 0.708
    GBQ_HAB = 0.23
    rate1_HABvsLAB = ${my_rate1_HABvsLAB} # rate_HABvsLAB + 1
    rate2_HABvsLAB = ${my_rate2_HABvsLAB}
<<<<<<< HEAD
    # outputs = my_exodus
=======
    outputs = my_exodus
>>>>>>> 33d23280851440a845efbd15dd6c7ab7c31899f0
  [../]
  # [./CuGrGr]
  #   # Material properties
  #   type = GBEvolution
  #   block = 0
  #   T = 450 # Constant temperature of the simulation (for mobility calculation)
  #   wGB = ${my_wGB} # Width of the diffuse GB 0.6 14 0.6(不行)
  #   GBmob0 = ${my_GBmob0} #m^4(Js) for copper from Schoenfelder1997 2.5e-6 2.5e-9(晶界没有演化)
  #   Q = 0.23 #eV for copper from Schoenfelder1997
  #   GBenergy = 0.708 #J/m^2 from Schoenfelder1997
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

# [Preconditioning]
#   [./SMP]
#     type = SMP
#     coupled_groups = 'disp_x,disp_y'
#   [../]
# []

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -pc_hypre_boomeramg_strong_threshold'
  petsc_options_value = 'hypre boomeramg 31 0.7'

  l_max_its = 20 # Max number of linear iterations
  l_tol = 1e-4 # Relative tolerance for linear solves
  nl_max_its = 12 # Max number of nonlinear iterations
  nl_abs_tol = 1e-11 # Relative tolerance for nonlinear solves
  nl_rel_tol = 1e-10 # Absolute tolerance for nonlinear solves
  start_time = 0.0
  end_time = ${my_end_time}
  # num_steps = 10

  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 5.0
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

[Outputs]
  file_base = ./${my_filename}/out_${my_filename}
  print_linear_residuals = false
<<<<<<< HEAD
  [./console]
    type = Console
    max_rows = 10 # Will print the 20 most recent postprocessor values to the screen
  [../]
=======
>>>>>>> 33d23280851440a845efbd15dd6c7ab7c31899f0
  [./my_exodus]
    type = Nemesis # Exodus Nemesis
    interval = ${my_interval} # The interval at which time steps are output
    # sync_times = '10 50 100 500 1000 5000 10000 50000 100000'
    # sync_only = true
    # sequence = true
  [../]
  csv = true
  [pgraph]
    type = PerfGraphOutput
    execute_on = 'TIMESTEP_END FINAL'  # Default is "final" initial
    level = 6                    # Default is 1~6
    heaviest_branch = true      # Default is false
    heaviest_sections = 10        # Default is 0~
  []
  [./my_checkpoint]
    type = Checkpoint
    num_files = 10
    interval = ${my_interval}
  [../]
[]