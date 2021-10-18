function [xs, ys, x, y] = create2DGrid(xrange, yrange, nx, ny)

    % Compute x/y grid points
    x = linspace(xrange(1), xrange(2), nx);
    y = linspace(yrange(1), yrange(2), ny);
    
    % Create x/y sample vectors which explore every point in the grid
    n_points = nx*ny;
    xs = zeros(n_points, 1);
    ys = xs;
    for i = 1:nx
        for j = 1:ny
            xs(k) = x(i);
            ys(k) = y(j);
        end
    end

end