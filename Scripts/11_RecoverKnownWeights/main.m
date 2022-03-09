% User setting
method = 'bayesopt'; % 'bayesopt' or 'ga'
upper_limit = 0.2;
lower_limit = 0.0;
reference_weights = 0.1*ones(1, 5);

% Inputs
output_dir = createOutputFolder('11_RecoverKnownWeights');
reference_path = [output_dir filesep 'reference.sto'];
upper_objective = @sumSquaredStateDifference;
switch method
    case 'bayesopt'
        model_path = '2D_gait_jointspace.osim';
        tracking_path = 'TrackingSolution.sto';
    case 'bo'
        model_path = '2D_gait_jointspace_welded.osim';
        tracking_path = 'TrackingSolutionBlock.sto';
end

% Generate reference motion if needed
if ~isfile(reference_path)
    sitToStandInterface(...
        model_path, tracking_path, reference_path, reference_weights);
end

% Process reference data 
reference = Data(reference_path);
labels = reference.Labels(1:end - 6);
upper_args = {reference, labels};

% Define objective 
outer_objective = @ (weights) objective(upper_objective, upper_args, ...
    model_path, tracking_path, output_dir, weights);

switch method
    case 'bayesopt'
        % Optimal Control Weights
        range = [lower_limit, upper_limit];
        names = {'effort', 'stability', 'aload', 'kload', 'hload'};
        args = {'Type', 'real'};
        n_variables = length(names);
        optimisation_variables = [];
        for i = 1:n_variables
            optimisation_variables = [optimisation_variables ...
                optimizableVariable(names{i}, range, args{:})];
        end
        results = bayesopt(outer_objective, optimisation_variables, ...
            'MaxObjectiveEvaluations', 150, 'ExplorationRatio', 2.0, ...
            'AcquisitionFunctionName', 'expected-improvement-plus', ...
            'NumSeedPoints', 10, 'IsObjectiveDeterministic', true);
    case 'ga'
        options = optimoptions('ga', 'Display', 'iter', ...
            'MaxGenerations', 15, 'PlotFcn', 'gaplotscores', ...
            'PopulationSize', 10); 
        lb = lower_limit*ones(1, 5);
        ub = upper_limit*ones(1, 5);
        [x, fval, exitflag, output, population, scores] = ga(...
            outer_objective, 5, [], [], [], [], lb, ub, [], options);
end

