import subprocess
import tempfile
import opensim

EXECUTABLE_PATH = "../../bin/solveAndPrint"

class LowerLevel():

    def __init__(self, task, config_path):
        self.task = task
        self.config_path = config_path

    def run(self, weights, output=None):
        if not output:
            temp = tempfile.NamedTemporaryFile(suffix=".sto")
            output = temp.name
        command = [EXECUTABLE_PATH] + [self.task] + [self.config_path] + [output]
        for weight in weights:
            command = command + [str(weight)]
        subprocess.run(command)
        return opensim.MocoTrajectory(output)

