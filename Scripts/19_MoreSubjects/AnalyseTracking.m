solution = 's2/perturbed/ioc_solution.sto';
ref_folder = 's2/perturbed/sols';
m = 101;
labels = {'/jointset/lumbar/lumbar/value', ...
    '/jointset/hip_r/hip_flexion_r/value', ...
    '/jointset/knee_r/knee_angle_r/value', ...
    '/jointset/ankle_r/ankle_angle_r/value'};

[n, files] = getFilePaths(ref_folder, '.sto');

sol = Data(solution);
ref = cell(1, n);
for i = 1:n
    ref{i} = Data(files{i});
end

for i = 1:length(labels)
    sol_vec = sol.getColumn(labels{i});
    values = zeros(n, m);
    for j = 1:n
        ref_vec = ref{j}.getColumn(labels{i});
        values(j, :) = stretchVector(ref_vec, m);
    end
    plotShadedSDevs({values}, {'Data'}, '% of Motion', 'Angle (deg)', 0:100);
    hold on;
    plot(stretchVector(sol_vec, m), 'LineWidth', 2);
    legend('Data', 'Solution');
    title(labels{i}, 'Interpreter', 'none');
end