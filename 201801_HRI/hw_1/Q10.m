%% Q10
% Paul 'Nick' Laurenzano
% EN.525.786.91
% 2018/02/15

%% Prompt
% Use the toolbox functions to calculate the new position and orientation
% after the following steps are taken.
%
% Use trplot to illustrate the new frame in the world frame.
% 
% Publish and upload your results.
%
% 1. Translate 5 units in the world Y direction.
% 
% 2. Rotate 40 degrees in the world Z direction.
% 
% 3. Translate 3 units in the world Z direction.

%% Setup
% Note that all movements are with regards to the WORLD reference frame.
% Therefore, both translations can effectively be performed at one time
% first, then the rotation can be applied afterwards, all theoretically
% in one step instead of compounded steps.
clear;
close all;

%% World Frame
t = 'World Frame';

frame = rt2tr(rpy2r(0, 0, 0), [0;0;0]);

figure;
trplot(frame);
title(t);

disp(t);
disp(frame);

%% 1. Translate 5 units in the world Y direction.
t = 'Step 1';

frame = rt2tr(rpy2r(0, 0, 0), [0;5;0]);

figure;
trplot(frame);
title(t);

disp(t);
disp(frame);

%% 2. Rotate 40 degrees in the world Z direction.
t = 'Step 2';

frame = rt2tr(rpy2r(0, 0, 40, 'deg'), [0;5;0]);

figure;
trplot(frame);
title(t);

disp(t);
disp(frame);

%% 3. Rotate 40 degrees in the world Z direction.
t = 'Step 3';

frame = rt2tr(rpy2r(0, 0, 40, 'deg'), [0;5;3]);

figure;
trplot(frame);
title(t);

disp(t);
disp(frame);