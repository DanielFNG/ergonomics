% Gather inputs
normalise_dir = [pwd filesep 'Normalised'];
n_points = 101;
labels = {'center_of_mass_X', 'center_of_mass_Y', 'center_of_mass_Z'};

% Get BK files
[n, files] = getFilePaths(normalise_dir, '.sto');

% Initialise matrices
com = zeros(n_points, n, 3);
means = zeros(n_points, 3);
sdevs = zeros(n_points, 3);

% Get X/Y/Z CoM positions
for i = 1:n
    positions = Data(files{i});
    for j = 1:3
        com(:, i, j) = stretchVector(positions.getColumn(labels{j}), n_points);
    end
end

% Compute means & standard deviations 
for i = 1:3
    means(:, i) = mean(com(:, :, i), 2);
    sdevs(:, i) = std(com(:, :, i), 0, 2);
end

% Visualise results
plotShadedSDevs({com(:, :, 1)', com(:, :, 2)'}, {'X', 'Y'}, '% of Movement', 'Position (m)', 0:100)
