n_iterations = length(iterations);
values = zeros(n_iterations, length(function_names));
for i = 1:length(iterations)
    data = load(['results' num2str(iterations(i)) '.mat']);
    values(i, :) = data.(mode).(method);
end
figure;
bar(values');
set(gca, 'YScale', 'log');
legend(strsplit(num2str(iterations)));
xticklabels(function_names);
title('Surrogate - Noisy - Minimum vs # Iterations');
ylabel('Objective Value');
set(gca, 'FontSize', 15);