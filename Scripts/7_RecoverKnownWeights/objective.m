function result = objective(executable, upper_objective, upper_args, ...
    model_path, tracking_path, output_path, weights)

    % Generate sit-to-stand solution
    success = mocoExecutableInterface(executable, model_path, tracking_path, output_path, weights);
    
    % Grade solution results
    switch success
        case false
            result = -1;
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