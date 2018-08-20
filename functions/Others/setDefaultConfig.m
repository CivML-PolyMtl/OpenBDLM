function [misc, data]=setDefaultConfig(misc, data)
%SETDEFAULTCONFIG Set default variables if not already defined
%
%   SYNOPSIS:
%     [misc]=SETDEFAULTCONFIG(misc)
%
%   INPUT:
%      misc         - structure
%                     see documentation for details about the fields of misc
%
%     data             - structure (required)
%                         see documentation for details about the fields of
%                         data
%
%   OUTPUT:
%      misc         - structure
%                     see documentation for details about the fields of misc
%
%   DESCRIPTION:
%      SETDEFAULTCONFIG sets default variables if not already defined
%
%   EXAMPLES:
%      [misc]=SETDEFAULTCONFIG(misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also

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
%       July 30, 2018
%
%   DATE LAST UPDATE:
%       July 30, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'misc', @isstruct );
addRequired(p,'data', @isstruct );
parse(p, misc, data);

misc=p.Results.misc;
data=p.Results.data;

%% Default method
if ~isfield(misc, 'method')
    misc.method = 'kalman';
end

%% Default training period
if ~isfield(misc, 'trainingPeriod')

    timestamps = data.timestamps;
    
    % Get training dataset from timestamp vector
    [trainingPeriod] = defineTrainingPeriod(timestamps, 'Percent', 100);
    misc.trainingPeriod = trainingPeriod;
end

%--------------------END CODE ------------------------
end
