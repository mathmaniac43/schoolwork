%% Midterm Question 5 (Take 2)
% Paul "Nick" Laurenzano

%% First Overview
% The block (0.2 units on each side) centered on the table shown below is
% rotated by 90 degrees about z2 and moved so that its center has
% coordinates [-0.3, 0.7, 0.1]’ relative to the frame o1x1y1z1.
% The camera is centered over the table and the front edge of the table is
% aligned with y0. 
%
% Compute the homogeneous transformation relating the following.

%% Setup
% I think that there is some conflict between what the description says
% about rotating the block 90 degrees about z2 and the diagram not clearly
% showing the block rotated about anything (relative to pose0 or pose1). I
% am going to work from the diagram and take note of the inherend 90-degree
% rotation in the final part of the question.
clear;
close all;

pose0 = rt2tr(eye(3), [0; 0; 0]); % the robot is the center of the universe
pose0_to_pose1 = rt2tr(eye(3), [0; 1; 1]);
pose1_to_pose2 = rt2tr(eye(3), [-0.3; 0.7; 0.1]);
pose1_to_pose3 = rt2tr(rotx(pi)*rotz(-pi/2), [-0.5; 0.5; 2]);

pose1 = pose0_to_pose1;
pose2 = pose0_to_pose1 * pose1_to_pose2;
pose3 = pose0_to_pose1 * pose1_to_pose3;

figure;
trplot(pose0, 'axis', [-1.5, 0.5, -0.5, 2.5, -0.5, 3.5], 'color', 'black');
hold on;
trplot(pose1, 'color', 'red');
trplot(pose2, 'color', 'green');
trplot(pose3, 'color', 'blue');
hold off;
title('Sanity Check');

%% i) the block frame to the camera frame as a MATLAB HTM
pose3_to_pose2 = inv(pose1_to_pose3) * pose1_to_pose2;
pose3_to_pose2

figure;
tranimate(pose3, pose3 * pose3_to_pose2);
title('Block Relative to Camera');

%% ii)  the camera in the robot frame as a MATLAB HTM
pose0_to_pose3 = pose3; % done in setup
pose0_to_pose3

figure;
tranimate(pose0, pose0 * pose0_to_pose3);
title('Camera Relative to Robot');

%% Second Overview
% The camera measures the block position and orientation and sends it to the robot. 

%% iii) Compute the block frame in the robot frame (using i and ii) as a MATLAB HTM.
pose0_to_pose2 = pose0_to_pose3 * pose3_to_pose2;
pose0_to_pose2

% pretty small tolerance from rounding errors
pose0_to_pose2_test = (abs(pose2 - pose0 * pose0_to_pose2) < eps(1));
pose0_to_pose2_test

figure;
tranimate(pose0, pose0 * pose0_to_pose2);
title('Block Relative to Robot');

%% iv) Compute the joint parameters for the robot (from question 4) to pickup the block (center the end effector in the block). 

% Set up equations
robot = SerialLink([Revolute('d', 0.5), Prismatic('alpha', -pi/2, 'qlim', [0, 3]), Prismatic('offset', 0.75, 'qlim', [0, 3])]);
syms theta d2 d3 x y z;
joint_vars = [theta; d2; d3];
pos_vars = [x; y; z];
A = robot.fkine(joint_vars);
T = A.T;
[theta_eqn, d2_eqn, d3_eqn] = solve(T(1:3, 4) == pos_vars, joint_vars);
theta_eqn = theta_eqn(1);
d2_eqn    = d2_eqn(1);
d3_eqn    = d3_eqn(1);

% Calculate parameters
pos_vals = pose2(1:3, 4); % position for pose2, which is the center of the block
theta_val = double(vpa(subs(theta_eqn, pos_vars, pos_vals)));
d2_val = double(vpa(subs(d2_eqn, pos_vars, pos_vals)));
d3_val = double(vpa(subs(d3_eqn, pos_vars, pos_vals)));

actual_kine = robot.fkine([theta_val, d2_val, d3_val]);
actual_transform = actual_kine.T;
% pretty small tolerance from rounding errors
joint_sanity_test = (abs(actual_transform(1:3, 4) - pos_vals) < 10*eps(1));
joint_sanity_test

figure;
robot.teach([theta_val, d2_val, d3_val]);

%% v)  What should the very first rotation be (instead of 90), if the robot end effector needs to be inserted into a hole in the center of the -x2 face of the block.  (the x2 axis should line up with link d3)
% I want the same rotation as the Revolute joint of the robot (plus 90
% degrees about z, to align x2 with y0).
pose0_to_robot_rotation = robot.links(1).A(theta_val).T;
block_end = rt2tr(pose0_to_robot_rotation(1:3, 1:3), pose2(1:3, 4)) * trotz(90, 'deg');
block_start = pose2 * trotz(-90, 'deg');

% block_end = block_start * block_T => block_T = inv(block_start) * block_end;
block_T = inv(block_start) * block_end;
block_T

angles = tr2eul(block_T, 'deg');
angles

figure;
trplot(pose0, 'axis', [-1.5, 0.5, -0.5, 2.5, -0.5, 3.5], 'color', 'black');
hold on;
trplot(pose0_to_robot_rotation, 'color', 'red');
trplot(block_start, 'color', 'green');
trplot(block_end, 'color', 'blue');
trplot(block_start * block_T, 'color', 'yellow');
hold off;