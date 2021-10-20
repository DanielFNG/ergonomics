%% Parameters (which can be varied freely)

% Root directory for save - defaults to 
% ergonomics/output/MocoSitToStand/default, change as needed
save_dir = createOutputFolder(pwd); 
save_folder = 'default'; 

% State bounds for the tracking & prediction problems
bounds = {'/jointset/groundPelvis/pelvis_tilt/value', [], 43.426*pi/180, 0; ...
    '/jointset/groundPelvis/pelvis_tx/value', [], 0.05, []; ...
    '/jointset/groundPelvis/pelvis_ty/value', [], 0.535, []; ...
    '/jointset/hip_l/hip_flexion_l/value', [], 48.858*pi/180, 0; ...
    '/jointset/hip_r/hip_flexion_r/value', [], 48.858*pi/180, 0; ...
    '/jointset/knee_l/knee_angle_l/value', [], -112.113*pi/180, 0; ...
    '/jointset/knee_r/knee_angle_r/value', [], -112.113*pi/180, 0; ...
    '/jointset/ankle_l/ankle_angle_l/value', [], 21.109*pi/180, 0; ...
    '/jointset/ankle_r/ankle_angle_r/value', [], 21.109*pi/180, 0; ...
    '/jointset/lumbar/lumbar/value', [], -53.183*pi/180, 0; ...
    '/jointset/groundPelvis/pelvis_tilt/speed', [], 0, 0; ...
    '/jointset/groundPelvis/pelvis_tx/speed', [], 0, 0; ...
    '/jointset/groundPelvis/pelvis_ty/speed', [], 0, 0; ...
    '/jointset/hip_l/hip_flexion_l/speed', [], 0, 0; ...
    '/jointset/hip_r/hip_flexion_r/speed', [], 0, 0; ...
    '/jointset/knee_l/knee_angle_l/speed', [], 0, 0; ...
    '/jointset/knee_r/knee_angle_r/speed', [], 0, 0; ...
    '/jointset/ankle_l/ankle_angle_l/speed', [], 0, 0; ...
    '/jointset/ankle_r/ankle_angle_r/speed', [], 0, 0; ...
    '/jointset/lumbar/lumbar/speed', [], 0, 0};

% Settings for reference data
r_name = 'ReferenceData';

% Settings for the tracking problem
t_name = 'TrackingSolution';
t_states = 1;
t_controls = 0.01;

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
s_savepath = [save_dir filesep save_folder filesep 'settings.mat'];

% Reference data
r_savepath = [save_dir filesep save_folder filesep r_name '.sto'];

% Tracking solution
t_savepath = [save_dir filesep save_folder filesep t_name '.sto'];

% Predictive solution
p_savepath = [save_dir filesep save_folder filesep p_name '.sto'];

%% Manage saved settings + data - see local functions below

% If an existing settings file is detected, need some management. Otherwise
% write settings and continue.
if exist(s_savepath, 'file')
    
    % Load old settings
    old_settings = load(s_savepath);
    
    % Generate new settings structure
    settings = struct('input_model', input_model, ...
        'input_kinematics', input_kinematics, 'bounds', {bounds}, ...
        't_name', t_name, 't_states', t_states, ...
        't_controls', t_controls, 'p_name', p_name, ...
        'p_effort', p_effort, 'p_load', p_load);
    
    % Compare old and new settings
    [general_flag, predictive_flag] = ...
        compareSettings(old_settings, settings);
    
    % Run the settings/file deletion user interface
    rewrite = settingsUserInterface(general_flag, predictive_flag, ...
        s_savepath, t_savepath, p_savepath);
    
    % Rewrite the settings file if needed
    if rewrite
        save(s_savepath, ...
            'input_model', 'input_kinematics', 'bounds', 't_*', 'p_*');
    end
else
    save(s_savepath, ...
        'input_model', 'input_kinematics', 'bounds', 't_*', 'p_*');
end

%% Produce reference coordinates for the tracking problem from input data

% Load model & input data
input = Data(input_kinematics);
osim = org.opensim.modeling.Model(input_model);

% Project data on to 2D model
projection = projectIK(input, osim, sub_model, sub_data);

% Make symmetric
symmetric = produceSymmetricIK(projection);

% Convert to Moco STO format
sto = convertIKToMocoSTO(symmetric, osim);

% Write resulting data to file
sto.writeToFile(r_savepath);

%% Produce a solution which tracks the experimental data

% If we don't already have a tracking solution...
if ~exist(t_savepath, 'file')
    
    % Track motion
    tracking_solution = produceTrackingGuess(t_name, ...
        t_states, t_controls, input_model, input_kinematics, bounds);
    
    % Write tracking solution to file
    tracking_solution.write(t_savepath);
    
else
    
    % Read in the existing tracking solution
    tracking_solution = org.opensim.modeling.MocoTrajectory(t_savepath);
end

%% Produce a predictive solution

% NEED TO CHECK IF HAVING WEIGHT OF 0 IS THE SAME AS GOAL NOT BEING THERE
% IN TERMS OF COMPUTATION SPEED

% Effort goal
effort_goal = org.opensim.modeling.MocoControlGoal('effort', p_effort);
effort_goal.setDivideByDisplacement(true);
effort_goal.setExponent(3);

% Fixed foot placement
translation_goal = ...
    MocoTranslationTrackingGoal('translation', X.w_translation);
translation_table = TableProcessor(translation_reference);
translation_goal.setStatesReference(translation_table);
frames = org.opensim.modeling.StdVectorString();
frames.add('/bodyset/calcn_r');
frames.add('/bodyset/calcn_l');
translation_goal.setFramePaths(frames);
problem.addGoal(footPlacementGoal);

% Combine goals
goals = {effort_goal, r_knee_load};

% Predict
predictive_solution = predictMotion(...
    p_name, input_model, goals, tracking_solution, timerange, bounds);

% Write prediction to file
predictive_solution.write(p_savepath);

%% Helper functions

function [general, predictive] = compareSettings(one, two)

    % Compare two sets of user settings
    general = all([...
        strcmp(one.input_model, two.input_model), ...
        strcmp(one.input_kinematics, two.input_kinematics), ...
        all(strcmp(one.bounds(:, 1), two.bounds(:, 1))), ...
        isequal(one.bounds(:, 2:end), two.bounds(:, 2:end)), ...
        one.t_name == two.t_name, ...
        one.t_states == two.t_states, ...
        one.t_controls == two.t_controls]);
    predictive = all([...
        one.p_name == two.p_name, ...
        one.p_effort == two.p_effort, ...
        one.p_load == two.p_load]);

end

function rewrite = settingsUserInterface(general_flag, predictive_flag, ...
    settings_path, tracking_path, predictive_path)

    % If general settings are different, inform the user & ask for
    % permission to delete old results. Similar for if only predictive
    % settings are changed but we need to delete less things.
    if ~general_flag
        rewrite = true;
        fprintf(['Change in general settings detected. Old settings, ' ...
            'old tracking solution and old predictive solution must be '...
            'deleted to continue.\n']);
        s = input('Enter ''accept'' to confirm.\n', 's');
    elseif ~predictive_flag
        rewrite = true;
        fprintf(['Change in predictive settings detected. Old settings, ' ...
            'and old predictive solution must be deleted to continue.\n']);
        s = input('Enter ''accept'' to confirm.\n', 's');
    else
        rewrite = false;
    end

    % If no difference do nothing (don't even write settings since they are
    % identifcal. Otherwise, check user command & act as needed
    if rewrite
        if ~strcmp(s, 'accept')
            error('User requested early termination.');
        else
            % No matter what, delete predictive solution
            delete(predictive_path);

            % If we have a general settings change, delete everything
            if general_flag
                delete(settings_path);
                delete(tracking_path);
            end
        end
    end

end










