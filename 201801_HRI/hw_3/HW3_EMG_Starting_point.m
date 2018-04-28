% Program / Class example of simple EMG processing of stored data
% modify with your algorithms and data.

clear;
close all;

teaching=0;

NUM_SAMPLES = 18001;
FS = 1000;

% Un-Comment out the file you want to read 

%load('EMG1.mat');
%thresh_vals = [0.03, 0.08, 0.045, 0.03];
%weights = [8, 4, 2, 1];

load('EMG2.mat');
thresh_vals = [0.035, 0.06, 0.06, 0.05];
weights = [8, 4, 2, 1];

%load('EMG3.mat');
%thresh_vals = [0.05, 0.05, 0.05, 0.05];
%weights = [8, 4, 2, 1];


DC_Avg=500; % number of samples to average for the DC subtraction
LPF=400;    %200 
use_env = 0;      % 1= evelope 0=average
Zero_crossing=0;  % Set to 1 to use zero crossing instead of amplitude

envelope=50;  % Envelope window for max function
Intent_filter=100; % Window length for intent determination
if (Zero_crossing)
    thresh_vals=thresh_vals*envelope*6;
end

raw_channels = [data(:,1), data(:,2), data(:,3), data(:,4)];
raw_time     = data(:,18);

figure;
subplot(2,2,1);plot(raw_time, raw_channels(:,1),'b');
subplot(2,2,2);plot(raw_time, raw_channels(:,2),'g');
subplot(2,2,3);plot(raw_time, raw_channels(:,3),'r');
subplot(2,2,4);plot(raw_time, raw_channels(:,4),'c');
title('Raw Data');

if teaching
    k = waitforbuttonpress;
end

% 1000 Hz sample rate
%% First Lever is the boxcar average
% Calculate rolling DC offset for subtracting from the signals
dc_avg = zeros(NUM_SAMPLES, 4);
for i=DC_Avg:1:NUM_SAMPLES
    dc_avg(i,1) = sum(data(i-(DC_Avg-1):i,1)/DC_Avg);
    dc_avg(i,2) = sum(data(i-(DC_Avg-1):i,2)/DC_Avg);
    dc_avg(i,3) = sum(data(i-(DC_Avg-1):i,3)/DC_Avg);
    dc_avg(i,4) = sum(data(i-(DC_Avg-1):i,4)/DC_Avg);
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

if teaching
    k = waitforbuttonpress;
end

%% Zero Crossing or MAV

if (Zero_crossing)
    % todo: I understand the criteria, but what is the actual value?
    % count over the filter length
    disp 'Not ready.';
    return;
else %use mAV
    mav = smoothdata(shifted_channels, 1, 'movmean', [0, LPF-1]);
end

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

if teaching
    k = waitforbuttonpress;
end

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

% Data set 1
%bin_sum = thresh(:,4)*8 + thresh(:,2)*4 + thresh(:,3)*2 + thresh(:,1)*1;

% Data set 3
bin_sum = weights(1) * thresh(:,1) + ...
          weights(2) * thresh(:,2) + ...
          weights(3) * thresh(:,3) + ...
          weights(4) * thresh(:,4);

figure;
plot(raw_time, bin_sum);
title('Binary Sum');

blanks = uint8(zeros(NUM_SAMPLES, 4));
blanks((1*FS+1):2*FS, :) = uint8(ones(FS, 4));
blanks((3*FS+1):4*FS, :) = uint8(ones(FS, 4));
blanks((5*FS+1):6*FS, :) = uint8(ones(FS, 4));
blanks((7*FS+1):8*FS, :) = uint8(ones(FS, 4));
blanks((9*FS+1):10*FS, :) = uint8(ones(FS, 4));
blanks((11*FS+1):12*FS, :) = uint8(ones(FS, 4));
blanks((13*FS+1):14*FS, :) = uint8(ones(FS, 4));
blanks((15*FS+1):16*FS, :) = uint8(ones(FS, 4));
blanks((17*FS+1):18*FS, :) = uint8(ones(FS, 4));

bin_sum_blanked = bin_sum .* blanks;
figure;
plot(raw_time, bin_sum_blanked);
title('Binary Sum Blanked');

bin_sum_2 = smoothdata(bin_sum, 1, 'movmedian', 400);
figure;
plot(raw_time, bin_sum_2);
title('Binary Sum 2');

states = zeros(9,1);
for i = 0:8
    start = (2*i + 1)*FS + 1;
    stop  = 2*(i + 1)*FS;
    states(i+1) = mode(bin_sum_2(start:stop));
end
