model = 'C:\Users\danie\Documents\GitHub\ergonomics\Models\Scaled\gait2392musc.osim';
controls = 'C:\Users\danie\Documents\GitHub\ergonomics\OpenSim\CMC\gait2392_contact\CMC_controls_modified.sto';
states = 'C:\Users\danie\Documents\GitHub\ergonomics\OpenSim\CMC\gait2392_contact\CMC_states.sto';
actuators = 'C:\Users\danie\Documents\GitHub\ergonomics\Settings\SO\gait2392\actuators.xml';
save_path = 'cmc_simulation_states_new.sto';

simulate2392CMCContact(model, controls, states, actuators, save_path);