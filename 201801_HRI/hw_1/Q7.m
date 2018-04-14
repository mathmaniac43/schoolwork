%% Q7 Prompt 
% 1. Execute the MATLAB commands below the line from a script.   Under the publishing tab, select publishing Options.  Change the output to PDF.  
% 2. Note the output in PDF format.   You will use this technique to answer questions and create a PDF file for upload.  Put the answer to the question in as comments in the MATLAB script.  It will get uploaded with the published file.  
% 3. Upload the PDF file as your answer to this question as practice.
%
%%% Description of HTM
%HTM(1,1) is = 1 because there is no change in the x-axis
%
% blank '%'lines add a new line to the published result
%
%%  lines with %% add a new section to the published result
% HTM(2,2) is .707 = sqrt(2) because the dot product of the new y axis with
% the old y axis is the sin(pi/4)
% etc  

%% Problem 1.3
HTM=rt2tr(rpy2r(pi()/4,0,0),[1;2;3])
trplot(HTM)
