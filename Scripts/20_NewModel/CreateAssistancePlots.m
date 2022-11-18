files = {'stability', 'lumbar', 'combined', 'combined_ankle'};
label = '/apo';

figure;
hold on;
for i = 1:length(files)
    file = Data(['results' filesep files{i} '.sto']);
    vec = file.getColumn(label);
    plot(0:100, vec*200, 'LineWidth', 2);
end

legend(files, 'Interpreter', 'none');
xlabel('% of Motion');
ylabel('Torque (Nm)');
set(gca, 'FontSize', 20);
title('APO Assistance');