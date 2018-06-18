function [data]=mergeTimeStampVectors(data, varargin)
%MERGETIMESTAMPVECTORS Create a single time vector from a set of time series
%
%   SYNOPSIS:
%     [data]=MERGETIMESTAMPVECTORS(data, varargin)
%
%   INPUT:
%       data        - structure (required)
%                      data must contain three fields :
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
%                 N: number of time series
%                 M_i: number of samples of time series i
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
%      data         - structure (required)
%                     fields of data are timestamps, values, labels
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
%      [data] = MERGETIMESTAMPVECTORS (data)
%      [data] = MERGETIMESTAMPVECTORS (data, 'NanThreshold', 100, ...
%               'Tolerance', 0.01)
%      [data] = MERGETIMESTAMPVECTORS (data, 'NanThreshold', 100, ...
%               'Tolerance', 0.01, 'isPlot', true, 'isOutputFile', true)
%      [data] = MERGETIMESTAMPVECTORS (data, 'Tolerance', 0.01 )
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
%       April 16, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;
defaultNanThreshold = 0;
defaulttolerance = 10^(-6);
defaultisOutputFile =  false;
defaultisPlot = false;

addRequired(p,'data', @isstruct );
validationFcn = @(x) isreal(x) & x >= 0 & x <= 100;
addParameter(p,'NanThreshold',defaultNanThreshold,validationFcn);
addParameter(p,'tolerance',defaulttolerance,@isreal);
addParameter(p,'isOutputFile',defaultisOutputFile,@islogical);
addParameter(p,'isPlot',defaultisPlot,@islogical);

parse(p,data, varargin{:} );

data=p.Results.data;
NaNThreshold = p.Results.NanThreshold;
tolerance = p.Results.tolerance;
isOutputFile=p.Results.isOutputFile;
isPlot=p.Results.isPlot;

% Validation of structure data
isValid = verificationDataStructure(data);
if ~isValid
    disp(' ')
    disp('ERROR: Unable to read the data from the structure.')
    disp(' ')
    return
end

%displayData(data)

%% Gather all serial date number in a single matrix

% Get number of time series
numberOfTimeSeries = length(data.values);

% Get lengh of each time series (number of samples)
AllTimeSeriesLength = cellfun(@length, data.values);

% Gather serial dates number in same matrix
alldates = [];
% Load array
for i=1:numberOfTimeSeries
    alldates = [alldates ; data.timestamps{i}];
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
    fullOuterJoin(indice(1:AllTimeSeriesLength(i),i),i+1) = data.values{i};
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
    fprintf(['WARNING: NaNThreshold has been increased from ' ...
        '%6.2f %% to %6.2f %% to avoid removing all the data'], ...
        NaNThreshold, NaNThresholdTested )
    disp(' ')
end

%% Overwrite data structure
for i=1:numberOfTimeSeries
    
    if ~all(isnan(tmp(:,i+1)))
        % stores timestamps
        data.timestamps{i} = tmp(:,1);
        % stores values
        data.values{i} = tmp(:,i+1);
    else
        fprintf(['WARNING: %s has been removed because ' ...
            'it does not store real valued data anymore'], data.labels{i})
        disp(' ')
        data.timestamps{i}=[];
        data.values{i} = [];  
        data.labels{i} = [];
        disp(' ')

        continue
    end
end

% Remove empty fields
data.timestamps(cellfun(@isempty, data.timestamps))=[];
data.values(cellfun(@isempty, data.values))=[];
data.labels(cellfun(@isempty, data.labels))=[];

%% Plot
if isPlot
    plotData(data, 'FigurePath', 'figures')
end

%% Save in binary DATA_*.mat file
if isOutputFile
    saveDataBinary(data, 'FilePath','processed_data')
end
%--------------------END CODE ------------------------
end
