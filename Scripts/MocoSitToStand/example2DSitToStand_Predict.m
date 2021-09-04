%------------------------------------------------------------------------
% Set up a gait prediction problem where the goal is to minimize effort
% (squared controls) divided by distance traveled while enforcing symmetry of
% the walking cycle and a prescribed average gait speed through endpoint
% constraints. The solution of the coordinate tracking problem is
% used as an initial guess for the prediction.

% Load the Moco libraries
import org.opensim.modeling.*;

% Define the optimal control problem
% ==================================
study = MocoStudy();
study.setName('sitToStandPrediction');

problem = study.updProblem();
modelProcessor = ModelProcessor(input_model);
problem.setModelProcessor(modelProcessor);

% Goals
% =====

model = modelProcessor.process();
model.initSystem();

% Effort over distance
effortGoal = MocoControlGoal('effort', 1);
%problem.addGoal(effortGoal); % Temporarily removing effort goal
effortGoal.setExponent(3);

% Fixed foot placement
fixed_states = 'new_static_states.sto';
footPlacementGoal = MocoTranslationTrackingGoal('no_slip', 1);
tableProcessor = TableProcessor(fixed_states);
footPlacementGoal.setStatesReference(tableProcessor);
frames = org.opensim.modeling.StdVectorString();
frames.add('/bodyset/calcn_r');
frames.add('/bodyset/calcn_l');
footPlacementGoal.setFramePaths(frames);
problem.addGoal(footPlacementGoal);

% Fixed foot orientation
footOrientationGoal = MocoOrientationTrackingGoal('no_rotate', 1);
footOrientationGoal.setStatesReference(tableProcessor);
footOrientationGoal.setFramePaths(frames);
problem.addGoal(footOrientationGoal);

%% Minimise foot velocity
%r_foot_v = MocoOutputGoal('rfv', 1);
%r_foot_v.setOutputPath('/bodyset/calcn_r|linear_velocity');
%r_foot_w = MocoOutputGoal('rfw', 1);
%r_foot_w.setOutputPath('/bodyset/calcn_r|angular_velocity');
%problem.addGoal(r_foot_v);
%problem.addGoal(r_foot_w);


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
solver.setGuess(sitToStandTrackingSolution); % Use tracking solution as initial guess


% Solve problem
% =============
sitToStandPredictionSolution = study.solve();

% Create a full stride from the periodic single step solution.
% For details, view the Doxygen documentation for createPeriodicTrajectory().
fullStride = opensimMoco.createPeriodicTrajectory(sitToStandPredictionSolution);
fullStride.write('sitToStandPrediction_solution.sto');

% Uncomment next line to visualize the result
% study.visualize(fullStride);


% Extract ground reaction forces
% ==============================
contact_r = StdVectorString();
contact_l = StdVectorString();
contact_r.add('contactHeel_r');
contact_r.add('contactFront_r');
contact_l.add('contactHeel_l');
contact_l.add('contactFront_l');
butt_r = StdVectorString();
butt_l = StdVectorString();
butt_r.add('chair_r');
butt_l.add('chair_l');

% Create a conventional ground reaction forces file by summing the contact
% forces of contact spheres on each foot.
% For details, view the Doxygen documentation for
% createExternalLoadsTableForGait().
externalForcesTableFlat = opensimMoco.createExternalLoadsTableForGait(model, ...
    fullStride, contact_r, contact_l);
STOFileAdapter.write(externalForcesTableFlat, ...
    'sitToStandPrediction_solutionGRF.sto');
chair_forces = opensimMoco.createExternalLoadsTableForGait(...
    model, sitToStandTrackingSolution, butt_r, butt_l);
STOFileAdapter.write(chair_forces, 'sitToStandPrediction_solutionChair.sto');