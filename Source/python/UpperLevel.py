import rbfopt
import numpy as np

PATH_TO_BONMIN = "~/External/bonmin-binary/bonmin"
PATH_TO_IPOPT = "~/External/ipopt-binary/ipopt"

IDEAL_OPTIMISED_COST = 10
LOWER_BOUND = 0
UPPER_BOUND = 1

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

class UpperLevel():

    def __init__(self, lower_level, reference_set, dim):
        self.lower_level = lower_level
        self.reference_set = reference_set
        self.dim = dim
        self.normalisers = self.computeNormalisers()

    def computeNormalisers(self):
        normalisers = []
        input = [0 for i in range(self.dim)]
        for i in range(self.dim):
            input[i] = 1
            sol = self.sample(input)
            cost = sol.getObjective()
            normalisers.append(cost/IDEAL_OPTIMISED_COST)
            input[i] = 0
    
    def sample(self, weights):
        return self.lower_level.run(weights)

    def compare(self, solution):
        values = [solution.compareContinuousVariablesRMS(reference) for reference in self.reference_set]
        return np.mean(values)

    def objective(self, weights):
        sol = self.sample(np.divide(weights, self.normalisers))
        return self.compare(sol)

    def optimise(self):
        
        lbs = np.array([LOWER_BOUND] * self.dim)
        objective = lambda weights: self.objective(weights)
        solve_rbf(objective, self.dim, ) 

