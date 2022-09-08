""" Python implementation of IOC framework """
from asyncio.subprocess import DEVNULL
from platform import system
import os
import subprocess
import tempfile
import numpy
import PyNomad
import json
import opensim

# Low-level algorithmic options
_UPPER_LIMIT = 1
_LOWER_LIMIT = 0
_IDEAL_OPTIMISED_COST = 1
_PRE_NORMALISERS = [1, 1, 1000, 1000, 1000, 1000]
_N_PARAMETERS = 6

# File-structure
_NORMALISER_FOLDER = "normalisers"
_EXECUTABLE_PRINT = os.path.join(os.getenv("ERGONOMICS_HOME"), "bin", "solveAndPrint")
_OBJECTIVE_STR = "objective="

# Windows-specific implementation details
_DELETE_TEMP_FILES = system() == "Windows"
_ERR_OUTPUT = subprocess.DEVNULL if _DELETE_TEMP_FILES else None

def run_lower_level_print(output_path, weights, config_path):
    """Runs lower level optimiser and prints result file"""
    # Note: we ignore stdout to better see the NOMAD optimisation output. On Windows the
    # stderr is also ignored, because by default the IPOPT version included with the 
    # Windows OpenSim binary prints an error message each run, cluttering the output 
    str_weights = [str(weight) for weight in weights]
    command = [_EXECUTABLE_PRINT, "SitToStand", config_path, output_path] + str_weights
    subprocess.run(command, check=True, stdout=subprocess.DEVNULL, stderr=_ERR_OUTPUT)


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

    with tempfile.NamedTemporaryFile(suffix=".sto", delete=(not _DELETE_TEMP_FILES)) as temp_file:
        run_lower_level_print(temp_file.name, numpy.divide(weights, normalisers), config_path)
        sol = opensim.MocoTrajectory(temp_file.name)
        values = []
        for ref in reference_sols:
            values.append(sol.compareContinuousVariablesRMSPattern(ref, "states", ".*value"))
    if _DELETE_TEMP_FILES:
        os.remove(temp_file.name)
    return numpy.mean(values)


def solve_constrained_nomad(func, dim, lb, ub, params):
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
    params = [
        "DIMENSION 5",
        "BB_OUTPUT_TYPE OBJ EB",
        "MAX_BB_EVAL " + str(max_evaluations),
        "DIRECTION_TYPE ORTHO N+1 UNI",
        "VNS_MADS_SEARCH yes",
        "ANISOTROPIC_MESH no",
        "DISPLAY_ALL_EVAL yes",
        "DISPLAY_DEGREE 2",
        "DISPLAY_STATS BBE OBJ ( SOL ) CONS_H FEAS_BBE INF_BBE",
        "NB_THREADS_OPENMP 1"
    ]
    result = solve_constrained_nomad(
        inner_objective,
        _N_PARAMETERS,
        _LOWER_LIMIT,
        _UPPER_LIMIT,
        params,
    )

    # Save results to file
    with open(results_path, "w") as f:
        json.dump(result, f, indent=4)

def ground_truth(working_dir, results_folder, weights):

    # High-level options
    max_evaluations = 2000

    # Paths
    config_path = os.path.join(working_dir, "ioc_config.txt")

    # Initial setup
    normaliser_dir = os.path.join(working_dir, _NORMALISER_FOLDER)
    results_dir = os.path.join(working_dir, results_folder)
    os.mkdir(results_dir)
    weights_path = os.path.join(results_dir, "weights.txt")
    results_path = os.path.join(results_dir, "results.json")
    history_path = os.path.join(results_dir, "history.txt")
    reference_path = os.path.join(results_dir, "reference.sto")

    # Run normaliser simulations
    if not os.path.exists(normaliser_dir):
        simulate_normalisers(normaliser_dir, _N_PARAMETERS, config_path)

    # Load normaliser results
    normalisers = compute_normalisers(
        normaliser_dir, _N_PARAMETERS, _IDEAL_OPTIMISED_COST
    )

    # Generate reference
    run_lower_level_print(reference_path, numpy.divide(weights, normalisers), config_path)
    reference_sols = [opensim.MocoTrajectory(reference_path)]

    # Store reference weights
    with open(weights_path, "w", encoding="utf-8") as file:
        file.write(str(weights))

    # Use MADS to run upper-level optimisation
    inner_objective = lambda weights: objective(weights, normalisers, reference_sols, config_path)
    params = [
        "DIMENSION 5",
        "BB_OUTPUT_TYPE OBJ EB",
        "MAX_BB_EVAL " + str(max_evaluations),
        "DIRECTION_TYPE ORTHO N+1 UNI",
        "VNS_MADS_SEARCH yes",
        "ANISOTROPIC_MESH no",
        "DISPLAY_ALL_EVAL yes",
        "DISPLAY_DEGREE 2",
        "DISPLAY_STATS BBE OBJ ( SOL ) CONS_H FEAS_BBE INF_BBE",
        "HISTORY_FILE " + history_path,
        "NB_THREADS_OPENMP 1"
    ]
    result = solve_constrained_nomad(
        inner_objective,
        _N_PARAMETERS,
        _LOWER_LIMIT,
        _UPPER_LIMIT,
        params,
    )

    # Save results to file
    with open(results_path, "w") as f:
        json.dump(result, f, indent=4)

def print_solution(subject, mode, weights):
    """Helper script"""

    # Paths
    subject_path = "s" + str(subject)
    config_path = os.path.join(subject_path, mode, "ioc_config.txt")
    results_dir = os.path.join(subject_path, mode)
    output_path = os.path.join(results_dir, "ioc_solution.sto")

    # Initial setup
    normaliser_dir = os.path.join(results_dir, _NORMALISER_FOLDER)

    # Load normaliser results
    normalisers = compute_normalisers(
        normaliser_dir, _N_PARAMETERS, _IDEAL_OPTIMISED_COST
    )

    # Print requested solution
    run_lower_level_print(output_path, numpy.divide(weights, normalisers), config_path)

def print_specific_solution(config_path, output_path, weights, normaliser_dir):
    # Load normaliser results
    normalisers = compute_normalisers(
        normaliser_dir, _N_PARAMETERS, _IDEAL_OPTIMISED_COST
    )
    run_lower_level_print(output_path, numpy.divide(weights, normalisers), config_path)

if __name__ == "__main__":
    working_dir = "ground_truth"
    for i in range(0, 10):
        while True:
            x = numpy.random.random([1, 5])
            if numpy.sum(x) <= 1:
                x = x.tolist()[0]
                x.append(1 - sum(x))
                break
        print(x)
        ground_truth(working_dir, str(i), x)
