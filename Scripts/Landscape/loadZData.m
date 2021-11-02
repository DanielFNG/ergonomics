% Grid settings
w_effort_range = [0, 0.45];
n_effort = 10;
w_translation_range = [0, 1.0];
n_translation = 11;

% Get sample points
[xs, ys, x, y] = create2DGrid(w_effort_range, w_translation_range, ...
    n_effort, n_translation);

% Step through loading Z data
zs = zeros(size(xs));
root = 'D:\Dropbox\Ergonomics Results\Grid';
obj = @sumSquaredStateDifference;
obj_args = {[root filesep 'reduced_w_effort=0.25_w_translation=0.5.sto'], 'all'};
for i = length(xs):-1:1
    path = [root filesep 'reduced_w_effort=' num2str(xs(i)) ...
        '_w_translation=' num2str(ys(i)) '.sto'];
    try
        zs(i) = obj(path, obj_args{:});
    catch err
        fprintf([err.message '\n']);
        fprintf('Couldn''t load index %i.\n', i);
        xs(i) = [];
        ys(i) = [];
        zs(i) = [];
    end
end