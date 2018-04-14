%% Q5
% Paul 'Nick' Laurenzano
% EN.525.786.91
% 2018/02/15

%% Prompt
% Use a single line MATLAB command to create a homogenous transformation
% matrix with a -45 degree rotation about X axis and a translation of
% (2,3,5) in the world reference frame. What is the HTM produced?

%% Setup
clear;
close all;

%% Base Frame, No Rotation or Translation
t = 'Base Frame';

figure;
HTM = rt2tr(rpy2r(0, 0, 0), [0;0;0]);
trplot(HTM);
title(t);

disp(t);
disp(HTM);

%% Intermediate Frame, Rotation but No Translation
t = 'Intermediate Frame';

figure;
HTM = rt2tr(rpy2r(-pi()/4, 0, 0), [0;0;0]);
trplot(HTM);
title(t);

disp(t);
disp(HTM);

%% Final Frame, Rotation and Translation
t = 'Final Frame';

figure;
HTM = rt2tr(rpy2r(-pi()/4, 0, 0), [2;3;5]); % This is the single command
trplot(HTM);
title(t);

disp(t);
disp(HTM);