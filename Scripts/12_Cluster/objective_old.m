function result = objective(upper_objective, upper_args, ...
    model_path, tracking_path, output_dir, weights)

    % Handle bayesopt table-based weights
    if istable(weights)
        weights = table2array(weights);
    end

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
