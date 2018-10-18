function [isValid]=verificationDataStructure(data)
%VERIFICATIONDATASTRUCTURE Verify formatting of data structure
%
%   SYNOPSIS:
%     [isValid]=VERIFICATIONDATASTRUCTURE(data)
%
%   INPUT:
%       data      - structure (required)
%                   data must contain three fields:
%
%                       'timestamps' is a M×1 array
%
%                       'values' is a MxN  array
%
%                       'labels' is a 1×N cell array
%                        each cell is a character array
%
%                           N: number of time series
%                           M: number of samples
%
%   OUTPUT:
%      isValid    - logical
%                   if data is not valid, isValid = false
%
%   DESCRIPTION:
%      VERIFICATIONDATASTRUCTURE verifies formatting of data structure
%      If isValid = false, abnormal formatting
%
%   EXAMPLES:
%      [isValid]=verificationDataStructure(data)
%
%   See also READMULTIPLECSVFILES, PLOTDATA, PLOTDATAAVAILABILITY,
%            SAVEDATABINARY, SAVEDATACSV

%   AUTHORS:
%      Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       April 12, 2018
%
%   DATE LAST UPDATE:
%       October 16, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;
addRequired(p,'data', @isstruct );
parse(p,data);
data=p.Results.data;

% Default value
isValid = true;

%% Verifications of data
% verification of the correct field names
if ~isfield(data,'timestamps') || ~isfield(data,'values') || ...
        ~isfield(data,'labels')
    isValid = false;
    return
end

% verification that each field in not empty
if isempty(data.timestamps) || ...
   isempty(data.values) || ...
   any (cellfun(@isempty, data.labels))
    
    isValid = false;
    return
end

% verification that same number of observations in each field
if size(data.values,2) ~= length(data.labels)
    isValid = false;
    return
end

% verification that same number of samples for each time/value pair
if  size(data.timestamps,1) ~= size(data.values,1)
    isValid = false;
    return
end

% verification that timestamps are in chronological order
isChronological = @(x) any(diff(x) <= 0);

if any(isChronological(data.timestamps))
    isValid = false;
    return
end

%--------------------END CODE ------------------------
end
