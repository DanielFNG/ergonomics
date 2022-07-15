import optimisation_functions as opt
import numpy as np
from bayes_opt import BayesianOptimization
import rbfopt
import cma
import PyNomad
import time
import json

PATH_TO_BONMIN = "~/External/bonmin-binary/bonmin"
PATH_TO_IPOPT = "~/External/ipopt-binary/ipopt"
BAYESOPT_ID = "bayesopt"
RBF_ID = "rbf"
CMA_ID = "cma"
NOMAD_ID = "nomad"

def solve_bayesopt(func, dim, bounds, max_evals):
    init_evals = 4
    variables = [('x' + str(index)) for index in range(0, dim)]
    pbounds = dict(zip(variables, bounds))

    def objective(**kwargs):
        return func(list(kwargs.values()))

    optimiser = BayesianOptimization(objective, pbounds, random_state=1)
    optimiser.maximize(init_points = init_evals, n_iter = max_evals - init_evals)
    return -optimiser.max['target']


def solve_rbf(func, dim, lbs, ubs, types, max_evals):

    bb = rbfopt.RbfoptUserBlackBox(dim, lbs, ubs, types, func)
    settings = rbfopt.RbfoptSettings(
        minlp_solver_path = PATH_TO_BONMIN,
        nlp_solver_path = PATH_TO_IPOPT,
        max_evaluations = max_evals
    )
    alg = rbfopt.RbfoptAlgorithm(settings, bb)
    val, _, _, _, _ = alg.optimize()
    return val

def solve_cma(func, dim, lb, ub, max_evals):
    sigma = 0.5
    x0 = (ub - lb) * np.random.sample(dim) + lb
    x, es = cma.fmin2(func, x0, sigma, {'bounds': [lb, ub], 'maxfevals': max_evals})
    return es.result.fbest

def solve_nomad(func, dim, lb, ub, max_evals):
    def objective(x):
        vals = [x.get_coord(i) for i in range(x.size())]
        f = func(vals)
        x.setBBO(str(f).encode("UTF-8"))
        return 1

    x0 = np.random.uniform(0, 1, dim)
    lb = [0] * dim
    ub = [1] * dim

    params = ["DIMENSION " + str(dim), "BB_OUTPUT_TYPE OBJ", 
        "MAX_BB_EVAL " + str(max_evals), "DIRECTION_TYPE ORTHO N+1 UNI",
        "ANISOTROPIC_MESH no"] 

    return PyNomad.optimize(objective, x0, lb, ub, params)

if __name__ == '__main__':
    max_evals = 1000
    methods = ["nomad"] # "Bayesopt", "RBF", "CMA", "Nomad"
    methods = [x.lower() for x in methods]
    save_file = "py_results" + str(max_evals) + ".json"
    noise_level = 0.1
    dimensions = [2, 5, 10, 10, 10] * 2
    lbs = [-100, -100, -600, -5.12, -50] * 2
    deterministic_functions = [opt.schafferF6, opt.sphere, opt.griewank, opt.rastrigin, opt.rosenbrock]
    noisy_functions = [lambda x, func=func: func(x) + abs(np.random.normal(0, noise_level)) for func in deterministic_functions]
    functions = deterministic_functions + noisy_functions
    times = [[] for _ in range(len(methods))]
    values = [[] for _ in range(len(methods))]

    for func, dim, lb in zip(functions, dimensions, lbs):

        # Bayesian optimisation
        if BAYESOPT_ID in methods:
            init_samples = 4
            bounds = [[lb, -lb]]*dim
            func_inverted = lambda x: -func(x)
            t = time.time()
            index = methods.index(BAYESOPT_ID)
            values[index].append(solve_bayesopt(func_inverted, dim, bounds, max_evals))
            times[index].append(time.time() - t)

        # RBF optimisation
        if RBF_ID in methods:
            lower_bounds = np.array([lb] * dim)
            upper_bounds = -lower_bounds
            types = np.array(['R'] * dim)
            t = time.time()
            index = methods.index(RBF_ID)
            values[index].append(solve_rbf(func, dim, lower_bounds, upper_bounds, types, max_evals))
            times[index].append(time.time() - t)

        # CMA-ES
        if CMA_ID in methods:
            t = time.time()
            index = methods.index(CMA_ID)
            values[index].append(solve_cma(func, dim, lb, -lb, max_evals))
            times[index].append(time.time() - t)

        # Nomad
        if NOMAD_ID in methods:
            t = time.time()
            index = methods.index(NOMAD_ID)
            n = solve_nomad(func, dim, lb, -lb, max_evals)
            values[index].append(n['f_best'])
            times[index].append(time.time() - t)

    overall_times = [sum(inner_time) for inner_time in times]
    save_data = {"methods": methods, "times": overall_times, "values": values}
    with open(save_file, 'w') as f:
        json.dump(save_data, f, indent = 4)
