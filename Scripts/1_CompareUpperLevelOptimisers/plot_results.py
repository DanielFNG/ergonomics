import matplotlib.pyplot as plt
import json
import numpy as np

FUNCTIONS = ['SchafferF6', 'Sphere', 'Griewank', 'Rastrigin', 'Rosenbrock']
MIN_YLIM = 1e-16

def plotMultiBar(axes, data, title, ylims, ylabel, labels, x_labels, log=False):
    n = len(labels)
    m = len(x_labels)
    for i in range(0, n):
        x = [i + 1 + j * (n + 1) for j in range(0, m)]
        axes.bar(x, data[i, :], label = labels[i])
        axes.title.set_text(title)
        axes.set_ylabel(ylabel)
        if log:
            axes.set_yscale('log')
        axes.set_ylim(ylims)
        xtick_points = [(n + 1) / 2 + j * (n + 1) for j in range(0, m)]
        axes.set_xticks(xtick_points, x_labels)
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

def customTimePlot(data, methods, title, ylabel):

    # Compute appropriate ylims
    ylims = getYLims(data)

    # Create overall figure
    fig = plt.figure()

    # Add time plot
    ax = fig.add_subplot(1, 1, 1)
    ax.bar(methods, data)
    ax.set_title(title)
    ax.set_ylabel(ylabel)
    ax.set_ylim(ylims)

def customValuePlot(data, m, methods, title, ylabel, ylims):

    # Partition data
    d_data = data[:, :m]
    n_data = data[:, m:]

    # Create overall figure
    fig = plt.figure()
    fig.suptitle(title)

    # Add deterministic and noisy plots in turn
    d_fig = fig.add_subplot(1, 2, 1)
    plotMultiBar(d_fig, d_data, 'Deterministic', ylims, ylabel, methods, FUNCTIONS, log=True)
    n_fig = fig.add_subplot(1, 2, 2)
    plotMultiBar(n_fig, n_data, 'Noisy', ylims, ylabel, methods, FUNCTIONS, log=True)

    # Add some overall figure text & show
    fig.text(0.5, 0.04, 'Optimisation Functions', ha='center', va='center', rotation='horizontal')


if __name__ == "__main__":
    
    files = None # List of strings - paths to results .json files

    data_combined = []
    values_combined = []
    for file in files:
        with open(file, 'r') as f:
            data = json.load(f)
            data_combined.append(data)
            values_combined += data['values']

    # Get some common YLims for comparison's sake
    ylims = getYLims(np.array(values_combined))

    for file, data in zip(files, data_combined):

        # Organise data
        time_data = np.array(data['times'])
        value_data = np.array(data['values'])
        m = int(np.size(value_data, 1)/2)

        # Plot time data
        customTimePlot(time_data, data['methods'], 'Time ' + file, 'Time (s)')

        # Plot value data
        customValuePlot(value_data, m, data['methods'], 'Obtained Minima ' + file, 'Function Value', ylims)

    # Show all figs
    plt.show()
