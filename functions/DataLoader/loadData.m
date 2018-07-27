function [data, misc]=loadData(misc, varargin)
%LOADDATA Load data from csv file
%
%   SYNOPSIS:
%     [data, misc]=LOADDATA(misc, varargin)
%
%   INPUT:
%      misc                - structure
%                             see the documentation for details about the
%                             field in misc
%
%      FilePath            - character (optional)
%                             saving directory for data
%                             default: '.'  (current folder)
%
%      isPdf               - logical (optional)
%                             build a single pdf file to summarize data
%                             information
%                             default: true
%
%      NaNThreshold        - real (optional)
%                            maximum amount of missing data (NaN)
%                            allowed at each timestamp, given in percent
%                            0<= NanThreshold <= 100
%                            default: 100
%
%      tolerance           - real (optional)
%                           value given in number of days
%                           timestamps +/- tolerance are considered equal
%                           default: 10E-6
%
%   OUTPUT:
%      data                - structure 
%                            data must contain three fields:
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
%      misc                - structure
%                             see the documentation for details about the
%                             field in misc
%
%   DESCRIPTION:
%      LOADDATA loads data from csv file. 
%
%   EXAMPLES:
%      [data, misc] = LOADDATA(misc,'FilePath', 'processed_data', 'NaNThreshold', 30)
%      [data, misc] = LOADDATA(misc,'isPdf', false, 'NaNThreshold', 30)
%      [data] = LOADDATA(misc, 'NaNThreshold', 30, 'Tolerance', 10E-3)
%
%   EXTERNAL FUNCTIONS CALLED:
%      readMultipleCSVFiles.m, mergeTimeStampVectors,testFileExistence
%
%   See also READMULTIPLECSVFILES, MERGETIMESTAMPVECTORS
%       TESTFILEEXISTENCE

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
%       July 24, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;
defaultNaNThreshold = 100;
defaultisPdf = true;
defaultFilePath = '.';
defaulttolerance = 10E-6;

addRequired(p, 'misc', @isstruct)
addParameter(p,'FilePath',defaultFilePath);
validationFcnNaNThreshold = @(x) isreal(x) & x >= 0 & x <= 100;
addParameter(p,'NaNThreshold',defaultNaNThreshold,validationFcnNaNThreshold);
addParameter(p,'isPdf',defaultisPdf,@islogical);
validationFcntolerance = @(x) isreal(x) & x >= 0;
addParameter(p, 'Tolerance', defaulttolerance, validationFcntolerance);

parse(p, misc, varargin{:} );

misc=p.Results.misc;
NaNThreshold = p.Results.NaNThreshold;
%isPdf=p.Results.isPdf;
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

%% Read .csv files
[dataOrig, misc] = readMultipleCSVFiles(misc);

%% Merge database
[data, misc] = mergeTimeStampVectors (dataOrig, misc, ...
        'NaNThreshold', NaNThreshold, 'Tolerance', tolerance);
        
%--------------------END CODE ------------------------
end
