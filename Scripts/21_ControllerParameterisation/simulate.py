import subprocess
from platform import system
import os
import numpy as np
import opensim
from controller_parameterisation import controller

_GOAL_SPECIFICATION = "CombinedSitToStand"
_EXECUTABLE_PRINT = os.path.join(os.getenv("ERGONOMICS_HOME"), "bin", "solveAndPrint")
_DELETE_TEMP_FILES = system() == "Windows"
_ERR_OUTPUT = subprocess.DEVNULL if _DELETE_TEMP_FILES else None
_WEIGHTS = [0.25 * 1/16.35585, 0.75 * 1/0.049487]  # From normalisers

def run_lower_level_print(output_path, weights, config_path):
    """Runs lower level optimiser and prints result file"""
    # Note: we ignore stdout to better see the NOMAD optimisation output. On Windows the
    # stderr is also ignored, because by default the IPOPT version included with the 
    # Windows OpenSim binary prints an error message each run, cluttering the output 
    str_weights = [str(weight) for weight in weights]
    command = [_EXECUTABLE_PRINT, _GOAL_SPECIFICATION, config_path, output_path] + str_weights
    subprocess.run(command, check=True, stderr=_ERR_OUTPUT)

def generate_profile():
    pass

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
    prescribed_force.setFrameName("APO_group_r")
    prescribed_force.setForceIsInGlobalFrame(True)
    prescribed_force.setTorqueFunctions(zero, zero, torque)

    # Create the equal & opposite force
    opposite_force = opensim.PrescribedForce()
    opposite_force.setFrameName("APO_link_r")
    opposite_force.setForceIsInGlobalFrame(True)
    opposite_force.setTorqueFunctions(zero, zero, torque_opposite)
    
    # Add to model
    osim = opensim.Model(input_filename)
    force_set = osim.updForceSet()
    force_set.append(prescribed_force)
    force_set.append(opposite_force)
    
    # Print new model
    osim.printToXML(output_filename)

if __name__ == "__main__":
    config_path = "config.txt"
    input_model = "base.osim"
    output_model = "assisted.osim"

    timesteps = [0,1,2,3]
    values = [5,5,5,1]
    create_assisted_model(input_model, output_model, timesteps, values)
