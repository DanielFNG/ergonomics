root = uigetdir('Choose root data folder');
files = {'stability', 'lumbar', 'combined', 'combined_ankle'};
label = '/forceset/apo';
apo_torque = 150;

figure;
hold on;
for i = 1:length(files)
    file = Data([root filesep files{i} '.sto']);
    vec = file.getColumn(label);
    plot(0:100, vec*apo_torque, 'LineWidth', 2);
end

legend(files, 'Interpreter', 'none');
xlabel('% of Motion');
ylabel('Torque (Nm)');
set(gca, 'FontSize', 20);
title('APO Assistance');