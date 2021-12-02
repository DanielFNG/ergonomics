function applyStateBounds(problem, bounds)

    for i = 1:height(bounds)
        
        % Parse initial and final values which may be NaN's
        initial = bounds.InitialValue(i);
        if isnan(initial)
            initial = [];
        end
        final = bounds.FinalValue(i);
        if isnan(final)
            final = [];
        end
        
        % Set state info
        problem.setStateInfo(bounds.Name{i}, ...
            [bounds.LowerBound(i), bounds.UpperBound(i)], initial, final);
    end

end