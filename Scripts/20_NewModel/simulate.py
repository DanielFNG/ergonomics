import subprocess
from platform import system
import os

_GOAL_SPECIFICATION = "CombinedSitToStand"
_EXECUTABLE_PRINT = os.path.join(os.getenv("ERGONOMICS_HOME"), "bin", "solveAndPrint")
_DELETE_TEMP_FILES = system() == "Windows"
_ERR_OUTPUT = subprocess.DEVNULL if _DELETE_TEMP_FILES else None

def run_lower_level_print(output_path, weights, config_path):
    """Runs lower level optimiser and prints result file"""
    # Note: we ignore stdout to better see the NOMAD optimisation output. On Windows the
    # stderr is also ignored, because by default the IPOPT version included with the 
    # Windows OpenSim binary prints an error message each run, cluttering the output 
    str_weights = [str(weight) for weight in weights]
    command = [_EXECUTABLE_PRINT, _GOAL_SPECIFICATION, config_path, output_path] + str_weights
    subprocess.run(command, check=True, stderr=_ERR_OUTPUT)

if __name__ == "__main__":
    config_path = "config.txt"
    config_path_weak = "config_weak.txt"
    config_path_assisted = "config_assisted.txt"

    #run_lower_level_print("results/normal.sto", [0.0001, 1], config_path)
    #run_lower_level_print("results/weak.sto", [0.0001, 1], config_path_weak)
    #run_lower_level_print("results/stability.sto", [0.000001, 1], config_path_assisted)
    run_lower_level_print("results/lumbar.sto", [0.0001, 0.01], config_path_assisted)
    #run_lower_level_print("results/combined.sto", [0.0001, 1], config_path_assisted)

    #stability_normaliser = 0.049487
    #lumbar_normaliser = 1.635585/0.1
