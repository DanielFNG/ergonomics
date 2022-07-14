%% Optimisation

% User-modifiable parameters
method_names = {'surrogateopt', 'ga'};
max_evaluations = 10000;

% Internal parameters
function_names = {'schafferF6', 'sphere', 'griewank', 'rastrigin', 'rosenbrock'};
save_file = ['results' num2str(max_evaluations) '.mat'];

% Run optimisation script if needed
if ~isfile(save_file)
    runOptimisers;
end

% Load results data
load(save_file);

%% Plot results of a single optimisation (i.e. to N iterations)

plotOptimisationResults;

%% Meta-analysis - compare over iterations. 
% Requires save files for the values in the 'iterations' array

% User-modifiable parameters
mode = 'noisy';
method = 'surrogate';
iterations = [100 1000 10000];

compareOverIterations;
