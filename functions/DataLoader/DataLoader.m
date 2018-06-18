function [data, dataFilename]=DataLoader(varargin)
%DATALOADER Create a data file
%
%   SYNOPSIS:
%     [data, dataFilename]=DATALOADER(varargin)
%
%   INPUT:
%      FilePath   - character (optional)
%                   saving directory for data
%                   default: '.'  (current folder)
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
%      Tolerance    - real (optional)
%                     value given in number of days
%                     timestamps +/- tolerance are considered equal
%                     default: 10E-6
%   OUTPUT:
%      data         - structure 
%                     data must contain three fields :
%
%                         'timestamps' is a 1×N cell array
%                         each cell is a M_ix1 real array
%
%                         'values' is a 1×N cell array
%                         each cell is a M_ix1 real array
%
%                         'labels' is a 1×N cell array
%                         each cell is a character array
%
%                   N: number of time series
%                   M_i: number of samples of time series i
%
%     dataFilename  -  character  
%
%   DESCRIPTION:
%      DATALOADER chooses a file DATA_*.mat amongst file already existing 
%      or create a new one
%
%   EXAMPLES:
%      [data, dataFilename ] = DATALOADER
%      [data, dataFilename] = DATALOADER('FilePath', 'processed_data')
%      [data, dataFilename] = DATALOADER('FilePath', 'processed_data', 'NaNThreshold', 30, 'isOverlapDetection', true, 'Tolerance', 10E-3)
%
%   EXTERNAL FUNCTIONS CALLED:
%      displayDataBinary, loadData
%
%   See also DISPLAYDATABINARY, LOADDATA

%   AUTHORS:
%      Ianis Gaudot, Luong Ha Nguyen,  James-A Goulet
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
defaultFilePath = '.';
defaultisOverlapDetection = false;
defaultNaNThreshold = 0;
defaulttolerance = 10E-6;


addParameter(p,'FilePath',defaultFilePath);
addParameter(p,'isOverlapDetection',defaultisOverlapDetection,@islogical);
validationFcnNaNThreshold = @(x) isreal(x) & x >= 0 & x <= 100;
addParameter(p,'NaNThreshold',defaultNaNThreshold,validationFcnNaNThreshold);
validationFcntolerance = @(x) isreal(x) & x >= 0;
addParameter(p, 'Tolerance', defaulttolerance, validationFcntolerance);

parse(p, varargin{:} );

FilePath=p.Results.FilePath;
isOverlapDetection = p.Results.isOverlapDetection;
NaNThreshold = p.Results.NaNThreshold;
tolerance = p.Results.Tolerance;

% Validation of FilePath
if ~ischar(FilePath) || isempty(FilePath(~isspace(FilePath)))
    disp(' ')
    disp('ERROR: Path should be a non-empty character array.')
    disp(' ')
    return
end

% define global variable for user's answers from input file
global isAnswersFromFile AnswersFromFile AnswersIndex

%% Choice for new datase
disp(' ')
fprintf('     %-3s -> %-25s\t\n', num2str(0), 'Build new database')
disp(' ')
[FileInfo] = displayDataBinary('FilePath', FilePath);

while(1)
     if isAnswersFromFile
        chosen_db=eval(char(AnswersFromFile{1}(AnswersIndex)));
        disp(['     ', num2str(chosen_db)])
     else
        disp(' ')
        chosen_db=input('     choice >> ');
    end
    if ischar(chosen_db) || any(mod(chosen_db,1)) || ~isempty(chosen_db(chosen_db<0))
        disp(' ')
        disp('     wrong input -> should be non-negative integers')
        disp(' ')
        continue
    elseif length(chosen_db)>1
        disp(' ')
        disp('     wrong input -> should be only one integer')
        disp(' ')
        continue
    elseif isempty(chosen_db)
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('                                                         ')
        disp(' Selection ''0'' creates a new processed database from raw data stored in .csv files.')
        disp(' If applicable, previously processed database can also be chosen. ')
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp(' ')
        inc=inc-1;
        continue
    elseif chosen_db > length(FileInfo)       
        disp(' ')
        disp('     wrong input -> out of range')
        disp(' ')
        continue   
    else
        break
    end
end

% Increment global variable to read next answer when required
AnswersIndex = AnswersIndex +1 ;

%% Load database
if chosen_db == 0
    % No database is selected, then call dataloader
    [data, dataFilename] = loadData('FilePath', FilePath, ...
         'NaNThreshold', NaNThreshold, 'Tolerance', tolerance,  ...
         'isOverlapDetection', isOverlapDetection ,'isPdf', false);
else
    % Select the data
    [data]=load(fullfile(FilePath, FileInfo{chosen_db}));
    dataFilename = fullfile(FilePath, FileInfo{chosen_db});
end
%--------------------END CODE ------------------------
end
