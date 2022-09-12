root = '/home/danielfng/Documents/Local Ergonomics Results/Ground Truth Weight Recovery';
samples = 0:16;

best_objective_plot = figure;
xlabel('Iterations');
ylabel('RMSE');
title('Objective');
set(gca, 'FontSize', 12);
set(gca, 'YScale', 'log');
hold on;
weight_error_plot = figure;
title('Weights Error');
xlabel('Iterations');
ylabel('Euclidian Distance');
set(gca, 'FontSize', 12);
hold on;

for sample = samples
    results_folder = [root filesep num2str(sample)];

    weights_path = [results_folder filesep 'weights.txt'];
    history_path = [results_folder filesep 'history.0.txt'];
   
    weights = readWeights(weights_path);
    [samples, objectives] = readHistory(history_path);
    
    [best_objective_vec, weight_error_vec, best_weights] = getBestHistory(objectives, samples, weights);

    figure(best_objective_plot);
    plot(best_objective_vec, 'LineWidth', 1.5);

    figure(weight_error_plot);
    plot(weight_error_vec, 'LineWidth', 1.5);
end


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