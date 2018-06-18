function [isValid]=verificationDataStructure(data)
%VERIFICATIONDATASTRUCTURE Verify formatting of data structure
%
%   SYNOPSIS:
%     [isValid]=VERIFICATIONDATASTRUCTURE(data)
%
%   INPUT:
%      data       - structure (required)
%                   data must contain three fields :
%
%                       'timestamps' is a 1×N cell array
%                       each cell is a M_ix1 real array
%
%                       'values' is a 1×N cell array
%                       each cell is a M_ix1 real array
%
%                       'labels' is a 1×N cell array
%                       each cell is a character array
%
%                 N: number of time series
%                 M_i: number of samples of time series i
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
%       April 12, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;
addRequired(p,'data', @isstruct );
parse(p,data);
data=p.Results.data;

% Default value
isValid = true;

%% Verifications of "data"
% verification of the correct field names
if ~isfield(data,'timestamps') || ~isfield(data,'values') || ...
        ~isfield(data,'labels')
    isValid = false;
    return
end

% verification non empty labels
if any (cellfun(@isempty, data.timestamps)) || ...
        any (cellfun(@isempty, data.values)) || ...
        any (cellfun(@isempty, data.labels))
    isValid = false;
    return
end


% verification there are data
% if any( structfun(@isempty, data) )
%     isValid = false;
%     return
% end

% verification data contains cell array
if ~all( structfun(@iscell, data) )
    isValid = false;
    return
end

% verification that same number of observations in each field
if length(data.timestamps) ~= length(data.values) || ...
        length(data.timestamps) ~= length(data.labels) || ...
        length(data.values) ~= length(data.labels)
    isValid = false;
    return
end

% verification that same number of samples for each time/value pair
if any(cellfun(@length, (data.timestamps))- ...
        cellfun(@length, (data.values)))
    isValid = false;
    return
end

% verification that timestamps are in chronological order
isChronological = @(x) any(diff(x) <= 0);

if any (cellfun(isChronological, data.timestamps))
    isValid = false;
    return
end

%--------------------END CODE ------------------------
end
