%% Midterm Question 4 (Take 2)
% Paul "Nick" Laurenzano

%% Setup
clear;
close all;

%% Overview
% For the shown RPP robot...

%% A
% Calculate the inverse kinematic equations for the three joint variables
% theta1, d2 and d3, given X, Y and Z. Type them into the window as your
% answer. Save them for the question below.
% Theta(X,Y,Z) =  ,    d2 (X,Y,Z) =   ,   and d3 (X,Y,Z) =    ,
clear;
close all;

robot = SerialLink([Revolute('d', 0.5), Prismatic('alpha', -pi/2, 'qlim', [0, 3]), Prismatic('offset', 0.75, 'qlim', [0, 3])]);

%robot.teach([0, 0, 0]);

syms theta d2 d3 x y z;
joint_vars = [theta; d2; d3];
pos_vars = [x; y; z];
A = robot.fkine(joint_vars);
T = A.T;

[theta_eqn, d2_eqn, d3_eqn] = solve(T(1:3, 4) == pos_vars, joint_vars);
theta_eqn = theta_eqn(1);
d2_eqn    = d2_eqn(1);
d3_eqn    = d3_eqn(1);

%% B
% Calculate the joint angles for (X,Y,Z) = (0.25,1,1.25)

pos_vals = [0.25; 1; 1.25];
theta_val = double(vpa(subs(theta_eqn, pos_vars, pos_vals)));
d2_val = double(vpa(subs(d2_eqn, pos_vars, pos_vals)));
d3_val = double(vpa(subs(d3_eqn, pos_vars, pos_vals)));

robot.teach([theta_val, d2_val, d3_val]);