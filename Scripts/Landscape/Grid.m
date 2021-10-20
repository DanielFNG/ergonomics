% Inputs

w_effort_range = [0.05, 0.45];
n_effort = 5;
w_translation_range = [0.1, 0.9];
n_translation = 5;
save_dir = 'Grid_5x5';
mkdir(save_dir);

% Get sample points
[xs, ys] = create2DGrid(w_effort_range, w_translation_range, ...
    n_effort, n_translation);

% At each sample point...
for i = 2:length(xs)
    
    % Define set of weights
    X.w_effort = xs(i);
    X.w_translation = ys(i);
    
    % Predict sit-to-stand
    solution = predictSitToStand(X);
    
    % Write solution to file
    writeSolutionToFile(solution, save_dir, X);
    
end
