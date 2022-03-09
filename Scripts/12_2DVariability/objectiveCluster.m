function result = objectiveCluster(upper_objective, upper_args, ...
    model_path, tracking_path, output_dir, weights)
% A special objective function for use with a vectorised GA implementation 
% running on the Eddie compute cluster

    % Produce weights.txt file from input matrix
    fid = fopen('weights.txt', 'w');
    fprintf(fid, '%f %f %f %f\n', weights);
    fclose(fid);

    % Create folder for generation data
    mkdir('data');

    % Modify base job submission script

    % Run job

    % Grade all results in turn

    % Generate path for the sit-to-stand solution
    labels = {'lumbar', 'knee'};
    name = [];
    for l = 1:length(labels)
        name = [name labels{l} '=' num2str(weights(l)) '_' ];  %#ok<AGROW>
    end
    name(end) = [];
    name = [name '.sto'];
    output_path = [output_dir filesep name];

    % Generate sit-to-stand solution
    success = optimise2DInterface(...
        model_path, tracking_path, output_path, weights);
    
    % Grade solution results
    switch success
        case false
            result = nan;
        otherwise
            try
                solution = Data(output_path);
            catch
                fprintf('Solution at path %s has nans, replacing with 0.\n', output_path);
                [values, labs, header] = MOTSTOTXTData.load(output_path);
                values(isnan(values)) = 0;
                solution = STOData(values, header, labs);
            end
            result = gradeSitToStand(solution, upper_objective, upper_args, []);
    end
end