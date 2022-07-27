""" Python implementation of IOC framework """
import os
import subprocess
import tempfile
import numpy
import PyNomad

# High-level options
N_EVALUATIONS = 1000
REFERENCE_WEIGHTS = [0.1, 0.2, 0.3, 0.1, 0.2, 0.1]
CONFIG_PATH = (
    "/home/danielfng/Documents/GitHub/ergonomics/Examples/SitToStand/config.txt"
)
RESULTS_DIR = os.getcwd()

# Low-level options
_UPPER_LIMIT = 1
_LOWER_LIMIT = 0
_IDEAL_OPTIMISED_COST = 1
_NORMALISER_FOLDER = "normalisers"
_REFERENCE_FILE = "reference.sto"
_EXECUTABLE_PRINT = "/home/danielfng/Documents/GitHub/ergonomics/bin/solveAndPrint"
_EXECUTABLE_COMPARE = "/home/danielfng/Documents/GitHub/ergonomics/bin/solveAndCompare"
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
    subprocess.run(command, check=True)


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
                return line.replace(_OBJECTIVE_STR, "")


def objective(weights, normalisers, reference_file):
    """Run lower level using normalised weights & compare to reference"""
    with tempfile.NamedTemporaryFile() as temp_file:
        run_lower_level_compare(
            temp_file.name, reference_file, numpy.divide(weights, normalisers)
        )
        return float(temp_file.readline())


def solve_constrained_nomad():
    """NOMAD interface with constraints, in batch mode"""


def main():
    """Main script"""
    # Initial setup
    n_parameters = len(REFERENCE_WEIGHTS)
    n_seeds = n_parameters**2
    normaliser_dir = os.path.join(RESULTS_DIR, _NORMALISER_FOLDER)
    reference_path = os.path.join(RESULTS_DIR, _REFERENCE_FILE)

    # Run normaliser simulations
    simulate_normalisers(normaliser_dir, n_parameters)

    # Load normaliser results
    normalisers = compute_normalisers(
        normaliser_dir, n_parameters, _IDEAL_OPTIMISED_COST
    )

    # Compute reference
    normalised_weights = numpy.divide(REFERENCE_WEIGHTS, normalisers)
    run_lower_level_print(reference_path, normalised_weights)


if __name__ == "__main__":
    main()
