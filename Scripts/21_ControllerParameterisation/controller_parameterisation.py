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
    values = [0, 0.1, 1, 0.7, 0.7, 0]
    xc, yc = controller(locations, values)
    plt.plot(locations, values, 'b--')
    plt.plot(xc, yc, 'g--')
    plt.show()