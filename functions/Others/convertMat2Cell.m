function [data]=convertMat2Cell(data)
%CONVERTMAT2CELL Convert matrices in data.timestamps and data.values to cell array
%
%   SYNOPSIS:
%     [data]=CONVERTMAT2CELL(data)
%
%   OUTPUT:
%      data             - structure (required)
%                          data must contain three fields :
%
%                               'timestamps' is a M×1 array
%
%                               'values' is a M×N array
%
%                               'labels' is a 1×N cell array
%                                each cell is a character array
%
%                                N: number of time series
%                                M: number of samples of time series i
%
%   OUTPUT:
%      data             - structure 
%                          data must contain three fields :
%
%                               'timestamps' is a 1×N cell array
%                                each cell is a M_ix1 real array
%
%                               'values' is a 1×N cell array
%                                each cell is a M_ix1 real array
%
%                               'labels' is a 1×N cell array
%                                each cell is a character array
%
%                                N: number of time series
%                                M_i: number of samples of time series i
%
%   DESCRIPTION:
%      CONVERTMAT2CELL Convert matrices in data.timestamps and data.values
%      to cell array
%
%   EXAMPLES:
%      [data]=CONVERTMAT2CELL(data)
%
%   EXTERNAL FUNCTIONS CALLED:
%      M/A
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also

%   AUTHORS:
%       Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       June 14, 2018
%
%   DATE LAST UPDATE:
%       July 24, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;
addRequired(p,'data', @isstruct );
parse(p,data);

data=p.Results.data;

% Convert field data.values
if isnumeric(data.values)
    
    numberOfDataPoints=size(data.values, 1);
    numberOfTimeSeries = size(data.values, 2);
    
    if  numberOfTimeSeries ~=1
        
        data.values = mat2cell(data.values, ...
            [numberOfDataPoints],ones(1,numberOfTimeSeries));
    else
        
        data.values = mat2cell(data.values,[numberOfDataPoints],[1]);
        
    end
    
end

% Convert field data.timestamps
if isnumeric(data.timestamps)
    
    timestamps = data.timestamps(:,1);
    
    data.timestamps = cell(1,numberOfTimeSeries);
    for i=1:numberOfTimeSeries
        data.timestamps{i} = timestamps;
    end
    
end

%--------------------END CODE ------------------------
end
