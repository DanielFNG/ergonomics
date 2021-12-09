%% Inputs
model_path = '2D_gait_contact_constrained_activation.osim';
solution_files = {'mos.sto', 'wmos.sto', 'pmos.sto'};
output_names = {'mos', 'wmos', 'pmos'};
contact_list = {'chair_r', 'chair_l', 'contactHeel_l', ...
        'contactFront_l', 'contactFront_r', 'contactHeel_r'};
contact_list_reduced = {'chair', 'contactHeel', 'contactFront'};
output_dir = createOutputFolder('4_EvaluateStability'); % Change if non-default folder needed
nan_value = 1; 
stability_direction = 1; % Corresponds to x direction  

%% Processing & Analysis

% Load model
model = org.opensim.modeling.Model(model_path);

% Create cell array to hold certain outputs
n_sources = length(solution_files);
mos = cell(n_sources, 1);
timesteps = cell(n_sources, 1);

% Create stability figures
mos_fig = figure;
pmos_fig = figure;
wmos_fig = figure;
mos_fig_int = figure;
pmos_fig_int = figure;
wmos_fig_int = figure;
stability_figures = {mos_fig, pmos_fig, wmos_fig};
stability_labels = {'mos', 'pmos', 'wmos'};
integral_figures = {mos_fig_int, pmos_fig_int, wmos_fig_int};
n_stability_figs = length(stability_figures);

% Do the rest in a loop
for i = 1:n_sources
    
    % Make directories
    source_dir = [output_dir filesep output_names{i}];
    image_dir = [source_dir filesep 'evolution'];
    grf_dir = [source_dir filesep 'grfs'];
    graphs_dir = [source_dir filesep 'graphs'];
    mkdir(image_dir);
    mkdir(grf_dir);
    mkdir(graphs_dir);
    
    % Load solution
    solution = Data(solution_files{i});
    
    % Compute stability regions & centroids
    [pbos, bos, wbos] = ...
        computeStabilityRegionEvolution(model, solution, contact_list);
    cpbos = computeCentroidEvolution(pbos);
    cbos = computeCentroidEvolution(bos);
    cwbos = computeCentroidEvolution(pbos, wbos);
    
    % Compute stability criteria
    [com_p, com_v] = computeCoMTrajectories(model, solution);
    xcom = computeXCoM(com_p, com_v);
    xcom = xcom(:, [1, 3]);
    mos = abs(xcom - cbos);
    mos(isnan(mos)) = nan_value;
    pmos = abs(xcom - cpbos);
    wmos = abs(xcom - cwbos);
    
    % Create a gif visualising the input motions
    visualiseStability(image_dir, solution.NFrames, ...
        pbos, bos, wbos, {cpbos, cbos, cwbos, xcom}, ...
        {'cpbos', 'cbos', 'cwbos', 'xcom'});
     
    % Compare stability evolution;
    stability_criteria = {mos, pmos, wmos};
    for j = 1:n_stability_figs
        figure(stability_figures{j});
        hold on;
        plot(solution.Timesteps/solution.Timesteps(end)*100, ...
            stability_criteria{j}(:, stability_direction), 'LineWidth', 2);
    end
    
    % Compare stability integral
    for j = 1:n_stability_figs
        figure(integral_figures{j});
        hold on
        bar(i, trapz(solution.Timesteps, ...
            stability_criteria{j}(:, stability_direction)));
    end

    % Produce grf files
    produceSymmetricGRFData(contact_list_reduced, ...
        model_path, solution_files{i}, grf_dir);

    % Produce grf plots
    createGRFComparisonPlots(grf_dir, graphs_dir);
end

% Finish up stability evolution & integral graphs
for j = 1:n_stability_figs
    figure(stability_figures{j});
    xlabel('% of Motion');
    ylabel(stability_labels{j});
    legend(solution_files{:}, 'Interpreter', 'none');
    set(gca, 'FontSize', 15);
    saveas(gcf, [output_dir filesep stability_labels{j} '.png']);
    close(stability_figures{j});
    
    figure(integral_figures{j});
    title(stability_labels{j});
    xlabel('Optimisation Criteria');
    xticklabels(solution_files);
    xticks(1:n_stability_figs);
    ylabel('Integral');
    set(gca, 'FontSize', 15);
    saveas(gcf, [output_dir filesep stability_labels{j} '_integral.png']);
    close(integral_figures{j});
end


