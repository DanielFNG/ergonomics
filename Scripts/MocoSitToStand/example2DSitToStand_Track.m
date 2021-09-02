% -------------------------------------------------------------------------- %
% OpenSim Moco: example2DWalking.m                                           %
% -------------------------------------------------------------------------- %
% Copyright (c) 2019 Stanford University and the Authors                     %
%                                                                            %
% Author(s): Brian Umberger                                                  %
%                                                                            %
% Licensed under the Apache License, Version 2.0 (the "License"); you may    %
% not use this file except in compliance with the License. You may obtain a  %
% copy of the License at http://www.apache.org/licenses/LICENSE-2.0          %
%                                                                            %
% Unless required by applicable law or agreed to in writing, software        %
% distributed under the License is distributed on an "AS IS" BASIS,          %
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   %
% See the License for the specific language governing permissions and        %
% limitations under the License.                                             %
% -------------------------------------------------------------------------- %

% This is a Matlab implementation of an example optimal control
% problem (2-D walking) orginally created in C++ by Antoine Falisse
% (see: example2DWalking.cpp).
%
% This example features two different optimal control problems:
%  - The first problem is a tracking simulation of walking.
%  - The second problem is a predictive simulation of walking.
%
% The code is inspired from Falisse A, Serrancoli G, Dembia C, Gillis J,
% De Groote F: Algorithmic differentiation improves the computational
% efficiency of OpenSim-based trajectory optimization of human movement.
% PLOS One, 2019.
%
% Model
% -----
% The model described in the file '2D_gait.osim' included in this file is a
% modified version of the 'gait10dof18musc.osim' available within OpenSim. We
% replaced the moving knee flexion axis by a fixed flexion axis, replaced the
% Millard2012EquilibriumMuscles by DeGrooteFregly2016Muscles, and added
% SmoothSphereHalfSpaceForces (two contacts per foot) to model the
% contact interactions between the feet and the ground.
%
% Do not use this model for research. The path of the gastroc muscle contains
% an error--the path does not cross the knee joint.
%
% Data
% ----
% The coordinate data included in the 'referenceCoordinates.sto' comes from
% predictive simulations generated in Falisse et al. 2019.  As such,
% they deviate slightly from typical experimental gait data.

clear;

% Load the Moco libraries
import org.opensim.modeling.*;

% ---------------------------------------------------------------------------
% Set up a coordinate tracking problem where the goal is to minimize the
% difference between provided and simulated coordinate values and speeds (and
% ground reaction forces), as well as to minimize an effort cost (squared
% controls). The provided data represents half a gait cycle. Endpoint
% constraints enforce periodicity of the coordinate values (except for
% pelvis tx) and speeds, coordinate actuator controls, and muscle activations.


% Define the optimal control problem
% ==================================
track = MocoTrack();
track.setName('sitToStandTracking');

% Set the weights for the terms in the objective function. The values below were
% obtained by trial and error.
%
% Note: If GRFTrackingWeight is set to 0 then GRFs will not be tracked. Setting
% GRFTrackingWeight to 1 will cause the total tracking error (states + GRF) to
% have about the same magnitude as control effort in the final objective value.
controlEffortWeight = 0.00001;
stateTrackingWeight = 1;

% Reference data for tracking problem
input_model = '2D_gait_scaled_contact.osim';
input_data = 'referenceSitToStandCoordinates.sto';
tableProcessor = TableProcessor(input_data);
tableProcessor.append(TabOpLowPassFilter(6));

modelProcessor = ModelProcessor(input_model);
track.setModel(modelProcessor);
track.setStatesReference(tableProcessor);
track.set_states_global_tracking_weight(stateTrackingWeight);
track.set_allow_unused_references(true);
track.set_track_reference_position_derivatives(true);
track.set_apply_tracked_states_to_guess(true);
input_data = Data(input_data);
track.set_initial_time(input_data.Timesteps(1));
track.set_final_time(input_data.Timesteps(end));
study = track.initialize();
problem = study.updProblem();


% Goals
% =====

% Model processing 
model = modelProcessor.process();
model.initSystem();

% Get a reference to the MocoControlGoal that is added to every MocoTrack
% problem by default and change the weight
effort = MocoControlGoal.safeDownCast(problem.updGoal('control_effort'));
effort.setWeight(controlEffortWeight);

% Bounds
% ======
problem.setStateInfo('/jointset/groundPelvis/pelvis_tilt/value', [0*pi/180, 50*pi/180], 0.757922497);
problem.setStateInfo('/jointset/groundPelvis/pelvis_tx/value', [0, 0.5], 0.05028483);
problem.setStateInfo('/jointset/groundPelvis/pelvis_ty/value', [0.5, 1.0], 0.54743397);
problem.setStateInfo('/jointset/hip_l/hip_flexion_l/value', [-15*pi/180, 80*pi/180], 0.844694386);
problem.setStateInfo('/jointset/hip_r/hip_flexion_r/value', [-15*pi/180, 80*pi/180], 0.852378254);
problem.setStateInfo('/jointset/knee_l/knee_angle_l/value', [-120*pi/180, 5], -1.95480329);
problem.setStateInfo('/jointset/knee_r/knee_angle_r/value', [-120*pi/180, 5], -1.956778099);
problem.setStateInfo('/jointset/ankle_l/ankle_angle_l/value', [0*pi/180, 35*pi/180], 0.324237382);
problem.setStateInfo('/jointset/ankle_r/ankle_angle_r/value', [0*pi/180, 35*pi/180], 0.368424034);
problem.setStateInfo('/jointset/lumbar/lumbar/value', [-70, 0*pi/180], -0.928212182);

% Speeds - inital and final to 0
problem.setStateInfo('/jointset/groundPelvis/pelvis_tilt/speed', [-500, 500], 0, 0);
problem.setStateInfo('/jointset/groundPelvis/pelvis_tx/speed', [-500, 500], 0, 0);
problem.setStateInfo('/jointset/groundPelvis/pelvis_ty/speed', [-500, 500], 0, 0);
problem.setStateInfo('/jointset/hip_l/hip_flexion_l/speed', [-500, 500], 0, 0);
problem.setStateInfo('/jointset/hip_r/hip_flexion_r/speed', [-500, 500], 0, 0);
problem.setStateInfo('/jointset/knee_l/knee_angle_l/speed', [-500, 500], 0, 0);
problem.setStateInfo('/jointset/knee_r/knee_angle_r/speed', [-500, 500], 0, 0);
problem.setStateInfo('/jointset/ankle_l/ankle_angle_l/speed', [-500, 500], 0, 0);
problem.setStateInfo('/jointset/ankle_r/ankle_angle_r/speed', [-500, 500], 0, 0);
problem.setStateInfo('/jointset/lumbar/lumbar/speed', [-500, 500], 0, 0);

% Solve the problem
% =================
sitToStandTrackingSolution = study.solve();
sitToStandTrackingSolution.write('sitToStandTracking_solution.sto');

% Extract ground reaction forces
% ==============================
contact_r = StdVectorString();
contact_l = StdVectorString();
contact_r.add('contactHeel_r');
contact_r.add('contactFront_r');
contact_l.add('contactHeel_l');
contact_l.add('contactFront_l');
butt_r = StdVectorString();
butt_l = StdVectorString();
butt_r.add('chair_r');
butt_l.add('chair_l');

external_forces = opensimMoco.createExternalLoadsTableForGait(...
    model, sitToStandTrackingSolution, contact_r, contact_l);
chair_forces = opensimMoco.createExternalLoadsTableForGait(...
    model, sitToStandTrackingSolution, butt_r, butt_l);
STOFileAdapter.write(external_forces, 'sitToStandTracking_solutionGRF.sto');
STOFileAdapter.write(chair_forces, 'sitToStandTracking_solutionChair.sto');





