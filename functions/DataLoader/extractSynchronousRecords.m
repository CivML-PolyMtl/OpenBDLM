function [data, misc]=extractSynchronousRecords(data, misc, varargin)
%EXTRACTSYNCHRONOUSRECORDS Extract synchronous records among time series
%
%   SYNOPSIS:
%     [data, misc]=EXTRACTSYNCHRONOUSRECORDS(data, misc, varargin)
%
%   INPUT:
%      data       - structure (required)
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
%      isOutputFile - logical (optional)
%                     if true, save the data in a DATA_*.mat Matlab file
%                     default: false
%
%      isPlot       - logical (optional)
%                     if true, plot data
%                     default: false
%
%      misc         - structure
%                     see the documentation for details about the
%                     field in misc
%   OUTPUT:
%      data       - structure
%                   fields of data are timestamps, values, labels
%
%      misc         - structure
%                     see the documentation for details about the
%                     field in misc
%   DESCRIPTION:
%      EXTRACTSYNCHRONOUSRECORDS extracts synchronous records among time
%      series
%      It may happen that several set of synchronous records exist.
%      Example with N=4 time series:
%                A
%      1 -----|---|   B   C
%      2      |---|-|---|--|  D
%      3                |--|----|-------
%      4            |---|--|----|
%
%      4 synchronous ranges, labeled A, B, C, D
%
%      In such case, EXTRACTSYNCHRONOUSRECORDS proceeds as follows:
%      1) Select the synchronous record that includes the maximum of the
%      time series
%      2) If 1) is not discriminant criterion, select the longest synchronous
%      record.
%
%      Consequently, EXTRACTSYNCHRONOUSRECORDS would select range C.
%      Data from time series #2,#3,#4 during time range C would be retained.
%
%   EXAMPLES:
%      [data, misc] = EXTRACTSYNCHRONOUSRECORDS(data, misc)
%      [data, misc] = EXTRACTSYNCHRONOUSRECORDS(data, misc, 'isPlot', true, 'isOutpufile', true)
%      [data, misc] = EXTRACTSYNCHRONOUSRECORDS(data, misc, 'isPlot', true)
%
%   EXTERNAL FUNCTIONS CALLED:
%      verificationDataStructure
%
%   See also GETTIMEOVERLAP, VERIFICATIONDATASTRUCTURE,
%      MERGETIMESTAMPVECTORS

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
%       July 20, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications

p = inputParser;
defaultisOutputFile = false;
defaultisPlot = false;

addRequired(p,'data', @isstruct );
addRequired(p,'misc', @isstruct );
addParameter(p,'isOutputFile',defaultisOutputFile,@islogical);
addParameter(p,'isPlot',defaultisPlot,@islogical);

parse(p,data, misc, varargin{:} );

data=p.Results.data;
misc=p.Results.misc;
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


%% Get number of time series
numberOfTimeSeries = length(data.values);

%% Get start and end date of each time series
Start_End=zeros(numberOfTimeSeries,2);

for i = 1:numberOfTimeSeries
    Start_End(i,1)=data.timestamps{i}(1); % get beg
    Start_End(i,2)=data.timestamps{i}(end); % get end
end

%% Get time overlap
[DetectedOverlap, Index] = getTimeOverlap(Start_End);

%% Remove time series which do not participate to detected overlap
% overwrite data structure
data.timestamps = data.timestamps(Index);
data.values = data.values(Index);
data.labels = data.labels(Index);

%% Get new number of time series
numberOfTimeSeries = length(data.values);

%% Select data between overlap range

for i = 1:numberOfTimeSeries
    
    % select samples that lie between start and end of the detected overlap
    selection = data.timestamps{i}(:) >= DetectedOverlap(1) & ...
        data.timestamps{i}(:) <= DetectedOverlap(2) ;
    
    data.timestamps{i} = data.timestamps{i}(selection);
    data.values{i} = data.values{i}(selection);
    
end

if isOutputFile ==  true
    [misc, ~] = saveDataBinary(data, 'FilePath','processed_data');
end

if isPlot == true
    plotData(data, 'FigurePath', 'figures')
end

%--------------------END CODE ------------------------
end
