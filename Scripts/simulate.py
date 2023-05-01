import subprocess
from platform import system
import os
import opensim
from random import randrange

SAVE_FOLDER = "Test"

_GOAL_SPECIFICATION = "CombinedSitToStand"
_EXECUTABLE_PRINT = os.path.join(os.getenv("ERGONOMICS_HOME"), "bin", "solveAndPrint")
_DELETE_TEMP_FILES = system() == "Windows"
_ERR_OUTPUT = subprocess.DEVNULL if _DELETE_TEMP_FILES else None
_ROOT = os.path.join(os.getenv("ERGONOMICS_HOME"), "Scripts")
_DATA_ROOT = os.path.join(os.getenv("ERGONOMICS_HOME"), "Data")
_BASE_MODEL_PATH = os.path.join(_ROOT, "models", "base.osim")
_WEAK_MODEL_PATH = os.path.join(_ROOT, "models", "weak.osim")
_GENERIC_MODEL_PATH = os.path.join(_ROOT, "models", "model.osim")
_ASSISTED_MODEL_PATH = os.path.join(_ROOT, "models", "assisted.osim")
_SUBJECT_DATA_PATH = os.path.join(_DATA_ROOT, SAVE_FOLDER, "subject_data.txt")

RANDOMNESS = 20
N_SUBJECTS = 5
WEAKENING = 0.1
BASE_STRENGTH = 200
LUMBAR_ON = 0.0001
LUMBAR_OFF = 0.000001
STABILITY_ON = 1
STABILITY_OFF = 0.01

_OBJECTIVE_STR = "objective="

def get_objective_from_file(filename):
    """Pull objective function value from solution file"""
    with open(filename, "r", encoding="utf-8") as file:
        for line in file:
            if _OBJECTIVE_STR in line:
                return float(line.replace(_OBJECTIVE_STR, ""))

def run_lower_level_print(output_path, weights, config_path):
    """Runs lower level optimiser and prints result file"""
    # Note: we ignore stdout to better see the NOMAD optimisation output. On Windows the
    # stderr is also ignored, because by default the IPOPT version included with the 
    # Windows OpenSim binary prints an error message each run, cluttering the output 
    str_weights = [str(weight) for weight in weights]
    command = [_EXECUTABLE_PRINT, _GOAL_SPECIFICATION, config_path, output_path] + str_weights
    subprocess.run(command, check=True, stderr=_ERR_OUTPUT)

def compute_mass_of_bodies(osim, bodies):
    body_set = osim.getBodySet()
    mass = 0
    for body in bodies:
        mass += body_set.get(body).getMass()
    return mass

def adjust_mass_of_bodies(osim, bodies, multiplier):
    body_set = osim.updBodySet()
    for body in bodies:
        body_set.get(body).setMass(body_set.get(body).getMass() * multiplier)
    return osim

def adjust_strength_of_actuators(osim, actuators, multiplier):
    actuator_set = osim.updActuators()
    for actuator in actuators:
        act = opensim.ActivationCoordinateActuator.safeDownCast(actuator_set.get(actuator))
        act.set_optimal_force(act.get_optimal_force() * multiplier)
    return osim

def activate_assistance(osim):
    actuator_set = osim.updActuators()
    apo = opensim.TorqueActuator.safeDownCast(actuator_set.get("apo"))
    apo.setMaxControl(1)
    return osim

def random_multiplier(random_limit):
    return 1 + ((randrange(random_limit * 2 + 1) - random_limit)/100.0)

if __name__ == "__main__":
    config_path = "config.txt"
    config_path_weak = "config_weak.txt"
    config_path_assisted = "config_assisted.txt"

    generic_model = opensim.Model(_GENERIC_MODEL_PATH)

    patient_bodies = ['pelvis', 'femur_r', 'tibia_r', 'talus_r', 'calcn_r', 'toes_r', 
                      'torso', 'humerus_r', 'ulna_r', 'radius_r', 'hand_r']
    base_mass = compute_mass_of_bodies(generic_model, patient_bodies)

    patient_actuators = ['lumbarAct', 'r_hip_act', 'r_knee_act', 'r_ankle_act', 'r_shoulder_act', 'r_elbow_act']
    
    os.mkdir(os.path.join(_DATA_ROOT, SAVE_FOLDER))
    with open(_SUBJECT_DATA_PATH, 'w') as f:
        f.write("Subject Mass Strength\n")

    for s in range(0, N_SUBJECTS):

        # Compute mass and strength
        mass_multiplier = 1
        strength_multiplier = 1
        if s > 0:
            mass_multiplier = random_multiplier(RANDOMNESS)
            strength_multiplier = random_multiplier(RANDOMNESS)
        
        mass = base_mass * mass_multiplier
        strength = BASE_STRENGTH * strength_multiplier

        with open(_SUBJECT_DATA_PATH, 'a') as f:
            f.write(f"{s} {mass} {strength}\n")

        # Create base model
        base = opensim.Model(_GENERIC_MODEL_PATH)
        mass_adjusted = adjust_mass_of_bodies(base, patient_bodies, mass_multiplier)
        strength_adjusted = adjust_strength_of_actuators(mass_adjusted, patient_actuators, strength_multiplier)
        strength_adjusted.printToXML(_BASE_MODEL_PATH)

        # Create weak model - reduce strength of specific joints by 90%
        weakened_actuators = ['lumbarAct', 'r_hip_act', 'r_knee_act']
        weakened = adjust_strength_of_actuators(strength_adjusted, weakened_actuators, WEAKENING)
        weakened.printToXML(_WEAK_MODEL_PATH)

        # Create assisted model - change max control of APO actuator to 1
        assisted = activate_assistance(weakened)
        assisted.printToXML(_ASSISTED_MODEL_PATH)

        # Run simulations
        save_folder = os.path.join(_DATA_ROOT, SAVE_FOLDER, str(s))
        print(os.path.exists(save_folder))
        if not os.path.exists(save_folder):
            os.mkdir(save_folder)
        run_lower_level_print(os.path.join(save_folder, "normal.sto"), [LUMBAR_ON, STABILITY_ON], config_path)
        run_lower_level_print(os.path.join(save_folder, "weak.sto"), [LUMBAR_ON, STABILITY_ON], config_path_weak)
        run_lower_level_print(os.path.join(save_folder, "stability.sto"), [LUMBAR_OFF, STABILITY_ON], config_path_assisted)
        run_lower_level_print(os.path.join(save_folder, "lumbar.sto"), [LUMBAR_ON, STABILITY_OFF], config_path_assisted)
        run_lower_level_print(os.path.join(save_folder, "combined.sto"), [LUMBAR_ON, STABILITY_ON], config_path_assisted)
        
        # Consider ankle weakness separately (new model)
        weakened = adjust_strength_of_actuators(assisted, weakened_actuators, 1.0/WEAKENING)
        weakened_actuators = ['r_ankle_act']
        weakened = adjust_strength_of_actuators(mass_adjusted, weakened_actuators, WEAKENING)
        weakened.printToXML(_ASSISTED_MODEL_PATH)
        run_lower_level_print(os.path.join(save_folder, "combined_ankle.sto"), [LUMBAR_ON, STABILITY_ON], config_path_assisted)
