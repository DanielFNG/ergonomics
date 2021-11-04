import org.opensim.modeling.*

model_path = '2D_gait_contact_constrained_activation.osim';
solution_path = 'mos_solution_retry.sto';
solution = MocoTrajectory(solution_path);

model_processor = ModelProcessor(model_path);
model = model_processor.process();
model.initSystem();

heel_r = StdVectorString();
heel_l = StdVectorString();
heel_r.add('contactHeel_r');
heel_l.add('contactHeel_l');

heel_forces = opensimMoco.createExternalLoadsTableForGait(...
    model, solution, heel_r, heel_l);
STOFileAdapter.write(heel_forces, 'heels_retry.sto');

toe_r = StdVectorString();
toe_l = StdVectorString();
toe_r.add('contactFront_r');
toe_l.add('contactFront_l');

toe_forces = opensimMoco.createExternalLoadsTableForGait(...
    model, solution, toe_r, toe_l);
STOFileAdapter.write(toe_forces, 'toes_retry.sto');

seat_r = StdVectorString();
seat_l = StdVectorString();
seat_r.add('chair_r');
seat_l.add('chair_l');

seat_forces = opensimMoco.createExternalLoadsTableForGait(...
    model, solution, seat_r, seat_l);
STOFileAdapter.write(seat_forces, 'seat_retry.sto');

