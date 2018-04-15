%% Q7
% Paul "Nick" Laurenzano

%%  Overview
% Redo the last problem, but add rotations that would simulate the need to
% pick something off the floor and put it on the wall. Assume the face of
% the end effector normal to the +Z axis is the action face of the end
% effector. Therefore, the starting pose should have +Z of the end effector
% facing in the world -Z and ending pose with end effector +Z facing in the
% world +X. Pick a view for the animation that best illuminates the motion.
% You can pick the location for pickup and drop off. 
clear;
close all;

mdl_puma560;

t_delta = 0.01;
t = (0:t_delta:1)';

cutoff = 40;

% Actual Positions

start = [-0.5, -0.5, 0.0];
stop  = [ 0.5,  0.0, 0.5];

% it can do the first cutoff or so and last cutoff or so steps fine.

P1 = rt2tr(rotx(pi), start);
P2 = rt2tr(roty(pi/2), stop);

%%
figure;
p560.name = 'P1';
p560.plot(p560.ikine6s(P1));

%%
figure;
p560.name = 'P2';
p560.plot(p560.ikine6s(P2));

%%
Ts_linear = ctraj(P1, P2, length(t));
q = p560.ikine6s(Ts_linear);
figure;
p560.name = 'P1=>P2';
p560.plot(q);

%%
figure;
title('End effector position');
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
