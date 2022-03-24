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

function results = upper_objective(weights)

    % Create an inner results folder based on time
    folder = [output_dir filesep datestr(datetime('now'), 'yy-mm-dd_hh-MM-ss')];
    mkdir(folder);

    % Write weights.txt file
    weights_file = [script_dir filesep 'weights.txt'];
    fid = fopen(weights_file, 'w');
    fprintf(fid, [repmat('%f ', 1, n_parameters) '\n'], weights);
    fclose(fid);

    % Execute cluster run
    system(['qsub -sync y ' cluster_script]);

    % Read results files
    results = zeros(population_size, 1);
    for i = 1:population_size
        try
            filename = [num2str(i) '.txt.'];
            fid = fopen(filename);
            results(i) = fscanf(fid, '%f');
            fclose(fid);
            movefile(filename, folder);
        catch
            results(i) = nan;
        end
    end

    % Move weights file from workspace dir to output dir
    movefile(weights_file, folder);

end

