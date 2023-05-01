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
    x = [0, 25, 50, 75, 100]
    y = [0,
        0.76999999999992,
        0.054,
        0.009, 0
    ]
    x1, y1 = controller(x, y)
    x = [0, 17, 34, 51, 68, 85, 100]
    y = [0,
        0.7,
        0.095,
        0.068,
        0.2,
        0.55, 0
    ]
    x2, y2 = controller(x, y)
    x = [0,
        11,
        63,
        66, 100]
    y = [0,
        0.90614182174349,
        0.0,
        0.0, 0
    ]
    x3, y3 = controller(x, y)
    plt.plot(x1, y1, 'g--')
    plt.plot(x2, y2, 'r--')
    plt.plot(x3, y3, 'b--')
    plt.show()