% Inputs
w_effort_range = [0, 0.1];
n_effort = 11;
w_translation_range = [0, 1];
n_translation = 11;
save_dir = 'Grid_10x10';

% Get sample points
[xs, ys] = create2DGrid(w_effort_range, w_translation_range, ...
    n_effort, n_translation);

% At each sample point...
for i = 1:length(xs)
    
    % Define set of weights
    X.w_effort = xs(i);
    X.w_translation = ys(i);
    
    % Predict sit-to-stand
    solution = predictSitToStand(X);
    
    % Write solution to file
    writeSolutionToFile(solution, save_dir, X);
    
end
