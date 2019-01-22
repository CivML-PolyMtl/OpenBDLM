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
%       August 9, 2018
 
%--------------------BEGIN CODE ---------------------- 
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;
addRequired(p,'misc', @isstruct );
parse(p,misc);
misc=p.Results.misc;  
 
% Set fileID for logfile
if misc.internalVars.isQuiet
    % output message in logfile
    fileID=fopen(misc.internalVars.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end

%% Project to simulate data ?
incTest=0;
MaxFailAttempts = 4;

isYesNoCorrect = false;
while ~isYesNoCorrect
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    fprintf(fileID,'\n');
    fprintf(fileID, ['- Does this project aim to ', ...
        'create synthetic data ? (y/n) \n']);
    % read from user input file (use of global variable )?
    if misc.internalVars.BatchMode.isBatchMode
        choice=eval(char(misc.internalVars.BatchMode.Answers{misc.internalVars.BatchMode.AnswerIndex}));
        fprintf(fileID,'     %s', choice);
    else
        choice = input('     choice >> ','s');
    end
    if isempty(choice)
        fprintf(fileID,'\n');
        fprintf(fileID,'     wrong input --> please make a choice\n');
        fprintf(fileID,'\n');
    elseif strcmpi(choice,'y') || strcmpi(choice,'yes')
        
        misc.internalVars.isDataSimulation = true;
        isYesNoCorrect =  true;
        
    elseif strcmpi(choice,'n') || strcmpi(choice,'no') 
        
        misc.internalVars.isDataSimulation = false;
        isYesNoCorrect =  true;
        
    else
        fprintf(fileID,'\n');
        fprintf(fileID,'     wrong input\n');
        fprintf(fileID,'\n');
    end
    
end
% Increment global variable to read next answer when required
misc.internalVars.BatchMode.AnswerIndex = misc.internalVars.BatchMode.AnswerIndex+1;
fprintf(fileID,'\n');
fprintf(fileID,'\n');
%--------------------END CODE ------------------------ 
end
