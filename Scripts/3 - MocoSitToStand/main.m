%% Parameters (which can be varied freely)

% Root directory for save - defaults to 
% ergonomics/output/MocoSitToStand/default, change as needed
save_dir = createOutputFolder(pwd); 
save_folder = 'new_bounds_fixed';

% Bound information
bounds_file = 'bounds.txt';

% Settings for reference data
r_name = 'ReferenceData';

% Settings for the tracking problem
t_name = 'TrackingSolution';
t_states = 1;
t_controls = 0.001;

% Weights for the predictive problem
p_name = 'PredictiveSolution';
p_effort = 0.01;
p_translation = 1;

% Time horizon for predictive problem
timerange = [1.0, 2.0];

%% Parameters (which should be varied carefully)

% Input model & kinematics
input_model = '2D_gait_contact_constrained_activation.osim';
input_kinematics = 'inputIK.mot';

% Specific settings for this model & kinematics combo
sub_model = {'lumbar'};
sub_data = {'lumbar_extension'};

% Reference data for the translation tracking goal
translation_reference = 'translation_reference.sto';

%% Create savepaths

mkdir([save_dir filesep save_folder]);

% Settings
settings_savepath = [save_dir filesep save_folder filesep 'settings.mat'];

% Reference data
r_savepath = [save_dir filesep save_folder filesep r_name '.sto'];

% Tracking solution
t_savepath = [save_dir filesep save_folder filesep t_name '.sto'];

% Predictive solution
p_savepath = [save_dir filesep save_folder filesep p_name '.sto'];

%% Load model & input data & parse the bounds data file

% Load model & input data
input = Data(input_kinematics);
osim = org.opensim.modeling.Model(input_model);

% Parse bounds
bounds = parseBounds(bounds_file, osim);

%% Save the settings of the run

save(settings_savepath, ...
    'input_model', 'input_kinematics', 'bounds', 't_*', 'p_*');

%% Produce reference coordinates for the tracking problem from input data

% Project data on to 2D model
projection = projectIK(input, osim, sub_model, sub_data);

% Make symmetric
symmetric = produceSymmetricIK(projection);

% Convert to Moco STO format
sto = convertIKToMocoSTO(symmetric, osim);

% Write resulting data to file
sto.writeToFile(r_savepath);

%% Produce a solution which tracks the experimental data
    
% Track motion
tracking_solution = produceTrackingGuess(t_name, ...
    t_states, t_controls, input_model, r_savepath, bounds);

% Write tracking solution to file
tracking_solution.write(t_savepath);

%% Produce a predictive solution

% Effort goal
effort_goal = org.opensim.modeling.MocoControlGoal('effort', p_effort);
effort_goal.setDivideByDisplacement(true);
effort_goal.setExponent(3);

% Fixed foot placement
translation_goal = org.opensim.modeling.MocoTranslationTrackingGoal(...
    'translation', p_translation);
translation_table = ...
    org.opensim.modeling.TableProcessor(translation_reference);
translation_goal.setStatesReference(translation_table);
frames = org.opensim.modeling.StdVectorString();
frames.add('/bodyset/calcn_r');
frames.add('/bodyset/calcn_l');
translation_goal.setFramePaths(frames);

% Combine goals
goals = {effort_goal, translation_goal};

% Predict
predictive_solution = predictMotion(...
    p_name, input_model, goals, tracking_solution, timerange, bounds);

% Write prediction to file
predictive_solution.write(p_savepath);
