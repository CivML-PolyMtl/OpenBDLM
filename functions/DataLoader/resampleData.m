function [data_resample, misc]=resampleData(data, misc, varargin)
%RESAMPLEDATA Resample dataset according to a given timestep.
%
%   SYNOPSIS:
%     [data, misc]=RESAMPLEDATA(data, misc, varargin)
%
%   INPUT:
%       data            - structure (required)
%                         data must contain three fields:
%
%                               'timestamps' is a M×1 array
%
%                               'values' is a MxN  array
%
%                               'labels' is a 1×N cell array
%                               each cell is a character array
%
%                                   N: number of time series
%                                   M: number of samples
%
%       misc            - structure
%                           see the documentation for details about the
%                           field in misc
%
%      Timestep         - real (optionnal)
%                         requested timestep (in days)
%                         default: 1 day
%   OUTPUT:
%      data_resample    - structure 
%                         data must contain three fields:
%
%                               'timestamps' is a M×1 array
%
%                               'values' is a MxN  array
%
%                               'labels' is a 1×N cell array
%                               each cell is a character array
%
%                                   N: number of time series
%                                   M: number of samples
%
%     misc              - structure
%                           see the documentation for details about the
%                           field in misc
%
%   DESCRIPTION:
%      RESAMPLEDATA resamples dataset according to a given timestep.
%      For each time series, RESAMPLEDATA computes the mean of the values 
%      (ignoring missing value) in a fixed length window of length
%      corresponding to the requested timestep.
%
%      For non-uniform input timestamp vector, the number of values used to
%      computed the mean in each time window can be different.
%
%      RESAMPLEDATA add missing data (NaN) where no data are available to
%      compute the mean.
%
%   EXAMPLES:
%      [data, misc]=RESAMPLEDATA(data, misc)
%      [data, misc]=RESAMPLEDATA(data, misc, 'Timestep', 10)
%      [data, misc]=RESAMPLEDATA(data, misc, 'Timestep', 0.041667)
%
%   EXTERNAL FUNCTIONS CALLED:
%      verificationMergedDataset, mergeTimeStampVectors
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also EDITDATA, MERGETIMESTAMPVECTORS, VERIFICATIONMERGEDDATASET

%   AUTHORS:
%       Ianis Gaudot, Luong Ha Nguyen,  James-A Goulet,
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
%       July 24, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

validationFct_Timestep = @(x) isnumeric(x) && length(x)==1;

defaultTimestep = 1;

addRequired(p,'data', @isstruct );
addRequired(p,'misc', @isstruct );
addParameter(p, 'Timestep',defaultTimestep, validationFct_Timestep)
parse(p,data, misc, varargin{:});

data=p.Results.data;
misc=p.Results.misc;
dt_ref=p.Results.Timestep;

%% Get number of time series

numberOfTimeSeries =size(data.values, 2);

%% Verify that the dataset is merged (unique timestamp vector)
% 
% [isMerged] = verificationMergedDataset(data);
% 
% if ~isMerged
%     % If not, merge the dataset
%    [data, misc] = mergeTimeStampVectors(data, misc, 'NaNThreshold', 100);
% end

%% Convert data structure from array to cell
[dataCell]=convertMat2Cell(data);

%% Get unique timestamps vector
timestamps=dataCell.timestamps{1};

%% Get beg and endd date corresponding to the first and last sample 

begg = timestamps(1);
endd = timestamps(end);

%% Generate reference uniform timestamp vector with requested timestep

timestamps_ref = begg:dt_ref:endd;
timestamps_ref=timestamps_ref';
values_ref = zeros(length(timestamps_ref),1);

%% Add reference timestamps, reference values, and reference labels to 
%% the original dataset
dataCell.timestamps = [timestamps_ref {dataCell.timestamps{:}}];
dataCell.values=[values_ref {dataCell.values{:}}];
dataCell.labels=['reference' {dataCell.labels{:}}];

%% Merge dataset
[data, misc] = mergeTimeStampVectors(dataCell, misc, 'NaNThreshold', 100);

%% Convert data structure from array to cell
[dataCell]=convertMat2Cell(data);

%% Remove reference timestamps, reference values, and reference labels to 
%% the original dataset
dataCell.timestamps{1}=[];
dataCell.timestamps=dataCell.timestamps(~cellfun(@isempty, dataCell.timestamps));

dataCell.values{1}=[];
dataCell.values=dataCell.values(~cellfun(@isempty, dataCell.values));

dataCell.labels{1}=[];
dataCell.labels=dataCell.labels(~cellfun(@isempty, dataCell.labels));

%% Get new unique timestamps vector
timestamps=dataCell.timestamps{1};

%% Compute mean value over fixed window of length dt_ref
 for i=1:length(timestamps_ref)-1

     idx = timestamps >= timestamps_ref(i) & timestamps < timestamps_ref(i+1);
     
     for j=1:numberOfTimeSeries
         data_resampleCell.values{j}(i)=nanmean(dataCell.values{j}(idx));
     end
     
 end

%% Create new timestamp vector and labels
for j=1:numberOfTimeSeries
         data_resampleCell.timestamps{j}=timestamps_ref(1:end-1)+dt_ref/2;
         data_resampleCell.values{j}=data_resampleCell.values{j}';
         data_resampleCell.labels{j}=dataCell.labels{j};
end

%% Convert cell to mat
[data_resample]=convertCell2Mat(data_resampleCell);

%--------------------END CODE ------------------------
end
