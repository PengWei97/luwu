my_filename = "05_ebsd"

[Mesh]
  [ebsd_mesh]
    type = EBSDMeshGenerator
    filename = 4_Ti700du_10minFill.inl #4_Ti700du_10minFill.inl #Ti700du_10minFill_3.inl #Small_IN100_4.txt
    # pre_refine = 2
  []
[]

[GlobalParams]
  op_num = 12
  var_name_base = gr
[]

[UserObjects]
  [ebsd_reader]
    type = EBSDReader
    # Load and manage DREAM.3D EBSD data files for running simulations on reconstructed microstructures
    L_norm = 1 # Specifies the type of average the user intends to perform
    # custom_columns = 10 # Number of additional custom data columns to read from the EBSD file
    
    # execute_on = TIMESTEP_END
  []
  [ebsd]
    type = PolycrystalEBSD
    # Object for setting up a polycrystal structure from an EBSD Datafile
    coloring_algorithm = jp
    ebsd_reader = ebsd_reader
    # EBSD Reader for initial condition
    enable_var_coloring = true
    compute_var_to_feature_map = false
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
  [ghost_elements]
    order = CONSTANT
    family = MONOMIAL
  []
  [halos]
    order = CONSTANT
    family = MONOMIAL
  []
  [var_indices_ic]
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
  [ebsd_grains]
    family = MONOMIAL
    order = CONSTANT
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
  [var_indices_ic]
    type = FeatureFloodCountAux
    variable = var_indices_ic
    execute_on = 'initial'
    flood_counter = ebsd
    field_display = VARIABLE_COLORING
  []
  [unique_grains_ic]
    type = FeatureFloodCountAux
    variable = unique_grains_ic
    execute_on = 'initial'
    flood_counter = ebsd
    field_display = UNIQUE_REGION
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
    execute_on = 'initial timestep_end'
    flood_counter = grain_tracker
    field_display = UNIQUE_REGION
  []
  [phi1]
    type = OutputEulerAngles
    variable = phi1
    euler_angle_provider = ebsd_reader
    grain_tracker = grain_tracker
    output_euler_angle = 'phi1'
    execute_on = 'initial'
  []
  [Phi]
    type = OutputEulerAngles
    variable = Phi
    euler_angle_provider = ebsd_reader
    grain_tracker = grain_tracker
    output_euler_angle = 'Phi'
    execute_on = 'initial'
  []
  [phi2]
    type = OutputEulerAngles
    variable = phi2
    euler_angle_provider = ebsd_reader
    grain_tracker = grain_tracker
    output_euler_angle = 'phi2'
    execute_on = 'initial'
  []
  [grain_aux]
    type = EBSDReaderPointDataAux
    variable = ebsd_grains
    ebsd_reader = ebsd_reader
    data_name = 'feature_id'
    execute_on = 'initial timestep_end'
  []
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
  # [Copper]
  #   # T = 500 # K
  #   type = GBEvolution
  #   T = 500
  #   wGB = 0.5 # um
  #   GBmob0 = 2.5e-6 # m^4/(Js) from Schoenfelder 1997
  #   Q = 0.23 # Migration energy in eV
  #   GBenergy = 0.708 # GB energy in J/m^2
  #   molar_volume = 7.11e-6 # Molar volume in m^3/mol
  #   length_scale = 1.0e-6
  #   time_scale = 1.0e-6
  # []
  [CuGrGranisotropic]
    type = GBAnisotropyGrainGrowth
    type_crystalline = hcp
    grain_tracker = grain_tracker
    euler_angle_provider = ebsd_reader 
    T = 450 # K

    inclination_anisotropy = false # true
    gbEnergy_anisotropy = true # true false
    gbMobility_anisotropy = false

    GBmob_HAB = 2.5e-6
    GBsigma_HAB = 0.708
    GBQ_HAB = 0.23

    rate1_HABvsLAB_mob = 0.0
    rate2_HABvsLAB_mob = 1.0
    rate1_HABvsLAB_sigma = 0.3
    rate2_HABvsLAB_sigma = 0.7
    wGB = 0.5
    length_scale = 1.0e-6
    time_scale = 1.0e-6

    output_properties = 'kappa_op L mu gamma_asymm delta_theta'
    outputs = my_exodus
  []
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
  num_steps = 1000

  [TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.9
    dt = 7.0
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
    type = Exodus
    interval = 5
  [../]
  print_linear_residuals = false
  
  checkpoint = true
  perf_graph = true
  csv = true
[]