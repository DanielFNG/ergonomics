function result = computeMeanNormalisedDifference(input, reference, labels)
    
    % Process labels argument 
    if strcmp(labels, 'all')
        labels = reference.Labels(2:end - 6); % Don't take the lambda stuff
    elseif isa(labels, 'char')
        labels = {labels};
    end
    
    % Initialise result
    n_labels = length(labels);
    ndiff = zeros(1, n_labels);
    
    % Compute normalised difference for each state coordindate
    for i = 1:n_labels
        ref = stretchVector(reference.getColumn(labels{i}), 101);
        joint = stretchVector(input.getColumn(labels{i}), 101);
        joint(ref == 0) = [];
        ref(ref == 0) = [];
        ndiff(i) = mean(abs((joint - ref)./ref)*100);
    end
    
    % Return mean of normalised differences over all coordinates
    ndiff
    result = mean(ndiff);

end