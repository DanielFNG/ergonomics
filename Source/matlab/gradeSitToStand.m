function result = gradeSitToStand(solution_data, obj, obj_args, filter)

    % Objective calculation
    result = obj(solution_data, obj_args{:});

    % Pass through optional filter
    if ~isempty(filter)
        result = filter(result);
    end

end