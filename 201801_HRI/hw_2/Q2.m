%% Q2
% Paul "Nick" Laurenzano

%%  Overview
% Using the Toolbox, create a script, run it, and attach the published
% results. Some useful commands might be Link, RevoluteJoint, Clone, and
% SerialLink.
clear;
close all;

%% a
% Draw the class robot with the joint variables in radians as inputs. Check
% to make sure the inputs are in the proper range for the robot and reset
% the input to the limit if the input exceeds the limit.

% I copied most of this from Bobby's mdl_cyton, but I did add the limits
% based on their website's specifications.
% http://www.robai.com/robots/robot/cyton-epsilon-1500-2/

fun_lim_from_deg = @(deg) deg2rad([-deg/2, deg/2]);

lim_shoulder_roll  = fun_lim_from_deg(300);
lim_shoulder_pitch = fun_lim_from_deg(220);
lim_shoulder_yaw   = fun_lim_from_deg(220);
lim_elbow_pitch    = fun_lim_from_deg(220);
lim_wrist_yaw      = fun_lim_from_deg(220);
lim_wrist_pitch    = fun_lim_from_deg(220);
lim_wrist_roll     = fun_lim_from_deg(320);

links = [
    % Create the robot using RVC tools
    Revolute('d', 0.2,  'a', 0,     'alpha', pi/2,  'offset', pi/2, 'qlim', lim_shoulder_roll);
    Revolute('d', 0,    'a', 0.135, 'alpha', -pi/2, 'offset', pi/2, 'qlim', lim_shoulder_pitch);
    Revolute('d', 0,    'a', 0.125, 'alpha', pi/2,  'offset', 0,    'qlim', lim_shoulder_yaw);
    Revolute('d', 0,    'a', 0.125, 'alpha', -pi/2, 'offset', 0,    'qlim', lim_elbow_pitch);
    Revolute('d', 0,    'a', 0.135, 'alpha', pi/2,  'offset', 0,    'qlim', lim_wrist_yaw);
    Revolute('d', 0,    'a', 0,     'alpha', pi/2,  'offset', pi/2, 'qlim', lim_wrist_pitch);
    Revolute('d', 0.09, 'a', 0,     'alpha', 0,     'offset', pi/2, 'qlim', lim_wrist_roll);
];

cyton = SerialLink(links, 'name', 'Cyton Epsilon 1500', 'manufacturer', 'Cyton');
cyton.base = transl(0.0, 0.0, 0.0)*rpy2tr(0, 0, 0, 'xyz');

qz = [0 0 0 0 0 0 0]; % zero angles, arm up (given joint offsets)
qr = [pi/2 pi/4 0 pi/4 0 0 0]; % ready pose, arm slightly bent
qstretch = [pi/2 pi/2  0 0 0 0 0];
qn = qr;

%% b
% Manually determine joint angles that place the tip of the end effector on
% the table, Z=0, at some point in the workspace of your choosing (X, Y).
% What are X and Y.

q_touch_table = deg2rad([-12.5, 50.4, 72.6, 110, 18, 0, 0])

figure;
cyton.teach(q_touch_table);

T_SE3 = cyton.fkine(q_touch_table);
T = T_SE3.T;
xyz = T(1:3, 4)'
