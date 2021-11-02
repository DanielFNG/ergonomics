function solution = predictSitToStand(X)

    % Load the Moco libraries
    import org.opensim.modeling.*;

    % Define the optimal control problem
    % ==================================
    study = MocoStudy();
    study.setName('sitToStandPrediction');

    problem = study.updProblem();
    %input_model = '2D_gait_scaled_contact.osim';
    %input_model = '2D_gait_scaled_contact_constrained.osim';
    input_model = '2D_gait_contact_constrained_activation.osim';
    modelProcessor = ModelProcessor(input_model);
    problem.setModelProcessor(modelProcessor);

    % Goals
    % =====

    model = modelProcessor.process();
    model.initSystem();

    % Effort over distance
    effortGoal = MocoControlGoal('effort', X.w_effort);
    effortGoal.setDivideByDisplacement(true); % This slightly increased
    % objective cost, but reduces iterations required. Maybe do further
    % testing, but for now going to keep it in
    effortGoal.setExponent(2); % Tested 2 > 3 for performance
    problem.addGoal(effortGoal);

    % Fixed foot placement
    fixed_states = 'adjusted_reference_StatesReporter_states.sto';
    footPlacementGoal = MocoTranslationTrackingGoal('no_slip', X.w_translation);
    tableProcessor = TableProcessor(fixed_states);
    footPlacementGoal.setStatesReference(tableProcessor);
    frames = org.opensim.modeling.StdVectorString();
    frames.add('/bodyset/calcn_r');
    frames.add('/bodyset/calcn_l');
    footPlacementGoal.setFramePaths(frames);
    problem.addGoal(footPlacementGoal);

%     % Fixed foot orientation
%     footOrientationGoal = MocoOrientationTrackingGoal('no_rotate', X.w_rotation);
%     footOrientationGoal.setStatesReference(tableProcessor);
%     footOrientationGoal.setFramePaths(frames);
%     problem.addGoal(footOrientationGoal);
    
%     % Knee joint loading
%     r_knee_load = MocoJointReactionGoal('r_knee_load', X.w_reaction);
%     r_knee_load.setJointPath('/jointset/knee_r');
%     l_knee_load = MocoJointReactionGoal('l_knee_load', X.w_reaction);
%     l_knee_load.setJointPath('/jointset/knee_l');
%     problem.addGoal(r_knee_load);
%     problem.addGoal(l_knee_load);
    

    % Bounds
    % ======
    problem.setTimeBounds(0, [1.0, 2.0]);
    problem.setStateInfo('/jointset/groundPelvis/pelvis_tilt/value', [0*pi/180, 50*pi/180], 43.426*pi/180, 0);
    problem.setStateInfo('/jointset/groundPelvis/pelvis_tx/value', [0, 0.5], 0.05);
    problem.setStateInfo('/jointset/groundPelvis/pelvis_ty/value', [0.5, 1.0], 0.535);
    problem.setStateInfo('/jointset/hip_l/hip_flexion_l/value', [-15*pi/180, 80*pi/180], 48.858*pi/180, 0);
    problem.setStateInfo('/jointset/hip_r/hip_flexion_r/value', [-15*pi/180, 80*pi/180], 48.858*pi/180, 0);
    problem.setStateInfo('/jointset/knee_l/knee_angle_l/value', [-120*pi/180, 5*pi/180], -112.113*pi/180, 0);
    problem.setStateInfo('/jointset/knee_r/knee_angle_r/value', [-120*pi/180, 5*pi/180], -112.113*pi/180, 0);
    problem.setStateInfo('/jointset/ankle_l/ankle_angle_l/value', [0*pi/180, 35*pi/180], 21.109*pi/180, 0);
    problem.setStateInfo('/jointset/ankle_r/ankle_angle_r/value', [0*pi/180, 35*pi/180], 21.109*pi/180, 0);
    problem.setStateInfo('/jointset/lumbar/lumbar/value', [-70*pi/180, 0*pi/180], -53.183*pi/180, 0);
    
    % Speeds in degrees
    problem.setStateInfo('/jointset/groundPelvis/pelvis_tilt/speed', 10*[-150, 150]*pi/180, 0, 0);
    problem.setStateInfo('/jointset/groundPelvis/pelvis_tx/speed', 10*[-0.5, 0.5], 0, 0);
    problem.setStateInfo('/jointset/groundPelvis/pelvis_ty/speed', 10*[-0.2, 1], 0, 0);
    problem.setStateInfo('/jointset/hip_l/hip_flexion_l/speed', 10*[-250, 150]*pi/180, 0, 0);
    problem.setStateInfo('/jointset/hip_r/hip_flexion_r/speed', 10*[-250, 150]*pi/180, 0, 0);
    problem.setStateInfo('/jointset/knee_l/knee_angle_l/speed', 10*[-50, 300]*pi/180, 0, 0);
    problem.setStateInfo('/jointset/knee_r/knee_angle_r/speed', 10*[-50, 300]*pi/180, 0, 0);
    problem.setStateInfo('/jointset/ankle_l/ankle_angle_l/speed', 10*[-120, 80]*pi/180, 0, 0);
    problem.setStateInfo('/jointset/ankle_r/ankle_angle_r/speed', 10*[-120, 80]*pi/180, 0, 0);
    problem.setStateInfo('/jointset/lumbar/lumbar/speed', 10*[-100, 200]*pi/180, 0, 0);

    % Configure the solver
    % ====================
    solver = study.initCasADiSolver();
    solver.set_num_mesh_intervals(50);
    solver.set_verbosity(2);
    solver.set_optim_solver('ipopt');
    solver.set_optim_convergence_tolerance(1e-2);
    solver.set_optim_constraint_tolerance(1e-4);
    solver.set_optim_max_iterations(1000); 

%     % Implicit settings 
%     solver.set_multibody_dynamics_mode('implicit')
%     solver.set_minimize_implicit_multibody_accelerations(true)
%     solver.set_implicit_multibody_accelerations_weight(0.001)
%     solver.set_implicit_multibody_acceleration_bounds(MocoBounds(-200, 200))
%     solver.set_minimize_implicit_auxiliary_derivatives(true)
%     solver.set_implicit_auxiliary_derivatives_weight(0.01)

    % Initial guess
    sitToStandTrackingSolution = MocoTrajectory('sitToStandTracking_solution_constrained_activation.sto');
    solver.setGuess(sitToStandTrackingSolution); % Use tracking solution as initial 
    
    % Solve problem
    % =============
    solution = study.solve();

end