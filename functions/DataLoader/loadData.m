function [data, dataFilename]=loadData(varargin)
%LOADDATA Load data from csv file
%
%   SYNOPSIS:
%     [data]=LOADDATA(varargin)
%
%   INPUT:
%      FilePath   - character (optional)
%                   saving directory for data
%                   default: '.'  (current folder)
%
%      isPdf               - logical (optional)
%                             build a single pdf file to summarize data
%                             information
%                             default: true
%
%      isOverlapDetection  - logical (optional)
%                            if isOverlapDetection = true, automatic
%                            overlap detection
%                            default: false
%
%      NaNThreshold        - real (optional)
%                            maximum amount of missing data (NaN)
%                            allowed at each timestamp, given in percent
%                            0<= NanThreshold <= 100
%                            default: 0
%
%      tolerance    - real (optional)
%                     value given in number of days
%                     timestamps +/- tolerance are considered equal
%                     default: 10E-6
%
%   OUTPUT:
%      data                - structure (required)
%                            data contains three fields :
%
%                              'timestamps' is a 1×N cell array
%                              each cell is a M_ix1 real array
%
%                              'values' is a 1×N cell array
%                              each cell is a M_ix1 real array
%
%                              'labels' is a 1×N cell array
%                              each cell is a character array
%
%                               N: number of time series
%                               M_i: number of samples of time series i
%
%      dataFilename        - character   
%                           full name of the filename where data are saved
%   DESCRIPTION:
%      LOADDATA loads data from csv file
%
%   EXAMPLES:
%      [data] = LOADDATA('FilePath', 'processed_data', 'NaNThreshold', 30)
%      [data] = LOADDATA('isPdf', false, 'NaNThreshold', 30)
%      [data] = LOADDATA('NaNThreshold', 30, 'isOverlapDetection', true, 'Tolerance', 10E-3)
%
%   EXTERNAL FUNCTIONS CALLED:
%      readMultipleCSVFiles.m, chooseTimeSeries.m, mergeTimeStampVectors,
%       extractSynchronousRecords.m, saveDataBinary.m, plotData.m
%
%   See also READMULTIPLECSVFILES, CHOOSETIMESERIES, MERGETIMESTAMPVECTORS
%       EXTRACTSYNCHRONOUSRECORDS, SAVEDATABINARY, PLOTDATA

%   AUTHORS:
%      Ianis Gaudot, Luong Ha Nguyen, James-A Goulet,
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       April 18, 2018
%
%   DATE LAST UPDATE:
%       April 18, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;
defaultisOverlapDetection = false;
defaultNaNThreshold = 0;
defaultisPdf = true;
defaultFilePath = '.';
defaulttolerance = 10E-6;

addParameter(p,'isOverlapDetection',defaultisOverlapDetection,@islogical);
addParameter(p,'FilePath',defaultFilePath);
validationFcnNaNThreshold = @(x) isreal(x) & x >= 0 & x <= 100;
addParameter(p,'NaNThreshold',defaultNaNThreshold,validationFcnNaNThreshold);
addParameter(p,'isPdf',defaultisPdf,@islogical);
validationFcntolerance = @(x) isreal(x) & x >= 0;
addParameter(p, 'Tolerance', defaulttolerance, validationFcntolerance);

parse(p, varargin{:} );

isOverlapDetection = p.Results.isOverlapDetection;
NaNThreshold = p.Results.NaNThreshold;
isPdf=p.Results.isPdf;
FilePath = p.Results.FilePath;
tolerance = p.Results.Tolerance;

% Validation of FilePath
if ~ischar(FilePath) || isempty(FilePath(~isspace(FilePath)))
    disp(' ')
    disp('ERROR: Path should be a non-empty character array.')
    disp(' ')
    return
end

% Create file path if not existing
[isFileExist] = testFileExistence(FilePath, 'dir');
if ~isFileExist
    % create directory
    mkdir(FilePath)    
    % set directory on path
    addpath(FilePath)
end


%% Control script

[dataOrig] = readMultipleCSVFiles;

if isPdf
    plotData(dataOrig, 'FilePath', 'figures', 'isPdf', true)
end

[dataChoose] = chooseTimeSeries(dataOrig);

if isOverlapDetection
    [dataOverlap] = extractSynchronousRecords(dataChoose);
    [dataMerged] = mergeTimeStampVectors (dataOverlap, ...
        'NaNThreshold', NaNThreshold, 'Tolerance', tolerance);
else
    [dataMerged] = mergeTimeStampVectors (dataChoose, ...
        'NaNThreshold', NaNThreshold, 'Tolerance', tolerance);
end

[dataFilename] = saveDataBinary(dataMerged, 'FilePath', FilePath);

data=dataMerged;

%--------------------END CODE ------------------------
end
