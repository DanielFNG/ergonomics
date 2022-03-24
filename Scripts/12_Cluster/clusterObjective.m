function results = clusterObjective(output_dir, script_dir, cluster_script, ...
    population_size, weights)

    % Create an inner results folder based on time
    folder = [output_dir filesep datestr(datetime('now'), 'yy-mm-dd_hh-MM-ss')];
    mkdir(folder);

    % Write weights.txt file
    n_parameters = size(weights, 2);
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
            filename = [num2str(i) '.txt'];
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
