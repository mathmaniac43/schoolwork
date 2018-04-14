%% Midterm Question 2
% Paul "Nick" Laurenzano

%% Overview
% The toolbox can compute Euler rotations, and different Euler angle
% transformations can produce the same results. Publish your results and
% upload them.

%% Part 1
% Using the toolbox, determine the ZYZ transformation that is equivalent
% to an XYZ transformation of (0.2, 0.4, 0.5).
xyz_angles = [0.2, 0.4, 0.5];
xyz_rot = rotx(xyz_angles(1)) * roty(xyz_angles(2)) * rotz(xyz_angles(3));
zyz_angles = tr2eul(xyz_rot);

zyz_angles

%% Part 2
% Test both methods and determine the location of the point p(5, 3, 2)
% after both translations.

T_p = transl(5, 3, 2);

T_xyz = trotx(xyz_angles(1)) * troty(xyz_angles(2)) * trotz(xyz_angles(3)) * T_p;
p_xyz = T_xyz(1:3, 4)';

T_zyz = trotz(zyz_angles(1)) * troty(zyz_angles(2)) * trotz(zyz_angles(3)) * T_p;
p_zyz = T_zyz(1:3, 4)';

p_xyz
p_zyz