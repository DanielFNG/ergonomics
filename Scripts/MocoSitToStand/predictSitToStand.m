function result = predictSitToStand(X)

    % Load the Moco libraries
    import org.opensim.modeling.*;

    % Define the optimal control problem
    % ==================================
    study = MocoStudy();
    study.setName('sitToStandPrediction');

    problem = study.updProblem();
    input_model = '2D_gait_scaled_contact.osim';
    modelProcessor = ModelProcessor(input_model);
    problem.setModelProcessor(modelProcessor);

    % Goals
    % =====

    model = modelProcessor.process();
    model.initSystem();

    % Effort over distance
    effortGoal = MocoControlGoal('effort', X.w_effort);
    problem.addGoal(effortGoal);
    effortGoal.setExponent(3);

    % Fixed foot placement
    fixed_states = 'new_static_states.sto';
    footPlacementGoal = MocoTranslationTrackingGoal('no_slip', X.w_translation);
    tableProcessor = TableProcessor(fixed_states);
    footPlacementGoal.setStatesReference(tableProcessor);
    frames = org.opensim.modeling.StdVectorString();
    frames.add('/bodyset/calcn_r');
    frames.add('/bodyset/calcn_l');
    footPlacementGoal.setFramePaths(frames);
    problem.addGoal(footPlacementGoal);

    % Fixed foot orientation
    footOrientationGoal = MocoOrientationTrackingGoal('no_rotate', X.w_rotation);
    footOrientationGoal.setStatesReference(tableProcessor);
    footOrientationGoal.setFramePaths(frames);
    problem.addGoal(footOrientationGoal);
    
    % Knee joint loading
    r_knee_load = MocoJointReactionGoal('r_knee_load', X.w_reaction);
    r_knee_load.setJointPath('/jointset/knee_r');
    l_knee_load = MocoJointReactionGoal('l_knee_load', X.w_reaction);
    l_knee_load.setJointPath('/jointset/knee_l');
    problem.addGoal(r_knee_load);
    problem.addGoal(l_knee_load);
    

    % Bounds
    % ======
    problem.setTimeBounds(0, [1.0, 2.0]);
    problem.setStateInfo('/jointset/groundPelvis/pelvis_tilt/value', [0*pi/180, 50*pi/180], 43.426*pi/180, 0);
    problem.setStateInfo('/jointset/groundPelvis/pelvis_tx/value', [0, 0.5], 0.05);
    problem.setStateInfo('/jointset/groundPelvis/pelvis_ty/value', [0.5, 1.0], 0.536);
    problem.setStateInfo('/jointset/hip_l/hip_flexion_l/value', [-15*pi/180, 80*pi/180], 47.148*pi/180, 0);
    problem.setStateInfo('/jointset/hip_r/hip_flexion_r/value', [-15*pi/180, 80*pi/180], 47.148*pi/180, 0);
    problem.setStateInfo('/jointset/knee_l/knee_angle_l/value', [-120*pi/180, 5*pi/180], -109.565*pi/180, 0);
    problem.setStateInfo('/jointset/knee_r/knee_angle_r/value', [-120*pi/180, 5*pi/180], -109.565*pi/180, 0);
    problem.setStateInfo('/jointset/ankle_l/ankle_angle_l/value', [0*pi/180, 35*pi/180], 21.109*pi/180, 0);
    problem.setStateInfo('/jointset/ankle_r/ankle_angle_r/value', [0*pi/180, 35*pi/180], 21.109*pi/180, 0);
    problem.setStateInfo('/jointset/lumbar/lumbar/value', [-70*pi/180, 0*pi/180], -53.183*pi/180, 0);
    problem.setStateInfo('/jointset/groundPelvis/pelvis_tilt/speed', [-500, 500], 0, 0);
    problem.setStateInfo('/jointset/groundPelvis/pelvis_tx/speed', [-500, 500], 0, 0);
    problem.setStateInfo('/jointset/groundPelvis/pelvis_ty/speed', [-500, 500], 0, 0);
    problem.setStateInfo('/jointset/hip_l/hip_flexion_l/speed', [-500, 500], 0, 0);
    problem.setStateInfo('/jointset/hip_r/hip_flexion_r/speed', [-500, 500], 0, 0);
    problem.setStateInfo('/jointset/knee_l/knee_angle_l/speed', [-500, 500], 0, 0);
    problem.setStateInfo('/jointset/knee_r/knee_angle_r/speed', [-500, 500], 0, 0);
    problem.setStateInfo('/jointset/ankle_l/ankle_angle_l/speed', [-500, 500], 0, 0);
    problem.setStateInfo('/jointset/ankle_r/ankle_angle_r/speed', [-500, 500], 0, 0);
    problem.setStateInfo('/jointset/lumbar/lumbar/speed', [-500, 500], 0, 0);


    % Configure the solver
    % ====================
    solver = study.initCasADiSolver();
    solver.set_num_mesh_intervals(50);
    solver.set_verbosity(2);
    solver.set_optim_solver('ipopt');
    solver.set_optim_convergence_tolerance(1e-4);
    solver.set_optim_constraint_tolerance(1e-4);
    solver.set_optim_max_iterations(1000); 
    sitToStandTrackingSolution = MocoTrajectory('sitToStandTracking_solution.sto');
    solver.setGuess(sitToStandTrackingSolution); % Use tracking solution as initial guess


    % Solve problem
    % =============
    sitToStandPredictionSolution = study.solve();
    
    % Check if the solution is sealed, write it either way
    if sitToStandPredictionSolution.isSealed()
        sitToStandPredictionSolution.unseal();
    end
    
    % Save the solution for posterity
    save_name = [pwd filesep 'ResultsDirectory' ...
        filesep 'solution' '_effort=' num2str(X.w_effort) '_reaction=' ...
        num2str(X.w_reaction) '_translation=' num2str(X.w_translation) ...
        '_rotation=' num2str(X.w_rotation) '.sto'];
    sitToStandPredictionSolution.write(save_name);
    
    % Run BK on result
    bk_settings = 'C:\Users\danie\Documents\GitHub\opensim-matlab\Defaults\BK\bk.xml';
    runAnalyse('bk', input_model, save_name, [], [pwd filesep 'solution'], bk_settings);
    
    %% Objective: sum of squared joint angles
    % Note both solution & reference data already start & end at
    % appropriate points of sit-to-stand motion, so no normalisation
    % required
    solution = Data(save_name);
    reference = Data('referenceSitToStandCoordinates.sto');
    squared_diffs = 0;
    for i = 2:reference.NCols
        joint = stretchVector(solution.getColumn(i), 101);
        ref = stretchVector(reference.getColumn(solution.Labels{i}), 101);
        joint_diff = (joint - ref).^2;
        squared_diffs = squared_diffs + joint_diff;
    end
    result = sum(squared_diffs);
    
%     %% Objective: CoM squared difference
%     % Slice the BK position 
%     bk = Data('solution\bk_BodyKinematics_pos_global.sto');
%     bk = bk.slice(start, finish);
%     bk.writeToFile('solution\bk_normalised.sto');
%     
%     % Compute normalised squared distance to mean
%     info = load('means.mat');
%     x_com = stretchVector(bk.getColumn('center_of_mass_X'), 101);
%     y_com = stretchVector(bk.getColumn('center_of_mass_Y'), 101);
%     result = sum((x_com' - info.means(:, 1)).^2 + (y_com' - info.means(:, 2)).^2);

end