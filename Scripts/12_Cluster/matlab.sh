#!/bin/bash

# Grid Engine options
#$ -cwd
#$ -l h_rt=12:00:00
#$ -l h_vmem=1G
 
# Initialise the environment modules
. /etc/profile.d/modules.sh
module load matlab

# Job payload
matlab -nodisplay -nosplash -nodesktop -r "main; exit"
