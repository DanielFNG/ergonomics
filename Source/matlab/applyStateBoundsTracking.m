function applyStateBoundsTracking(problem, bounds)
% A reduced version of applyStateBounds that only places bounds on the
% states, without specifying initial/final state positions. Named as such
% because this is more apt for running state tracking problems.

    for i = 1:height(bounds)
        problem.setStateInfo(...
            bounds.Name{i}, [bounds.LowerBound(i), bounds.UpperBound(i)]);
    end

end