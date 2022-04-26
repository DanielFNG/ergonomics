% High-level options
output_dir = createOutputFolder('14_BayesoptMuscleNew');
model_path = '2D_gait_jointspace_welded.osim';
guess_path = 'TrackingSolutionJoints.sto';
method = 'surrogateopt';

% Lower-level optimiser setup
executable = 'optimise4D';
reference_weights = [0.15 0.45 0.1 0.3]; %0.25*ones(1, 4);  % Determines n_variables
weights_active = [true, true, true, true];

% Internal settings
upper_limit = 1;
lower_limit = 0;
normaliser_dir = [output_dir filesep 'normalisers'];
ideal_optimised_cost = 10;
n_seeds = 4;
n_evaluations = 1000;

% Compute normalisers if needed, otherwise read from file
mkdir(normaliser_dir);
n_parameters = length(reference_weights);
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
reference_path = [output_dir filesep 'reference.sto'];
if ~isfile(reference_path)
    mocoExecutableInterface(executable, model_path, guess_path, ...
        reference_path, 'none', reference_weights./normalisers, true);
end

% Define objective 
outer_objective = @ (weights) objective(executable, ...
    model_path, guess_path, output_dir, reference_path, ...
    weights, normalisers, weights_active);

% Optimisation
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
            'MaxObjectiveEvaluations', n_seeds, ...
            'AcquisitionFunctionName', 'expected-improvement-plus', ...
            'NumSeedPoints', n_seeds, 'IsObjectiveDeterministic', false);
        for i = n_seeds + 1:n_evaluations
            results = results.resume('MaxObjectiveEvaluations', 1);
        end
    case 'surrogateopt'
        n_active_parameters = sum(weights_active);
        lb = ones(1, n_active_parameters)*lower_limit;
        ub = ones(1, n_active_parameters)*upper_limit;
        Aeq = ones(1, n_active_parameters);
        beq = 1;
        options = optimoptions('surrogateopt', 'PlotFcn', 'surrogateoptplot', 'Display', 'iter', ...
            'CheckpointFile', [output_dir filesep 'surrogateopt_checkpoint.mat'], ...
            'MaxFunctionEvaluations', n_evaluations);
        [x, fval, exitflag, output, trials] = surrogateopt(...
            outer_objective, lb, ub, [], [], [], Aeq, beq, options);
end

% Define constraints
function tf = xconstraint(X)
    tf = sum(X{:, 1:end - 1}, 2) <= ones(height(X), 1);
end

function X = condvariablefcn(X)
    X{:, :} = round(X{:, :}, 3);
    partial_sum = sum(X{:, 1:end - 1}, 2);
    X{partial_sum <= 1, end} = 1 - partial_sum;
end

