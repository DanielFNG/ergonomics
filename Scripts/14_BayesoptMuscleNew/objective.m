function result = objective(executable, model_path, guess_path, ...
    output_dir, reference_path, weights, normalisers, weights_active)

    % Handle bayesopt table-based weights
    if istable(weights)
        weights = table2array(weights);
    end

    % Handle working with subsets of the full weight set
    full_weights = zeros(length(weights_active), 1);
    full_weights(weights_active) = weights;

    % Normalise
    normalised_weights = full_weights./normalisers;

    % Generate sit-to-stand solution
    output_path = [output_dir filesep 'results.txt'];
    [~, result] = mocoExecutableInterface(executable, ...
        model_path, guess_path, output_path, reference_path, normalised_weights);

    % Delete results file
    delete(output_path);

end
