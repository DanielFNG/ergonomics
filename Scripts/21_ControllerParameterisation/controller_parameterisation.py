import numpy as np
import matplotlib.pyplot as plt
import numpy.polynomial as poly

def controller(locations, magnitudes):
    locs = np.array(locations)
    vals = np.array(magnitudes)

    # Check locs are ordered
    n_points = len(locs)
    if not (all(locs[i] <= locs[i + 1]) for i in range(n_points - 1)):
        raise Exception('Need ordered list of point locations.')

    # Check values within bounds
    if not (max(vals) <= 1 and min(vals) >= 0):
        raise Exception('Controls must be bounded within 0 and 1.')

    x = np.linspace(0, 100, 101)
    y = np.linspace(0, 100, 101)

    y[0] = vals[0]
    for i in range(0, n_points - 1):
        x_dist = locs[i + 1] - locs[i]
        if x_dist > 0:
            x_range = np.linspace(1, x_dist, x_dist)
            lam = np.pi/x_dist
            magnitude = (vals[i+1] - vals[i])/2
            v_offset = magnitude + vals[i]
            freq_offset = -np.pi/2
            y[locs[i] + 1:locs[i+1] + 1] = magnitude*np.sin(lam * x_range + freq_offset) + v_offset

    return x, y

if __name__ == "__main__":
    l1 = [0, 50, 100]
    l2 = [0, 25, 50, 75, 100]
    v1 = [0, 0.972, 0]
    v2 = [0.884, 0.976, 0.298]
    v3 = [0, 0.993, 0.990, 1.0, 0]
    v4 = [0, 1, 1, 1, 0]
    x1, y1 = controller(l1, v1)
    x2, y2 = controller(l1, v2)
    x3, y3 = controller(l2, v3)
    x4, y4 = controller(l2, v4)
    plt.plot(x1, y1, 'g--')
    plt.plot(x2, y2, 'r--')
    plt.plot(x3, y3, 'b--')
    plt.plot(x4, y4, 'c--')
    plt.show()