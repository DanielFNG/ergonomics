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
    locations = [0, 20, 40, 60, 80, 100]
    values = [0, 0.9, 1, 1.0, 0.5, 0]
    locs2 = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
    values2 = [0, 0.9,
        0.9,
        0.9,
        0.1181,
        0.1,
        0.1031,
        0.1271,
        0.8,
        0.2001, 
        0
    ]
    locs3 = [0, 20, 40, 60, 80, 100]
    values3 = [0, 0.338, 0.0, 1.0, 0.1, 0]
    xc, yc = controller(locations, values)
    xp, yp = controller(locs2, values2)
    xd, yd = controller(locs3, values3)
    #plt.plot(locations, values, 'b--')
    plt.plot(xc, yc, 'g--')
    plt.plot(xp, yp, 'r--')
    plt.plot(xd, yd, 'b--')
    plt.show()