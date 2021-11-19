function result = sumSquaredStateDifference(...
    input_path, reference_path, labels)

    % Load data objects
    input = Data(input_path);
    reference = Data(reference_path);
    
    % Process labels argument 
    if strcmp(labels, 'all')
        labels = reference.Labels(2:end);
    elseif isa(labels, 'char')
        labels = {labels};
    end
    
    % Initialise result
    result = 0;
    
    % Compute sum of squared state differences over required labels
    for i = 1:length(labels)
        ref = stretchVector(reference.getColumn(labels{i}), 101);
        joint = stretchVector(input.getColumn([labels{i} filesep 'value']), 101);
        result = result + sum((joint - ref).^2);
    end

end