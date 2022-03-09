% Folder containing data
input_dir = 'dataset';
[n, files] = getFilePaths(input_dir, '.sto');

% Evaluate resulting data
hip = zeros(n, 101);
knee = hip;
ankle = hip;
lumbar = hip;
for i = 1:n
    file_data = Data(files{i});
    hip(i, :) = rad2deg(stretchVector(file_data.getColumn(...
        '/jointset/hip_r/hip_flexion_r/value'), 101));
    knee(i, :) = rad2deg(stretchVector(file_data.getColumn(...
        '/jointset/knee_r/knee_angle_r/value'), 101));
    ankle(i, :) = rad2deg(stretchVector(file_data.getColumn(...
        '/jointset/ankle_r/ankle_angle_r/value'), 101));
    lumbar(i, :) = rad2deg(stretchVector(file_data.getColumn(...
        '/jointset/lumbar/lumbar/value'), 101));
end

plotShadedSDevs({hip, knee, ankle, lumbar}, ...
    {'hip', 'knee', 'ankle', 'lumbar'}, ...
    '% of Motion', 'Angle (deg)', 0:100);