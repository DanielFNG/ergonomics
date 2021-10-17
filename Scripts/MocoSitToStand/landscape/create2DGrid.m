function [xs, ys, x, y] = create2DGrid(xrange, yrange, nx, ny)

    % Initialise vectors for x/y points and sample points
    x = zeros(nx, 1);
    y = zeros(ny, 1);
    xs = zeros(nx * ny, 1);
    ys = zeros(nx * ny, 1);

    % Compute the length between each point on the grid
    dx = (xrange(2) - xrange(1))/(nx - 1);
    dy = (yrange(2) - yrange(1))/(ny - 1);
    
    % Compute x locations
    for i = 1:nx
        x(i) = xrange(1) + (i - 1)*dx;
    end
    
    % Compute y locations
    for i = 1:ny
        y(i) = yrange(1) + (i - 1)*dy;
    end
    
    % Create x/y sample vectors which explore every point in the grid
    k = 1;
    for i = 1:nx
        for j = 1:ny
            xs(k) = x(i);
            ys(k) = y(j);
            k = k + 1;
        end
    end

end