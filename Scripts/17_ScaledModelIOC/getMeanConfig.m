% Mode selection
mode = 'perturbed';

% Get file paths
root = [mode filesep 'ik'];
[n, files] = getFilePaths(root, '.mot');

% Open an initial file to initialise the config array
file = Data(files{1});
config = zeros(n, file.NCols - 1);

% Step through storing the initial configurations
for i = 1:n
    file = Data(files{i});
    row = file.getRow(1);
    config(i, :) = row(2:end);
end

% Compute the mean configuration and save it in a table
labels = file.Labels(2:end);
mean_config = array2table(mean(config, 1), 'VariableNames', labels);

% Set pelvis_tx to 0 without loss of generality
mean_config.pelvis_tx = 0;