my_GBmob0 = 2.5e-12
my_length_scale = 1.0e-6
my_time_scale = 1.0 # miu s

my_wGB = 0.5
my_T = 973.15 #K

my_filename = '01_isotropy_sigma0p5'
my_number_adaptivity = 3
my_end_time = 1e4
my_interval = 5

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 12
  ny = 12
  xmin = 0
  xmax = 22
  ymin = 0
  ymax = 22
  elem_type = QUAD4
  
  parallel_type = distributed
[]

[GlobalParams]
  op_num = 2
  var_name_base = gr
  length_scale = ${my_length_scale}
  time_scale = ${my_time_scale}
[]

[Variables]
  [./PolycrystalVariables]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[UserObjects]
  [./euler_angle_file]
    type = EulerAngleFileReader
    file_name = grn_2_rand_2D_45.tex # 45
  [../]
  [./grain_tracker]
    type = GrainTracker
    threshold = 0.2
    connecting_threshold = 0.06
    compute_halo_maps = true # Only necessary for displaying HALOS
    compute_var_to_feature_map = true
  [../]
  [./term]
    type = Terminator
    expression = 'gr0area < 5'
  [../]
[]

[ICs]
  [./PolycrystalICs]
    [./BicrystalCircleGrainIC]
      radius = 8
      x = 11
      y = 11
      int_width = ${my_wGB}
    [../]
  [../]
[]

[AuxVariables]
  [./bounds_dummy]
    order = FIRST
    family = LAGRANGE
  [../]
  [./bnds]
    order = FIRST
    family = LAGRANGE
  [../]  
  [./total_energy_density]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./phi_1]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./Phi]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./phi_2]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
  [./PolycrystalKernel]
  [../]
[]

[BCs]
  [./Periodic]
    [./top_bottom]
      auto_direction = 'x y'
    [../]
  [../]
[]

[AuxKernels]
  [./BndsCalc]
    type = BndsCalcAux
    variable = bnds
    execute_on = timestep_end
  [../]
  [./toal_free_energy]
    type = TotalFreeEnergy # Total free energy (both the bulk and gradient parts)
    f_name = f_loc
    variable = total_energy_density
    kappa_names = 'kappa_op kappa_op'
    interfacial_vars = 'gr0 gr1'
  [../]
  [./phi_1]
    type = OutputEulerAngles
    variable = phi_1
    euler_angle_provider = euler_angle_file
    grain_tracker = grain_tracker
    output_euler_angle = 'phi1'
    #  phi1, Phi, phi2
    execute_on = 'initial timestep_end'
  [../]
  [./Phi]
    type = OutputEulerAngles
    variable = Phi
    euler_angle_provider = euler_angle_file
    grain_tracker = grain_tracker
    output_euler_angle = 'Phi'
    #  phi1, Phi, phi2
    execute_on = 'initial timestep_end'
  [../]
  [./phi_2]
    type = OutputEulerAngles
    variable = phi_2
    euler_angle_provider = euler_angle_file
    grain_tracker = grain_tracker
    output_euler_angle = 'phi2'
    #  phi1, Phi, phi2
    execute_on = 'initial timestep_end'
  [../]
[]

[Materials]
  [./CuGrGranisotropic]
    type = GBAnisotropy
    T = ${my_T} # K
    wGB = ${my_wGB}
    # molar_volume_value = 7.11e-6 #Units:m^3/mol
    Anisotropic_GB_file_name = anisotropy_energy.txt   # anisotropy_energy.txt
    inclination_anisotropy = false # true
    outputs = my_exodus
  [../]
  [./local_free_energy]
    type = DerivativeParsedMaterial
    f_name= f_loc
    args = 'gr0 gr1'
    material_property_names = 'mu gamma_asymm'
    function = 'mu*(gr0^4/4.0 - gr0^2/2.0 + gr1^4/4.0 - gr1^2/2.0 + gamma_asymm*gr0^2*gr1^2+1.0/4.0)'
    derivative_order = 2
    enable_jit = true
    outputs = my_exodus
    output_properties = 'f_loc df_loc/dgr0 df_loc/dgr1'
  [../]
[]

[Postprocessors]
  [./dofs]
    type = NumDOFs
  [../]
  [./dt]
    type = TimestepSize
  [../]
  [./run_time]
    type = PerfGraphData
    section_name = "Root"
    data_type = total
  [../]
  [./gr0area]
    type = ElementIntegralVariablePostprocessor
    variable = gr0
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -pc_hypre_boomeramg_strong_threshold'
  petsc_options_value = 'hypre boomeramg 31 0.7'
  l_tol = 1.0e-4
  l_max_its = 30
  nl_max_its = 25
  nl_rel_tol = 1.0e-7

#   automatic_scaling = true # to improve the convergence of linear solves
  start_time = 0.0
#   end_time = ${my_end_time}
  num_steps = 1000

  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1.5
    growth_factor = 1.2
    cutback_factor = 0.8
    optimal_iterations = 8
  [../]
  [./Adaptivity]
    initial_adaptivity = ${my_number_adaptivity} # 8 
    cycles_per_step = 2 # The number of adaptivity cycles per step
    refine_fraction = 0.5 # The fraction of elements or error to refine.
    coarsen_fraction = 0.05
    max_h_level = ${my_number_adaptivity}
  [../]
[]

[Outputs]
  file_base = ./${my_filename}/out_${my_filename}
  # exodus = true
  csv = true
  [./my_checkpoint]
    type = Checkpoint
    # num_files = 6
    # interval = 2
  [../]
  [./my_exodus]
    type = Nemesis
    interval = ${my_interval} # The interval at which time steps are output
    # sync_times = '10 50 100 500 1000 5000 10000 50000 100000'
    # sync_only = true
  [../]
  [./pgraph]
    type = PerfGraphOutput
    execute_on = 'initial timestep_end final'  # Default is "final"
    level = 2                     # Default is 1
    heaviest_branch = true        # Default is false
    heaviest_sections = 7         # Default is 0
  [../]
  [./my_console]
    type = Console
    output_linear = false
    # output_screen = false
    interval = 5
  [../]
[]
