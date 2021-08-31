% Gather inputs
model = 'gait2392_markers_scaled.osim';
data_dir = [pwd filesep 'Data'];
analyse_dir = [pwd filesep 'BK'];
normalise_dir = [pwd filesep 'Normalised'];
bk_settings = 'C:\Users\danie\Documents\GitHub\opensim-matlab\Defaults\BK\bk.xml';

% Create normalise directory
mkdir(normalise_dir);

% Get marker data
[n, files] = getFilePaths(data_dir, '.mot');

% For each IK...
for i = 1:n
    
    % Run Body Kinematics
    runAnalyse(num2str(i), model, files{i}, [], analyse_dir, bk_settings);
    
    % Identify start/end times for the sit-to-stand
    velocity = Data([analyse_dir filesep num2str(i) ...
        '_BodyKinematics_vel_global.sto']);
    [start, finish] = findSitToStandTimes(velocity);
    
    % Slice the BK position 
    bk = Data([analyse_dir filesep num2str(i) '_BodyKinematics_pos_global.sto']);
    bk = bk.slice(start, finish);
    bk.writeToFile([normalise_dir filesep num2str(i) '_BK_Positions']);
    
end