% User setting
upper_limit = 0.1;
lower_limit = 0;
reference_weights = [0.02, 0.04, 0.02, 0.08];
executable = 'optimise4D_cluster'; % Same as optimise 4D but produces GRF file
cluster_script = 'cluster.sh';
script_dir = pwd;
output_dir = '/exports/eddie/scratch/dgordon3/results_testrun';
population_size = 10; % THIS MUST BE IN SYNC WITH .SH JOB FILE!
max_generations = 2;

% Inputs
reference_path = [output_dir filesep 'reference.sto'];
model_path = '2D_gait_jointspace_welded.osim';
tracking_path = 'guess.sto';

% Define objective function
upper_objective = (weights) clusterObjective(output_dir, script_dir, ...
    cluster_script, population_size, weights);

% Create output directory
mkdir(output_dir);

% Generate reference motion if needed
if ~isfile(reference_path)
    command = ['~/ergonomics/bin/optimise4D_cluster ' model_path ' ' ...
        guess_path ' ' reference_path ' none'];
    for i = 1:length(weights)
        command = [command ' ' num2str(weights(i))];
    end
    [~, ~] = system(command);
end

% Use GA to run optimisation
n_parameters = length(reference_weights);
options = optimoptions('ga', 'Display', 'iter', 'UseVectorized', true, ...
    'MaxGenerations', max_generations, 'PopulationSize', population_size); 
lb = lower_limit*ones(1, n_parameters);
ub = upper_limit*ones(1, n_parameters);
[x, fval, exitflag, output, population, scores] = ga(...
    @upper_objective, n_parameters, [], [], [], [], lb, ub, [], options);

% Save result
save([output_dir filesep 'results.mat']);



