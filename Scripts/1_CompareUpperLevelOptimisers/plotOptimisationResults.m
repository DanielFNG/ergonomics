% Gather data in to suitable arrays
n_methods = 3;
n_functions = 5;
dvals = zeros(n_methods, n_functions);
nvals = dvals;
for i = 1:n_functions
    dvals(1, i) = deterministic.bayesopt(i);
    dvals(2, i) = deterministic.surrogate(i);
    dvals(3, i) = deterministic.ga(i);
    nvals(1, i) = noisy.bayesopt(i);
    nvals(2, i) = noisy.surrogate(i);
    nvals(3, i) = noisy.ga(i);
end

% Plot 
figure;
bar(dvals');
set(gca, 'YScale', 'log');
legend('Bayesopt', 'Surrogate', 'GA');
xticklabels(function_names);
set(gca, 'FontSize', 15);
ylabel('Obtained Minimum');
title(['Deterministic (' num2str(max_evaluations) ' evals)']);
ylim([1e-4, 1e8]);

figure;
bar(nvals');
set(gca, 'YScale', 'log');
legend('Bayesopt', 'Surrogate', 'GA');
xticklabels(function_names);
set(gca, 'FontSize', 15);
ylabel('Obtained Minimum');
title(['Noisy (' num2str(max_evaluations) ' evals)']);
ylim([1e-4, 1e8]);

figure;
b = bar(1:3, [time.bayesopt time.surrogate time.ga]./60);
set(gca, 'YScale', 'log');
xticklabels({'Bayesopt', 'Surrogate', 'GA'});
set(gca, 'FontSize', 15);
ylabel('Time (min)');
title(['Time (' num2str(max_evaluations) ' evals)']);
b.DataTipTemplate.DataTipRows(1) = [];
b.DataTipTemplate.DataTipRows(1).Label = "Time (min)";
datatip(b, 1, time.bayesopt);
datatip(b, 2, time.surrogate);
datatip(b, 3, time.ga);