% User setting
method = 'bayesopt'; % 'bayesopt' or 'ga'
upper_limit = 10;
lower_limit = -10;
n_dimensions = 5;
max_iter = 300;

% Inputs
output_dir = createOutputFolder('9_OptimisationEvaluation');

% Define objective 
outer_objective = @ rastrigin;

switch method
    case 'bayesopt'
        % Optimal Control Weights
        range = [lower_limit, upper_limit];
        args = {'Type', 'real'};
        optimisation_variables = [];
        for i = 1:n_dimensions
            optimisation_variables = [optimisation_variables ...
                optimizableVariable(['n' num2str(i)], range, args{:})];
        end
        seed_iter = round(max_iter/10);
        results = bayesopt(outer_objective, optimisation_variables, ...
            'MaxObjectiveEvaluations', max_iter, ...
            'AcquisitionFunctionName', 'expected-improvement-plus', ...
            'NumSeedPoints', seed_iter, 'IsObjectiveDeterministic', true);
    case 'ga'
        if n_dimensions <= 5
            max_generations = round(max_iter/50);
        else
            max_generations = round(max_iter/200);
        end
        options = optimoptions('ga', 'Display', 'iter', ...
            'PlotFcn', 'gaplotscores', 'MaxGenerations', max_generations); 
        lb = lower_limit*ones(1, n_dimensions);
        ub = upper_limit*ones(1, n_dimensions);
        [x, fval, exitflag, output, population, scores] = ga(...
            outer_objective, 5, [], [], [], [], lb, ub, [], options);
end

