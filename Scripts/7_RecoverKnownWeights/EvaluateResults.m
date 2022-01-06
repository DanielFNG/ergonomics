% Data directories
reference_path = 'reference.sto';
save_dir = '/Users/daniel/Documents/GitHub/ergonomics/Output/7_RecoverKnownWeights';
cma1 = [save_dir filesep 'First CMAES'];
cma2 = [save_dir filesep 'Second CMAES'];
bopt = [save_dir filesep 'First Bayesopt'];
save_dirs = {cma1, cma2, bopt};

% Upper-level objective settings
upper_objective = @sumSquaredStateDifference;
reference = Data(reference_path);
labels = reference.Labels(1:end - 6);
upper_args = {reference, labels};

% Main pass
n_dirs = length(save_dirs);
dir_results = cell(n_dirs, 1);
overall_results = [];
overall_weights = [];
for d = 1:length(save_dirs)
    [n, paths] = getFilePaths(save_dirs{d}, '.sto');
    results = zeros(n, 1);
    for i = 1:n
        % Save weights
        [~, filename] = fileparts(paths{i});
        one = strsplit(filename, '=');
        one = one(2:end);
        for j = 1:6
            parts = strsplit(one{j}, '_');
            one{j} = parts{1};
        end
        for j = 1:7
            weights(j) = str2num(one{j});
        end
        if min(weights) > 0 % Ignore negative weights
            overall_weights = [overall_weights; weights];
        end
        
        % Get objectives
        try
            solution = Data(paths{i});
        catch
            fprintf('Solution at path %s has nans, replacing with 0.\n', paths{i});
            [values, labs, header] = MOTSTOTXTData.load(paths{i});
            values(isnan(values)) = 0;
            solution = STOData(values, header, labs);
        end
            results(i) = abs(gradeSitToStand(solution, upper_objective, upper_args, []) - baseline_result);
            if min(weights) > 0 
                overall_results = [overall_results results(i)];
            end
    end
    dir_results{d} = results;
    figure;
    bar(results);
    [~, name] = fileparts(save_dirs{d});
    title(name);
    xlabel('Iterations');
    ylabel('Sum Squared State Difference');
    set(gca, 'FontSize', 15);
end

% Overall minimum
mins = [min(dir_results{1}), min(dir_results{2}), min(dir_results{3})]; 
figure;
bar(mins);
xticklabels({'CMA1', 'CMA2', 'BayesOpt'});
ylabel('Lowest Obtained Objective');
set(gca, 'FontSize', 15);