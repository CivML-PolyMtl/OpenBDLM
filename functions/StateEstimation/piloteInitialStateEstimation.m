function [data, model, estimation, misc]=piloteInitialStateEstimation(data, model, estimation, misc)
%PILOTEINITIALSTATEESTIMATION Pilote function to estimate initial states
%
%   SYNOPSIS:
%     [data, model, estimation, misc]=PILOTEINITIALSTATEESTIMATION(data, model, estimation, misc)
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
%      PILOTEINITIALSTATEESTIMATION Pilote function to estimate initial states
%
%   EXAMPLES:
%      [data, model, estimation, misc]=PILOTEINITIALSTATEESTIMATION(data, model, estimation, misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%      computeInitialHiddenStates, saveProject
%
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also COMPUTEINITIALHIDDENSTATES, SAVEPROJECT

%   AUTHORS:
%       Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
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

ProjectPath=misc.internalVars.ProjectPath;


% Set fileID for logfile
if misc.internalVars.isQuiet
    % output message in logfile
    fileID=fopen(misc.internalVars.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end

fprintf(fileID,'\n');
fprintf(fileID,['-----------------------------------------', ...
    '----------------------------------------------------- \n']);
fprintf(fileID,'/ Estimate initial hidden states x_0 \n');
fprintf(fileID,['-----------------------------------------', ...
    '----------------------------------------------------- \n']);
fprintf(fileID,'\n');

% Compute initial hidden states values
[model] = computeInitialHiddenStates(data, model, estimation, misc, ...
    'FilePath', ProjectPath, 'Percent', 100);

% Save project
%saveProject(data, model, estimation, misc,'FilePath', ProjectPath)

%--------------------END CODE ------------------------
end
