function [misc]=piloteModifyTrainingPeriod(data, model, estimation, misc)
%PILOTEMODIFYTRAININGPERIOD Pilote function to modify training period
%   SYNOPSIS:
%     [misc]=PILOTEMODIFYTRAININGPERIOD(data, model, estimation, misc)
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
%      misc               - structure
%                            see documentation for details about the fields
%                            in structure "misc"
%
%   DESCRIPTION:
%      PILOTEMODIFYTRAININGPERIOD Pilote function to modify training period
%
%   EXAMPLES:
%      [misc]=PILOTEMODIFYTRAININGPERIOD(data, model, estimation, misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%      modifyTrainingPeriod
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also MODIFYTRAININGPERIOD

%   AUTHORS:
%        Ianis Gaudot,Luong Ha Nguyen, James-A Goulet
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
disp('/ Modify training period')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])

[misc] = modifyTrainingPeriod(data, model, estimation, misc, ...
    'FilePath', ProjectPath);

%--------------------END CODE ------------------------
end
