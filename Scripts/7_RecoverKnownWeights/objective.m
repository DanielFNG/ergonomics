function result = objective(upper_objective, upper_args, ...
    model_path, tracking_path, output_dir, weights)

    % Generate sit-to-stand solution
    path = sitToStandInterface(model_path, tracking_path, output_dir, weights);
    
    % Grade solution results
    switch path
        case -1
            result = -1;
        otherwise
            try
                solution = Data(path);
            catch
                fprintf('Solution at path %s has nans, replacing with 0.\n', path);
                [values, labs, header] = MOTSTOTXTData.load(path);
                values(isnan(values)) = 0;
                solution = STOData(values, header, labs);
            end
            result = gradeSitToStand(solution, upper_objective, upper_args, []);
    end
    
end