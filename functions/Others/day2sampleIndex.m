function [Index]=day2sampleIndex(day, timestamps)
%DAY2SAMPLEINDEX Convert a number of days to timestamp index
%
%   SYNOPSIS:
%     [Index]=DAY2SAMPLEINDEX(day, timestamps)
% 
%   INPUT:
%      day              - real (required)
%                         number of days since first sample of vector 
%                         timestamp
%
%      timestamp        - Nx1 real array (required)
%                         timestamp vector
%                         N: number of samples in the time series
% 
%   OUTPUT:
%      Index            - sample index in "timestamps" vector corresponding 
%                         to the number of day given by "day"
% 
%   DESCRIPTION:
%      DAY2SAMPLEINDEX converts a number of days to timestamp index
% 
%   EXAMPLES:
%      [Index]=DAY2SAMPLEINDEX(day, timestamps)
% 
%   See also
 
%   AUTHORS: 
%     Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
% 
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
% 
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
% 
%   DATE CREATED:
%       April 20, 2018
% 
%   DATE LAST UPDATE:
%       August 15, 2018
 
%--------------------BEGIN CODE ---------------------- 
 
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'day', @real );
ValidationFcn = @(x)isnumeric(x)&~isempty(x);
addRequired(p,'timestamps', ValidationFcn );
parse(p,day,timestamps );

day=p.Results.day;
timestamps=p.Results.timestamps;
 
if day == Inf
    Index=length(timestamps);
else
    Index = find(abs(timestamps-timestamps(1)-day+1)== ...
        min(abs(timestamps-timestamps(1)-day+1)),1,'first');
end
%--------------------END CODE ------------------------ 
end
