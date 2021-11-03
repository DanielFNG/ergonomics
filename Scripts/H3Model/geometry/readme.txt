To match the xyz orientation used in opensim, all of the stl files have been rotated clockwise by 90degrees in the x-axis. This rotated the object together with its coordinate frame. As a result the exoskeleton could be visualised upright in opensim but the coordinate frame of the objects (x-forward, y-left, z-up) was misaligned with OpenSim's default coordinate frame (x-forward, y-up, z-right). To convert the coordinate frame to OpenSim's standard coordinate frame a clockwise rotation in x-axis was performed. Similarly the CoM and Inertia properties of each body were rotated accordingly. The following procedure was followed:

- Rotate all stl bodies clockwise used CAD (COMs and Inertias are unaffected). 
- Import stls in Opensim
- Transfer the information found in the urdf to an .osim file for the model.
- Make sure COM and Inertia properties and all transformations are expressed in OpenSim's default coordinate frames. This means rotating all values in the urdf by 90 counter clockwise in the x-direction. 
i.e. for COM: 

[1        0          0 ]   {x} 	       {x}
[0 cos(pi/2) -sin(pi/2)] X {y}       = {y}
[0 sin(pi/2) cos(pi/2) ]   {z}_urdf    {z}_opensim

[R] x [COM]_urdf = [COM]_opensim

x_urdf = x_opensim
y_urdf = -z_opensim
z_urdf = y_opensim

for Inertia:

[R]^T x [I]_urdf x [R] = [I]_opensim

Ixx_urdf = Ixx_opensim
Iyy_urdf = Izz_opensim
Izz_urdf = Iyy_opensim
Ixy_urdf = Ixz_opensim
Ixz_urdf = -Ixy_opensim
Iyz_urdf = -Iyz_opensim

for translation in parent's frame:

x_urdf = -x_opensim
y_urdf = -z_opensim
z_urdf = y_opensim
