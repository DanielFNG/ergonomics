% User inputs
method = 'bayesopt';  % 'bayesopt' or 'ga'
model = 'block';  % 'block' or 'contact'
upper_limit = 0.2;
lower_limit = 0.0;
reference_weights = 0.1*ones(1, 4);  % Determines n_variables
output_dir = createOutputFolder('11_RecoverKnownWeights');
executable = 'optimise4D';

% Two possible model/tracking combinations
switch model
    case 'contact'
        model_path = '2D_gait_jointspace.osim';
        tracking_path = 'TrackingSolution.sto';
    case 'block'
        model_path = '2D_gait_jointspace_welded.osim';
        tracking_path = 'TrackingSolutionBlock.sto';
end

% Generate reference motion if needed
reference_path = [output_dir filesep 'reference.sto'];
if ~isfile(reference_path)
    mocoExecutableInterface(executable, ...
        model_path, tracking_path, reference_path, reference_weights);
end

% Upper objective setup
upper_objective = @sumSquaredStateDifference; 
reference = Data(reference_path);
labels = reference.Labels(1:end - 6); % Ignore optimisation parameters
upper_args = {reference, labels};

% Define objective 
outer_objective = @ (weights) objective(upper_objective, upper_args, ...
    model_path, tracking_path, output_dir, weights);

n_variables = length(reference_weights);
switch method
    case 'bayesopt'
        % Optimal Control Weights
        range = [lower_limit, upper_limit];
        args = {'Type', 'real'};
        optimisation_variables = [];
        for i = 1:n_variables
            optimisation_variables = [optimisation_variables ...
                optimizableVariable(['w' num2str(i)], range, args{:})];
        end
        results = bayesopt(outer_objective, optimisation_variables, ...
            'MaxObjectiveEvaluations', 150, 'ExplorationRatio', 2.0, ...
            'AcquisitionFunctionName', 'expected-improvement-plus', ...
            'NumSeedPoints', 10, 'IsObjectiveDeterministic', true);
    case 'ga'
        options = optimoptions('ga', 'Display', 'iter', ...
            'MaxGenerations', 15, 'PlotFcn', 'gaplotscores', ...
            'PopulationSize', 10); 
        lb = lower_limit*ones(1, n_variables);
        ub = upper_limit*ones(1, n_variables);
        [x, fval, exitflag, output, population, scores] = ga(...
            outer_objective, n_variables, [], [], [], [], lb, ub, [], options);
end

