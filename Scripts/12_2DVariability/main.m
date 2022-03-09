% User setting
method = 'bayesopt'; % 'bayesopt' or 'ga'
upper_limit = 0.1;
lower_limit = 0;
reference_weights = [0.07, 0.05, 0.05, 0.02];

% Inputs
output_dir = createOutputFolder('12_2DVariability');
reference_path = [output_dir filesep 'reference.sto'];
upper_objective = @compareRelativeKinematicsAndGRFs;
model_path = '2D_gait_jointspace_welded.osim';
tracking_path = 'guess.sto';

% Generate reference motion if needed
if ~isfile(reference_path)
    optimise2DInterface(...
        model_path, tracking_path, reference_path, reference_weights);
end

% Process reference data 
reference = Data(reference_path);
% labels = reference.Labels(1:end - 6);
labels = {'/jointset/lumbar/lumbar/value', '/jointset/hip_r/hip_flexion_r/value', ...
    '/jointset/knee_r/knee_angle_r/value', '/jointset/ankle_r/ankle_angle_r/value'};
contacts = {'chair_r', 'r_1', 'r_2', 'r_3', 'r_4'};
upper_args = {reference, labels, contacts, model_path};

% Define objective 
outer_objective = @ (weights) objective(upper_objective, upper_args, ...
    model_path, tracking_path, output_dir, weights);

switch method
    case 'bayesopt'
        % Optimal Control Weights
        range = [lower_limit, upper_limit];
        names = {'lumbar', 'hip', 'knee', 'ankle'};
        args = {'Type', 'real'};
        n_variables = length(names);
        optimisation_variables = [];
        for i = 1:n_variables
            optimisation_variables = [optimisation_variables ...
                optimizableVariable(names{i}, range, args{:})];
        end
        results = bayesopt(outer_objective, optimisation_variables, ...
            'MaxObjectiveEvaluations', 150, ...
            'AcquisitionFunctionName', 'expected-improvement-plus', ...
            'NumSeedPoints', 10, 'IsObjectiveDeterministic', true);
    case 'ga'
        options = optimoptions('ga', 'Display', 'iter', ...
            'MaxGenerations', 15, 'PlotFcn', 'gaplotscores', ...
            'PopulationSize', 10); 
        lb = lower_limit*ones(1, 2);
        ub = upper_limit*ones(1, 2);
        [x, fval, exitflag, output, population, scores] = ga(...
            outer_objective, 2, [], [], [], [], lb, ub, [], options);
end

