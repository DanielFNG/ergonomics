% Inputs
results_dir = '9DNoChange';
obj = @sumSquaredStateDifference;
obj_args = {[pwd filesep 'bk_w_effort=0.25_w_translation=0.75.sto'], 'all'};

% Create results directory
mkdir(results_dir);

% Define sampling points
effort_range = [0.0, 0.4];
translation_range = [0.0, 1.0];
n_effort = 3;
n_translation = 3;
[w_effort_points, w_translation_points] = create2DGrid(...
    effort_range, translation_range, n_effort, n_translation);

% Set up results array
n_results = n_effort * n_translation;
results = zeros(n_results, 1);

% Step through, predicting each point
for i = 1:length(w_effort_points)
    X.w_effort = w_effort_points(i);
    X.w_translation = w_translation_points(i);
    results(i) = predictSitToStand(X, results_dir, obj, obj_args);
end

% Run a fake BayesOpt just to have it do the GP modelling
w_effort = optimizableVariable('w_effort', effort_range, 'Type', 'real');
w_translation = optimizableVariable('w_translation', translation_range, 'Type', 'real');
optimisation_variables = [w_effort, w_translation];
inputs = table(w_effort_points, w_translation_points, ...
    'VariableNames', {'w_effort', 'w_translation'});
bo = bayesopt(@sin, optimisation_variables, ...
    'MaxObjectiveEvaluations', n_results, ...
    'IsObjectiveDeterministic', true, ...
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'InitialX', inputs, 'InitialObjective', results);
save([pwd filesep 'ResultsDirectory' filesep 'results.mat'], 'bo');

% Fit the resulting points to a GP landscape - leaving this for now as we
% can use the BayesOpt graphs to have a look anyway. 

function [xs, ys, x, y] = create2DGrid(xrange, yrange, nx, ny)

    % Initialise vectors for x/y points and sample points
    x = zeros(nx, 1);
    y = zeros(ny, 1);
    xs = zeros(nx * ny, 1);
    ys = zeros(nx * ny, 1);

    % Compute the length between each point on the grid
    dx = (xrange(2) - xrange(1))/(nx + 1);
    dy = (yrange(2) - yrange(1))/(ny + 1);
    
    % Compute x locations
    for i = 1:nx
        x(i) = xrange(1) + i*dx;
    end
    
    % Compute y locations
    for i = 1:ny
        y(i) = yrange(1) + i*dy;
    end
    
    % Create x/y sample vectors which explore every point in the grid
    k = 1;
    for i = 1:nx
        for j = 1:ny
            xs(k) = x(i);
            ys(k) = y(j);
            k = k + 1;
        end
    end

end