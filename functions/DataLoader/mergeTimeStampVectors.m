function [data, misc]=mergeTimeStampVectors(dataOrig, misc, varargin)
%MERGETIMESTAMPVECTORS Create a single time vector from a set of time series
%
%   SYNOPSIS:
%     [data, misc]=MERGETIMESTAMPVECTORS(data, misc, varargin)
%
%   INPUT:
%       dataOrig    - structure (required)
%                     dataOrig must contain three fields :
%
%                           'timestamps' is a 1×N cell array
%                           each cell is a M_ix1 real array
%
%                           'values' is a 1×N cell array
%                           each cell is a M_ix1 real array
%
%                           'labels' is a 1×N cell array
%                           each cell is a character array
%
%                               N: number of time series
%                               M_i: number of samples of time series i
%
%      misc         - structure
%                     see the documentation for details about the
%                     field in misc
%
%      NanThreshold - real (optional)
%                     maximum amount of missing data (NaN) allowed at each
%                     timestamp, given in percent 0<= NanThreshold <= 100
%                     default: 0 (no missing data is allowed)
%
%
%      tolerance    - real (optional)
%                     value given in number of days
%                     timestamps +/- tolerance are considered equal
%                     default: 10E-6
%
%      isOutputFile - logical (optional)
%                     if true, save the data in a DATA_*.mat Matlab file
%                     default: false
%
%      isPlot       - logical (optional)
%                     if true, plot data
%                     default: false
%
%   OUTPUT:
%       data        - structure (required)
%                     data must contain three fields :
%
%                           'timestamps' is a M×1 array
%
%                           'values' is a M×N array
%
%                           'labels' is a 1×N cell array
%                           each cell is a character array
%
%                           N: number of time series
%                           M: number of samples
%
%      misc         - structure
%                     see the documentation for details about the
%                     field in misc
%
%   DESCRIPTION:
%      MERGETIMESTAMPVECTORS process a set of time series, each having
%      their own timestamp vector.
%      MERGETIMESTAMPVECTORS merge all  timestamps vector in a single one by
%      removing samples and/or padding with missing data if required.
%      The parameter "NanThreshold" controls the amount of missing data
%      allowed at each time step.
%      Small "NanThreshold" value may force to remove a lot of data
%      samples.
%      High "NanThreshold" usually preserve the data, but may lead to a
%      strong NaN padding.
%
%      Note that timestamps +/- tolerance are considered equal
%      Tolerance variable is a real value given in number of days.
%
%   EXAMPLES:
%      [data, misc] = MERGETIMESTAMPVECTORS (dataOrig, misc)
%      [data, misc] = MERGETIMESTAMPVECTORS (dataOrig, misc, 'NanThreshold', 100, ...
%               'Tolerance', 0.01)
%      [data, misc] = MERGETIMESTAMPVECTORS (dataOrig, misc, 'NanThreshold', 100, ...
%               'Tolerance', 0.01, 'isPlot', true, 'isOutputFile', true)
%      [data, misc] = MERGETIMESTAMPVECTORS (dataOrig,misc, 'Tolerance', 0.01 )
%
%   See also EXTRACTSYNCHRONOUSRECORDS

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
%       April 13, 2018
%
%   DATE LAST UPDATE:
%       December 3, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;
defaultNanThreshold = 0;
defaulttolerance = 10^(-6);
defaultisOutputFile =  false;
defaultisPlot = false;

addRequired(p,'dataOrig', @isstruct );
addRequired(p,'misc', @isstruct );
validationFcn = @(x) isreal(x) & x >= 0 & x <= 100;
addParameter(p,'NanThreshold',defaultNanThreshold,validationFcn);
addParameter(p,'tolerance',defaulttolerance,@isreal);
addParameter(p,'isOutputFile',defaultisOutputFile,@islogical);
addParameter(p,'isPlot',defaultisPlot,@islogical);

parse(p,dataOrig, misc, varargin{:} );

dataOrig=p.Results.dataOrig;
misc=p.Results.misc;
NaNThreshold = p.Results.NanThreshold;
tolerance = p.Results.tolerance;
isOutputFile=p.Results.isOutputFile;
isPlot=p.Results.isPlot;

%% Gather all serial date number in a single matrix

% Get number of time series
numberOfTimeSeries = length(dataOrig.values);

% Get lengh of each time series (number of samples)
AllTimeSeriesLength = cellfun(@length, dataOrig.values);

% Gather serial dates number in same matrix
alldates = [];
% Load array
for i=1:numberOfTimeSeries
    alldates = [alldates ; dataOrig.timestamps{i}];
end

%% Full outer join
% select identical timestamp with tolerance
[keys,~,ind] = uniquetol( alldates, tolerance, 'Datascale', 1 ); 
indice=[];
for i=1:numberOfTimeSeries
    if i==1
        beg_idx=1;
        end_idx=AllTimeSeriesLength(i);
        indice(1:end_idx-beg_idx+1,i)=ind(beg_idx:end_idx,1);
    else
        beg_idx=end_idx+1;
        end_idx=beg_idx+AllTimeSeriesLength(i)-1;
        indice(1:end_idx-beg_idx+1,i)=ind(beg_idx:end_idx,1);
    end
end

fullOuterJoin = zeros(length(keys),numberOfTimeSeries+1);
fullOuterJoin(:,:)=NaN; % fill with NaN (missing data)
fullOuterJoin(:,1) = keys; % union of dates

%% Build full outerjoin
for i=1:numberOfTimeSeries    
    % stores values
    fullOuterJoin(indice(1:AllTimeSeriesLength(i),i),i+1) = ...
        dataOrig.values{i};
end

%% Remove time samples to try to reach NaNThreshold condition
NaNThresholdTested = NaNThreshold;

isData = false;
while isData == false
    
    tmp = fullOuterJoin;
    criteria=(numberOfTimeSeries*NaNThresholdTested)./100;
    tmp(sum(isnan(tmp(:,2:end)),2) > criteria,:)=[];
    
    if isempty(tmp)
        NaNThresholdTested = NaNThresholdTested + 1;
        
        if NaNThresholdTested >= 100
            tmp = fullOuterJoin;
            isData = true;
        end
        
    else
        isData = true;
    end
    
end

if NaNThresholdTested ~= NaNThreshold
    disp(' ')
    warning(['NaNThreshold has been increased from ' ...
        '%6.2f %% to %6.2f %% to avoid removing all the data'], ...
        NaNThreshold, NaNThresholdTested )
    disp(' ')
end

%% Overwrite data structure
TimeSeriesIdxToRemove = [];

data.timestamps = [];
data.values = [];

for i=1:numberOfTimeSeries
    
    if ~all(isnan(tmp(:,i+1)))
        % stores timestamps
        data.timestamps = [data.timestamps tmp(:,1) ];
        % stores values
        data.values = [ data.values tmp(:,i+1)];
        
        data.labels{i} = dataOrig.labels{i};
    else
        warning(['%s has been removed because ' ...
            'it is full of missing data (NaN)'], dataOrig.labels{i})
        disp(' ')
        
        TimeSeriesIdxToRemove = [i TimeSeriesIdxToRemove];

        data.timestamps = [data.timestamps zeros(size(tmp,1),1 )];
        data.values = [data.values zeros(size(tmp,1),1 )];
        data.labels{i} = [];

        continue
    end
end

% Remove empty fields
data.timestamps(:,TimeSeriesIdxToRemove)=[];
data.timestamps = data.timestamps(:,1);
data.values(:,TimeSeriesIdxToRemove)=[];
data.labels(cellfun(@isempty, data.labels))=[];

%--------------------END CODE ------------------------
end
