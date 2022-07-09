import numpy as np

def sphere(x):
    return sum(np.power(x, 2))

def schafferF6(x):
    return 0.5 + ((np.sin(np.sqrt(x[0]**2 + x[1]**2)))**2 - 0.5)/(1 + 0.001*(x[0]**2 + x[1]**2))

def griewank(x):
    n = len(x)
    return 1/4000 * sum(np.power(x, 2)) - np.prod(np.cos(x / np.sqrt(np.linspace(1, n, n)))) + 1

def rastrigin(x):
    A = 10
    n = len(x)
    return A * n + sum(np.power(x, 2) - A * np.cos(np.multiply(x, 2 * np.pi)))


def rosenbrock(x):
    y = x[1:] - np.power(x[:-1], 2)
    return sum(100*np.power(y, 2) + np.power(np.subtract(1, x[:-1]), 2)) 