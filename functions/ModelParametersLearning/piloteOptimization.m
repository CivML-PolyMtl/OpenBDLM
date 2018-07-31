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
%       July 27, 2018

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

MaxFailAttempts=4;

disp(' ')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])
disp('/ Learn model parameters')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])
incTest=0;
isCorrectAnswer =  false;
while ~isCorrectAnswer
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    disp(' ')
    disp('     1 ->  Newton-Raphson')
    disp('     2 ->  Stochastic Gradient Ascent')
    disp(' ')
    disp('     3 ->  Return to menu')
    disp(' ')
    
    if misc.BatchMode.isBatchMode
        user_inputs=eval(char(misc.BatchMode.Answers ...
            {misc.BatchMode.AnswerIndex}));
        disp(user_inputs)
    else
        user_inputs = input('     choice >> ');
    end
    
    if user_inputs == 1
        
        % Learn model parameters
        [data, model, estimation, misc]= ...
            learnModelParameters(data, model, ...
            estimation, misc, ...
            'FilePath', FilePath, ...
            'Method', 'NR');
        
        % Save project
        saveProject(data, model, estimation, misc, ...
            'FilePath', FilePath)
        
        isCorrectAnswer =  true;
    elseif user_inputs == 2
        
        % Learn model parameters
        [data, model, estimation, misc]= ...
            learnModelParameters(data, model, ...
            estimation, misc, ...
            'FilePath', FilePath, ...
            'Method', 'SGA');
        
        % Save project
        saveProject(data, model, estimation, misc, ...
            'FilePath', FilePath)
        
        isCorrectAnswer =  true;
    elseif user_inputs == 3
        break
    else
        disp(' ')
        disp('      wrong input')
        continue
    end
    
end
misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;

%--------------------END CODE ------------------------
end
