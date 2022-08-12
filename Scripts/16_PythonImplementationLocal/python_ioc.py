""" Python implementation of IOC framework """
import os
import subprocess
import tempfile
import numpy
import PyNomad
import json

# High-level options
MAX_EVALUATIONS = 1000
REFERENCE_WEIGHTS = [0.4, 0.0, 0.1, 0.1, 0.0, 0.4]
CONFIG_PATH = "serial_config.txt"
RESULTS_DIR = os.getcwd()

# Low-level options
_UPPER_LIMIT = 1
_LOWER_LIMIT = 0
_IDEAL_OPTIMISED_COST = 1
_NORMALISER_FOLDER = "normalisers"
_REFERENCE_FILE = "reference.sto"
_EXECUTABLE_PRINT = os.path.join(os.getenv("ERGONOMICS_HOME"), "bin", "solveAndPrint")
_EXECUTABLE_COMPARE = os.path.join(
    os.getenv("ERGONOMICS_HOME"), "bin", "solveAndCompare"
)
_OBJECTIVE_STR = "objective="


def run_lower_level_print(output_path, weights):
    """Runs lower level optimiser and prints result file"""
    str_weights = [str(weight) for weight in weights]
    command = [_EXECUTABLE_PRINT, "SitToStand", CONFIG_PATH, output_path] + str_weights
    subprocess.run(command, check=True)


def run_lower_level_compare(output_path, reference_path, weights):
    """Runs lower level optimisers and prints difference compared to reference"""
    str_weights = [str(weight) for weight in weights]
    command = [
        _EXECUTABLE_COMPARE,
        "SitToStand",
        CONFIG_PATH,
        output_path,
        reference_path,
    ] + str_weights
    subprocess.run(command, check=True, stdout=subprocess.DEVNULL)


def simulate_normalisers(destination, n_parameters):
    """Run normaliser simulations"""
    os.makedirs(destination, exist_ok=True)
    for i in range(0, n_parameters):
        normaliser_path = os.path.join(destination, str(i) + ".sto")
        normaliser_weights = [0] * n_parameters
        normaliser_weights[i] = 1
        run_lower_level_print(normaliser_path, normaliser_weights)


def compute_normalisers(folder, n_parameters, divisor):
    """Compute normalisers from simulated data"""
    normalisers = [0] * n_parameters
    for i in range(0, n_parameters):
        normaliser_path = os.path.join(folder, str(i) + ".sto")
        normalisers[i] = get_objective_from_file(normaliser_path) / divisor
    return normalisers


def get_objective_from_file(filename):
    """Pull objective function value from solution file"""
    with open(filename, "r", encoding="utf-8") as file:
        for line in file:
            if _OBJECTIVE_STR in line:
                return float(line.replace(_OBJECTIVE_STR, ""))


def objective(weights, normalisers, reference_file):
    """Run lower level using normalised weights & compare to reference"""
    with tempfile.NamedTemporaryFile() as temp_file:
        run_lower_level_compare(
            temp_file.name, reference_file, numpy.divide(weights, normalisers)
        )
        return float(temp_file.readline())


def solve_constrained_nomad(func, dim, lb, ub, max_evals):
    """NOMAD interface with constraints, in serial mode"""

    def objective(x):
        vals = [x.get_coord(i) for i in range(x.size())]
        total = numpy.sum(numpy.array(vals))
        vals.append(max(0, 1 - total))
        g = total - 1
        #f = 10  # Prohibitvely high score for constraint violation, but I don't think this is used
        #if g <= 0 and h <= 0:  # So we don't evaluate a useless point - too expensive
        #    f = func(vals)
        #    eval_ok = True
        f = func(vals)
        rawBBO = str(f) + " " + str(g)
        x.setBBO(rawBBO.encode("UTF-8"))
        return True

    local_dim = dim - 1
    unit = numpy.round(1/dim, 4)
    x0 = numpy.multiply([1] * local_dim, unit)
    params = [
        "DIMENSION " + str(local_dim),
        "BB_OUTPUT_TYPE OBJ PB",
        "MAX_BB_EVAL " + str(max_evals),
        "DIRECTION_TYPE ORTHO N+1 UNI",
        "VNS_MADS_SEARCH yes",
        "ANISOTROPIC_MESH no",
        "DISPLAY_ALL_EVAL yes",
        "DISPLAY_DEGREE 2",
        "DISPLAY_STATS BBE OBJ ( SOL ) CONS_H FEAS_BBE INF_BBE",
    ]

    return PyNomad.optimize(objective, x0, [lb] * local_dim, [ub] * local_dim, params)


def main():
    """Main script"""
    # Initial setup
    n_parameters = len(REFERENCE_WEIGHTS)
    n_seeds = n_parameters**2
    normaliser_dir = os.path.join(RESULTS_DIR, _NORMALISER_FOLDER)
    reference_path = os.path.join(RESULTS_DIR, _REFERENCE_FILE)
    results_path = os.path.join(RESULTS_DIR, "results.json")

    # Run normaliser simulations
    if not os.path.exists(normaliser_dir):
        simulate_normalisers(normaliser_dir, n_parameters)

    # Load normaliser results
    normalisers = compute_normalisers(
        normaliser_dir, n_parameters, _IDEAL_OPTIMISED_COST
    )

    # Compute reference
    if not os.path.exists(reference_path):
        normalised_weights = numpy.divide(REFERENCE_WEIGHTS, normalisers)
        run_lower_level_print(reference_path, normalised_weights)

    # Use MADS to run upper-level optimisation
    inner_objective = lambda weights: objective(weights, normalisers, reference_path)
    result = solve_constrained_nomad(
        inner_objective,
        n_parameters,
        _LOWER_LIMIT,
        _UPPER_LIMIT,
        MAX_EVALUATIONS,
    )

    # Save results to file
    with open(results_path, "w") as f:
        json.dump(result, f, indent=4)


if __name__ == "__main__":
    main()
