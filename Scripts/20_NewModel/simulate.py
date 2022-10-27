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

    # Strong 
    output_path = "results/normal.sto"
    combined_weights = [1, 1]
    #run_lower_level_print(output_path, [0, 0], config_path)

    # Weak
    output_path = "results/weak.sto"
    #run_lower_level_print(output_path, [0, 0], config_path_weak)

    # Assistance - stability
    output_path = "results/stability.sto"
    #run_lower_level_print(output_path, [0, 1], config_path_assisted)

    # Assistance - lumbar loading
    output_path = "results/lumbar.sto"
    run_lower_level_print(output_path, [0.1, 0], config_path_assisted)

    # Assistance - stability & lumbar loading
    output_path = "results/combined.sto"
    run_lower_level_print(output_path, [0.1, 1], config_path_assisted)