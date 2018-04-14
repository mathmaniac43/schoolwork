%% Midterm Question 7
% Paul "Nick" Laurenzano

%% Overview
% Produce and plot a linear trajectory in Cartesian space from [-5,1,2]
% to [6,7,4] in 3 seconds using a polynomial basis.
from = SE3(-5, 1, 2);
to   = SE3( 6, 7, 4);
t = 0:0.05:3;

Ts = ctraj(from, to, length(t));

plot(t, Ts.transl);
legend('x', 'y', 'z');

%% Follow-up
% What is the maximum speed that the robot reaches?
pos = Ts.tv;
vel_xyz = diff(Ts.tv, 1, 2);
vel = sqrt(vel_xyz(1,:).^2 + vel_xyz(2,:).^2 + vel_xyz(3,:).^2);
max_vel = max(vel);

max_vel % units per second