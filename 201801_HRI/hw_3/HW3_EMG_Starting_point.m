%% HW3
% Paul "Nick" Laurenzano

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

VEL_FACTOR = 0.1;

figure;
subplot(2,2,1);plot(raw_time, raw_channels(:,1),'b');
subplot(2,2,2);plot(raw_time, raw_channels(:,2),'g');
subplot(2,2,3);plot(raw_time, raw_channels(:,3),'r');
subplot(2,2,4);plot(raw_time, raw_channels(:,4),'c');
title('Raw Data');

%% First Lever is the boxcar average
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

figure;
subplot(2,2,1);plot(raw_time, shifted_channels(:,1),'b');
subplot(2,2,2);plot(raw_time, shifted_channels(:,2),'g');
subplot(2,2,3);plot(raw_time, shifted_channels(:,3),'r');
subplot(2,2,4);plot(raw_time, shifted_channels(:,4),'c');
title('Offset Average About Zero');

%% Zero Crossing or MAV
mav = smoothdata(shifted_channels, 1, 'movmean', [0, LPF-1]);

figure;
subplot(2,2,1);
hold on;
plot(raw_time, mav(:,1), 'b');
plot([raw_time(1), raw_time(end)], [thresh_vals(1), thresh_vals(1)], 'k');
hold off;
subplot(2,2,2);
hold on;
plot(raw_time, mav(:,2), 'g');
plot([raw_time(1), raw_time(end)], [thresh_vals(2), thresh_vals(2)], 'k');
hold off;
subplot(2,2,3);
hold on;
plot(raw_time, mav(:,3), 'r');
plot([raw_time(1), raw_time(end)], [thresh_vals(3), thresh_vals(3)], 'k');
hold off;
subplot(2,2,4);
hold on;
plot(raw_time, mav(:,4), 'c');
plot([raw_time(1), raw_time(end)], [thresh_vals(4), thresh_vals(4)], 'k');
hold off;
title('MAV');

%% Convert data to binary
thresh(:,1) = uint8(mav(:,1) > thresh_vals(1));
thresh(:,2) = uint8(mav(:,2) > thresh_vals(2));
thresh(:,3) = uint8(mav(:,3) > thresh_vals(3));
thresh(:,4) = uint8(mav(:,4) > thresh_vals(4));

figure;
plot(raw_time, thresh);
title('Thresholded');
legend('1', '2', '3', '4');

%% Binary Sum Order is determined here

bin_sum_raw = int8( ...
    weights(1) * thresh(:,1) + ...
    weights(2) * thresh(:,2) + ...
    weights(3) * thresh(:,3) + ...
    weights(4) * thresh(:,4) ...
);

figure;
plot(raw_time, bin_sum_raw);
title('Binary Sum Raw');

bin_sum_refined = int8(round(smoothdata(bin_sum_raw, 1, 'movmedian', intent)));
figure;
plot(raw_time, bin_sum_refined);
title('Binary Sum Refined');

%% Estimate/Interpret the State

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

%% Associate each state with a motion

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

intent_states = int8(round(smoothdata(decimate(double(bin_sum_refined), 100), 1, 'movmedian', 5)));
Intents = [(0:0.1:18)', state_velocities(intent_states+1, 2:4)];
save('Intents');

% TODO: HANDLE JACOBIAN AND GENERATE Vels.mat

