""" Python implementation of IOC framework """
from asyncio.subprocess import DEVNULL
import os
import subprocess
import tempfile
import numpy
import PyNomad
import json
import opensim

# Low-level options
_UPPER_LIMIT = 1
_LOWER_LIMIT = 0
_IDEAL_OPTIMISED_COST = 1
_PRE_NORMALISERS = [1, 1, 1000, 1000, 1000, 1000]
_N_PARAMETERS = 6
_NORMALISER_FOLDER = "normalisers"
_EXECUTABLE_PRINT = os.path.join(os.getenv("ERGONOMICS_HOME"), "bin", "solveAndPrint")
_OBJECTIVE_STR = "objective="


def run_lower_level_print(output_path, weights, config_path):
    """Runs lower level optimiser and prints result file"""
    str_weights = [str(weight) for weight in weights]
    command = [_EXECUTABLE_PRINT, "SitToStand", config_path, output_path] + str_weights
    subprocess.run(command, check=True, stdout=DEVNULL)


def simulate_normalisers(destination, n_parameters, config_path):
    """Run normaliser simulations"""
    os.makedirs(destination, exist_ok=True)
    for i in range(0, n_parameters):
        normaliser_path = os.path.join(destination, str(i) + ".sto")
        normaliser_weights = [0] * n_parameters
        normaliser_weights[i] = 1 / _PRE_NORMALISERS[i]
        run_lower_level_print(normaliser_path, normaliser_weights, config_path)


def compute_normalisers(folder, n_parameters, divisor):
    """Compute normalisers from simulated data"""
    normalisers = [0] * n_parameters
    for i in range(0, n_parameters):
        normaliser_path = os.path.join(folder, str(i) + ".sto")
        normalisers[i] = (get_objective_from_file(normaliser_path) * _PRE_NORMALISERS[i]) / divisor 
    return normalisers


def get_objective_from_file(filename):
    """Pull objective function value from solution file"""
    with open(filename, "r", encoding="utf-8") as file:
        for line in file:
            if _OBJECTIVE_STR in line:
                return float(line.replace(_OBJECTIVE_STR, ""))


def objective(weights, normalisers, reference_sols, config_path):
    """Run lower level using normalised weights & compare to reference"""
    with tempfile.NamedTemporaryFile(suffix=".sto") as temp_file:
        run_lower_level_print(temp_file.name, numpy.divide(weights, normalisers), config_path)
        sol = opensim.MocoTrajectory(temp_file.name)
        values = []
        for ref in reference_sols:
            values.append(sol.compareContinuousVariablesRMSPattern(ref, "states", ".*"))
        return numpy.mean(values)


def solve_constrained_nomad(func, dim, lb, ub, max_evals):
    """NOMAD interface with constraints, in serial mode"""

    def objective(x):
        vals = [x.get_coord(i) for i in range(x.size())]
        total = numpy.sum(numpy.array(vals))
        vals.append(max(0, 1 - total))
        g = total - 1
        f = 10  # Prohibitvely high score for constraint violation, but I don't think this is used
        if g <= 0:  # So we don't evaluate a useless point - too expensive
            f = func(vals)
        rawBBO = str(f) + " " + str(g)
        x.setBBO(rawBBO.encode("UTF-8"))
        return True

    local_dim = dim - 1
    unit = numpy.round(1/dim, 4)
    x0 = numpy.multiply([1] * local_dim, unit)
    params = [
        "DIMENSION " + str(local_dim),
        "BB_OUTPUT_TYPE OBJ EB",
        "MAX_BB_EVAL " + str(max_evals),
        "DIRECTION_TYPE ORTHO N+1 UNI",
        "VNS_MADS_SEARCH yes",
        "ANISOTROPIC_MESH no",
        "DISPLAY_ALL_EVAL yes",
        "DISPLAY_DEGREE 2",
        "DISPLAY_STATS BBE OBJ ( SOL ) CONS_H FEAS_BBE INF_BBE",
        "NB_THREADS_OPENMP 1"
    ]

    return PyNomad.optimize(objective, x0, [lb] * local_dim, [ub] * local_dim, params)


def process(subject, mode):
    """Main script"""

    # High-level options
    max_evaluations = 1000

    # Paths
    subject_path = "s" + str(subject)
    config_path = os.path.join(subject_path, mode, "ioc_config.txt")
    results_dir = os.path.join(subject_path, mode)
    reference_dir = os.path.join(subject_path, mode, "sols")
    os.makedirs(results_dir, exist_ok=True)

    # Initial setup
    normaliser_dir = os.path.join(results_dir, _NORMALISER_FOLDER)
    results_path = os.path.join(results_dir, "results.json")

    # Run normaliser simulations
    if not os.path.exists(normaliser_dir):
        simulate_normalisers(normaliser_dir, _N_PARAMETERS, config_path)

    # Load normaliser results
    normalisers = compute_normalisers(
        normaliser_dir, _N_PARAMETERS, _IDEAL_OPTIMISED_COST
    )

    # Pre-load reference solutions
    reference_paths = [file for file in os.listdir(reference_dir) if 
        os.path.isfile(os.path.join(reference_dir, file)) and not file.startswith('.')]
    reference_sols = []
    for file in reference_paths:
        full_path = os.path.join(reference_dir, file)
        reference_sols.append(opensim.MocoTrajectory(full_path))

    # Use MADS to run upper-level optimisation
    inner_objective = lambda weights: objective(weights, normalisers, reference_sols, config_path)
    result = solve_constrained_nomad(
        inner_objective,
        _N_PARAMETERS,
        _LOWER_LIMIT,
        _UPPER_LIMIT,
        max_evaluations,
    )

    # Save results to file
    with open(results_path, "w") as f:
        json.dump(result, f, indent=4)

if __name__ == "__main__":
    process(1, "unperturbed")
    process(1, "perturbed")
