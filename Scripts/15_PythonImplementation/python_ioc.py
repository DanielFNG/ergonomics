""" Python implementation of IOC framework """
import os
import subprocess
import tempfile
import json
import numpy
import PyNomad

# High-level options
N_EVALUATIONS = 50
REFERENCE_WEIGHTS = [0.1, 0.2, 0.3, 0.1, 0.2, 0.1]
CONFIG_PATH = (
    "cluster_config.txt"  # No need to give cluster_config here, even in cluster mode
)
RESULTS_DIR = os.getcwd()
_MODE = "cluster"

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
_CLUSTER_WEIGHTS_FILE = "weights.txt"

# A global, for now
_N_BLOCK = 0


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
                return float(line.replace(_OBJECTIVE_STR, ""))


def objective(weights, normalisers, reference_file):
    """Run lower level using normalised weights & compare to reference"""
    with tempfile.NamedTemporaryFile() as temp_file:
        run_lower_level_compare(
            temp_file.name, reference_file, numpy.divide(weights, normalisers)
        )
        return float(temp_file.readline())


def solve_constrained_nomad(func, dim, lb, ub, max_evals, n_seeds, mode):
    """NOMAD interface with constraints, in batch mode"""

    def cluster_objective(block):
        global _N_BLOCK
        _N_BLOCK = _N_BLOCK + 1
        n_points = block.size()
        eval_ok = [False for i in range(n_points)]
        gs = []
        validity = []
        local_savedir = str(_N_BLOCK)
        os.makedirs(local_savedir)

        # Write weights file
        with open(_CLUSTER_WEIGHTS_FILE, "w") as file:
            for i in range(n_points):
                x = block.get_x(i)
                vals = [x.get_coord(i) for i in range(x.size())]
                total = numpy.sum(numpy.array(vals))
                g = total - 1
                gs.append(g)
                if g <= 0:
                    validity.append(True)
                    for val in vals:
                        file.write(f"{val:.4f}" + " ")
                    file.write("\n")
                else:
                    validity.append(False)

        # Dispatch to cluster
        if any(validity):
            command = [
                "qsub",
                "-P",
                "inf_slmc",
                "-sync",
                "y",
                "-t",
                "1-" + str(n_points),
                "cluster.sh",
            ]
            if _N_BLOCK > 1:  # We've already computed the reference - temporary
                subprocess.run(command, check=True)

        # Read results & move files
        for i in range(n_points):
            x = block.get_x(i)
            f = 0
            if validity[i]:
                f = 1
                filepath = str(i + 1) + ".txt"
                with open(filepath, "r") as file:
                    f = float(file.readline())
                os.rename(filepath, os.path.join(local_savedir, filepath))
            rawBBO = str(f) + " " + str(gs[i])
            x.setBBO(rawBBO.encode("UTF-8"))
            eval_ok[i] = True

        # Move results files
        os.rename(
            _CLUSTER_WEIGHTS_FILE, os.path.join(local_savedir, _CLUSTER_WEIGHTS_FILE)
        )

        return eval_ok

    def local_objective(block):
        n_points = block.size()
        eval_ok = [False for i in range(n_points)]
        for i in range(n_points):
            x = block.get_x(i)
            vals = [x.get_coord(i) for i in range(x.size())]
            total = numpy.sum(numpy.array(vals))
            g = total - 1
            f = 0
            if g <= 0:  # So we don't evaluate a useless point - too expensive
                f = func(vals)
            rawBBO = str(f) + " " + str(g)
            x.setBBO(rawBBO.encode("UTF-8"))
            eval_ok[i] = True
        return eval_ok

    params = [
        "DIMENSION " + str(dim),
        "BB_OUTPUT_TYPE OBJ EB",
        "MAX_BB_EVAL " + str(max_evals),
        "DIRECTION_TYPE ORTHO N+1 QUAD",
        "DIRECTION_TYPE ORTHO 2N",
        "DIRECTION_TYPE ORTHO N+1 NEG",
        "DIRECTION_TYPE N+1 UNI",
        "VNS_MADS_SEARCH yes",
        "ANISOTROPIC_MESH no",
        "BB_MAX_BLOCK_SIZE " + str(n_seeds),
        "LH_SEARCH " + str(n_seeds) + " 0",
        "GRANULARITY * 0.0001",
    ]

    objective = local_objective
    if mode == "cluster":
        objective = cluster_objective

    x0 = [0.1, 0.1, 0.2, 0.2, 0.2, 0.2]

    return PyNomad.optimize(objective, x0, [lb] * dim, [ub] * dim, params)


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
        N_EVALUATIONS,
        n_seeds,
        _MODE,
    )

    # Save results to file
    with open(results_path, "w") as f:
        json.dump(result, f, indent=4)


if __name__ == "__main__":
    main()
