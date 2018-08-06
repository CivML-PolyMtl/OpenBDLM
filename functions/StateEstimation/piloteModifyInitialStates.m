function [model, misc]=piloteModifyInitialStates(data, model, estimation, misc)
%PILOTEMODIFYINITIALSTATES Pilote function to modify initial hidden states
%
%   SYNOPSIS:
%     [model, misc]=PILOTEMODIFYINITIALSTATES(data, model, estimation, misc)
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
%      PILOTEMODIFYINITIALSTATES Pilote function to modify initial hidden states
%
%   EXAMPLES:
%      [model, misc]=piloteModifyInitialStates(data, model, estimation, misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%      ModifyInitialHiddenStates
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also MODIFYINITIALHIDDENSTATES

%   AUTHORS:
%        Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
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
disp('/    Modify current initial hidden states (x_0) values')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])

[model, misc] = modifyInitialHiddenStates(data, model, estimation, misc, ...
    'FilePath', ProjectPath);

%--------------------END CODE ------------------------
end
