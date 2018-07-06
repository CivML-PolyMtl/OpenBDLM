function [data_resample]=resampleData(data, varargin)
%RESAMPLEDATA Resample dataset according to a given timestep.
%
%   SYNOPSIS:
%     [data]=RESAMPLEDATA(data,varargin)
%
%   INPUT:
%      data             - structure (required)
%                          data must contain three fields :
%
%                               'timestamps' is a 1×N cell array
%                               each cell is a M_ix1 real array
%
%                               'values' is a 1×N cell array
%                               each cell is a M_ix1 real array
%
%                               'labels' is a 1×N cell array
%                               each cell is a character array
%
%                                   N: number of time series
%                                   M_i: number of samples of time series i
%
%
%      Timestep         - real (optionnal)
%                         requested timestep (in days)
%                         default: 1 day
%   OUTPUT:
%      data             - structure 
%                          data must contain three fields :
%
%                               'timestamps' is a 1×N cell array
%                               each cell is a M_ix1 real array
%
%                               'values' is a 1×N cell array
%                               each cell is a M_ix1 real array
%
%                               'labels' is a 1×N cell array
%                               each cell is a character array
%
%                                   N: number of time series
%                                   M_i: number of samples of time series i
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
%      [data]=RESAMPLEDATA(data)
%      [data]=RESAMPLEDATA(data,'Timestep', 10)
%      [data]=RESAMPLEDATA(data,'Timestep', 0.041667)
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
%       July 5, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

validationFct_Timestep = @(x) isnumeric(x) && length(x)==1;

defaultTimestep = 1;

addRequired(p,'data', @isstruct );
addParameter(p, 'Timestep',defaultTimestep, validationFct_Timestep)
parse(p,data, varargin{:});

data=p.Results.data;
dt_ref=p.Results.Timestep;


%% Get number of time series

numberOfTimeSeries =size(data.values, 2);


%% Verify that the dataset is merged (unique timestamp vector)

[isMerged] = verificationMergedDataset(data);

if ~isMerged
    % If not, merge the dataset
   [data] = mergeTimeStampVectors(data, 'NaNThreshold', 100);
end


%% Get unique timestamps vector
timestamps=data.timestamps{1};

%% Get beg and endd date corresponding to the first and last sample 

begg = timestamps(1);
endd = timestamps(end);

%% Generate reference uniform timestamp vector with requested timestep

timestamps_ref = begg:dt_ref:endd;
timestamps_ref=timestamps_ref';
values_ref = zeros(length(timestamps_ref),1);

%% Add reference timestamps, reference values, and reference labels to 
%% the original dataset
data.timestamps = [timestamps_ref {data.timestamps{:}}];
data.values=[values_ref {data.values{:}}];
data.labels=['reference' {data.labels{:}}];

%% Merge dataset
[data] = mergeTimeStampVectors (data, 'NaNThreshold', 100);

%% Remove reference timestamps, reference values, and reference labels to 
%% the original dataset
data.timestamps{1}=[];
data.timestamps=data.timestamps(~cellfun(@isempty, data.timestamps));

data.values{1}=[];
data.values=data.values(~cellfun(@isempty, data.values));

data.labels{1}=[];
data.labels=data.labels(~cellfun(@isempty, data.labels));

%% Get new unique timestamps vector
timestamps=data.timestamps{1};

%% Compute mean value over fixed window of length dt_ref
 for i=1:length(timestamps_ref)-1

     idx = timestamps >= timestamps_ref(i) & timestamps < timestamps_ref(i+1);
     
     for j=1:numberOfTimeSeries
         data_resample.values{j}(i)=nanmean(data.values{j}(idx));
     end
     
 end

%% Create new timestamp vector and labels
for j=1:numberOfTimeSeries
         data_resample.timestamps{j}=timestamps_ref(1:end-1)+dt_ref/2;
         data_resample.values{j}=data_resample.values{j}';
         data_resample.labels{j}=data.labels{j};
end

%--------------------END CODE ------------------------
end
