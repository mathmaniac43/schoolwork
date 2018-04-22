% Program / Class example of simple EMG processing of stored data
% modify with your algorithms and data.
teaching=1;

% Un-Comment out the file you want to read 


%a= 'vie_emg_20091012_185408_ch1234.mat';
a= 'vie_emg_20091012_185442_ch1234.mat';
%a = 'vie_emg_20091012_185521_ch1234.mat'
%a='vie_emg_20091012_185550_ch1234.mat';
%a= 'vie_emg_20091012_185649_ch1234.mat';

load(a);

DC_Avg=500; % number of samples to average for the DC subtraction
LPF=200;    % 
use_env = 0;      % 1= evelope 0=average
Zero_crossing=0;  % Set to 1 to use zero crossing instead of amplitude

envelope=50;  % Envelope window for max function
Intent_filter=100; % Window length for intent determination
thres_start=[0.1,0.1,0.1,0.1]  % Use same threshold for all channels
thres_start=[0.07,0.11,0.07,0.05]  % Use individual threshold for each channel
if (Zero_crossing) thres_start=thres_start*envelope*6
end

figure(1);
subplot(2,2,1);plot(data(:,18),data(:,1),'b')
subplot(2,2,2);plot(data(:,18),data(:,2),'g')
subplot(2,2,3);plot(data(:,18),data(:,3),'r')
subplot(2,2,4);plot(data(:,18),data(:,4),'c')
figure(5);
subplot(1,1,1);plot(data(:,18),data(:,1),'b',data(:,18),data(:,2),...
    'g',data(:,18),data(:,3),'r',data(:,18),data(:,4),'c')

if teaching k = waitforbuttonpress 
end

% 1000 Hz sample rate
%% First Lever is the boxcar average
% Calculate rolling DC offset for subtracting from the signals                     
for i=DC_Avg:1:18001
    data(i,5)=sum(data(i-(DC_Avg-1):i,1)/DC_Avg);
    data(i,6)=sum(data(i-(DC_Avg-1):i,2)/DC_Avg);
    data(i,7)=sum(data(i-(DC_Avg-1):i,3)/DC_Avg);
    data(i,8)=sum(data(i-(DC_Avg-1):i,4)/DC_Avg);
end
data(1:DC_Avg-1,5)=data(DC_Avg,5);  %Fill in the first DC_Avg samples with a the first average.  s
data(1:DC_Avg-1,6)=data(DC_Avg,6);
data(1:DC_Avg-1,7)=data(DC_Avg,7);
data(1:DC_Avg-1,8)=data(DC_Avg,8);

figure(1)
subplot(2,2,1);plot(data(:,18),data(:,1),'b',data(:,18),data(:,5),'r');
subplot(2,2,2);plot(data(:,18),data(:,2),'b',data(:,18),data(:,6),'r');
subplot(2,2,3);plot(data(:,18),data(:,3),'b',data(:,18),data(:,7),'r');
subplot(2,2,4);plot(data(:,18),data(:,4),'b',data(:,18),data(:,8),'r');

if teaching k = waitforbuttonpress 
end

%%  Subtract the rolling DC offset from the signal
% to create 4 signals with zero as the minimum and
% that will allow for Evelope calculation and thresholding


if (Zero_crossing)
data(:,9)=
data(:,10)=
data(:,11)=
data(:,12)=
else %use mAV
data(:,9)=
data(:,10)=
data(:,11)=
data(:,12)=
end

figure(1)
subplot(2,2,1);plot(data(:,18),data(:,9),'b')
subplot(2,2,2);plot(data(:,18),data(:,10),'g')
subplot(2,2,3);plot(data(:,18),data(:,11),'r')
subplot(2,2,4);plot(data(:,18),data(:,12),'c')
figure(5)
subplot(1,1,1);plot(data(:,18),data(:,9),'b',data(:,18),data(:,10),'g',data(:,18),data(:,11),'r',data(:,18),data(:,12),'c')

if teaching k = waitforbuttonpress 
end

%% average high sample rate data to get an 'continuous' curve

%% Binary Sum Order is determined here
%data(:,5)=data(:,3)*8+data(:,4)*4+data(:,2)*2+data(:,1);
data(:,5)=data(:,1)*8+data(:,2)*4+data(:,3)*2+data(:,4)*1;
figure(6);
plot(data(:,18),data(:,5));
text(10,3,sprintf('%s\nDC Avg = %d ;  LPF = %d \nThresholds=%4.2f %4.2f %4.2f %4.2f\nUse Env = %d ; Envelope Width=%d\nIntent filter=%d ',...
    a,DC_Avg,LPF,thres,use_env,envelope, Intent_filter),...
     'HorizontalAlignment','left')


%% set the Intent change filter parameter
% Controls how fast the system switches between 
% different intents (motions)
%  Larger Intent_filter causes slow transition but smooth motion
% Lower Intent_filter causes quick transitions, but more noise 
%


figure(7);
plot(data(:,18),(data(:,7)));
text(10,3,sprintf('%s\nDC Avg = %d ;  LPF = %d \nThresholds=%4.2f %4.2f %4.2f %4.2f\nUse Env = %d ; Envelope Width=%d\nIntent filter=%d ',...
    a,DC_Avg,LPF,thres,use_env,envelope, Intent_filter),...
     'HorizontalAlignment','left')


% create data sampled at 10 Hz into moves array (first column is time step)
moves=[1.0 1.0];

%%direct control

figure(8)
plot(moves(:,1), moves(:,2),':+');
text(10,3,sprintf('%s\nDC Avg = %d ;  LPF = %d \nThresholds=%4.2f %4.2f %4.2f %4.2f\nUse Env = %d ; Envelope Width=%d\nIntent filter=%d ',...
    a,DC_Avg,LPF,thres,use_env,envelope, Intent_filter),...
     'HorizontalAlignment','left')

save ('./Dorsey/movements_', 'moves');
end


 