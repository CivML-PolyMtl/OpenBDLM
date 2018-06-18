function [ReferenceTimestep]=defineReferenceTimeStep(timestamps)
%DEFINEREFERENCETIMESTEP computes reference timestep of a timestamp vector
%
%   SYNOPSIS:
%     [referencetimestep]=DEFINEREFERENCETIMESTEP(ts)
%
%   INPUT:
%      timestamp                 - Nx1 real array (required)
%                                  timestamp vector
%                                  N: number of samples in the time series
%
%   OUTPUT:
%      referencetimestep         - real                     
%
%   DESCRIPTION:
%      DEFINEREFERENCETIMESTEP computes reference timestep
%
%   EXAMPLES:
%     [referencetimestep] = DEFINEREFERENCETIMESTEP(timestamp)
%
%   See also CONFIGURE, CONFIGUREREAL, CONFIGURESIMULATION

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
%       April 19, 2018
%
%   DATE LAST UPDATE:
%       April 20, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;
ValidationFcn = @(x)isnumeric(x)&~isempty(x);
addRequired(p,'timestamps', ValidationFcn );
parse(p,timestamps);

%% Get reference time step
% get time step
dt_steps=diff(timestamps);
% compute reference (most frequent) time step
unique_dt_steps=unique(dt_steps);
counts_dt_steps= [unique_dt_steps,histc(dt_steps(:),unique_dt_steps)];
ReferenceTimestep=counts_dt_steps(find(counts_dt_steps(:,2)== ...
    max(counts_dt_steps(:,2)),1,'first'),1);
%--------------------END CODE ------------------------
end
