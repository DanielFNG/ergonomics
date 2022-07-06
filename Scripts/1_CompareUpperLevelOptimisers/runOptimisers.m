%% Parameters common to all methods
n_functions = length(function_names);
dimension = [2, 5, 10, 10, 10];
lb = [-100, -100, -600, -5.12, -50];
ub = [100, 100, 600, 5.12, 50];
nan_array = ones(1, n_functions)*nan;

%% Noisy objectives

noise = 0.1;
handles = cellfun(@str2func, function_names, 'UniformOutput', false);
noisy_handles = cell(size(handles));
for i = 1:n_functions
    noisy_handles{i} = @ (x) noisyFunction(x, handles{i}, noise);
end

%% Bayesian Optimisation

if any(strcmp(method_names, 'bayesopt'))
    tic;
    for i = 1:n_functions
    
        % Set up optimisable variables
        optimisation_variables = [];
        for j = 1:dimension(i)
            optimisation_variables = [optimisation_variables ...
                optimizableVariable(['x' num2str(j)], [lb(i), ub(i)], 'Type', 'real')];
        end
    
        % Define objectives - translate from Table input to Array input
        objective = @ (x) fromTable(x, handles{i});
        noisy_objective = @ (x) fromTable(x, noisy_handles{i});
    
        % Run
        deterministic_result = ...
            bayesopt(objective, optimisation_variables, 'MaxObjectiveEvaluations', max_evaluations); 
        noisy_result = ...
            bayesopt(noisy_objective, optimisation_variables, 'MaxObjectiveEvaluations', max_evaluations);

        % Save results
        deterministic.bayesopt(i) = deterministic_result.MinObjective;
        noisy.bayesopt(i) = noisy_result.MinObjective;

    end
    time.bayesopt = toc;
else
    deterministic.bayesopt = nan_array;
    noisy.bayesopt = nan_array;
    time.bayesopt = nan;
end

%% Surrogate Optimisation

if any(strcmp(method_names, 'surrogateopt'))
    tic;
    for i = 1:n_functions
    
        % Set up some options including initial sample points. Otherwise, the
        % algorithm generates these points itself, and includes the midpoint of
        % the domain - typically (0,0) which is typically the true minimum!
        initial_points = (rand(max(20, 2*dimension(i)), dimension(i)) - 0.5)*2*ub(i);
        options = optimoptions('surrogateopt', 'Display', 'iter', ...
            'MaxFunctionEvaluations', max_evaluations, 'InitialPoints', initial_points);
    
        % Run
        [~, deterministic.surrogate(i)] = surrogateopt(handles{i}, ...
            ones(1, dimension(i))*lb(i), ones(1, dimension(i))*ub(i), [], [], [], [], [], options);
        [~, noisy.surrogate(i)] = surrogateopt(noisy_handles{i}, ...
            ones(1, dimension(i))*lb(i), ones(1, dimension(i))*ub(i), [], [], [], [], [], options);
    end
    time.surrogate = toc;
else
    deterministic.surrogate = nan_array;
    noisy.surrogate = nan_array;
    time.surrogate = nan;
end

%% Genetic Optimisation

if any(strcmp(method_names, 'ga'))
    tic;
    for i = 1:n_functions
    
        % Set up options
        if dimension(i) <= 5
            pop_size = 50;
        else
            pop_size = 200;
        end
        max_gen = max(floor(max_evaluations/pop_size), 1); % At least 1 generation
        options = optimoptions('ga', ...
            'Display', 'iter', 'PlotFcn', 'gaplotscores', 'MaxGenerations', max_gen);
    
        % Run
        [~, deterministic.ga(i)] = ga(handles{i}, dimension(i), [], [], [], [], ...
            ones(1, dimension(i))*lb(i), ones(1, dimension(i))*ub(i), [] , options);
        [~, noisy.ga(i)] = ga(noisy_handles{i}, dimension(i), [], [], [], [], ...
            ones(1, dimension(i))*lb(i), ones(1, dimension(i))*ub(i), [] , options);
    end
    time.ga = toc;
else
    deterministic.ga = nan_array;
    noisy.ga = nan_array;
    time.ga = nan;
end

%% Save results

save(save_file, 'deterministic', 'noisy', 'time');


%% Helper Functions 

function result = noisyFunction(x, func, noise)

    result = func(x) + abs(normrnd(0, noise));

end

function result = fromTable(x, func)

    result = func(table2array(x));

end