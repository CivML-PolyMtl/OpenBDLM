function [model, misc]=piloteModifyModelParameters(data, model, estimation, misc)
%PILOTEMODIFYMODELPARAMETERS Pilote function to modify model parameters
%
%   SYNOPSIS:
%     [model, misc]=PILOTEMODIFYMODELPARAMETERS(data, model, estimation, misc)
%
%   INPUT:
%      data                - structure
%                            see documentation for details about the fields
%                            in structure "data"
%
%      model               - structure
%                            see documentation for details about the fields
%                            in structure "model"
%
%      estimation         - structure
%                            see documentation for details about the fields
%                            in structure "estimation"
%
%      misc               - structure
%                            see documentation for details about the fields
%                            in structure "misc"
%
%
%   OUTPUT:
%
%      model               - structure
%                            see documentation for details about the fields
%                            in structure "model"
%
%      misc               - structure
%                            see documentation for details about the fields
%                            in structure "misc"
%
%
%   DESCRIPTION:
%      PILOTEMODIFYMODELPARAMETERS Pilote function to modify parameters
%
%   EXAMPLES:
%      [model, misc]=PILOTEMODIFYMODELPARAMETERS(data, model, estimation, misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%      modifyModelParameters
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also MODIFYMODELPARAMETERS

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

ProjectPath=misc.ProjectPath;

disp(' ')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])
disp('/ Modify current parameters values')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])

[model, misc] = modifyModelParameters(data, model, ...
    estimation, misc, 'FilePath', ProjectPath);

%--------------------END CODE ------------------------
end
