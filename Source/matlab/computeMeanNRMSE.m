function result = computeMeanNRMSE(input, reference, labels)
    
    % Process labels argument 
    if strcmp(labels, 'all')
        labels = reference.Labels(2:end);
    elseif isa(labels, 'char')
        labels = {labels};
    end
    
    % Initialise result
    n_labels = length(labels);
    nrmse = zeros(1, n_labels);
    
    % Compute RMSE for each state coordindate
    for i = 1:n_labels
        ref = stretchVector(reference.getColumn(labels{i}), 101);
        joint = stretchVector(input.getColumn(labels{i}), 101);
        nrmse(i) = (sqrt(sum((ref - joint).^2)/101))/mean(ref);
    end
    
    % Return mean of NRMSE's over all coordinates
    result = mean(nrmse);

end