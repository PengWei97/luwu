[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 3
  xmax = 1000
  ymax = 1000
  elem_type = QUAD4
  uniform_refine = 2
  # skip_partitioning = true
[]

[GlobalParams]
  op_num = 2
  var_name_base = gr
[]

[Variables]
  [./PolycrystalVariables]
  [../]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
[]

[ICs]
  [./PolycrystalICs]
    [./BicrystalBoundingBoxIC]
      x1 = 0
      y1 = 0
      x2 = 500
      y2 = 1000
    [../]
    # Custom crystal model
  [../]
[]

[AuxVariables]
  # [./bnds]
  #   order = FIRST
  #   family = LAGRANGE
  # [../]
  # [./elastic_strain11]
  #   order = CONSTANT
  #   family = MONOMIAL
  # [../]
  # [./elastic_strain22]
  #   order = CONSTANT
  #   family = MONOMIAL
  # [../]
  # [./elastic_strain12]
  #   order = CONSTANT
  #   family = MONOMIAL
  # [../]
  # [./unique_grains]
  #   order = CONSTANT
  #   family = MONOMIAL
  # [../]
  # [./var_indices]
  #   order = CONSTANT
  #   family = MONOMIAL
  # [../]
  # [./C1111]
  #   order = CONSTANT
  #   family = MONOMIAL
  # [../]
  # [./active_bounds_elemental]
  #   # ？？
  #   order = CONSTANT
  #   family = MONOMIAL
  # [../]
  # [./euler_angle]
  #   order = CONSTANT
  #   family = MONOMIAL
  # [../]
[]

[Kernels]
  [./PolycrystalKernel]
  [../]
  [./PolycrystalElasticDrivingForce]
    # adds the elastic driving force for each order parameter
    # Input:op_num = 2,var_name_base = gr
    # output:D_stiff_name = delasticity_tensor/dgr0,delasticity_tensor/dgr1
    # call:ACGrGrElasticDrivingForce
      # Calculates the porton of the Allen-Cahn equation that results from the deformation energy.
      # public:ACBulk
      # Input:_D_elastic_tensor,_elastic_strain
        # get: _D_elastic_tensor <-- ComputePolycrystalElasticityTensor,
        # get:_elastic_strain <-- ComputeLinearElasticStress
  [../]
  [./TensorMechanics]
    displacements = 'disp_x disp_y'
  [../]
[]

[AuxKernels]
  # [./bnds_aux]
  #   type = BndsCalcAux
  #   variable = bnds
  #   execute_on = timestep_end
  # [../]
  # [./elastic_strain11]
  #   type = RankTwoAux
  #   variable = elastic_strain11
  #   rank_two_tensor = elastic_strain
  #   index_i = 0
  #   index_j = 0
  #   execute_on = timestep_end
  # [../]
  # [./elastic_strain22]
  #   type = RankTwoAux
  #   variable = elastic_strain22
  #   rank_two_tensor = elastic_strain
  #   index_i = 1
  #   index_j = 1
  #   execute_on = timestep_end
  # [../]
  # [./elastic_strain12]
  #   type = RankTwoAux
  #   variable = elastic_strain12
  #   rank_two_tensor = elastic_strain
  #   index_i = 0
  #   index_j = 1
  #   execute_on = timestep_end
  # [../]
  # [./unique_grains]
  #   type = FeatureFloodCountAux
  #   variable = unique_grains
  #   flood_counter = grain_tracker
  #   execute_on = 'initial timestep_begin'
  #   field_display = UNIQUE_REGION
  # [../]
  # [./var_indices]
  #   type = FeatureFloodCountAux
  #   variable = var_indices
  #   flood_counter = grain_tracker
  #   execute_on = 'initial timestep_begin'
  #   field_display = VARIABLE_COLORING
  # [../]
  # [./C1111]
  #   type = RankFourAux
  #   variable = C1111
  #   rank_four_tensor = elasticity_tensor
  #   index_l = 0
  #   index_j = 0
  #   index_k = 0
  #   index_i = 0
  #   execute_on = timestep_end
  # [../]
  # [./active_bounds_elemental]
  #   type = FeatureFloodCountAux
  #   variable = active_bounds_elemental
  #   field_display = ACTIVE_BOUNDS
  #   execute_on = 'initial timestep_begin'
  #   flood_counter = grain_tracker
  # [../]
  # [./euler_angle]
  #   type = OutputEulerAngles
  #   variable = euler_angle
  #   euler_angle_provider = euler_angle_file
  #   # Name of Euler angle provider user object
  #   grain_tracker = grain_tracker
  #   # The GrainTracker UserObject to get values from.
  #   output_euler_angle = 'phi1'
  #   # "phi1 Phi phi2
  # [../]
[]

[BCs]
  [./top_displacement]
    type = DirichletBC
    variable = disp_y
    boundary = top
    value = -10.0
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
    T = 500 # K
    wGB = 75 # nm
    GBmob0 = 2.5e-6 #m^4/(Js) from Schoenfelder 1997
    Q = 0.23 #Migration energy in eV
    GBenergy = 0.708 #GB energy in J/m^2
    time_scale = 1.0e-6 # μs
    # length_scale = 1.0e-9 # nm
  [../]
  [./ElasticityTensor]
    type = ComputePolycrystalElasticityTensor
      # Compute an evolving elasticity tensor coupled to a grain growth phase field model.
      # public: ComputeElasticityTensorBase
    # length_scale = 1.0e-9
    # pressure_scale = 1.0e6
    grain_tracker = grain_tracker
    # grain_tracker_euler = grain_tracker_euler
    # Input the elasticity modulus after rotation
      # Name of GrainTracker user object that provides RankFourTensors  
    outputs = exodus

    # input: c_ijkl rotationed <--grain_tracker
    # output: elasticity_tensor_ijkl,dElasticity_Tensor/dgr0_ijkl，dElasticity_Tensor/dgr1_ijkl
  [../]
  [./strain]
    type = ComputeSmallStrain # ComputeFiniteStrain
    # Input: grad_tensor 
    # Output: mechanical_strain_ij,total_strain_ij
      # _total_strain[_qp] = (grad_tensor + grad_tensor.transpose()) / 2.0;
      # _mechanical_strain[_qp] = _total_strain[_qp];

    block = 0
    displacements = 'disp_x disp_y'
    # outputs = exodus
  [../]
  [./stress]
    type = ComputeLinearElasticStress # ComputeFiniteStrainElasticStress
      # output:elastic_strain_ij,stress_ij,jocabian_mult_ij(dstress_dstrain)
    block = 0
  [../]
[]

[UserObjects]
  [./euler_angle_file]
    type = EulerAngleFileReader
    file_name = test.tex
  [../]
  [./grain_tracker]
    type = GrainTrackerElasticity
    # The elastic modulus after rotation is assigned to the grain
    # postprocessor why ?
    # Manage a list of elasticity tensors for the grains
    connecting_threshold = 0.05
    compute_var_to_feature_map = true
    flood_entity_type = elemental
    execute_on = 'initial timestep_begin'

    euler_angle_provider = euler_angle_file
    # <--UserObjects/euler_angle_file
    fill_method = symmetric9
    C_ijkl = '1.27e5 0.708e5 0.708e5 1.27e5 0.708e5 1.27e5 0.7355e5 0.7355e5 0.7355e5'
    # output:C_ijkl rotationed for every grain
    output = exodus
  [../]
  # [./grain_tracker_euler]
  #   type = GrainTrackerElasticityPW
    
  #   connecting_threshold = 0.05
  #   compute_var_to_feature_map = true
  #   flood_entity_type = elemental
  #   execute_on = 'initial timestep_begin'

  #   euler_angle_provider = euler_angle_file
  # [../]
  # [./grain_tracker_rot]
  #   type = GrainTrackerElasticityPWRot
  #   # The elastic modulus after rotation is assigned to the grain
  #   # postprocessor why ?
  #   # Manage a list of elasticity tensors for the grains
  #   connecting_threshold = 0.05
  #   compute_var_to_feature_map = true
  #   flood_entity_type = elemental
  #   execute_on = 'initial timestep_begin'

  #   euler_angle_provider = euler_angle_file
  #   # <--UserObjects/euler_angle_file
  #   # fill_method = symmetric9
  #   # C_ijkl = '1.27e5 0.708e5 0.708e5 1.27e5 0.708e5 1.27e5 0.7355e5 0.7355e5 0.7355e5'
  #   # # output:C_ijkl rotationed for every grain
  # [../]
  # materials/ComputePolycrystalElasticityTensor
    # public:ComputeElasticityTensorBase
    # Output: dElasticity_Tensor/dgr*_ijkl
    # Output: effective_stiffness 
    # Output: elasticity_tensor_ijkl
    # Input: Stiffness matrix after rotation and order parameter gr* 

  # materials/ComputeSmallStrain
    # public:ComputeStrainBase
    # Output: mechanical_strain_ij = total_strain_ij
    # Output: total_strain_ij = (grad_disp + grad_disp^T)/2
    # Input: grad_disp

  # materials/ComputeLinearElasticStress
    # public:ComputeElasticityTensor
    # Output: elastic_strain_ij = _mechanical_strain[_qp];
    # Output: stress_ij; _stress[_qp] = _elasticity_tensor[_qp] * _mechanical_strain[_qp];
    # Output: jocabian_mult_ijkl(dstress_dstrain) = _elasticity_tensor[_qp]
    # Input: _elasticity_tensor[_qp],_mechanical_strain[_qp]
[]

[Postprocessors]
  [./dt]
    type = TimestepSize
  [../]
  [./gr0_area]
    type = ElementIntegralVariablePostprocessor
    variable = gr0
  [../]
  [./run_time]
    type = PerfGraphData
    section_name = "Root"
    data_type = total
  [../]
[]

[Preconditioning]
  [./SMP]
   type = SMP
   coupled_groups = 'gr0,gr1 disp_x,disp_y'
  [../]
[]

[Executioner]
  type = Transient

  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -pc_hypre_boomeramg_strong_threshold'
  petsc_options_value = 'hypre boomeramg 31 0.7'

  l_max_its = 30
  l_tol = 1e-4
  nl_max_its = 30
  nl_rel_tol = 1e-9

  start_time = 0.0
  num_steps = 3
  dt = 0.2

  [./Adaptivity]
   initial_adaptivity = 2
    refine_fraction = 0.7
    coarsen_fraction = 0.1
    max_h_level = 2
  [../]
[]

[Outputs]
  execute_on = 'timestep_end'
  exodus = true
[]

