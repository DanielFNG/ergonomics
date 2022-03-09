%% Parameters

% Save directory
output_dir = createOutputFolder('6_JointSpaceModel');
output_path = [output_dir filesep 'prediction.sto'];

% Input model & kinematics
model_path = '2D_gait_jointspace.osim';
tracking_path = 'TrackingSolution.sto';

% Lower-level executable
executable = 'optimise7D';

% % 
% % % ref
% % reference_data = 'ReferenceData.sto';
% % 
% % % Bound information
% % bounds_file = 'bounds.txt';
% % 
% % % Settings for the tracking problem
% % t_name = 'TrackingSolution';
% % t_savepath = [save_dir filesep t_name '.sto'];
% % t_states = 1;
% % t_controls = 10000;
% 
% %% Load model & input data & parse the bounds data file
% 
% % Load model
% osim = org.opensim.modeling.Model(input_model);
% 
% % Parse bounds
% bounds = parseBounds(bounds_file, osim);
% 
% %% Produce a solution which tracks the experimental data
%     
% % Track motion
% tracking_solution = produceTrackingGuess(t_name, ...
%     t_states, t_controls, input_model, reference_data, bounds);
% 
% % Write tracking solution to file
% tracking_solution.write(t_savepath);
% 
% % Clean the tracking solution file that is autogenerated by Moco
% delete([t_name '_tracked_states.sto']);
% 
% %% Run a suite of predictive solutions using the generated tracking guess
% 
% t_savepath = 'TrackingSolution.sto';

% Weights
weights = [0.1 0.1 0.1 0.1 0.1 0.1 0.1];

mocoExecutableInterface(executable, model_path, tracking_path, output_path, weights);