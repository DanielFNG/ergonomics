%% User-modifiable settings

% High-level options
method = 'bayesopt';
executable = 'optimise4D';
n_evaluations = 1;%1000;

% Reference weights -> can be changed, but user care is needed to avoid
% reusing old normalisers. The weights_active variable allows you to 
% switch off weight terms, so that (for example) you could run optimise4D
% as a 2D problem (caring only about effort and stability, say) without 
% having to create a new almost identical executable for this purpose. 
% Active weights must sum to 1. Inactive weights must have 0 weight. 
reference_weights = [0.1 0.3 0.4 0.2]; % Determines n_variables
weights_active = [true, true, true, true];

% Inputs -> can be changed, but a new model requires an associated guess
model_path = '2D_gait_jointspace_welded.osim';
guess_path = 'TrackingSolutionJoints.sto';

% Base results directory
base_dir = createOutputFolder('14_RecoverKnownWeightsWorking');

%% Internal settings

% Create required directories
executable_dir = [base_dir filesep executable];
mkdir(executable_dir);
normaliser_dir = [executable_dir filesep 'normalisers'];
mkdir(normaliser_dir);
output_dir = [executable_dir filesep method num2str(n_evaluations)];
mkdir(output_dir);
checkpoint_file = [output_dir filesep 'checkpoint.mat'];
save_file = [output_dir filesep 'results.mat'];
settings_file = [output_dir filesep 'settings.mat'];
reference_path = [output_dir filesep 'reference.sto'];

% Save relevant settings for reference
save(settings_file, 'method', 'executable', 'n_evaluations', ...
    'reference_weights', 'weights_active', 'model_path', 'guess_path');

% Optimisation parameters 
upper_limit = 1;
lower_limit = 0;
ideal_optimised_cost = 10;
n_parameters = length(reference_weights);
n_active_parameters = sum(weights_active);
n_seeds = n_parameters^2;

%% Initialisation steps

% Compute normalisers if needed, otherwise read from file
normalisers = zeros(1, n_parameters);
for i = 1:n_parameters
    normaliser_path = [normaliser_dir filesep num2str(i) '.sto'];
    if ~isfile(normaliser_path)
        normaliser_weights = zeros(1, n_parameters);
        normaliser_weights(i) = 1;
        mocoExecutableInterface(executable, model_path, guess_path, ...
            normaliser_path, 'none', normaliser_weights, true);
    end
    normaliser_data = Data(normaliser_path);
    objective_info = strsplit(normaliser_data.Header{9}, '=');
    cost = str2double(objective_info{2});
    normalisers(i) = cost/ideal_optimised_cost;
end

% Generate reference motion if needed
if ~isfile(reference_path)
    mocoExecutableInterface(executable, model_path, guess_path, ...
        reference_path, 'none', reference_weights./normalisers, true);
end

%% Main optimisation step

% Define objective 
outer_objective = @ (weights) objective(executable, ...
    model_path, guess_path, output_dir, reference_path, ...
    weights, normalisers, weights_active);

switch method
    case 'bayesopt'
        range = [lower_limit, upper_limit];
        args = {'Type', 'real'};
        optimisation_variables = [];
        for i = 1:n_parameters
            if weights_active(i)
                optimisation_variables = [optimisation_variables ...
                    optimizableVariable(['w' num2str(i)], range, args{:})];
            end
        end

        % Here, we run the seed points first, then start doing bayesopt
        % step by step. This is helpful incase we need to pause, or if an
        % error occurs (since we will have access to the results object).
        results = bayesopt(outer_objective, optimisation_variables, ...
            'XConstraintFcn', @xconstraint, ...
            'ConditionalVariableFcn', @condvariablefcn, ...
            'MaxObjectiveEvaluations', min(n_seeds, n_evaluations), ...
            'AcquisitionFunctionName', 'expected-improvement-plus', ...
            'NumSeedPoints', n_seeds, 'IsObjectiveDeterministic', false);
        for i = n_seeds + 1:n_evaluations
            results = results.resume('MaxObjectiveEvaluations', 1);
            save(checkpoint_file, 'results');
        end
    case 'surrogateopt'
        lb = ones(1, n_active_parameters)*lower_limit;
        ub = ones(1, n_active_parameters)*upper_limit;
        Aeq = ones(1, n_active_parameters);
        beq = 1;
        options = optimoptions('surrogateopt', 'PlotFcn', 'surrogateoptplot', 'Display', 'iter', ...
            'CheckpointFile', checkpoint_file, ...
            'MaxFunctionEvaluations', n_evaluations);
        [x, fval, exitflag, output, trials] = surrogateopt(...
            outer_objective, lb, ub, [], [], [], Aeq, beq, options);
        results = struct(...
            'x', x, 'fval', fval, 'exitflag', exitflag, 'output', output, 'trials', trials);
end

% Save results to file
save(save_file, 'results');

%% Helper functions

function tf = xconstraint(X)
    tf = sum(X{:, 1:end - 1}, 2) <= ones(height(X), 1);
end

function X = condvariablefcn(X)
% Constrain the sum of optimisation variables to equal 1
% This is achieved by summing the first n - 1 variables, and setting the
% nth equal to 1 minus this summation. In the case that the summation is
% greater than 1, we do nothing - these parameters will be filtered later
% by the xconstraint function
    X{:, :} = round(X{:, :}, 3);
    partial_sum = sum(X{:, 1:end - 1}, 2);
    if height(X(partial_sum <= 1, :)) > 0
        X{partial_sum <= 1, end} = 1 - partial_sum(partial_sum <= 1);
    end
end

