function [timesteps]=computeTimeSteps(timestamps)
%COMPUTETIMESTEPS Compute timestep vector from timestamps vector
%
%   SYNOPSIS:
%     [timestep]=COMPUTETIMESTEPS(timestamps)
% 
%   INPUT:
%      timestamps                 - Nx1 real array (required)
%                                  timestamp vector
%                                  N: number of samples in the time series
% 
%   OUTPUT:
%      timesteps                 - (N-1)x1 real array (required)
%                                  timestep vector
%                                  N: number of samples in the time series
%
%   DESCRIPTION:
%      COMPUTETIMESTEPS compute timestep vector from timestamps vector
% 
%   EXAMPLES:
%      [timesteps]=COMPUTETIMESTEPS(timestamps)
% 
%   See also DISPLAYMODELMATRICES
 
%   AUTHORS: 
%      James-A Goulet, Luong Ha Nguyen, Ianis Gaudot
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
%       April 24, 2018
 
%--------------------BEGIN CODE ---------------------- 
 
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;
ValidationFcn = @(x)isnumeric(x)&~isempty(x)&length(x)>2;
addRequired(p,'timestamps', ValidationFcn );
parse(p,timestamps);     

%% Compute timestep vector

[referencetimestep]=defineReferenceTimeStep(timestamps);

timesteps = [referencetimestep; diff(timestamps)];

%--------------------END CODE ------------------------ 
end
