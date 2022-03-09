function reba_curve = calculateREBA(input)
% This function contains several fairly hard-coded assumptions about the
% REBA score, as well as assuming a certain format of OpenSim model (i.e.
% paths to bodies) - not yet general enough.

    % Define REBA scoring matrices
    reba_lower_matrix = [1 2 3; 2 3 4; 2 4 5; 3 5 6];
    reba_overall_matrix = [1; 1; 2; 3; 4; 5];
    
    % Initialise REBA score vector
    reba_curve = zeros(1, input.NFrames);

    % Get access to needed arrays
    lumbar = rad2deg(input.getColumn('/jointset/lumbar/lumbar/value')) ...
        + rad2deg(input.getColumn('/jointset/groundPelvis/pelvis_tilt/value'));
    hip = rad2deg(input.getColumn('/jointset/hip_r/hip_flexion_r/value'));

    for i = 1:input.NFrames

        % Compute trunk score
        if lumbar(i) == 0
            lumbar_score = 1;
        elseif abs(lumbar(i)) < 20
            lumbar_score = 2;
        elseif lumbar(i) > 20
            lumbar_score = 3;
        elseif lumbar(i) < - 20 && lumbar(i) > -60
            lumbar_score = 3;
        elseif lumbar_score < -60
            lumbar_score = 4;
        end

        % Compute hip score
        if abs(hip(i)) < 30
            hip_score = 1;
        elseif abs(hip(i)) < 60
            hip_score = 2;
        else
            hip_score = 3;
        end

        % Compute overall posture score
        posture_score = reba_lower_matrix(lumbar_score, hip_score);

        % Force/load score
        load_score = 0;

        % Score A
        a_score = posture_score + load_score;

        % Arm score 
        arm_score = 1;

        % Coupling score
        coupling_score = 0;

        % B score
        b_score = arm_score + coupling_score;

        % C score
        c_score = reba_overall_matrix(a_score, b_score);

        % Activity score
        activity_score = 1;

        % Reba score
        reba_curve(i) = c_score + activity_score;
    end
end
