import subprocess
from platform import system
import os
import numpy as np
import opensim
from controller_parameterisation import controller
import PyNomad
import json

_GOAL_SPECIFICATION = "CombinedSitToStand"
_EXECUTABLE_PRINT = os.path.join(os.getenv("ERGONOMICS_HOME"), "bin", "solveAndPrint")
_DELETE_TEMP_FILES = system() == "Windows"
_ERR_OUTPUT = subprocess.DEVNULL if _DELETE_TEMP_FILES else None
_WEIGHTS = [0.0001, 1]  # Same as previous combined results
_TIME = 1.5
_MAX_TORQUE = 150
_OBJECTIVE_STR = "objective="

def run_lower_level_print(output_path, weights, config_path):
    """Runs lower level optimiser and prints result file"""
    # Note: we ignore stdout to better see the NOMAD optimisation output. On Windows the
    # stderr is also ignored, because by default the IPOPT version included with the 
    # Windows OpenSim binary prints an error message each run, cluttering the output 
    str_weights = [str(weight) for weight in weights]
    command = [_EXECUTABLE_PRINT, _GOAL_SPECIFICATION, config_path, output_path] + str_weights
    subprocess.run(command, check=True, stderr=_ERR_OUTPUT, stdout=subprocess.DEVNULL)

def create_assisted_model(input_filename, output_filename, timesteps, values):
    
    # Create piecewise constant function for the torque vector
    torque = opensim.PiecewiseConstantFunction()
    torque_opposite = opensim.PiecewiseConstantFunction()
    n_timesteps = len(timesteps)
    for i in range(0, n_timesteps):
        torque.addPoint(timesteps[i], values[i])
        torque_opposite.addPoint(timesteps[i], -values[i])

    # Create constant 0 functions for inactive dimensions
    zero = opensim.Constant(0)
    
    # Create a prescribed force
    prescribed_force = opensim.PrescribedForce()
    prescribed_force.setFrameName("/bodyset/APO_group_r")
    prescribed_force.setForceIsInGlobalFrame(True)
    prescribed_force.setTorqueFunctions(zero, zero, torque)

    # Create the equal & opposite force
    opposite_force = opensim.PrescribedForce()
    opposite_force.setFrameName("/bodyset/APO_r_link")
    opposite_force.setForceIsInGlobalFrame(True)
    opposite_force.setTorqueFunctions(zero, zero, torque_opposite)
    
    # Add to model
    osim = opensim.Model(input_filename)
    force_set = osim.updForceSet()
    force_set.append(prescribed_force)
    force_set.append(opposite_force)
    
    # Print new model
    osim.printToXML(output_filename)

def solve_constrained_nomad(func, dim, lb, ub, params):
    """NOMAD interface with constraints, in serial mode"""

    def objective(x):
        vals = [x.get_coord(i) for i in range(x.size())]
        f = func(vals)
        rawBBO = str(f)
        x.setBBO(rawBBO.encode("UTF-8"))
        return True

    unit = np.round(1/dim, 4)
    x0 = np.multiply([1] * dim, unit)

    return PyNomad.optimize(objective, [], [lb] * dim, [ub] * dim, params)

def get_objective_from_file(filename):
    """Pull objective function value from solution file"""
    with open(filename, "r", encoding="utf-8") as file:
        for line in file:
            if _OBJECTIVE_STR in line:
                return float(line.replace(_OBJECTIVE_STR, ""))

def objective(node_values, input_model, output_model, config_path):
    nodes = [0, 20, 40, 60, 80, 100]
    node_values = [0] + node_values + [0]
    x, y = controller(nodes, node_values)
    timesteps = x * _TIME / x[-1]
    create_assisted_model(input_model, output_model, timesteps, y * _MAX_TORQUE)
    run_lower_level_print("solution.sto", _WEIGHTS, config_path)
    return get_objective_from_file("solution.sto")


if __name__ == "__main__":

    config_path = "config.txt"
    input_model = "base.osim"
    output_model = "assisted.osim"

    max_evaluations = 100
    inner_objective = lambda node_values: objective(node_values, input_model, output_model, config_path)
    params = [
        "DIMENSION 4",
        "BB_OUTPUT_TYPE OBJ",
        "MAX_BB_EVAL " + str(max_evaluations),
        "VNS_MADS_SEARCH yes",
        "X0 x0.txt",
        "DISPLAY_ALL_EVAL yes",
        "DISPLAY_DEGREE 2",
        "DISPLAY_STATS BBE OBJ ( SOL )",
        "NB_THREADS_OPENMP 1"
    ]
    result = solve_constrained_nomad(
        inner_objective, 4, 0, 1, params
    )

    with open("results.json", "w") as f:
        json.dump(result, f, indent=4)