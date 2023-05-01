[![DOI](https://zenodo.org/badge/350362988.svg)](https://zenodo.org/badge/latestdoi/350362988)

## Overview

This repository contains research code for learning human motion strategies via inverse musculoskeletal optimal control and simulating 
human-robot collaboration scenarios.

The code in this repository was used to generate simulations for two research papers which have been accepted for publication. Links to these
publications will be provided here upon publication.

Dependencies include OpenSim and OpenSim Moco. The code is a research prototype and is still undergoing active development.

This branch contains a cleaned version of the repository which can be used to generate the results and figures from the 2023 Royal Society publication.

## Dependencies 

Simulations: 
* OpenSim (tested on OpenSim 4.4), ensure the Python API is set up and working (`import opensim` should work)

Plotting:
* Matlab 
* opensim-matlab from https://github.com/DanielFNG/opensim-matlab, ensure the source directory is added to your Matlab path 

## Setup

* Use CMake to build the source files in `ergonomics/Source/cpp/`. This should populate the ergonomics/bin directory with two executables.

## Usage 

* Navigate to `ergonomics/Scripts` and run `simulate.py`. This will create a directory `ergonomics/Data/Test` which corresponds to a new Case Study 1 simulation with 5 newly simulated subjects. You can modify the `SAVE_FOLDER` parameter in `simulate.py` to rerun the simulation to a new location.
* The Matlab scripts `CreateAssistancePlots.m` and `CreateMetricPlots.m` can be used to visualise the optimised exoskeleton assistances and the metric analysis data, respectively. For the former you should point to the data for a specific subject when requested by the script, e.g `ergonomics/Data/Royal Society/1`. For the latter you should point to an entire save folder, e.g. `ergonomics/Data/Royal Society`.

## Notes

* The subjects are randomised for each run so you will not simulate exactly the same data as is in the paper. However, this data (and associated subject info) is stored in the `ergonomics/Data/Royal Society` folder for posterity. 
