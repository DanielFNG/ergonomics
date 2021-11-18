function spheres = getContactSpheres(model, forces)

    n_spheres = length(forces);
    spheres = cell(1, n_spheres);
    geometry_set = model.getContactGeometrySet();
    for i = 1:n_spheres
        sphere_path = forces{i}.getPropertyByName('socket_sphere');
        [~, name, ~] = fileparts(char(sphere_path));
        spheres{i} = geometry_set.get(name);
    end

end