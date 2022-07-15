import PyNomad
import cma
import numpy as np
import optimisation_functions as opt
import time
import json

def solve_cma(func, dim, lb, ub, max_evals):

    def constraints(x):
        return [np.sum(x) - 1, -np.sum(x) - 1] # Just saying sum can't be greater than 1
    cfun = cma.ConstrainedFitnessAL(func, constraints)
    sigma = 0.5
    x0 = (ub - lb) * np.random.sample(dim) + lb
    _, es = cma.fmin2(cfun, x0, sigma, {'bounds': [lb, ub], 'maxfevals': max_evals})
    return es, cfun.find_feasible(es)

def solve_nomad(func, dim, lb, ub, max_evals):

    def objective(x):
        vals = [x.get_coord(i) for i in range(x.size())]
        f = func(vals)
        total = np.sum(np.array(vals))
        g = total - 1
        rawBBO = str(f) + " " + str(g)
        x.setBBO(rawBBO.encode("UTF-8"))
        return 1

    x0 = np.random.uniform(0, 1, dim)
    #x0_str = "X0 ( "
    #for i in range(0, dim):
    #    x0_str += str(x0[i]) + " "
    #x0_str += ")"
    lb = [0] * dim
    ub = [1] * dim

    params = ["DIMENSION " + str(dim), "BB_OUTPUT_TYPE OBJ PB", "MAX_BB_EVAL " + str(max_evals)] 
        #x0_str, "LOWER_BOUND * " + str(lb), "UPPER_BOUND * " + str(ub)]

    return PyNomad.optimize(objective, x0, lb, ub, params)

max_evals = 1000
noise_level = 0.1
dimensions = [2, 5, 10, 10, 10] * 2
ubs = [1, 1, 1, 1, 1] * 2
lbs = [0, 0, 0, 0, 0] * 2
deterministic_functions = [opt.schafferF6, opt.sphere, opt.griewank, opt.rastrigin, opt.rosenbrock]
noisy_functions = [lambda x, func=func: func(x) + abs(np.random.normal(0, noise_level)) for func in deterministic_functions]
functions = deterministic_functions + noisy_functions
times = [[], []]
values = [[], []]

for func, dim, lb, ub in zip(functions, dimensions, lbs, ubs):

    # CMA-ES
    t = time.time()
    es, x = solve_cma(func, dim, lb, ub, max_evals)
    if x is None:
        values[0].append(100)
    else:
        values[0].append(func(x))
    times[0].append(time.time() - t)

    # Nomad
    t = time.time()
    n = solve_nomad(func, dim, lb, ub, max_evals)
    values[1].append(n['f_best'])
    times[1].append(time.time() - t)

methods = ['cma', 'nomad']
times[0] = np.sum(np.array(times[0]))
times[1] = np.sum(np.array(times[1]))

save_file = 'py_constrained_results' + str(max_evals) + '.json'
save_data = {"methods": methods, "times": times, "values": values}
with open(save_file, 'w') as f:
    json.dump(save_data, f, indent = 4)
