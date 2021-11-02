function output = produceSymmetricIK(input)
% Note: written exclusively for IK .mot files, in particular assumes that
% the column labels have only the local coordinate name e.g.
% 'hip_flexion_r' as opposed to '/jointset/hip_r/hip_flexion_r'

    % Start with the output a copy of the input
    output = copy(input);
    
    % Step through replacing left coordinates with their right counterparts
    for i = 2:input.NCols
        label = input.Labels{i};
        if strcmp(label(end - 1:end), '_r')
            opposite = [label(1:end-2) '_l'];
            output.setColumn(opposite, output.getColumn(label));
        end
    end      

end