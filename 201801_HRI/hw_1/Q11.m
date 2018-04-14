%% Q11
% Paul 'Nick' Laurenzano
% EN.525.786.91
% 2018/02/17

%% Prompt
% Use the 'tranimate' command in the Toolbox to view a translation from
% 2,2,2 to 3,5,7 and a counterclockwise rotation of 90 degrees around the
% X axis.
% 
% Show your code, use the publish command in MATLAB, create a PDF and
% upload as your answer. (NOTE: only the final location will be in the
% MATLAB publication, do not try to include a movie of the moving frame.
% This is an exercise to teach to use the tranimate tool). 

%% Setup
clear;
close all;

%% Animate
start = rt2tr(rpy2r(0, 0, 0), [2;2;2]);
% Per the right-hand rule, "positive" angles are in the counter-clockwise
% direction...
stop  = rt2tr(rpy2r(90, 0, 0, 'deg'), [3, 5, 7]);

tranimate(start, stop);
title('Animate');