function plot2DObjectiveModel(results, n_points)
% Visualise the results of a 2D Bayesopt run. 
%
% Input: results - a bayesopt results object
%        n_points - # of points to feed to linspace in the x/y vector

    % Check function dimensions
    if length(results.VariableDescriptions) ~= 2
        error('This function is designed exclusively for 2D bayesopt.');
    end

    % Get variable ranges
    x_range = results.VariableDescriptions(1).Range;
    y_range = results.VariableDescriptions(2).Range;
    
    % Create arrays of specified size
    [xs, ys] = create2DGrid(x_range, y_range, n_points, n_points);
    
    % Predict function value on all coordinates
    z = predict(results.ObjectiveFcnModel, [xs, ys]);

    % Produce resulting plot
    figure;
    %surf(x, y, transpose(reshape(z, [n_points, n_points])));
    surf(x, y, reshape(z, [n_points, n_points]));
    
    % Overplot the sampled points
    hold on;
    scatter3(results.XTrace{:, 1}, results.XTrace{:, 2}, ...
        results.ObjectiveTrace, 100, 'b', 'filled');

end
