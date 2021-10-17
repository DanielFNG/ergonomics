%% Define inputs
model = 'gait2392_markers_scaled.osim';
data_dir = [pwd filesep 'Data'];
output_dir = createOutputFolder(pwd);
bk_settings = 'bk.xml';
n_points = 101;
labels = {'center_of_mass_X', 'center_of_mass_Y', 'center_of_mass_Z'};

%% Produce Normalised BK

% Directories
bk_dir = [output_dir filesep 'BK'];
normalise_dir = [output_dir filesep 'Normalised'];
mkdir(normalise_dir);

% Get marker data
[n, files] = getFilePaths(data_dir, '.mot');

% Specify 

% For each IK...
for i = 1:n
    
    % Run Body Kinematics
    runAnalyse(num2str(i), model, files{i}, [], bk_dir, bk_settings);
    
    % Identify start/end times for the sit-to-stand
    velocity = Data([bk_dir filesep num2str(i) ...
        '_BodyKinematics_vel_global.sto']);
    [start, finish] = findSitToStandTimes(velocity);
    
    % Slice the BK position 
    bk = Data([bk_dir filesep num2str(i) '_BodyKinematics_pos_global.sto']);
    bk = bk.slice(start, finish);
    bk.writeToFile([normalise_dir filesep num2str(i) '_BK_Positions']);
    
end

%% Produce Mean CoM Trajectories

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
