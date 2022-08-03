#!/bin/bash

# Grid Engine options
#$ -cwd
#$ -l h_rt=02:00:00
#$ -l h_vmem=1G
 
# Initialise the environment modules
. /etc/profile.d/modules.sh
module load phys/compilers/gcc/11.2.0
module load openmpi

# Paths to required shared libraries
export OPENSIM_PROJECT_LOCATION=/home/dgordon3/opensim
export OPENSIM_INSTALL_LOCATION=${OPENSIM_PROJECT_LOCATION}/install
export OPENSIM_DEPENDENCIES_DIR=${OPENSIM_INSTALL_LOCATION}/opensim-dependencies-install
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${OPENSIM_INSTALL_LOCATION}/opensim-core-install/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${OPENSIM_DEPENDENCIES_DIR}/adol-c/lib64
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${OPENSIM_DEPENDENCIES_DIR}/ipopt/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${OPENSIM_DEPENDENCIES_DIR}/casadi/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${OPENSIM_DEPENDENCIES_DIR}/ezc3d/lib64
export ERGONOMICS_HOME=~/ergonomics
export NOMAD_HOME=~/nomad

# Read weights file in to array
readarray -t weights < weights.txt

# Job payload
~/ergonomics/bin/solveAndCompare SitToStand cluster_config.txt ${SGE_TASK_ID}.txt reference.sto ${weights[$((-1 + ${SGE_TASK_ID}))]}
