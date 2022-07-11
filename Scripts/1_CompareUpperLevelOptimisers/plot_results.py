import matplotlib.pyplot as plt
import json
import numpy as np

METHODS = ['Bayesopt', 'RBF', 'CMA-ES']
FUNCTIONS = ['SchafferF6', 'Sphere', 'Griewank', 'Rastrigin', 'Rosenbrock']
MIN_YLIM = 1e-16

def plotBar(axes, data, title, ylims, ylabel, x_labels, y_labels, log=False):
    n = len(x_labels)
    m = len(y_labels)
    for i in range(0, n):
        x = np.linspace(i + 1, 2 * (m + 1) + i + m, m)
        axes.bar(x, data[i, :], label = METHODS[i])
        axes.title.set_text(title)
        axes.set_ylabel(ylabel)
        if log:
            axes.set_yscale('log')
        axes.set_ylim(ylims)
        xtick_points = [(n + 1) / 2 + j * (n + 1) for j in range(1, m + 1)]
        axes.set_xticks(xtick_points, FUNCTIONS)
        axes.legend()

def getYLims(array):
    min_lim, max_lim = MIN_YLIM, MIN_YLIM
    if np.min(array) > 0:
        min_lim = np.min(array)
    if np.max(array) > 0:
        max_lim = np.max(array)
    ylims = [min_lim * (1 - 0.1 * np.sign(min_lim)), 
        max_lim * (1 + 0.1 * np.sign(max_lim))] 
    return ylims

def customPlot(data, m, title, ylabel):

    # Compute appropriate ylims
    ylims = getYLims(data)

    # Partition data
    d_data = data[:, :m]
    n_data = data[:, m:]

    # Create overall figure
    fig = plt.figure()
    fig.suptitle(title)

    # Add deterministic and noisy plots in turn
    d_fig = fig.add_subplot(1, 2, 1)
    plotBar(d_fig, d_data, 'Deterministic', ylims, ylabel, METHODS, FUNCTIONS, log=True)
    n_fig = fig.add_subplot(1, 2, 2)
    plotBar(n_fig, n_data, 'Noisy', ylims, ylabel, METHODS, FUNCTIONS, log=True)

    # Add some overall figure text & show
    fig.text(0.5, 0.04, 'Optimisation Functions', ha='center', va='center', rotation='horizontal')
    plt.show()


if __name__ == "__main__":
    save_file = "py_results100.json"

    with open(save_file, 'r') as f:
        data = json.load(f)

    # Organise data
    time_data = np.array(data['times'])
    value_data = np.array(data['values'])
    value_data[0, :] = -value_data[0, :]
    m = int(np.size(time_data, 1)/2)

    # Plot time data
    customPlot(time_data, m, 'Time', 'Time (s)')

    # Plot value data
    customPlot(value_data, m, 'Obtained Minima', 'Function Value')
