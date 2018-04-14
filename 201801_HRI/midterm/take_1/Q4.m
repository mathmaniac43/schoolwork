%% Midterm Question 4
% Paul "Nick" Laurenzano

%% Overview
% For the shown RPP robot...

%% A
% Calculate the inverse kinematic equations for the three joint variables
% theta1, d2 and d3, given X, Y and Z. Type them into the window as your
% answer. Save them for the question below.
% Theta(X,Y,Z) =  ,    d2 (X,Y,Z) =   ,   and d3 (X,Y,Z) =    ,
clear;
close all;

robot = SerialLink([Revolute('d', 0.5), Prismatic('alpha', -pi/2, 'qlim', [0, 3]), Prismatic('offset', 0.75, 'qlim', [0, 3])]);

robot.teach([0, 0, 0]);

dh = DHFactor(robot);

% It took me a loooooong time to figure out the proper parameters for each
% of the links... that was a problem...
% Based on the notes I could decompose this into each of the 4 variables,
% looking at the matrices and tables we have. Then I could simply use
% MATLAB to reverse solve those equations in matrix form for part B. But I
% did not have time to do so.


%% B
% Calculate the joint angles for (X,Y,Z) = (0.25,1,1.25)
