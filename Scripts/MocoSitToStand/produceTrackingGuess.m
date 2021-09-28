% Choose save name 
save_name = 'sitToStandTracking_solution_constrained_activation_redone_puretrack.sto';

% Load the Moco libraries
import org.opensim.modeling.*;

% Define the optimal control problem
% ==================================
track = MocoTrack();
track.setName('sitToStandTracking');

% Set the weights for the terms in the objective function. The values below were
% obtained by trial and error.
controlEffortWeight = 0.0000000000000001;
stateTrackingWeight = 1;

% Reference data for tracking problem
input_model = '2D_gait_contact_constrained_activation.osim';
input_data = 'referenceSitToStandCoordinates_symmetric.sto';
%input_model = '2D_gait_scaled_contact.osim';
%input_data = 'referenceSitToStandCoordinates.sto';
tableProcessor = TableProcessor(input_data);
tableProcessor.append(TabOpLowPassFilter(6));

modelProcessor = ModelProcessor(input_model);
track.setModel(modelProcessor);
track.setStatesReference(tableProcessor);
track.set_states_global_tracking_weight(stateTrackingWeight);
track.set_allow_unused_references(true);
track.set_track_reference_position_derivatives(true);
track.set_apply_tracked_states_to_guess(true);
input_data = Data(input_data);
track.set_initial_time(input_data.Timesteps(1));
track.set_final_time(input_data.Timesteps(end));
study = track.initialize();
problem = study.updProblem();



% Goals
% =====

% Model processing 
model = modelProcessor.process();
model.initSystem();

% Get a reference to the MocoControlGoal that is added to every MocoTrack
% problem by default and change the weight
effort = MocoControlGoal.safeDownCast(problem.updGoal('control_effort'));
effort.setWeight(controlEffortWeight);

% Bounds
% ======
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
    problem.setStateInfo('/jointset/groundPelvis/pelvis_tilt/speed', [-150, 150]*pi/180, 0, 0);
    problem.setStateInfo('/jointset/groundPelvis/pelvis_tx/speed', [-0.5, 0.5], 0, 0);
    problem.setStateInfo('/jointset/groundPelvis/pelvis_ty/speed', [-0.2, 1], 0, 0);
    problem.setStateInfo('/jointset/hip_l/hip_flexion_l/speed', [-250, 150]*pi/180, 0, 0);
    problem.setStateInfo('/jointset/hip_r/hip_flexion_r/speed', [-250, 150]*pi/180, 0, 0);
    problem.setStateInfo('/jointset/knee_l/knee_angle_l/speed', [-50, 300]*pi/180, 0, 0);
    problem.setStateInfo('/jointset/knee_r/knee_angle_r/speed', [-50, 300]*pi/180, 0, 0);
    problem.setStateInfo('/jointset/ankle_l/ankle_angle_l/speed', [-120, 80]*pi/180, 0, 0);
    problem.setStateInfo('/jointset/ankle_r/ankle_angle_r/speed', [-120, 80]*pi/180, 0, 0);
    problem.setStateInfo('/jointset/lumbar/lumbar/speed', [-100, 200]*pi/180, 0, 0);

% % Implicit settings
% solver = MocoCasADiSolver.safeDownCast(study.updSolver());
% solver.set_multibody_dynamics_mode('implicit');
% solver.resetProblem(problem);
% solver.set_minimize_implicit_multibody_accelerations(true);
% solver.set_implicit_multibody_accelerations_weight(0.001);
% solver.set_implicit_multibody_acceleration_bounds(MocoBounds(-200, 200));
% solver.set_minimize_implicit_auxiliary_derivatives(true);
% solver.set_implicit_auxiliary_derivatives_weight(0.01);
% 
% % Re-randomise the guess
% guess = solver.createGuess();
% guess.randomizeAdd();
% solver.setGuess(guess);


% Solve the problem
% =================
sitToStandTrackingSolution = study.solve();
sitToStandTrackingSolution.write(save_name);





