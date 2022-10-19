root = '/Users/daniel/Library/CloudStorage/OneDrive-UniversityofEdinburgh/Projects/Ergonomics/IOC Framework/Sit To Stand Pertubation Testing/Ground Truth Weight Recovery/New IOC Settings';
samples = 0:7;

best_objective_plot = figure;
xlabel('Iterations');
ylabel('Error');
set(gca, 'FontSize', 25);
set(gca, 'YScale', 'log');
hold on;
box on;
weight_error_plot = figure;
title('Error');
xlabel('Iterations');
ylabel('Euclidian Distance');
set(gca, 'FontSize', 15);
hold on;
box on;

ground_truth_error = [];
weights_error = [];
individual_weights_error = [];

best_objective_matrix = [];
weight_error_matrix = [];

for sample = samples
    results_folder = [root filesep num2str(sample)];

    weights_path = [results_folder filesep 'weights.txt'];
    history_path = [results_folder filesep 'history.0.txt'];
   
    weights = readWeights(weights_path);
    [samples, objectives] = readHistory(history_path);
    
    [best_objective_vec, weight_error_vec, best_weights] = getBestHistory(objectives, samples, weights);

    if sample == 1
        visibility = 'on';
    else
        visibility = 'off';
    end
    figure(best_objective_plot);
    plot(best_objective_vec, 'LineWidth', 1.5, 'Color', [0, 0.4470, 0.7410, 0.4], 'HandleVisibility', visibility);

    %figure(weight_error_plot);
    plot(weight_error_vec, 'LineWidth', 1.5, 'Color', [0.8500, 0.3250, 0.0980, 0.4], 'HandleVisibility', visibility);

    best_objective_matrix = [best_objective_matrix; best_objective_vec];
    weight_error_matrix = [weight_error_matrix; weight_error_vec];

    ground_truth_error = [ground_truth_error best_objective_vec(end)];
    weights_error = [weights_error weight_error_vec(end)];
    individual_weights_error = [individual_weights_error; abs(best_weights - weights)];
end

plot(mean(best_objective_matrix, 1), 'LineWidth', 3, 'Color', [0, 0.4470, 0.7410, 1.0]);
plot(mean(weight_error_matrix, 1), 'LineWidth', 3, 'Color', [0.8500, 0.3250, 0.0980, 1.0]);
legend('Objective (Sample)', 'Weights (Sample)', 'Objective (Mean)', 'Weights (Mean)', 'Location', 'northoutside', 'Orientation', 'horizontal');


function weights = readWeights(weights_path)
    weight_cell = importdata(weights_path);
    weight_str = weight_cell{1};
    weight_str_interior = weight_str(3:end-2);
    weights_in_cell = strsplit(weight_str_interior, ', ');
    n_weights = length(weights_in_cell);
    weights = zeros(1, n_weights);
    for i = 1:n_weights
        weights(i) = str2num(weights_in_cell{i});
    end
end

function [samples, objectives] = readHistory(history_path)
    history_matrix = importdata(history_path);
    history_length = size(history_matrix, 2);
    samples = history_matrix(:, 1:history_length - 2);
    missing_weight = 1 - sum(samples, 2);
    samples = [samples, missing_weight];
    objectives = history_matrix(:, history_length - 1);
end

function [best_objective_vec, weight_error_vec, best_weights] = ...
    getBestHistory(objectives, samples, weights)
    len = length(objectives);
    best_objective_vec = zeros(1, len);
    weight_error_vec = zeros(1, len);
    best_objective_vec(1) = objectives(1);
    best_weights = samples(1, :);
    weight_error_vec(1) = sqrt(sum((best_weights - weights).^2));
    for i = 2:len
        if objectives(i) < best_objective_vec(i - 1)
            best_objective_vec(i) = objectives(i);
            best_weights = samples(i, :);
            weight_error_vec(i) = sqrt(sum((best_weights - weights).^2));
        else
            best_objective_vec(i) = best_objective_vec(i - 1);
            weight_error_vec(i) = weight_error_vec(i - 1);
        end
    end
end