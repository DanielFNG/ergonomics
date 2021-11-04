output_dir = createOutputFolder(pwd);
image_dir = [output_dir filesep 'images'];
mkdir(image_dir);
model_path = '2D_gait_contact_constrained_activation.osim';
solution_path = 'mos_solution.sto';

[mos, timesteps] = visualiseMoS(model_path, solution_path, image_dir);

figure;
timesteps = timesteps/timesteps(end)*100;
plot(timesteps, mos, 'LineWidth', 2);
xlabel('% of Motion');
ylabel('MoS');
set(gca, 'FontSize', 15);

print([output_dir filesep 'mos'], '-dpng');