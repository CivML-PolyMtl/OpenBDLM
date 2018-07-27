function [data]=convertCell2Mat(data)
%CONVERTCELL2MAT Convert cells in data.timestamps and data.values to array
%
%   SYNOPSIS:
%     [data]=CONVERTCELL2MAT(data)
% 
%   INPUT:
%      data             - structure (required)
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
%   OUTPUT:
%      data             - structure 
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
%                                M: number of samples 
% 
%   DESCRIPTION:
%      CONVERTCELL2MAT convert cells in data.timestamps and data.values to 
%      single array
% 
%   EXAMPLES:
%      [data]=CONVERTCELL2MAT(data)
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
%      Tested on 9.1.0.441655 (R2016b)
% 
%   DATE CREATED:
%       June 14, 2018
% 
%   DATE LAST UPDATE:
%       June 14, 2018
 
%--------------------BEGIN CODE ---------------------- 
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;
addRequired(p,'data', @isstruct );
parse(p,data);

data=p.Results.data;      

% Convert the field values
if iscell(data.values)
    data.values=cell2mat(data.values);
end

% Convert the field timestamps
if iscell(data.timestamps)
    timestamps = cell2mat(data.timestamps);    
    data.timestamps=timestamps(:,1);
end
 
 
%--------------------END CODE ------------------------ 
end
