%% Q9
% Paul 'Nick' Laurenzano
% EN.525.786.91
% 2018/02/15

%% Prompt
% Execute the toolbox command below (in a script so you can publish the
% results).
% 
% This command takes a roll, pitch and yaw values in radians and creates a
% rotation matrix representing the new orientation.   In the answer
% produced by MATLAB, explain the non-zero elements of the 3x3 rotation
% matrix.  

%% Setup
clear;
close all;

%% Base Frame, No Rotation or Translation
t = 'Base Frame';
r = rpy2r(0, 0, 0);

figure;
HTM = rt2tr(r, [0;0;0]);
trplot(HTM);
title(t);

disp(t);
disp(r);

%% Final Frame, After Rotation
t = 'Final Frame';
r = rpy2r(pi()/2, 0, 0);

figure;
HTM = rt2tr(r, [0;0;0]);
trplot(HTM);
title(t);

disp(t);
disp(r);

%% Explain Results
% The command executed a 30-degree rotation about the X axis. Consider the
% matrix to be a mapping of the magnitudes of the original X, Y, and Z axes
% down the rows, and a mapping of the resulting X, Y, and Z axes across the
% columns.
% 
% Since the X axis is being rotated around, it does not actually
% move; therefore, a 1 maps the original X axis to the new X axis, with no
% change.
%
% The original Y axis does move, and the 90-degree rotation puts it exactly
% where the Z axis was originally. Therefore, the second column (new Y)
% contains a 1 in the third row (original Z).
%
% Finally, the original Z axis moves as well, and the rotation puts it
% exactly opposite to the original Y axis. Therefore, the third column (new
% Z) contains a -1 in the second row (original Y).