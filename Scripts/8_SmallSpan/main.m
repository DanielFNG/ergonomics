% Inputs - can in general choose output_dir as any folder containing a
% range of .sto results you want to evaluate the motions for
output_dir = createOutputFolder('8_SmallSpan');
[n, files] = getFilePaths(output_dir, '.sto');

% Generate spanning data if needed
if n == 0
    model_path = '2D_gait_jointspace_welded.osim';
    tracking_path = 'guess.sto';
    for i = 1:52
        for j = 1:5
            for k = 1:5
                w_effort = 0.5*(i - 1);
                w_stability = 0.5*(j - 1);
                w_kload = 0.5*(k - 1);
                weights = [w_effort, w_stability, 0, w_kload, 0];
                output_path = [output_dir filesep ...
                    'w_effort=' num2str(w_effort) ...
                    'w_stability=' num2str(w_stability) ...
                    'w_kload=' num2str(w_kload) '.sto'];
                sitToStandInterface(...
                    model_path, tracking_path, output_path, weights);
            end
        end
    end
    [n, files] = getFilePaths(output_dir, '.sto');
end

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