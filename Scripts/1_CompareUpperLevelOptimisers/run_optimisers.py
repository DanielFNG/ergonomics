import optimisation_functions as opt
import numpy as np
from bayes_opt import BayesianOptimization
import rbfopt
import cma
import time
import json

PATH_TO_BONMIN = "~/External/bonmin-binary/bonmin"
PATH_TO_IPOPT = "~/External/ipopt-binary/ipopt"


def solve_bayesopt(func, dim, bounds, max_evals):
    init_evals = 4
    variables = [('x' + str(index)) for index in range(0, dim)]
    pbounds = dict(zip(variables, bounds))

    def objective(**kwargs):
        return func(list(kwargs.values()))

    optimiser = BayesianOptimization(objective, pbounds, random_state=1)
    optimiser.maximize(init_points = init_evals, n_iter = max_evals - init_evals)
    return optimiser.max['target']


def solve_rbf(func, dim, lbs, ubs, types, max_evals):

    bb = rbfopt.RbfoptUserBlackBox(dim, lbs, ubs, types, func)
    settings = rbfopt.RbfoptSettings(
        minlp_solver_path = PATH_TO_BONMIN,
        nlp_solver_path = PATH_TO_IPOPT,
        max_evaluations = max_evals
    )
    alg = rbfopt.RbfoptAlgorithm(settings, bb)
    val, x, itercount, evalcount, fast_evalcount = alg.optimize()
    return val

def solve_cma(func, dim, lb, ub, max_evals):
    sigma = 0.5
    x0 = (ub - lb) * np.random.sample(dim) + lb
    x, es = cma.fmin2(func, x0, sigma, {'bounds': [lb, ub], 'maxfevals': max_evals})
    return es.result.fbest

if __name__ == '__main__':
    max_evals = 100
    save_file = "py_results" + str(max_evals) + ".json"
    noise_level = 1
    dimensions = [2, 5, 10, 10, 10] * 2
    lbs = [-100, -100, -600, -5.12, -50] * 2
    deterministic_functions = [opt.schafferF6, opt.sphere, opt.griewank, opt.rastrigin, opt.rosenbrock]
    noisy_functions = [lambda x: func(x) + abs(np.random.normal(0, noise_level)) for func in deterministic_functions]
    functions = deterministic_functions + noisy_functions
    n_deterministic_functions = len(deterministic_functions)
    n_functions = len(functions)
    times = [[], [], []]
    values = [[], [], []]

    for func, dim, lb in zip(functions, dimensions, lbs):

        # Bayesian optimisation
        init_samples = 4
        bounds = [[lb, -lb]]*dim
        func_inverted = lambda x: -func(x)
        t = time.time()
        values[0].append(solve_bayesopt(func_inverted, dim, bounds, max_evals))
        times[0].append(time.time() - t)

        # RBF optimisation
        lower_bounds = np.array([lb] * dim)
        upper_bounds = -lower_bounds
        types = np.array(['R'] * dim)
        t = time.time()
        values[1].append(solve_rbf(func, dim, lower_bounds, upper_bounds, types, max_evals))
        times[1].append(time.time() - t)

        # CMA-ES
        t = time.time()
        values[2].append(solve_cma(func, dim, lb, -lb, max_evals))
        times[2].append(time.time() - t)

    save_data = {"times": times, "values": values}
    with open(save_file, 'w') as f:
        json.dump(save_data, f, indent = 4)