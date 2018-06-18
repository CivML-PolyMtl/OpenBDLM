function [isMerged]=verificationMergedDataset(data)
%VERIFICATIONMERGEDDATASET returns true if the time series are merged
%
%   SYNOPSIS:
%     [output_1,output_2, output_3]=VERIFICATIONMERGEDDATASET(input_1,input_2)
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
%      isMerged   - logical
%                   isMerged = true if the dataset is merged
% 
%   DESCRIPTION:
%      VERIFICATIONMERGEDDATASET returns true if the time series are merged
%      A merged dataset means the timestsamp vector is identical for each
%      time series of the dataset
% 
%   EXAMPLES:
%      [isMerged]=VERIFICATIONMERGEDDATASET(data)
% 
%   EXTERNAL FUNCTIONS CALLED:
%      verificationDataStructure
% 
%   See also VERIFICATIONDATASTRUCTURE

%   AUTHORS: 
%      Ianis Gaudot,  Luong Ha Nguyen, James-A Goulet
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
%       April 19, 2018
 
%--------------------BEGIN CODE ---------------------- 
 %% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'data', @isstruct );
parse(p,data);

data=p.Results.data;

% Validation of structure data
isValid = verificationDataStructure(data);
if ~isValid
    disp(' ')
    disp('ERROR: Unable to read the data from the structure.')
    disp(' ')
    return
end
 
X = cell2mat(data.timestamps);

if any(diff(X,1,2) ~= 0)
    isMerged = false;
else
    isMerged = true;
end
 
 
%--------------------END CODE ------------------------ 
end
