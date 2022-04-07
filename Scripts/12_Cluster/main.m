% User setting
upper_limit = 1;
lower_limit = 0;
reference_weights = [0.25, 0.25, 0.25, 0.25]; % SYNC
executable = 'optimise4D_cluster'; % Same as optimise 4D but produces GRF file
reference_script = 'reference.sh';
cluster_script = 'cluster.sh';
guess_path = 'guess.sto';
script_dir = pwd;
output_dir = '/exports/eddie/scratch/dgordon3/results_testrun';
population_size = 50; % THIS MUST BE IN SYNC WITH .SH JOB FILE!
normalisers = [4.5, 1.5, 3.2, 3.9];

% Inputs
reference_path = 'reference.sto';
model_path = '2D_gait_jointspace_welded.osim';
tracking_path = 'guess.sto';

% Define objective function
upper_objective = @ (weights) clusterObjective(output_dir, script_dir, ...
    cluster_script, population_size, weights, normalisers);

% Create output directory
mkdir(output_dir);

% Generate reference motion
system(['qsub -sync y ' reference_script]);


% Use GA to run optimisation
n_parameters = length(reference_weights);
options = gaoptimset('Display', 'iter', 'Vectorized', 'on', ...
    'PopulationSize', population_size); 
lb = lower_limit*ones(1, n_parameters);
ub = upper_limit*ones(1, n_parameters);
[x, fval, exitflag, output, population, scores] = ga(...
    upper_objective, n_parameters, [], [], ...
    ones(1, n_parameters), 1, lb, ub, [], options);

% Save result
save([output_dir filesep 'results.mat']);



