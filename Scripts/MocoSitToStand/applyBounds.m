function applyBounds(problem, bounds)

    for i = 1:size(bounds, 1)
        problem.setStateInfo(...
            bounds{i, 1}, bounds{i, 2}, bounds{i, 3}, bounds{i, 4});
    end

end