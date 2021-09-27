function result = computeSumSquaredJointAngleDifference(reference, sample)

    squared_diffs = 0;
    for i = 2:reference.NCols
        ref = stretchVector(reference.getColumn(i), 101);
        joint = stretchVector(sample.getColumn(reference.Labels{i}), 101);
        joint_diff = (joint - ref).^2;
        squared_diffs = squared_diffs + joint_diff;
        figure;
        plot(joint_diff);
        title(reference.Labels{i}, 'Interpreter', 'none');
    end
    result = sum(squared_diffs);
    
end