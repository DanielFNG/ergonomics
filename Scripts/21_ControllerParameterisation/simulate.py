import subprocess
from platform import system
import os
import numpy as np
import opensim
from controller_parameterisation import controller
import PyNomad
import json
import contextlib, io

_GOAL_SPECIFICATION = "CombinedSitToStand"
_EXECUTABLE_PRINT = os.path.join(os.getenv("ERGONOMICS_HOME"), "bin", "solveAndPrint")
_DELETE_TEMP_FILES = system() == "Windows"
_ERR_OUTPUT = subprocess.DEVNULL if _DELETE_TEMP_FILES else None
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
    subprocess.run(command, check=True, stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)

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

def solve_constrained_nomad(func, lb, ub, params):
    """NOMAD interface with constraints, in serial mode"""

    def objective(x):
        vals = [x.get_coord(i) for i in range(x.size())]
        f = func(vals)
        rawBBO = str(f)
        x.setBBO(rawBBO.encode("UTF-8"))
        return True

    return PyNomad.optimize(objective, [], lb, ub, params)

def get_objective_from_file(filename):
    """Pull objective function value from solution file"""
    with open(filename, "r", encoding="utf-8") as file:
        for line in file:
            if _OBJECTIVE_STR in line:
                return float(line.replace(_OBJECTIVE_STR, ""))

def objective(node_values, input_model, output_model, config_path, weights):
    nodes = [0, 17, 34, 51, 68, 85, 100]
    node_values = [0] + node_values + [0]
    x, y = controller(nodes, node_values)
    timesteps = x * _TIME / x[-1]
    create_assisted_model(input_model, output_model, timesteps, y * _MAX_TORQUE)
    run_lower_level_print("solution.sto", weights, config_path)
    return get_objective_from_file("solution.sto")

def objective2(n, node_values, input_model, output_model, config_path, weights, output):
    nodes = np.linspace(0, 100, n).astype(int)
    x, y = controller(nodes, node_values)
    timesteps = x * _TIME / x[-1]
    create_assisted_model(input_model, output_model, timesteps, y * _MAX_TORQUE)
    run_lower_level_print(output, weights, config_path)
    return get_objective_from_file(output)

def objective_variable_nodes(nodes, input_model, output_model, config_path, weights):
    n_variables = len(nodes)
    n_nodes = n_variables//2
    points = [0] + [int(node) for node in nodes[0:n_nodes]] + [100]
    values = [0] + nodes[n_nodes:n_variables] + [0]
    x, y = controller(points, values)
    timesteps = x * _TIME / x[-1]
    create_assisted_model(input_model, output_model, timesteps, y * _MAX_TORQUE)
    run_lower_level_print("solution_variable.sto", weights, config_path)
    return get_objective_from_file("solution_variable.sto")

if __name__ == "__main__":

    # Suppress opensim logger output
    opensim.Logger.setLevelString("Off")

    weights = [0.0001, 1, 0.0001]
    iterations = [100]
    config_path = "config.txt"
    input_model = "base.osim"
    output_model = "assisted.osim"
    dimension = 6
    lb_value = 0
    ub_value = 1
    initial_search_size = 10

    inner_objective = lambda nodes: objective_variable_nodes(nodes, input_model, output_model, config_path, weights)
    
    n_nodes = dimension//2
    m_nodes = n_nodes - 1
    interval = 100//n_nodes
    cutoff = (n_nodes - 1) * interval
    lb_points = list(np.linspace(0, cutoff, n_nodes))
    ub_points = list(np.linspace(interval, cutoff, m_nodes)) + [100]
    lb = lb_points + [lb_value] * n_nodes
    ub = ub_points + [ub_value] * n_nodes

    for max_iterations in iterations:
        params = [
            "DIMENSION " + str(dimension),
            "LH_SEARCH " + str(initial_search_size) + " 0",
            "BB_INPUT_TYPE ( " + "I " * n_nodes + "R " * n_nodes + ")",
            "BB_OUTPUT_TYPE OBJ",
            "MAX_BB_EVAL " + str(max_iterations),
            "VNS_MADS_SEARCH yes",
            "DISPLAY_ALL_EVAL yes",
            "DISPLAY_DEGREE 2",
            "DISPLAY_STATS BBE OBJ ( SOL )",
            "NB_THREADS_OPENMP 1"
        ]
        result = solve_constrained_nomad(inner_objective, lb, ub, params)
        with open("with-knee-variable-nodes.json", "w") as f:
            json.dump(result, f, indent=4)

