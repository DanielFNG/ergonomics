% User setting
upper_limit = 0.1;
lower_limit = 0;
reference_weights = [0.02, 0.04, 0.02, 0.08];
executable = 'optimise4D_cluster'; % Same as optimise 4D but produces GRF file
results_dir = '/exports/eddie/scratch/dgordon3/results';

% Inputs
output_dir = createOutputFolder(results_dir);
reference_path = [output_dir filesep 'reference.sto'];
upper_objective = @compareRelativeKinematicsAndGRFs;
model_path = '2D_gait_jointspace_welded.osim';
tracking_path = 'guess.sto';

% Generate reference motion if needed
if ~isfile(reference_path)
    mocoExecutableInterface(executable, model_path, tracking_path, ...
        reference_path, reference_weights, true, false);
end

% Process reference data 
reference = Data(reference_path);
% labels = reference.Labels(1:end - 6);
labels = {'/jointset/lumbar/lumbar/value', '/jointset/hip_r/hip_flexion_r/value', ...
    '/jointset/knee_r/knee_angle_r/value', '/jointset/ankle_r/ankle_angle_r/value'};
contacts = {'chair_r', 'r_1', 'r_2', 'r_3', 'r_4'};
upper_args = {reference, labels, contacts, model_path};

% Define objective 
outer_objective = @ (weights) objective(...
    upper_objective, upper_args, output_dir, weights);

% Use GA to run optimisation
n_parameters = length(reference_weights);
options = optimoptions('ga', 'Display', 'iter', ...
    'MaxGenerations', 3, 'PlotFcn', 'gaplotscores', ...
    'PopulationSize', 10, 'UseVectorized', true); 
lb = lower_limit*ones(1, n_parameters);
ub = upper_limit*ones(1, n_parameters);
[x, fval, exitflag, output, population, scores] = ga(...
    outer_objective, n_parameters, [], [], [], [], lb, ub, [], options);

