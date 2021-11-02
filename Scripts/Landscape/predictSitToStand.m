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
    effortGoal.setDivideByDisplacement(true);
    effortGoal.setExponent(3); 
    problem.addGoal(effortGoal);

    % Fixed foot placement
    fixed_states = 'translation_reference.sto';
    footPlacementGoal = MocoTranslationTrackingGoal('no_slip', X.w_translation);
    tableProcessor = TableProcessor(fixed_states);
    footPlacementGoal.setStatesReference(tableProcessor);
    frames = org.opensim.modeling.StdVectorString();
    frames.add('/bodyset/calcn_r');
    frames.add('/bodyset/calcn_l');
    footPlacementGoal.setFramePaths(frames);
    problem.addGoal(footPlacementGoal);

    % Bounds
    % ======
    problem.setTimeBounds(0, [1.0, 2.0]);
    problem.setStateInfo('/jointset/groundPelvis/pelvis_tilt/value', 2*[0*pi/180, 50*pi/180], 43.426*pi/180, 0);
    problem.setStateInfo('/jointset/groundPelvis/pelvis_tx/value', 2*[0, 0.5], 0.05);
    problem.setStateInfo('/jointset/groundPelvis/pelvis_ty/value', [0.0, 1.0], 0.535);
    problem.setStateInfo('/jointset/hip_l/hip_flexion_l/value', 2*[-15*pi/180, 80*pi/180], 48.858*pi/180, 0);
    problem.setStateInfo('/jointset/hip_r/hip_flexion_r/value', 2*[-15*pi/180, 80*pi/180], 48.858*pi/180, 0);
    problem.setStateInfo('/jointset/knee_l/knee_angle_l/value', 2*[-120*pi/180, 5*pi/180], -112.113*pi/180, 0);
    problem.setStateInfo('/jointset/knee_r/knee_angle_r/value', 2*[-120*pi/180, 5*pi/180], -112.113*pi/180, 0);
    problem.setStateInfo('/jointset/ankle_l/ankle_angle_l/value', 2*[0*pi/180, 35*pi/180], 21.109*pi/180, 0);
    problem.setStateInfo('/jointset/ankle_r/ankle_angle_r/value', 2*[0*pi/180, 35*pi/180], 21.109*pi/180, 0);
    problem.setStateInfo('/jointset/lumbar/lumbar/value', 2*[-70*pi/180, 0*pi/180], -53.183*pi/180, 0);
    
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

    % Initial guess
    sitToStandTrackingSolution = MocoTrajectory('TrackingSolution.sto');
    solver.setGuess(sitToStandTrackingSolution); % Use tracking solution as initial 
    
    % Solve problem
    % =============
    solution = study.solve();

end