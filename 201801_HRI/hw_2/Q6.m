%% Q6
% Paul "Nick" Laurenzano

%%  Overview
% Plan a linear trajcetory using the PUMA simulator from P1=(-0.2, -0.7,
% 0.2) in the 'right handed, elbow up' pose to P2=(0.1, 0.8, 0.3) in the
% 'left handed, elbow down' pose. Publish the trajectory path in MATLAB. A
% trajectory can be mapped using some of the ideas from the 3_3_4
% Articulated Manipulator example in the Class 4 module. You can try the
% 'trail' option to the SerialLink.plot command (check the help file for
% information), or you can do a trail manually with hTrail.
%
% First - Create a plotting object with red stars as the markers with 
% |hTrail = plot3(0, 0, 0, 'r*');|
%
% Second - Add data to the hTrail object, where the latest positions have
% to be extracted from the last matrix column for the end effector. The
% plot is updated every time new data is added to the object. Take a couple
% of datapoints as the robot moves to complete the path and show how
% it moved. The publish option should capture the final path in the plot
% window.
%
% htrail.XData=[htrail.XData 'Latest X position']; % Replace 'Latest X
% postiion' with code that returns the current X
%
% htrail.YData=[htrail.YData 'Latest Y position']; % Replace 'Latest Y
% postiion' with code that returns the current Y
%
% htrail.ZData=[htrail.ZData 'Latest Z position']; % Replace 'Latest Z
% postiion' with code that returns the current Z
%
% Note: this can be compelted in less than 20 lines of code using the
% toolbox. If you have more than that, you might be making it too hard.
clear;
close all;

mdl_puma560;

t_delta = 0.01;
t = (0:t_delta:1)';

% Actual Positions

start = [-0.2; -0.7; 0.2];
stop  = [ 0.1;  0.8; 0.3];

P1 = rt2tr(eye(3), start);
P2 = rt2tr(eye(3), stop);

% Example of Linear that Works
%P1 = rt2tr(eye(3), [.5; .5; -.5]);
%P2 = rt2tr(eye(3), [.5; -.5; .5]);

% Joint-Space Trajectory
%q1 = p560.ikine6s(P1, 'ru');
%q2 = p560.ikine6s(P2, 'ld');
%q = mtraj(@tpoly, q1, q2, t);
%q = jtraj(q1, q2, t);

q1 = p560.ikine(P1, 'ru');
figure;
p560.name = 'P1';
p560.plot(q1);

q2 = p560.ikine(P2, 'ld');
figure;
p560.name = 'P2';
p560.plot(q2);
Ts = ctraj(P1, P2, length(t));

% For some reason it can't converge...
%q = p560.ikine(Ts, 'ru');

figure;
p560.name = 'Stepper';
q = zeros(size(Ts, 3), 6);
for step = 1:size(Ts, 3)
    disp(step);
    q(step, :) = p560.ikine(Ts(:,:,step));
    p560.plot(q(step, :));
end

figure;
p560.name = 'P1=>P2';
p560.plot(q);

figure;
axis equal;
htrail = plot3(0, 0, 0, 'rx');
title('P1=>P2');
xlabel('X'); ylabel('Y'); zlabel('Z');
htrail.XData = []; htrail.YData = []; htrail.ZData = [];
for q_index = 1:size(q, 1)
    T = p560.fkine(q(q_index, :));
    htrail.XData = [htrail.XData T.t(1)];
    htrail.YData = [htrail.YData T.t(2)];
    htrail.ZData = [htrail.ZData T.t(3)];
    pause(t_delta);
end
