%% Q8
% Paul "Nick" Laurenzano

%%  Overview
% Based on Textbook Ch. 7 Question 9
clear;
close all;

% This is disabled by default because drawing is slow and does weird things
% when publishing.
ROBOT_DRAW = false;

load hershey;
max_speeds = [0.5, 0.5, 0.5];
start = rt2tr(eye(3), [-0.3; 0.3; 0]);
vertical_offset = 0.2; % Makes it easier to read as the robot draws.

height = 100;
mdl_puma560; robot = p560;
sentence = 'B';
traj = writeSentence(hershey, sentence, height, max_speeds, vertical_offset);
plotSentence(sentence, traj, 'setup');
drawSentenceIkine6s(sentence, traj, robot, start, ROBOT_DRAW);

%% a
% Change the size of a letter.
height = 200;
traj = writeSentence(hershey, sentence, height, max_speeds, vertical_offset);
plotSentence(sentence, traj, 'a');
drawSentenceIkine6s(sentence, traj, robot, start, ROBOT_DRAW);

%% b
% Write a word or sentence.
sentence = 'Hershey!';
traj = writeSentence(hershey, sentence, height, max_speeds, vertical_offset);
plotSentence(sentence, traj, 'b');
drawSentenceIkine6s(sentence, traj, robot, start, ROBOT_DRAW);

%% c
% Write on a vertical plane.
rot = rotx(90, 'deg');
vert_traj = rot * traj;
vert_start = start * rt2tr(rot, [0; 0; 0]);
plotSentence(sentence, vert_traj, 'c');
drawSentenceIkine6s(sentence, traj, robot, vert_start, ROBOT_DRAW);

%% d
% Write on an inclined plane.
rot = rotx(15, 'deg') * roty(30, 'deg') * rotz(45, 'deg');
inclined_traj = rot * traj;
inclined_start = start * rt2tr(rot, [0; 0; 0]);
plotSentence(sentence, inclined_traj, 'd');
drawSentenceIkine6s(sentence, traj, robot, inclined_start, ROBOT_DRAW);

%% e
% Change the robot from a puma 560 to the Fanuc 10L
mdl_fanuc10L; robot = R;
sentence = 'B';
traj = writeSentence(hershey, sentence, height, max_speeds, vertical_offset);
plotSentence(sentence, traj, 'e');
drawSentenceIkine(sentence, traj, robot, start, ROBOT_DRAW);

%% Helper Functions

function traj = writeSentence(alphabet, sentence, height, max_speeds, vertical_offset)
% WRITESENTENCE Creates the trajectory needed to write a sentence.
% alphabet   - map of characters to their drawing information (i.e.
% 'hershey')
% sentence   - characters to print (string)
% height     - physical height of letters (mm)
% max_speeds - max speeds of robot (m/sec, XYZ)

    scale = height / 1000; % scale to 1mm
    x_pos = 0;
    sentence_path = [];
    for char = sentence
        info = alphabet{char};
        
        % Scales letter to height, and picks up after each letter.
        letter_path = scale * [x_pos + info.stroke(1,:), NaN; ...
                                       info.stroke(2,:), NaN];
        
        x_pos = x_pos + info.width;
        sentence_path = [sentence_path, letter_path];
    end
    
    % Remove last column, which are extra NaNs for lifting.
    sentence_path = sentence_path(:, 1:end-1);
    
    % Bolt on third row for Z.
    sentence_path = [sentence_path; zeros(1, numcols(sentence_path))];
    lift_indices = find(isnan(sentence_path(1,:)));

    % Assume no lifts at beginning or end...
    sentence_path(:, lift_indices) = ...
        (sentence_path(:, lift_indices - 1) + sentence_path(:, lift_indices + 1)) / 2;
    sentence_path(3, lift_indices) = 0.01; % pick up 1cm
    
    % Start and end at the same height above the sentence.
    sentence_path = [[sentence_path(1:2,1); vertical_offset],    ...
                     sentence_path,                              ...
                     [sentence_path(1:2,end); vertical_offset]];
    
    % Transpose to have rows be X, Y, Z like the paths.
    traj = mstraj(sentence_path(:,2:end)', max_speeds, [], sentence_path(:,1)', 0.02, 0.2)';
end

function plotSentence(sentence, traj, label)
% PLOTSENTENCE Plots the trajetory from a sentence in 3d space.

    figure;
    plot3(traj(1,:), traj(2,:), traj(3,:));
    axis equal;
    title(sprintf('%s (%s)', sentence, label));
end

function drawSentenceIkine6s(sentence, traj, robot, start, enabled)
% DRAWSENTENCEIKINE6S Uses the SerialLink.ikine6s function to determine the
% robot's state over time to write the given trajectpry, then plots it.

    if (enabled)
        figure;
        Tp = SE3(start) * SE3(traj');
        q = robot.ikine6s(Tp);
        robot.plot(q, 'noloop', 'trail', 'r');
        title(sentence);
    end
end

function drawSentenceIkine(sentence, traj, robot, start, enabled)
% DRAWSENTENCEIKINE6S Uses the SerialLink.ikine function to determine the
% robot's state over time to write the given trajectpry, then plots it.

    if (enabled)
        figure;
        Tp = SE3(start) * SE3(traj');
        q = robot.ikine(Tp);
        robot.plot(q, 'noloop', 'trail', 'r');
        title(sentence);
    end
end