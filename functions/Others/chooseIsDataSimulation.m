function [misc]=chooseIsDataSimulation(misc)
%CHOOSEISDATASIMULATION Interactive choice about project based on data simulation, or not
%
%   SYNOPSIS:
%     [misc]=CHOOSEISDATASIMULATION(misc)
% 
%   INPUT:
%      misc - structure (required)
% 
%   OUTPUT:
%      misc - structure
% 
%   DESCRIPTION:
%      Interactive choice about project based on data simulation, or not.
%      CHOOSEISDATASIMULATION request user's input.
%     
% 
%   EXAMPLES:
%      [misc]=CHOOSEISDATASIMULATION(misc)
% 
%   See also 
 
%   AUTHORS: 
%      Ianis Gaudot, Luong Ha Nguyen,   James-A Goulet
% 
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
% 
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
% 
%   DATE CREATED:
%       April 27, 2018
% 
%   DATE LAST UPDATE:
%       April 27, 2018
 
%--------------------BEGIN CODE ---------------------- 
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;
addRequired(p,'misc', @isstruct );
parse(p,misc);
misc=p.Results.misc;  
 
%% Project to simulate data ?
incTest=0;
MaxFailAttempts = 4;

isYesNoCorrect = false;
while ~isYesNoCorrect
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    disp(' ')
    fprintf('- Does this project aim to perform data simulation ? \n')
    % read from user input file (use of global variable )?
    if misc.BatchMode.isBatchMode
        choice=eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
        disp(['     ', choice])
    else
        choice = input('     (y/n) >> ','s');
    end
    if isempty(choice)
        disp(' ')
        disp('     wrong input --> please make a choice')
        disp(' ')
    elseif strcmp(choice,'y') || strcmp(choice,'yes') ||  ...
            strcmp(choice,'Y') || strcmp(choice,'Yes')  || ...
            strcmp(choice,'YES')
        
        misc.isDataSimulation = true;
        isYesNoCorrect =  true;
        
    elseif strcmp(choice,'n') || strcmp(choice,'no') ||  ...
            strcmp(choice,'N') || strcmp(choice,'No')  || ...
            strcmp(choice,'NO')
        
        misc.isDataSimulation = false;
        isYesNoCorrect =  true;
        
    else
        disp(' ')
        disp('     wrong input')
        disp(' ')
    end
    
end
% Increment global variable to read next answer when required
misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;
disp(' ')
%--------------------END CODE ------------------------ 
end
