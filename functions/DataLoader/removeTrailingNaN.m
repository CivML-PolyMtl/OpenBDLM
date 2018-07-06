function [data]=removeTrailingNaN(data)
%REMOVETRAILINGNAN Removes trailing missing data
%
%   SYNOPSIS:
%     [data]=REMOVETRAILINGNAN(data)
%
%   INPUT:
%      data         - structure (required)
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
%      data         - structure
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
%   DESCRIPTION:
%      REMOVETRAILINGNAN removes trailing missing data (NaN) at the end and
%      at the beginning of time series.
%
%   EXAMPLES:
%      [data]=REMOVETRAILINGNAN(data)
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also EDITDATA, EXTRACTSYNCHRONOUSRECORDS

%   AUTHORS:
%        Ianis Gaudot,Luong Ha Nguyen, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       July 5, 2018
%
%   DATE LAST UPDATE:
%       July 5, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'data', @isstruct );

parse(p,data);

data=p.Results.data;

%% Get number of time series
numberOfTimeSeries =size(data.values, 2);

%% Remove trailing NaN
for i=1:numberOfTimeSeries
    values=data.values{i};
    timestamps = data.timestamps{i};
    
    values_clean = values(find(~any(isnan(values),2),1,'first'): ...
        find(~any(isnan(values),2),1,'last'));
    
    timestamps_clean = timestamps(find(~any(isnan(values),2),1,'first'): ...
        find(~any(isnan(values),2),1,'last'));
    
    data.values{i} = values_clean;
    data.timestamps{i} = timestamps_clean;
    
end

%--------------------END CODE ------------------------
end
