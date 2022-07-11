import matplotlib.pyplot as plt
import json
import numpy as np

save_file = "py_results100.json"

with open(save_file, 'r') as f:
    data = json.load(f)

n = len(data['times'][0])
m = int(n/2)
n_sets = 6
colours = ['r', 'g', 'b']
labels = ['Bayesopt', 'RBF', 'CMA-ES']
fig = plt.figure()
ax1 = fig.add_subplot(1, 2, 1)
ax2 = fig.add_subplot(1, 2, 2)
for i in range(0, 3):
    x = np.linspace(i + 1, 2 * (m + 1) + i + m, m)
    ax1.bar(x, data['times'][i][:m], label=labels[i])
    ax2.bar(x, data['times'][i][m:], label=labels[i])
    ax1.title.set_text('Deterministic')
    ax2.title.set_text('Noisy')
    ax1.set_ylabel('Time (s)')
    ax2.set_ylabel('Time (s)')
    ax1.set_yscale('log')
    ax2.set_yscale('log')
    y_max = 1.1*max(max(data['times']))
    y_min = 0.9*min(min(data['times']))
    ax1.set_ylim([y_min, y_max])
    ax2.set_ylim([y_min, y_max])
    ax1.set_xticks([2, 6, 10, 14, 18], ['SchafferF6', 'Sphere', 'Griewank', 'Rastrigin', 'Rosenbrock'])
    ax2.set_xticks([2, 6, 10, 14, 18], ['SchafferF6', 'Sphere', 'Griewank', 'Rastrigin', 'Rosenbrock'])
    fig.text(0.5, 0.04, 'Optimisation Functions', ha='center', va='center', rotation='horizontal')
    ax1.legend()
    ax2.legend()
plt.show()