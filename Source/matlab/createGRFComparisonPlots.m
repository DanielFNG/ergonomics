function createGRFComparisonPlots(grf_dir, output_dir)

    % Load GRF data
    [n, files] = getFilePaths(grf_dir, '.sto');
    grfs = cell(1, n);
    names = cell(1, n);
    for i = 1:n
        [~, names{i}] = fileparts(files{i});
        grfs{i} = Data(files{i});
    end
    
    % Assume labels are consistent between files
    labels = grfs{1}.Labels(2:end);
    
    % Open figure
    f = figure;
    
    % Create & save plots 
    for i = 1:length(labels)
        hold on;
        for j = 1:n
            timesteps = grfs{j}.Timesteps/grfs{j}.Timesteps(end)*100;
            plot(timesteps, grfs{j}.getColumn(labels{i}), 'LineWidth', 2);
        end
        xlabel('% of Motion');
        ylabel('Quantity (N, m, or Nm)');
        title(labels{i}, 'Interpreter', 'none');
        legend(names);
        saveas(gcf, [output_dir filesep labels{i} '.png']);
        clf;
    end
    
    % Close figure
    close(f);

end