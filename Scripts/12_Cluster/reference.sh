#!/bin/bash

# Grid Engine options
#$ -cwd
#$ -l h_rt=02:00:00
#$ -l h_vmem=1G
 
# Initialise the environment modules
. /etc/profile.d/modules.sh
module load roslin/gcc/7.3.0

# Paths to required shared libraries
export OPENSIM_PROJECT_LOCATION=/home/dgordon3/opensim
export OPENSIM_INSTALL_LOCATION=${OPENSIM_PROJECT_LOCATION}/install
export OPENSIM_DEPENDENCIES_DIR=${OPENSIM_INSTALL_LOCATION}/opensim-dependencies-install
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${OPENSIM_INSTALL_LOCATION}/opensim-core-install/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${OPENSIM_DEPENDENCIES_DIR}/adol-c/lib64
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${OPENSIM_DEPENDENCIES_DIR}/ipopt/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${OPENSIM_DEPENDENCIES_DIR}/casadi/lib

# Job payload
