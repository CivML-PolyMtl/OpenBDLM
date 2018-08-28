function [data, misc]=defineDataLabels(data, misc)
%DEFINEDATALABELS Request user's input to define data labels
%
%   SYNOPSIS:
%     [data, misc]=DEFINEDATALABELS(data, misc)
%
%   INPUT:
%      data     - structure (required)
%      misc     - structure (required)
%
%   OUTPUT:
%      data     - structure
%      misc     - structure
%
%   DESCRIPTION:
%      DEFINEDATALABELS request user input to define data labels
%      DEFINEDATALABELS create the field labels of the structure data
%
%   EXAMPLES:
%      [data, misc]=DEFINEDATALABELS(data, misc)
%
%   See also DEFINETIMESTAMPS, DEFINECUSTOMANOMALIES

%   AUTHORS:
%    Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       April 24, 2018
%
%   DATE LAST UPDATE:
%       August 9, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'data', @isstruct );
addRequired(p,'misc', @isstruct );
parse(p,data, misc);

data=p.Results.data;
misc=p.Results.misc;

MaxFailAttempts=4;

% Set fileID for logfile
if misc.internalVars.isQuiet
    % output message in logfile
    fileID=fopen(misc.internalVars.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end

%% Request user's input to get the number of time series to simulate

incTest=0;
isCorrect =false;
while ~isCorrect
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    fprintf(fileID,'- Give the number of time series to simulate:\n');
    if misc.internalVars.BatchMode.isBatchMode
        user_choice=eval(char(misc.internalVars.BatchMode.Answers{misc.internalVars.BatchMode.AnswerIndex}));
        fprintf(fileID,'     %s\n', num2str(user_choice));
    else
        user_choice=input('     choice >> ');
    end
    
    if isempty(user_choice)
        continue
    elseif (rem(user_choice,1) == 0) && (user_choice > 0)
        nts = user_choice;
        isCorrect =  true;
    else
        fprintf(fileID,'     Wrong input.\n');
        continue
    end
end

%% Automatically generate time series labels and store them in data.labels

% Base name
BaseName = 'TS';

for i=1:nts
    data.labels{i}=[BaseName num2str(i,'%02d')];
end

% Increment AnswerIndex to read next answer when required
misc.internalVars.BatchMode.AnswerIndex = misc.internalVars.BatchMode.AnswerIndex + 1;
%--------------------END CODE ------------------------
end
