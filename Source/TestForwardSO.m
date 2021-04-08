model = 'C:\Users\danie\Documents\GitHub\ergonomics\Models\Scaled\gait2392musc_contact.osim';
controls = 'C:\Users\danie\Documents\GitHub\ergonomics\OpenSim\SO\gait2392_contact\with_grfs_StaticOptimization_controls.xml';
states = 'C:\Users\danie\Documents\GitHub\ergonomics\OpenSim\SO\gait2392_contact\states_StatesReporter_states.sto';
actuators = 'C:\Users\danie\Documents\GitHub\ergonomics\Settings\SO\gait2392\actuators.xml';
save_path = 'cmc_simulation_states_contact.sto';

simulate2392SO(model, controls, states, actuators, save_path);