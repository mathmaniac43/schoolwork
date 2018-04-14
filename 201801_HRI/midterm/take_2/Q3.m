%% Midterm Question 3
% Paul "Nick" Laurenzano

%% Overview
% A frame o1 is translated 2.5 units along the x-axis, then rotated pi/6
% about the o1 z-axis, with a final translation along the fixed z-axis
% of -1.5 units.
% 
% Compute o1 with respect to o0 after each step
% (use the publish command and Table 2.2 in the book).
% Remember to use the correct order to multiplication. 
% 
% Show the final o1 in the o0 frame. 

%% Setup
o0 = transl(0, 0, 0);
o1 = o0;

disp 'Setup'
o1

%% Step 1
o1 = o0 * transl(2.5, 0, 0);

disp 'Step 1'
o1

%% Step 2
o1 = o1 * rpy2tr(0, 0, pi/6);

disp 'Step 2'
o1

%% Step 3
o1 = o1 * transl(0, 0, -1.5);

disp 'Step 3'
o1

%% Final
figure;
trplot(o1);