# This example tests the implementation of PolycrstalStoredEnergy kernels that assigns excess stored energy to grains with dislocation density

my_filename = 'df_01'
my_interval = 1
my_num_adaptivity = 0

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 100
  ny = 100
  nz = 0
  xmin = 0
  xmax = 64
  ymin = 0
  ymax = 64
  elem_type = QUAD4 # QUAD4 # TRI3
[]

[GlobalParams]
  block = 0
  op_num = 10
  deformed_grain_num = 10
  var_name_base = gr
  grain_num = 20
  grain_tracker = grain_tracker
  time_scale = 1e-2
  length_scale = 1e-8
[]

[Variables]
  [./PolycrystalVariables]
  [../]
[]

[AuxVariables]
  [./bnds]
    order = FIRST
    family = LAGRANGE
  [../]
  [./unique_grains]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./var_indices]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./centroids]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[UserObjects]
  [./voronoi]
    type = PolycrystalVoronoi
    rand_seed = 81
    coloring_algorithm = bt
  [../]
  [./grain_tracker]
    type = GrainTracker # Faux
    threshold = 0.2
    verbosity_level = 1
    connecting_threshold = 0.08
    compute_var_to_feature_map = true
    flood_entity_type = elemental
    execute_on = ' initial timestep_begin'
    polycrystal_ic_uo = voronoi
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

# [BCs]
#   [./Periodic]
#     [./all]
#       auto_direction = 'x'
#     [../]
#   [../]
# []

[Kernels]
  [./PolycrystalKernel]
  [../]
  [./PolycrystalStoredEnergy]
  [../]
[]

[AuxKernels]
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
  [./centroids]
    type = FeatureFloodCountAux
    variable = centroids
    execute_on = timestep_end
    field_display = CENTROID # centroid -- MooseEnum, field_display
    flood_counter = grain_tracker # getUserObject<FeatureFloodCount>

    # FeatureFloodCountAux <--- GrainTracker <--- FeatureFloodCount::getEntityValue(entity_id, field_type, var_index) <-- 
  [../]
[]

[Materials]
  [./deformed]
    type = DeformedGrainMaterialGG
    int_width = 4.0 # in length_scale unit
    GBMobility =  2.0e-13 # m^4/(J*s)
    Disloc_Den = 9.0e15 #  m^-2
    Elas_Mod = 2.50e10 # J/m^3
    Burg_vec = 3.0e-10 # Length of Burger Vector in m
    # length_scale = 1e-8 # e-1 nm
    # time_scale = 

    outputs = my_exodus
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  nl_max_its = 15
  scheme = bdf2
  solve_type = PJFNK
  petsc_options_iname = -pc_type
  petsc_options_value = asm
  l_max_its = 15
  l_tol = 1.0e-3
  nl_rel_tol = 1.0e-8
  start_time = 0.0
  num_steps = 5
  nl_abs_tol = 1e-8
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.20
    growth_factor = 1.2
    cutback_factor = 0.8
    optimal_iterations = 8
  [../]
  # [./Adaptivity]
  #   initial_adaptivity = ${my_num_adaptivity}
  #   refine_fraction = 0.7
  #   coarsen_fraction = 0.1
  #   max_h_level = ${my_num_adaptivity}
  # [../]
[]

# [VectorPostprocessors]
#   [./features]
#     type = FeatureVolumeVectorPostprocessor
#     flood_counter = flood_count

#     # Turn on centroid output
#     output_centroids = true
#     execute_on = INITIAL
#     boundary = 10
#     single_feature_per_element = true
#   [../]
# []

[VectorPostprocessors]
  [grain_volumes]
    type = FeatureVolumeVectorPostprocessor
    flood_counter = grain_tracker
    execute_on = 'timestep_begin'
    output_centroids = true
  []
[]


[Postprocessors]
  # Scalar postprocessors
  [dt]
    # Outputs the current time step
    type = TimestepSize
  []
  # [grain_center]
  #   type = GrainTracker
  #   variable = grain_tracker
  #   outputs = none
  #   compute_var_to_feature_map = true
  #   execute_on = 'timestep_begin'
  # []
[]

[Outputs]
  file_base = ./${my_filename}/out_${my_filename}
  # show = bnds
  csv = true
  [./my_exodus]
    type = Exodus
    interval = ${my_interval} # The interval at which time steps are output
    # sync_times = '10 50 100 500 1000 5000 10000 50000 100000'
    # sync_only = true
    sequence = true
  [../]
  # [./pgraph]
  #   type = PerfGraphOutput
  #   execute_on = 'initial timestep_end final'  # Default is "final"
  #   level = 2                     # Default is 1
  #   heaviest_branch = true        # Default is false
  #   heaviest_sections = 7         # Default is 0
  # [../]
  [./my_console]
    type = Console
    output_linear = False
    output_nonlinear = False
    # output_screen = False
    # interval = 1
  [../]
  # execute_on = 'timestep_end'
[]
