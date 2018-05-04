%% HW3
% Paul "Nick" Laurenzano

%% Overview
% Using the data file provided in the module, process the EMG data into
% velocity commands for the Cyton Robot using the following steps. The 
% data was sampled at 1000Hz and there are four channels with 18 seconds
% of data.  There are 9 poses, with 1 second of rest between each pose.
% Three EMG files were provided, you may use any one of them, if your code
% works better on one vs another.  

clear;
close all;

file_num = 1;
if file_num == 1
    disp('Loading 1');
    load('EMG1.mat');
    thresh_vals = [0.038, 0.09, 0.063, 0.034];
    weights = [8, 4, 2, 1];
elseif file_num == 2
    disp('Loading 2');
    load('EMG2.mat');
    thresh_vals = [0.035, 0.06, 0.06, 0.05];
    weights = [8, 4, 2, 1];
elseif file_num == 3
    disp('Loading 3');
    load('EMG3.mat');
    thresh_vals = [0.03, 0.069, 0.047, 0.044];
    weights = [2, 1, 4, 8];
end

FS           = 1000;
NUM_SAMPLES  = size(data, 1);
raw_channels = [data(:,1), data(:,2), data(:,3), data(:,4)];
raw_time     = data(:,18);

DC_Avg = 500; % number of samples to average for the DC subtraction
LPF    = 400;
intent = 800;

VEL_FACTOR = 0.005; % m/s?

%figure;
%subplot(2,2,1);plot(raw_time, raw_channels(:,1),'b');
%subplot(2,2,2);plot(raw_time, raw_channels(:,2),'g');
%subplot(2,2,3);plot(raw_time, raw_channels(:,3),'r');
%subplot(2,2,4);plot(raw_time, raw_channels(:,4),'c');
%title('Raw Data');

%% (a) (15 points)
% Draw a block diagram to process the EMG data into VIE motions for the
% robot. You have a good start from the class slides.
%
% <<block_diagram.png>>


%% (b) (20 points)
% Determine the poses in the EMG data file and discriminate them from
% rest. A plot similar to the ones in class that show the states is
% sufficient. You do not need to identify start and end times for each
% pose.



% First Lever is the boxcar average.
% Calculate rolling DC offset for subtracting from the signals
dc_avg = zeros(NUM_SAMPLES, 4);
for i=DC_Avg:1:NUM_SAMPLES
    dc_avg(i,1) = sum(raw_channels(i-(DC_Avg-1):i,1)/DC_Avg);
    dc_avg(i,2) = sum(raw_channels(i-(DC_Avg-1):i,2)/DC_Avg);
    dc_avg(i,3) = sum(raw_channels(i-(DC_Avg-1):i,3)/DC_Avg);
    dc_avg(i,4) = sum(raw_channels(i-(DC_Avg-1):i,4)/DC_Avg);
end
dc_avg(1:DC_Avg-1,1) = dc_avg(DC_Avg,1);
dc_avg(1:DC_Avg-1,2) = dc_avg(DC_Avg,2);
dc_avg(1:DC_Avg-1,3) = dc_avg(DC_Avg,3);
dc_avg(1:DC_Avg-1,4) = dc_avg(DC_Avg,4);

shifted_channels = abs(raw_channels - dc_avg);

%figure;
%subplot(2,2,1);plot(raw_time, shifted_channels(:,1),'b');
%subplot(2,2,2);plot(raw_time, shifted_channels(:,2),'g');
%subplot(2,2,3);plot(raw_time, shifted_channels(:,3),'r');
%subplot(2,2,4);plot(raw_time, shifted_channels(:,4),'c');
%title('Offset Average About Zero');



% LPF
mav = smoothdata(shifted_channels, 1, 'movmean', [0, LPF-1]);

% No envelope detection.

% figure;
% subplot(2,2,1);
% hold on;
% plot(raw_time, mav(:,1), 'b');
% plot([raw_time(1), raw_time(end)], [thresh_vals(1), thresh_vals(1)], 'k');
% hold off;
% subplot(2,2,2);
% hold on;
% plot(raw_time, mav(:,2), 'g');
% plot([raw_time(1), raw_time(end)], [thresh_vals(2), thresh_vals(2)], 'k');
% hold off;
% subplot(2,2,3);
% hold on;
% plot(raw_time, mav(:,3), 'r');
% plot([raw_time(1), raw_time(end)], [thresh_vals(3), thresh_vals(3)], 'k');
% hold off;
% subplot(2,2,4);
% hold on;
% plot(raw_time, mav(:,4), 'c');
% plot([raw_time(1), raw_time(end)], [thresh_vals(4), thresh_vals(4)], 'k');
% hold off;
% title('MAV');



thresh(:,1) = uint8(mav(:,1) > thresh_vals(1));
thresh(:,2) = uint8(mav(:,2) > thresh_vals(2));
thresh(:,3) = uint8(mav(:,3) > thresh_vals(3));
thresh(:,4) = uint8(mav(:,4) > thresh_vals(4));

%figure;
%plot(raw_time, thresh);
%title('Thresholded');
%legend('1', '2', '3', '4');

bin_sum_raw = int8( ...
    weights(1) * thresh(:,1) + ...
    weights(2) * thresh(:,2) + ...
    weights(3) * thresh(:,3) + ...
    weights(4) * thresh(:,4) ...
);

bin_sum_refined = int8(round(smoothdata(bin_sum_raw, 1, 'movmedian', intent)));
figure;
plot(raw_time, bin_sum_refined);
title('Discriminated States');
xlabel('Time (s)')
ylabel('State Number (discrete)');



% Estimate/Interpret the State

state_weight = zeros(16, 1);
for i = 1:length(bin_sum_refined)
    state = bin_sum_refined(i);
    % Ignore the zero state and focus on odd seconds for when the motion
    % should have occurred.
    state_weight(state+1) = state_weight(state+1) + ...
        (state > 0 && mod(floor(i/FS), 2) == 1);
end

[sorted_state_counts, sorted_indices] = sort(state_weight, 'descend');
sorted_states = sorted_indices - 1; % ignore the zero state

%% (c) (15 points)
% Assign pose one to the up velocity, one to down, one to right, one
% to left, one to in and one to out. Note that for up and down, these will
% be in the z-axis, and positive for up and negative for down. You can
% choose any starting point and it is your choice of coordinate system to
% go with the motions (X = In/out or Y=in/out etc).  You may have 3 ‘extra’
% poses that you need to handle.  There are also 16 possible states with 4
% channels. You will need to handle any ‘extra’ states. Produce a table of
% poses and directions. For example Pose1=-X, Pose3=+Z, etc.

state_velocities = zeros(16, 4);
state_velocities(:, 1) = sorted_states;
state_velocities(1:3, 2:4) =  eye(3) * VEL_FACTOR; % highest 3 are +X, +Y, +Z
state_velocities(4:6, 2:4) = -eye(3) * VEL_FACTOR; % next highest 3 are -X, -Y, -Z
% remainder are zeros

% This is the mapping from state number (0-15, including invalid states) to
% X/Y/Z velocities.
state_velocities = sortrows(state_velocities, 1);
disp('State #, X vel., Y vel., Z vel.');
disp(state_velocities);

%% (d) (25 points)
% Process the provided EMG data file into velocity commands for the Cyton
% robot and write a second file “Intents.MAT” with the intended velocity
% (speed and direction) at 0.1 second time stamps.  You can move at a
% fixed velocity, or you can use the MAV signal to determine the speed.
% This should have 4 columns, one for time and 3 for the velocity (+ / -)
% in each of the X, Y and Z directions.

t_delta = .1;
times = (0:t_delta:18)';
intent_states = int8(round(smoothdata(decimate(double(bin_sum_refined), 100), 1, 'movmedian', 5)));
Intents = [times, state_velocities(intent_states+1, 2:4)];
save('Intents');

max_motion_pos = sum(Intents(:,2:end) .* (Intents(:,2:end)>0), 1);
max_motion_neg = sum(Intents(:,2:end) .* (Intents(:,2:end)<0), 1);

%% (e) (25 points)
% Use the Jacobian methods to compute the required joint velocities at the
% same time steps and write a third file “Vels.MAT”. Use as many columns
% as you need (or that the RTB produces).

%spatial_velocities = [Intents(:,2:4), zeros(size(Intents,1), 3)];

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
q0 = [pi/2 pi/4 0 pi/4 0 0 0]; % ready pose, arm slightly bent

%figure;
%cyton.teach(qr);

%start_pos = cyton.fkine(qr);
%start_pos = start_pos.T;

joint_velocities = zeros(length(times), 7);
prev_angles = q0;
for i = 2:length(times)
    % Find the joint velocities from the prior pose to the next pose.
    jacobian = cyton.jacob0(prev_angles);
    velocities = [Intents(i, 2:4), zeros(1, 3)]';
    joint_velocities(i,:) = (pinv(jacobian) * velocities)';
    
    % Prepare for the next iteration.
    prev_pose = cyton.fkine(prev_angles);
    prev_pose = prev_pose.T;
    xyz_vel = Intents(i-1, 2:4);
    x = xyz_vel(1) * t_delta;
    y = xyz_vel(2) * t_delta;
    z = xyz_vel(3) * t_delta;
    new_pose = prev_pose * transl(x, y, z);
    
    prev_angles = cyton.ikine(new_pose, 'q0', prev_angles);
end

Vels = [times, joint_velocities];
save('Vels');

% Sanity Check
joint_angles = zeros(length(times), 7);
joint_angles(1,:) = q0;
for i = 2:length(times)
    joint_angles(i,:) = joint_angles(i-1,:) + Vels(i-1,2:end);
end

figure;
cyton.plot(joint_angles);
