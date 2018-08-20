function [data, model, estimation, misc]=piloteStateEstimation(data, model, estimation, misc)
%PILOTESTATEESTIMATION Pilote function for state estimation
%
%   SYNOPSIS:
%     [data, model, estimation, misc]=PILOTESTATEESTIMATION(data, model, estimation, misc)
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
%      PILOTESTATEESTIMATION Pilote function for state estimation
%
%   EXAMPLES:
%      [data, model, estimation, misc]=PILOTESTATEESTIMATION(data, model, estimation, misc)
%
%
%   EXTERNAL FUNCTIONS CALLED:
%       StateEstimation, saveProject, plotEstimations
%
%
%   SUBFUNCTIONS:
%
%   See also STATESESTIMATION, SAVEPROJECT, PLOTESTIMATIONS

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
%       July 27, 2018
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

ProjectPath=misc.ProjectPath;
FigurePath=misc.FigurePath;

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
    '----------------------------------------------------- \n']);
fprintf(fileID, '/    State estimation\n');
fprintf(fileID,['-----------------------------------------', ...
    '----------------------------------------------------- \n']);

%% Request user's choice about filtering or smoothing
incTest=0;
isCorrectAnswer =  false;
while ~isCorrectAnswer
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    fprintf(fileID,'\n');
    fprintf(fileID,'     1 ->  Filter \n');
    fprintf(fileID,'     2 ->  Smoother \n');
    fprintf(fileID,'\n');
    fprintf(fileID,'     Type R to return to the previous menu \n');
    fprintf(fileID,'\n');
    if misc.BatchMode.isBatchMode
        choice=eval(char(misc.BatchMode.Answers...
            {misc.BatchMode.AnswerIndex}));
        choice = num2str(choice);
        fprintf(fileID, '     %s\n', num2str(choice));
    else
        choice = input('     choice >> ', 's');
    end
    
    % Remove space and quotes
    choice=strrep(choice,'''',''); % remove quotes
    choice=strrep(choice,'"','' ); % remove double quotes
    choice=strrep(choice, ' ','' ); % remove spaces
    
    if round(str2double(choice)) == 1
        isSmoother = false;
        misc.isSmoother = isSmoother;
        isCorrectAnswer =  true;
    elseif round(str2double(choice)) == 2
        isSmoother = true;
        misc.isSmoother = isSmoother;
        isCorrectAnswer =  true;
        
    elseif ischar(choice) && length(choice) == 1 && strcmpi(choice, 'r')
        return
    else
        fprintf(fileID,'\n');
        fprintf(fileID,'     wrong input \n');
        continue
    end
    
end

% Save true hidden states values if they exist
if isfield(estimation, 'ref')
    ref=estimation.ref;
end

%% Filter / Smoother
[estimation]=StateEstimation(data, model, misc, ...
    'isSmoother',isSmoother);

% Store back true hidden states values if they exist
if exist('ref', 'var') == 1
    estimation.ref=ref;
end

% Save project
saveProject(data, model, estimation, misc, ...
    'FilePath',ProjectPath)

% Plot estimations
% fprintf(fileID,'\n');
% fprintf(fileID,'     Plot hidden variables in progress...\n');
plotEstimations(data, model, estimation, misc,'FilePath', FigurePath, ...
    'isExportPDF', false, ...
    'isExportPNG', false, ...
    'isExportTEX', false)

misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;

%--------------------END CODE ------------------------
end
