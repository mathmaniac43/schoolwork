%% Q8
% Paul 'Nick' Laurenzano
% EN.525.786.91
% 2018/02/15

%% Prompt
% Execute the toolbox command below (in a script so you can publish the results), 
% This command takes a roll, pitch and yaw rotation matrix  AND a translation vector (note the semi-colons to get a column vector).  It creates a transformation matrix representing the new orientation and position.   In the answer produced by MATLAB publish use % comment lines to explain the non-zero elements of the 4x4 HTM matrix.  
% 
%  HTM=rt2tr(rpy2r(0,pi()/4,0),[1;2;3])
%  trplot(HTM)

%% Base Frame, No Rotation or Translation
figure;
HTM = rt2tr(rpy2r(0, 0, 0), [0;0;0]);
trplot(HTM);

disp 'Base Frame';
disp(HTM);

%% Intermediate Frame, Rotation but No Translation
figure;
HTM = rt2tr(rpy2r(0, pi()/4, 0), [0;0;0]);
trplot(HTM);

disp 'Intermediate Frame';
disp(HTM);

%% Final Frame, Rotation and Translation
figure;
HTM = rt2tr(rpy2r(0, pi()/4, 0), [1;2;3]);
trplot(HTM);

disp 'Final Frame';
disp(HTM);

%% Analysis
%
% Since this is a rotation about the Y (second) axis, the rotation matrix
% outlined in the book on page 34, specifically $R_y(\theta)$, is what is
% used here, with $\theta=\pi/4$.
%
% $HTM(1, 3) =  sin(\pi/4) = \sqrt{2}/2 \approx 0.7071$
%
% $HTM(1, 1) =  cos(\pi/4) = \sqrt{2}/2 \approx 0.7071$
%
% $HTM(2, 2) =  1$
%
% $HTM(3, 1) = -sin(\pi/4) = \sqrt{2}/2 \approx 0.7071$
%
% $HTM(3, 3) =  cos(\pi/4) = \sqrt{2}/2 \approx 0.7071$
%
% The remaining interesting values are explained by the translation vector.
%
% $HTM(1, 4) = t_X = 1$
%
% $HTM(2, 4) = t_Y = 2$
%
% $HTM(3, 4) = t_Z = 3$
%
% $HTM(4, 4) = 1$