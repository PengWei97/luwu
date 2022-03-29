#  tri-grain model,500K,stretch 5%,left right fixed
#  1000*600,gr0 gr1 gr2
#  add Stress component
#  hcp
# 各向同性弹性模量
# tar -cvf - Free2000_T_01.e-s??0 Free2000_T_01.e-s???0 | pigz -9 -p 10 > Free2000_T_01_exodus.tgz
#  tar -cvf - Free2000_T_01_grain_volumes_???[05].csv | pigz -9 -p 10 > Free2000_T_01_csv.tgz
my_GBmob0 = 2.5e-6
my_length_scale = 1.0e-9
my_time_scale = 1.0e-9 # miu s
my_wGB = 15 # nm
my_T = 500
my_filename = 'GG_bicrystal_circular_2_nm_isoElastic_results'
my_number_adaptivity = 3

# my_GBMobility = 1.0e-12 # m^4/(Js) 1.0e-10
my_end_time = 40000000
# my_interval = 2 
my_model_length = 64e1
my_center_coord = 32e1
my_radius = 20e1
my_displacement = 0 #3.2e1 # 25.0e2 # 10 10 2% 500*5%

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 32
  ny = 32
  xmin = 0
  xmax = ${my_model_length}
  ymin = 0
  ymax = ${my_model_length}
  elem_type = QUAD4
  
  parallel_type = distributed
[]

[GlobalParams]
  op_num = 2
  var_name_base = gr
[]

[Variables]
  [./PolycrystalVariables]
  [../]
  [./disp_x]
    order = FIRST
    family = LAGRANGE
    # scaling = 1.0e4 #Scales residual to improve convergence 
  [../]
  [./disp_y]
    order = FIRST
    family = LAGRANGE
    # scaling = 1.0e4 #Scales residual to improve convergence 
  [../]
[]

# [Bounds]
#   [./gr0_upper_bound]
#     type = ConstantBoundsAux
#     variable = bounds_dummy
#     bounded_variable = gr0
#     bound_type = upper
#     bound_value = 1.0
#     execute_on = 'INITIAL LINEAR NONLINEAR TIMESTEP_END TIMESTEP_BEGIN FINAL'
#   [../]
#   [./gr0_lower_bound]
#     type = ConstantBoundsAux
#     variable = bounds_dummy
#     bounded_variable = gr0
#     bound_type = lower
#     bound_value = 0.0
#     execute_on = 'INITIAL LINEAR NONLINEAR TIMESTEP_END TIMESTEP_BEGIN FINAL'
#   [../]
#   [./gr1_upper_bound]
#     type = ConstantBoundsAux
#     variable = bounds_dummy
#     bounded_variable = gr1
#     bound_type = upper
#     bound_value = 1.0
#     execute_on = 'INITIAL LINEAR NONLINEAR TIMESTEP_END TIMESTEP_BEGIN FINAL'
#   [../]
#   [./gr1_lower_bound]
#     type = ConstantBoundsAux
#     variable = bounds_dummy
#     bounded_variable = gr1
#     bound_type = lower
#     bound_value = 0.0
#     execute_on = 'INITIAL LINEAR NONLINEAR TIMESTEP_END TIMESTEP_BEGIN FINAL'
#   [../]
# []


[UserObjects]
  [./euler_angle_file]
    type = EulerAngleFileReader
    file_name = grn_2_rand_2D.tex
  [../]
  [./grain_tracker]
    type = GrainTrackerElasticity
    threshold = 0.2
    compute_var_to_feature_map = true
    execute_on = 'initial timestep_begin'
    flood_entity_type = ELEMENTAL

    C_ijkl = '1.27e5 0.708e5 0.708e5 1.27e5 0.708e5 1.27e5 0.7355e5 0.7355e5 0.7355e5'
    # C_ijkl = '1.94e5 0.655e5 0.698e5 1.94e5 0.698e5 1.98e5 0.4627e5 0.4627e5 0.6435e5' # Titanium,2,0Pa，可行
    # C_ijkl = '1.27e5 0.708e5 0.708e5 1.27e5 0.708e5 1.27e5 0.281e5 0.281e5 0.281e5' # isotropic elastic tensor
    
    fill_method = symmetric9
    euler_angle_provider = euler_angle_file
  [../]
[]

[ICs]
  [./PolycrystalICs]
    [./BicrystalCircleGrainIC]
      radius = ${my_radius}
      x = ${my_center_coord}
      y = ${my_center_coord}
      int_width = 15
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
  [./grad_energy_density]
    order = CONSTANT
    family = MONOMIAL
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
  [./stress11]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress12]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress22]
    order = CONSTANT
    family = MONOMIAL
  [../]
#   [./unique_grains]
#     order = CONSTANT
#     family = MONOMIAL
#   [../]
#   [./var_indices]
#     order = CONSTANT
#     family = MONOMIAL
#   [../]
  [./vonmises_stress]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./C1111]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./euler_angle]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
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
  [./BndsCalc]
    type = BndsCalcAux
    variable = bnds
    execute_on = timestep_end
  [../]
  [./local_free_energy]
    type = TotalFreeEnergy
    f_name = f_chem
    variable = total_energy_density
    kappa_names = 'kappa_op kappa_op'
    interfacial_vars = 'gr0 gr1'
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
  [./stress11]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress11
    index_i = 0
    index_j = 0
  [../]
  [./stress12]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress12
    index_i = 0
    index_j = 1
  [../]
  [./stress22]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress22
    index_i = 1
    index_j = 1
  [../]
#   [./unique_grains]
#     type = FeatureFloodCountAux
#     variable = unique_grains
#     execute_on = timestep_end
#     flood_counter = grain_tracker
#     field_display = UNIQUE_REGION
#   [../]
#   [./var_indices]
#     type = FeatureFloodCountAux
#     variable = var_indices
#     execute_on = timestep_end
#     flood_counter = grain_tracker
#     field_display = VARIABLE_COLORING
#   [../]
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
  [./Periodic]
    [./All]
      auto_direction = 'x'
      variable = 'gr0 gr1'
    [../]
  [../]
  [./top_displacement]
    type = DirichletBC
    variable = disp_y
    boundary = top
    value = ${my_displacement} # 500
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
  [./Copper]
    type = GBEvolution
    block = 0
    T = ${my_T} # K
    wGB = ${my_wGB} # nm
    GBmob0 = ${my_GBmob0} # m^4/(Js) from Schoenfelder 1997
    Q = 0.23 # Migration energy in eV
    GBenergy = 0.708 # GB energy in J/m^2
    time_scale = ${my_time_scale}
    length_scale = ${my_length_scale}
    # GBMobility = ${my_GBMobility}
    outputs = my_exodus
    output_properties = 'kappa_op L mu gamma_asymm sigma M_GB l_GB'
  [../]
  [./ElasticityTensor]
    type = ComputePolycrystalElasticityTensor
    grain_tracker = grain_tracker
    length_scale = ${my_length_scale}
    # time_scale = ${my_time_scale}
    # outputs = my_exodus
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
  # [./elasticenergy]
  #   type = ElasticEnergyMaterial
  #   args = 'gr1 gr0'
	#   outputs = my_exodus
  # [../]
  [./local_free_energy]
    type = DerivativeParsedMaterial
    f_name= f_chem
    args = 'gr0 gr1'
    material_property_names = 'mu gamma_asymm'
    function = 'mu*(gr0^4/4.0 - gr0^2/2.0 + gr1^4/4.0 - gr1^2/2.0 + gamma_asymm*gr0^2*gr1^2+1.0/4.0)'
    derivative_order = 2
    enable_jit = true
    outputs = my_exodus
    output_properties = 'f_chem df_chem/dgr0 df_chem/dgr1'
  [../]
  [./elastic_free_energy]
    type = ElasticEnergyMaterial
    f_name = f_elastic
    block = 0
    args = 'gr0 gr1'
    outputs = my_exodus
    output_properties = 'f_elastic df_elastic/dgr0 df_elastic/dgr1'
  [../]
[]

[Postprocessors]
#   [./ngrains]
#     type = FeatureFloodCount
#     variable = bnds
#     threshold = 0.7
#   [../]
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
  # [./F_elastic]
  #   type = ElementIntegralMaterialProperty
  #   mat_prop = f_elastic
  # [../]
  # [./F_chem]
  #   type = ElementIntegralMaterialProperty
  #   mat_prop = f_chem
  #   outputs = csv
  # [../]
[]

# [Debug]
#   show_var_residual_norms = true
# []

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
  l_tol = 1.0e-4
  l_max_its = 30
  nl_max_its = 25
  nl_rel_tol = 1.0e-7

#   automatic_scaling = true # to improve the convergence of linear solves
  start_time = 0.0
  end_time = ${my_end_time}

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
    num_files = 6
    interval = 2
  [../]
  [./my_exodus]
    type = Nemesis
    # interval = ${my_interval} # The interval at which time steps are output
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
[]
