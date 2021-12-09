%% Parameters

% Save directory
save_dir = createOutputFolder(pwd);

% Input model & kinematics
input_model = '2D_gait_jointspace.osim';
reference_data = 'ReferenceData.sto';

% Bound information
bounds_file = 'bounds.txt';

% Settings for the tracking problem
t_name = 'TrackingSolution';
t_savepath = [save_dir filesep t_name '.sto'];
t_states = 1;
t_controls = 10000;

%% Load model & input data & parse the bounds data file

% Load model
osim = org.opensim.modeling.Model(input_model);

% Parse bounds
bounds = parseBounds(bounds_file, osim);

%% Produce a solution which tracks the experimental data
    
% Track motion
tracking_solution = produceTrackingGuess(t_name, ...
    t_states, t_controls, input_model, reference_data, bounds);

% Write tracking solution to file
tracking_solution.write(t_savepath);

% Clean the tracking solution file that is autogenerated by Moco
delete([t_name '_tracked_states.sto']);

%% Run a suite of predictive solutions using the generated tracking guess

t_savepath = 'TrackingSolution.sto';

% Weights
weights{1} = [0.1 0 0 0 0 0 0]; % effort
weights{2} = [0.01 0.1 0 0 0 0 0]; % mos
weights{3} = [0.01 0 0.1 0 0 0 0]; % pmos
weights{4} = [0.01 0 0 1.0 0 0 0]; % wmos
weights{5} = [0.01 0 0 0 0.1 0 0]; % ankle joint loading
weights{6} = [0.1 0.1 0.1 0.1 0.1 0.1 0.1];

for j = 1:length(weights)
    % Generate command 
    command = ['./main ' input_model ' ' t_savepath ' ' save_dir];
    for i = 1:length(weights{j})
        command = [command  ' ' num2str(weights{j}(i))];
    end

    % Run command 
    system(command);
end