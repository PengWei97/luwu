# /home/pengwei/projects/moose/modules/phase_field/include/postprocessors/GrainTracker.h

my_filename = "test2"

my_GBmob0 = 2.5e-13
my_wGB = 0.8
my_T = 973.15 # 700du

[Mesh]
  # Mesh block.  Meshes can be read in or automatically generated
  type = GeneratedMesh
  dim = 2 # Problem dimension
  nx = 25 # Number of elements in the x-direction
  ny = 25 # Number of elements in the y-direction
  xmin = 0    # minimum x-coordinate of the mesh
  xmax = 50 # 1000 maximum x-coordinate of the mesh 2000-400 400 1600
  ymin = 0    # minimum y-coordinate of the mesh
  ymax = 50 # 1000 maximum y-coordinate of the mesh
  elem_type = QUAD4  # Type of elements used in the mesh

  parallel_type = replicated # Periodic BCs distributed replicated
[]

[GlobalParams]
  op_num = 8
  var_name_base = gr
  grain_num = 10
  length_scale = 1.0e-6
  time_scale = 1.0
[]

[UserObjects]
  [./euler_angle_file]
    type = EulerAngleFileReader
    file_name = grn_10_testure_2D.tex
  [../]
  [./voronoi]
    type = PolycrystalVoronoi
    rand_seed = 20
    coloring_algorithm = jp # 保持序参数对应唯一的晶粒
    int_width = ${my_wGB}
  [../]
  [grain_tracker]
    type = GrainTracker
    # threshold = 0.2
    # halo_level = 4
    connecting_threshold = 0.01 # 0.001
    flood_entity_type = ELEMENTAL
    compute_halo_maps = true # For displaying HALO fields
    # execute_on = 'initial TIMESTEP_BEGIN'
    polycrystal_ic_uo = voronoi
    compute_var_to_feature_map = true

    euler_angle_provider = euler_angle_file   
  []
[]

[ICs]
  [./PolycrystalICs]
    [./PolycrystalColoringIC]
      polycrystal_ic_uo = voronoi
    [../]
  [../]
[]

[Variables]
  [PolycrystalVariables]
  []
[]

[AuxVariables]
  [bnds]
  []
  [unique_grains]
    order = CONSTANT
    family = MONOMIAL
  []
  [ghost_elements]
    order = CONSTANT
    family = MONOMIAL
  []
  [halos]
    order = CONSTANT
    family = MONOMIAL
  []
  [var_indices]
    order = CONSTANT
    family = MONOMIAL
  []
  [phi1]
    order = CONSTANT
    family = MONOMIAL
  []
  [Phi]
    order = CONSTANT
    family = MONOMIAL
  []
  [phi2]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Kernels]
  [PolycrystalKernel]
  []
[]

[AuxKernels]
  [BndsCalc]
    type = BndsCalcAux
    variable = bnds
    execute_on = 'initial timestep_end'
  []
  [ghost_elements]
    type = FeatureFloodCountAux
    variable = ghost_elements
    field_display = GHOSTED_ENTITIES
    execute_on = 'initial timestep_end'
    flood_counter = grain_tracker
  []
  [halos]
    type = FeatureFloodCountAux
    variable = halos
    field_display = HALOS
    execute_on = 'initial timestep_end'
    flood_counter = grain_tracker
  []
  [var_indices]
    type = FeatureFloodCountAux
    variable = var_indices
    execute_on = 'initial timestep_end'
    flood_counter = grain_tracker
    field_display = VARIABLE_COLORING
  []
  [unique_grains]
    type = FeatureFloodCountAux
    variable = unique_grains
    flood_counter = grain_tracker
    field_display = UNIQUE_REGION
  []
  [phi1]
    type = OutputEulerAngles
    variable = phi1
    euler_angle_provider = euler_angle_file
    grain_tracker = grain_tracker
    output_euler_angle = 'phi1'
    execute_on = 'initial TIMESTEP_BEGIN'
  []
  [Phi]
    type = OutputEulerAngles
    variable = Phi
    euler_angle_provider = euler_angle_file
    grain_tracker = grain_tracker
    output_euler_angle = 'Phi'
    execute_on = 'initial TIMESTEP_BEGIN'
  []
  [phi2]
    type = OutputEulerAngles
    variable = phi2
    euler_angle_provider = euler_angle_file
    grain_tracker = grain_tracker
    output_euler_angle = 'phi2'
    execute_on = 'initial TIMESTEP_BEGIN'
  []
[]

[Materials]
  [./CuGrGranisotropic]
    type = GBEvolution # Quantitative material properties for copper grain growth.  Dimensions are nm and ns
    GBmob0 = ${my_GBmob0} # Mobility prefactor for Cu from Schonfelder1997
    GBenergy = 0.708 # GB energy for Cu from Schonfelder1997
    Q = 0.23 # Activation energy for grain growth from Schonfelder 1997
    T = ${my_T} # Constant temperature of the simulation (for mobility calculation)
    wGB = ${my_wGB} # Width of the diffuse GB
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
  [dt]
    type = TimestepSize
  []
  [n_elements]
    type = NumElems
    execute_on = 'initial timestep_end'
  []
  [n_nodes]
    type = NumNodes
    execute_on = 'initial timestep_end'
  []
  [DOFs]
    type = NumDOFs
  []
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
  [./bnd_length]
    type = GrainBoundaryArea
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = PJFNK

  petsc_options_iname = '-pc_type -pc_hypre_type -pc_hypre_boomeramg_strong_threshold'
  petsc_options_value = 'hypre    boomeramg      0.7'

  l_tol = 1.0e-4
  l_max_its = 20
  nl_max_its = 15
  nl_rel_tol = 1.0e-8
  dtmin = 1.0e-4

  start_time = 0.0
  num_steps =  10
  # end_time = 30 # 7200

  [TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.8
    dt = 5.0
    growth_factor = 1.1
    optimal_iterations = 7
  []
  [Adaptivity]
    initial_adaptivity = 3
    refine_fraction = 0.8
    coarsen_fraction = 0.3 #0.05
    max_h_level = 2
  []
[]

[Outputs]
  file_base = ./${my_filename}/out_${my_filename}
  # [./my_checkpoint]
  #   type = Checkpoint
  #   # num_files = 10
  #   # interval = 5
  # [../]
  [my_exodus]
    type = Exodus # Nemesis Exodus
    # interval = 5
  [../]
  print_linear_residuals = false
  
  # perf_graph = true
  csv = true
[]