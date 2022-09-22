# my_filename = "03_local_ebsd_misori" # total_Ti700du_5minFill_refine_1 sigma = 0.02
# my_filename = "07_local_ebsd_misori_GBanisotropy" # total_Ti700du_5minFill_refine_1 sigma = 0.2 gb_width = 0.4
my_filename = "09_local_ebsd_misori_GBanisotropy" # total_Ti700du_5minFill_refine_1 sigma = 0.2 gb_width = 0.5

my_interval = 5

[Mesh]
  [ebsd_mesh]
    type = EBSDMeshGenerator
    filename = local_Ti700du_5minFill_refine_1.inl #total_Ti700du_10minFill.inl
  []
[]

[GlobalParams]
  op_num = 18
  var_name_base = gr
[]

[UserObjects]
  [ebsd_reader]
    type = EBSDReader
    # Load and manage DREAM.3D EBSD data files for running simulations on reconstructed microstructures
    # L_norm = 1 # Specifies the type of average the user intends to perform
    # custom_columns = 1 # Number of additional custom data columns to read from the EBSD file 自定义数据的数目
    
    execute_on = 'initial' #  timestep_begin
  []
  [ebsd]
    type = PolycrystalEBSD
    # Object for setting up a polycrystal structure from an EBSD Datafile
    coloring_algorithm = jp
    ebsd_reader = ebsd_reader
    # EBSD Reader for initial condition
    enable_var_coloring = true
    compute_var_to_feature_map = false
    execute_on = 'initial'
    # Instruct the Postprocessor to compute the active vars to features map
  []
  [grain_tracker]
    type = GrainTracker
    # to reduce the number of order parameters needed to model a large polycrystal system.
    flood_entity_type = ELEMENTAL
    compute_halo_maps = true # For displaying HALO fields
    polycrystal_ic_uo = ebsd
    compute_var_to_feature_map = true
  []
  [./term]
    type = Terminator
    expression = 'grain_tracker < 5'
  [../]
[]

[ICs]
  [PolycrystalICs]
    [PolycrystalColoringIC]
      polycrystal_ic_uo = ebsd
    []
  []
[]

[Variables]
  [PolycrystalVariables]
  []
[]

[AuxVariables]
  [bnds]
  []
  [unique_grains_ic]
    order = CONSTANT
    family = MONOMIAL
  []
  [unique_grains]
    order = CONSTANT
    family = MONOMIAL
  []
  # [ghost_elements]
  #   order = CONSTANT
  #   family = MONOMIAL
  # []
  # [halos]
  #   order = CONSTANT
  #   family = MONOMIAL
  # []
  # [var_indices_ic]
  #   order = CONSTANT
  #   family = MONOMIAL
  # []
  # [var_indices]
  #   order = CONSTANT
  #   family = MONOMIAL
  # []
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
  # [ebsd_grains]
  #   family = MONOMIAL
  #   order = CONSTANT
  # []
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
  # [ghost_elements]
  #   type = FeatureFloodCountAux
  #   variable = ghost_elements
  #   field_display = GHOSTED_ENTITIES
  #   execute_on = 'initial timestep_end'
  #   flood_counter = grain_tracker
  # []
  # [halos]
  #   type = FeatureFloodCountAux
  #   variable = halos
  #   field_display = HALOS
  #   execute_on = 'initial timestep_end'
  #   flood_counter = grain_tracker
  # []
  # [var_indices_ic]
  #   type = FeatureFloodCountAux
  #   variable = var_indices_ic
  #   execute_on = 'initial'
  #   flood_counter = ebsd
  #   field_display = VARIABLE_COLORING
  # []
  [unique_grains_ic]
    type = FeatureFloodCountAux
    variable = unique_grains_ic
    execute_on = 'initial'
    flood_counter = ebsd
    field_display = UNIQUE_REGION
  []
  # [var_indices]
  #   type = FeatureFloodCountAux
  #   variable = var_indices
  #   execute_on = 'initial timestep_end'
  #   flood_counter = grain_tracker
  #   field_display = VARIABLE_COLORING
  # []
  [unique_grains]
    type = FeatureFloodCountAux
    variable = unique_grains
    # execute_on = 'initial timestep_end'
    flood_counter = grain_tracker
    field_display = UNIQUE_REGION
  []
  [phi1]
    type = OutputEulerAngles
    variable = phi1
    euler_angle_provider = ebsd_reader
    grain_tracker = grain_tracker
    output_euler_angle = 'phi1'
    # execute_on = 'initial'
  []
  [Phi]
    type = OutputEulerAngles
    variable = Phi
    euler_angle_provider = ebsd_reader
    grain_tracker = grain_tracker
    output_euler_angle = 'Phi'
    # execute_on = 'initial'
  []
  [phi2]
    type = OutputEulerAngles
    variable = phi2
    euler_angle_provider = ebsd_reader
    grain_tracker = grain_tracker
    output_euler_angle = 'phi2'
    # execute_on = 'initial'
  []
  # [grain_aux] # exection = TIMESTEP_END
  #   type = EBSDReaderPointDataAux
  #   variable = ebsd_grains # 位错密度
  #   ebsd_reader = ebsd_reader
  #   data_name = 'feature_id' # custom feature_id CUSTOM0 CUSTOM0 Rho Rho0 CUSTOM0
  #   execute_on = 'initial timestep_end' 
  # []
[]

[Modules]
  [PhaseField]
    [EulerAngles2RGB]
      # EulerAngle2RGBAction
      # Set up auxvariables and auxkernels to output Euler angles as RGB values interpolated across inverse pole figure
      crystal_structure = hexagonal # hexagonal cubic 
      euler_angle_provider = ebsd_reader
      grain_tracker = grain_tracker
    []
  []
[]

[Materials]
  [Copper]
    # T = 500 # K
    type = GBEvolution
    T = 500
    wGB = 0.5 # um
    GBmob0 = 2.5e-6 # m^4/(Js) from Schoenfelder 1997
    Q = 0.23 # Migration energy in eV
    GBenergy = 0.5 # GB energy in J/m^2
    molar_volume = 7.11e-6 # Molar volume in m^3/mol
    length_scale = 1.0e-6
    time_scale = 1.0e-6

    output_properties = 'kappa_op L mu gamma_asymm sigma M_GB'
    outputs = my_exodus
  []
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

  start_time = 0.0
  num_steps = 1e5

  [TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.8
    dt = 0.1
    growth_factor = 1.1
    optimal_iterations = 7
  []

  [Adaptivity]
    initial_adaptivity = 2
    refine_fraction = 0.8
    coarsen_fraction = 0.3 #0.05
    max_h_level = 2
  []
[]

[Outputs]
  file_base = ./${my_filename}/out_${my_filename}
  [my_exodus]
    type = Nemesis # Nemesis Exodus
    interval = ${my_interval}
  [../]
  print_linear_residuals = false
  
  [./my_checkpoint]
    type = Checkpoint
    # num_files = 10
    interval = ${my_interval}
  [../]
  perf_graph = true
  csv = true
[]