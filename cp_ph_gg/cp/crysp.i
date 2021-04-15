[Mesh]
  type = GeneratedMesh
  dim = 3
  elem_type = HEX8
  displacements = 'ux uy uz'
  # The nonlinear displacement variables for the problem
[]

[Variables]
  [./ux]
    block = 0
  [../]
  [./uy]
    block = 0
  [../]
  [./uz]
    block = 0
  [../]
[]

[AuxVariables]
  # [./stress_zz]
  #   order = CONSTANT
  #   family = MONOMIAL
  #   # vs LANGUAGE??
  #   block = 0
  # [../]
  # [./fp_zz] # Plastic deformation gradient of previous increment
  # # <--materials\FiniteStrainCrystalPlasticity.C
  #   order = CONSTANT
  #   family = MONOMIAL
  #   block = 0
  # [../]
  # [./rotout]
  #   order = CONSTANT
  #   family = MONOMIAL
  #   block = 0
  # [../]
  # [./e_zz]
  #   order = CONSTANT
  #   family = MONOMIAL
  #   block = 0
  # [../]
  # [./gss1]
  #   order = CONSTANT
  #   family = MONOMIAL
  #   block = 0
  # [../]
[]

[Functions]
  [./tdisp]
    type = ParsedFunction
    value = 0.01*t
  [../]
[]

[Kernels]
  [./TensorMechanics]
    displacements = 'ux uy uz'
    use_displaced_mesh = true
    # Large Deformation (both Elasticity and Inelasticity)	Deformed mesh (current)
    # Stress divergence kernel for the Cartesian coordinate system
    # This kernel can be automatically created with the TensorMechanics Master Action.
  [../]
[]

[AuxKernels]
  # [./stress_zz]
  #   type = RankTwoAux
  #   variable = stress_zz
  #   rank_two_tensor = stress
  #   index_j = 2
  #   index_i = 2
  #   execute_on = timestep_end
  #   block = 0
  # [../]
  # [./fp_zz] # Plastic deformation gradient of previous increment
  #   type = RankTwoAux
  #   variable = fp_zz
  #   rank_two_tensor = fp
  #   index_j = 2
  #   index_i = 2
  #   execute_on = timestep_end
  #   block = 0
  # [../]
  # [./e_zz]
  #   type = RankTwoAux
  #   variable = e_zz
  #   rank_two_tensor = lage # Lagrangian strain
  #   index_j = 2
  #   index_i = 2
  #   execute_on = timestep_end
  #   block = 0
  # [../]
  # [./gss1]
  #   type = MaterialStdVectorAux
  #   # Extracting SDV from material modules
  #   variable = gss1 # Slip system resistances of previous increment
  #   property = gss
  #   index = 0
  #   execute_on = timestep_end
  #   block = 0
  # [../]
[]

[BCs]
  [./symmy]
    type = DirichletBC
    variable = uy
    boundary = bottom
    value = 0
  [../]
  [./symmx]
    type = DirichletBC
    variable = ux
    boundary = left
    value = 0
  [../]
  [./symmz]
    type = DirichletBC
    variable = uz
    boundary = back
    value = 0
  [../]
  [./tdisp]
    type = FunctionDirichletBC
    variable = uz
    boundary = front
    function = tdisp
  [../]
[]

[Materials]
  [./crysp]
    # Calculated stress
    type = FiniteStrainCrystalPlasticity
    # /**
    # * FiniteStrainCrystalPlasticity uses the multiplicative decomposition of deformation gradient
    # * and solves the PK2 stress residual equation at the intermediate configuration to evolve the
    # * material state.
    # * The internal variables are updated using an interative predictor-corrector algorithm.
    # * Backward Euler integration rule is used for the rate equations.
    # */
    # power law flow rule
    #     _slip_incr(i) = _a0(i) * std::pow(std::abs(_tau(i) / _gss_tmp[i]), 1.0 / _xm(i)) *
                    # std::copysign(1.0, _tau(i)) * _dt;
    # https://mooseframework.inl.gov/bison/source/materials/FiniteStrainCPSlipRateRes.html

    block = 0 # The list of block ids (SubdomainID) that this object will be applied
    gtol = 1e-2 # Constitutive slip system resistance residual tolerance  
    slip_sys_file_name = input_slip_sys.txt # 12 slip system for fcc
    nss = 12 # Number of slip systems
    num_slip_sys_flowrate_props = 2 # Number of properties in a slip system
    # Number of flow rate properties for a slip system
    # Used for reading flow rate parameters

    flowprops = '1 4 0.001 0.1 5 8 0.001 0.1 9 12 0.001 0.1'
    # 1-4,a0,xm
    # 1-4,alpha_0,m
    # Parameters used in slip rate equations

    hprops = '1.0 541.5 60.8 109.8 2.5'
    # Hardening properties
    # -r _h0 tau_init tau_sat a
    # q h0 tau_c tau_s alpha

    gprops = '1 4 60.8 5 8 60.8 9 12 60.8'
    # _gss,tau_c_init
    # Initial values of slip system resistances

    # slip_sys_res_prop_file_name = input_slip_sys_res.txt
    # intvar_read_type = slip_sys_res_file

    tan_mod_type = exact
    # Type of tangent moduli for preconditioner: default elastic
    # gen_random_stress_flag = true
    # # Flag to generate random stress to perform time cutback on constitutive failure
    
    # use_line_search = true
    # min_line_search_step_size = 0.01
    # Use line search in constitutive update

    # maximum_substep_iteration = 2
    # Maximum number of substep iteration    
    outputs = exodus
  [../]
  [./elasticity_tensor]
    type = ComputeElasticityTensorCP
    block = 0
    C_ijkl = '1.684e5 1.214e5 1.214e5 1.684e5 1.214e5 1.684e5 0.754e5 0.754e5 0.754e5'
    fill_method = symmetric9

  [../]
  [./strain]
    type = ComputeFiniteStrain
    block = 0
    displacements = 'ux uy uz'
    # outputs = exodus
  [../]

  # materials/ComputeElasticityTensorCP
    # public:ComputeElasticityTensor
    # Output: srysrot_ij = R(Euler1,Euler2,Euler3)
    # Output: effective_stiffness 
    # Output: elasticity_tensor_ijkl 
    # Input: Euler angle and stiffness matrix without rotation

  # materials/ComputeFiniteStrain
    # public:ComputeIncrementalStrainBase
    # Output: mechanics_strain_ij 
    # Output: total_strain_ij 
    # Output: rotation_increment_ij
    # Output: strain_increment_ij
    # Output: strain_rate_ij
    # Output: deformation_gradient_ij
    # Input: grad_disp，Calculation of deformation increment

  # materials/FiniteStrainCrystalPlasticity
    # public:ComputeElasticityTensor
    # Output: elastic_strain_ij 
    # Output: stress_ij 
    # Output: jocabian_mult_ijkl(dstress_dstrain)
    # Output: acc_slip
    # Output: lage_ij
    # Output: fp_ij
    # Output: pk2_ij
    # Output: up_rot_ij
    # Input: From the calculation of elastic tensor module: _elasticity_ tensor，_crysrot
[]

[Postprocessors]
  # [./stress_zz]
  #   type = ElementAverageValue
  #   variable = stress_zz
  #   block = 'ANY_BLOCK_ID 0'
  # [../]
  # [./fp_zz]
  #   type = ElementAverageValue
  #   variable = fp_zz
  #   block = 'ANY_BLOCK_ID 0'
  # [../]
  # [./e_zz]
  #   type = ElementAverageValue
  #   variable = e_zz
  #   block = 'ANY_BLOCK_ID 0'
  # [../]
  # [./gss1]
  #   type = ElementAverageValue
  #   variable = gss1
  #   block = 'ANY_BLOCK_ID 0'
  # [../]
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient

  #Preconditioned JFNK (default)
  solve_type = 'PJFNK'

  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-10

  dt = 0.05
  dtmax = 10.0
  dtmin = 0.05

  num_steps = 10
[]

[Outputs]
  file_base = out
  exodus = true
  # file_base = crysp_cutback_out
  # gnuplot = true
  # gnuplot is a command-line program that can generate two- 
  # and three-dimensional plots of functions, data, and data fits. 
  # # Output for postprocessors and scalar variables in GNU plot format.
[]

# If you cancel the all output, the Exodus file will output U (displacement)


