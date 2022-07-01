%% Parameters common to all methods
function_names = {'schafferF6', 'sphere', 'griewank', 'rastrigin', 'rosenbrock'};
n_functions = length(function_names);
dimension = [2, 5, 10, 10, 10];
lb = [-100, -100, -600, -5.12, -50];
ub = [100, 100, 600, 5.12, 50];
max_evaluations = 1000;

%% Noisy objectives
noise = 0.1;
handles = cellfun(@str2func, function_names, 'UniformOutput', false);
noisy_handles = cell(size(handles));
for i = 1:n_functions
    noisy_handles{i} = @ (x) noisyFunction(x, handles{i}, noise);
end

%% Bayesian Optimisation

% tic;

for i = 1:n_functions

    tic;

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
    deterministic.bayesopt(i) = ...
        bayesopt(objective, optimisation_variables, 'MaxObjectiveEvaluations', max_evaluations); 
    noisy.bayesopt(i) = ...
        bayesopt(noisy_objective, optimisation_variables, 'MaxObjectiveEvaluations', max_evaluations);

    partial_time(i) = toc;

    save(['baysopt' num2str(i) '.mat'], 'deterministic', 'noisy', 'partial_time');
    
end

time.bayesopt = toc;


% %% Surrogate Optimisation
% 
% tic;
% 
% for i = 1:n_functions
% 
%     % Set up some options including initial sample points. Otherwise, the
%     % algorithm generates these points itself, and includes the midpoint of
%     % the domain - typically (0,0) which is typically the true minimum!
%     initial_points = (rand(max(20, 2*dimension(i)), dimension(i)) - 0.5)*2*ub(i);
%     options = optimoptions('surrogateopt', 'Display', 'iter', ...
%         'MaxFunctionEvaluations', max_evaluations, 'InitialPoints', initial_points);
% 
%     % Run
%     [x, fval] = surrogateopt(handles{i}, ...
%         ones(1, dimension(i))*lb(i), ones(1, dimension(i))*ub(i), [], [], [], [], [], options);
%     deterministic.surrogate(i) = struct('x', x, 'fval', fval);
%     [x, fval] = surrogateopt(noisy_handles{i}, ...
%         ones(1, dimension(i))*lb(i), ones(1, dimension(i))*ub(i), [], [], [], [], [], options);
%     noisy.surrogate(i) = struct('x', x, 'fval', fval);
% 
% end
% 
% time.surrogate = toc;
% 
% %% Genetic Optimisation
% 
% tic;
% 
% for i = 1:n_functions
% 
%     if dimension(i) <= 5
%         pop_size = 50;
%     else
%         pop_size = 200;
%     end
%     max_gen = floor(max_evaluations/pop_size);
%     options = optimoptions('ga', ...
%         'Display', 'iter', 'PlotFcn', 'gaplotscores', 'MaxGenerations', max_gen);
% 
%     [x, fval] = ga(handles{i}, dimension(i), [], [], [], [], ...
%         ones(1, dimension(i))*lb(i), ones(1, dimension(i))*ub(i), [] , options);
%     deterministic.ga(i) = struct('x', x, 'fval', fval);
% 
%     [x, fval] = ga(noisy_handles{i}, dimension(i), [], [], [], [], ...
%         ones(1, dimension(i))*lb(i), ones(1, dimension(i))*ub(i), [] , options);
%     noisy.ga(i) = struct('x', x, 'fval', fval);
% 
% 
% end
% 
% time.ga = toc;

%% Helper Functions 

function result = noisyFunction(x, func, noise)

    result = func(x) + abs(normrnd(0, noise));

end

function result = fromTable(x, func)

    result = func(table2array(x));

end