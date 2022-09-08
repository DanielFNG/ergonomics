s0_unperturbed = [0.0008, 0.6963, 0.303, 0, 0];
s0_perturbed = [0.27766, 0.00201899, 0.22170572, 0.057030374, 0.236];
s1_unperturbed = [0.09707, 0.0002286, 0.3953416, 0.0051325, 0.2389984];
s1_perturbed = [0, 0.012, 0.952, 0.003, 0.003];
s2_unperturbed = [0.247864, 0, 0.439499, 0.00278, 0.0429153];
s2_perturbed = [0.310438, 0.0995925, 0.416597, 0.0774961, 0];

s0_unperturbed(end + 1) = 1 - sum(s0_unperturbed);
s0_perturbed(end + 1) = 1 - sum(s0_perturbed);
s1_unperturbed(end + 1) = 1 - sum(s1_unperturbed);
s1_perturbed(end + 1) = 1 - sum(s1_perturbed);
s2_unperturbed(end + 1) = 1 - sum(s2_unperturbed);
s2_perturbed(end + 1) = 1 - sum(s2_perturbed);

bar_plot(s0_unperturbed, s0_perturbed, 's0');
bar_plot(s1_unperturbed, s1_perturbed, 's1');
bar_plot(s2_unperturbed, s2_perturbed, 's2');

rmse = [0.1422, 0.5269; 0.6660, 0.616366; 0.5749, 0.6081];
figure;
bar(rmse');
title('RMSE');
xticklabels({'stable', 'unperturbed'});
legend('S0', 'S1', 'S2');
set(gca, 'FontSize', 15);

function bar_plot(unperturbed, perturbed, plot_title)
    figure;
    bar([unperturbed; perturbed]);
    xticklabels({'stable', 'unperturbed'});
    legend('effort', 'stability', 'lumbar', 'hip', 'knee', 'ankle');
    set(gca, 'FontSize', 15);
    ylim([0 1]);
    title(plot_title);
end