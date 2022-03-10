function result = sumSquaredStateDifference(input, reference, labels)
    
    % Process labels argument 
    if strcmp(labels, 'all')
        labels = reference.Labels(2:end);
    elseif isa(labels, 'char')
        labels = {labels};
    end
    
    % Initialise result
    result = zeros(1, length(labels));
    
    % Compute sum of squared state differences over required labels
    for i = 1:length(labels)
        if ref.NFrames ~= joint.NFrames
            % We assume evenly distributed knot points here
            ref = stretchVector(reference.getColumn(labels{i}), 101);
            joint = stretchVector(input.getColumn(labels{i}), 101);
        end
        ref = reference.getColumn(labels{i});
        joint = input.getColumn(labels{i});
        result(i) = sum((joint - ref).^2);
    end
    
    result = sum(result);

end