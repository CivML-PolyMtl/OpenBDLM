function [data, model, estimation, misc]=piloteOptimization(data, model, estimation, misc)
%PILOTEOPTIMIZATION Pilote function for optimization
%
%   SYNOPSIS:
%     [data, model, estimation, misc]=PILOTEOPTIMIZATION(data, model, estimation, misc)
%
%   INPUT:
%      data         - structure
%                     see documentation for details about the fields of data
%
%      model        - structure
%                     see documentation for details about the fields of
%                     model
%
%      estimation   - structure
%                     see documentation for details about the fields of
%                     estimation
%
%      misc         - structure
%                     see documentation for details about the fields of misc
%
%   OUTPUT:
%      data         - structure
%                     see documentation for details about the fields of data
%
%      model        - structure
%                     see documentation for details about the fields of
%                     model
%
%      estimation   - structure
%                     see documentation for details about the fields of
%                     estimation
%
%      misc         - structure
%                     see documentation for details about the fields of misc
%
%   DESCRIPTION:
%      PILOTEOPTIMIZATION Pilote function for optimization
%
%   EXAMPLES:
%      [data, model, estimation, misc]=PILOTEOPTIMIZATION(data, model, estimation, misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%       learnModelParameters, saveProject
%
%   SUBFUNCTIONS:
%       N/A
%
%   See also LEARNMODELPARAMETERS, SAVEPROJECT

%   AUTHORS:
%       Ianis Gaudot, Luong Ha Nguyen,  James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.4.0.813654 (R2018a)
%
%   DATE CREATED:
%       July 26, 2018
%
%   DATE LAST UPDATE:
%       August 9, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'estimation', @isstruct );
addRequired(p,'misc', @isstruct );
parse(p,data, model, estimation, misc );

data=p.Results.data;
model=p.Results.model;
estimation=p.Results.estimation;
misc=p.Results.misc;

FilePath = misc.ProjectPath;


% Set fileID for logfile
if misc.isQuiet
    % output message in logfile
    fileID=fopen(misc.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end


MaxFailAttempts=4;

fprintf(fileID,'\n');
fprintf(fileID,['-----------------------------------------', ...
    '-----------------------------------------------------\n']);
fprintf(fileID,'/ Learn model parameters\n');
fprintf(fileID,['-----------------------------------------', ...
    '-----------------------------------------------------\n']);
incTest=0;
isCorrectAnswer =  false;
while ~isCorrectAnswer
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    fprintf(fileID,'\n');
    fprintf(fileID,'     1 ->  Newton-Raphson\n');
    fprintf(fileID,'     2 ->  Stochastic Gradient Ascent\n');
    fprintf(fileID,'\n');
    fprintf(fileID,'     Type R to return to the previous menu\n');
    fprintf(fileID,'\n');
    
    if misc.BatchMode.isBatchMode
        user_inputs=eval(char(misc.BatchMode.Answers ...
            {misc.BatchMode.AnswerIndex}));
        user_inputs = num2str(user_inputs);
        if ischar(user_inputs)
            fprintf(fileID, '     %s  \n', user_inputs);
        else
            fprintf(fileID, '     %s  \n', num2str(user_inputs));
        end
        
    else
        user_inputs = input('     choice >> ', 's');
    end
    
    % Remove space and simple/double quotes
    user_inputs=strrep(user_inputs,'''',''); 
    user_inputs=strrep(user_inputs,'"','' ); 
    user_inputs=strrep(user_inputs, ' ','' ); 
    
    
    if round(str2double(user_inputs)) == 1
        
        % Learn model parameters
        [data, model, estimation, misc]= ...
            learnModelParameters(data, model, ...
            estimation, misc, ...
            'FilePath', FilePath, ...
            'Method', 'NR');
        
        isCorrectAnswer =  true;
    elseif round(str2double(user_inputs)) == 2
        
        % Learn model parameters
        [data, model, estimation, misc]= ...
            learnModelParameters(data, model, ...
            estimation, misc, ...
            'FilePath', FilePath, ...
            'Method', 'SGA');
        
        isCorrectAnswer =  true;
    elseif ischar(user_inputs) && length(user_inputs) == 1 && ...
            strcmpi(user_inputs, 'R')
        break
    else
        fprintf(fileID,'\n');
        fprintf(fileID,'      wrong input\n');
        continue
    end
    
end
misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;

%--------------------END CODE ------------------------
end
