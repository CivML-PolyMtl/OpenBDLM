function [data, misc, dataFilename]=DataLoader(misc, varargin)
%DATALOADER Create a data file
%
%   SYNOPSIS:
%     [data, misc, dataFilename]=DATALOADER(misc, varargin)
%
%   INPUT:
%      misc                 - structure
%                             see the documentation for details about the
%                             field in misc
%
%      FilePath             - character (optional)
%                               saving directory for data
%                               default: '.'  (current folder)
%
%      NaNThreshold         - real (optional)
%                               maximum amount of missing data (NaN)
%                               allowed at each timestamp, given in percent
%                               0<= NanThreshold <= 100
%                               default: 100
%
%      Tolerance            - real (optional)
%                               value given in number of days
%                               timestamps +/- tolerance are considered equal
%                               default: 10E-6
%   OUTPUT:
%       data                - structure (required)
%                             data must contain three fields:
%
%                               'timestamps' is a M×1 array
%
%                               'values' is a MxN  array
%
%                               'labels' is a 1×N cell array
%                                each cell is a character array
%
%                                   N: number of time series
%                                   M: number of samples
%
%     misc                  - structure
%                             see the documentation for details about the
%                             field in misc
%
%     dataFilename          -  character
%
%   DESCRIPTION:
%      DATALOADER:
%           - loads an existing processed database
%           - creates a new one from raw .csv files
%
%   EXAMPLES:
%      [data, misc, dataFilename] = DATALOADER(misc)
%      [data, misc, dataFilename] = DATALOADER(misc, 'FilePath', 'processed_data')
%      [data, misc, dataFilename] = DATALOADER(misc, 'FilePath', 'processed_data', 'NaNThreshold', 30, 'Tolerance', 10E-3)
%
%   EXTERNAL FUNCTIONS CALLED:
%      displayDataBinary, loadData, editData
%
%   See also DISPLAYDATABINARY, LOADDATA, EDITDATA

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
%       August 13, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications

p = inputParser;
defaultFilePath = '.';
defaultNaNThreshold = 100;
defaulttolerance = 10E-6;

validationFct_FilePath = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p, 'misc', @isstruct)
addParameter(p,'FilePath',defaultFilePath, validationFct_FilePath);
validationFcnNaNThreshold = @(x) isreal(x) & x >= 0 & x <= 100;
addParameter(p,'NaNThreshold',defaultNaNThreshold,validationFcnNaNThreshold);
validationFcntolerance = @(x) isreal(x) & x >= 0;
addParameter(p, 'Tolerance', defaulttolerance, validationFcntolerance);

parse(p, misc, varargin{:} );

misc=p.Results.misc;
FilePath=p.Results.FilePath;
NaNThreshold = p.Results.NaNThreshold;
tolerance = p.Results.Tolerance;


% Set fileID for logfile
if misc.isQuiet
    % output message in logfile
    fileID=fopen(misc.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end

disp('     Load data...')

%% Choice for new datase
fprintf(fileID, '\n');
fprintf(fileID, '- Choose a database\n');
fprintf(fileID, '\n');
fprintf(fileID,'     %-3s -> %-25s\t\n', num2str(0), ...
    'Build a new database from .csv files');
fprintf(fileID, '\n');
[FileInfo] = displayDataBinary(misc, 'FilePath', FilePath);

incTest=0;
MaxFailAttempts=4;
while(1)
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    if misc.BatchMode.isBatchMode
        chosen_db= ...
            eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
        fprintf(fileID, '     %s\n', num2str(chosen_db));
    else
        chosen_db=input('     choice >> ');
    end
    if ischar(chosen_db) || any(mod(chosen_db,1)) || ...
            ~isempty(chosen_db(chosen_db<0))
        fprintf(fileID, '\n');
        fprintf(fileID, ['     wrong input -> ', ...
            'should be non-negative integers\n']);
        fprintf(fileID, '\n');
        continue
    elseif length(chosen_db)>1
        fprintf(fileID, '\n');
        fprintf(fileID, '     wrong input -> should be only one integer\n');
        fprintf(fileID, '\n');
        continue
    elseif isempty(chosen_db)
        continue
    elseif chosen_db > length(FileInfo)
        fprintf(fileID, '\n');
        fprintf(fileID, '     wrong input -> out of range\n');
        fprintf(fileID, '\n');
        continue
    else
        break
    end
end

% Increment global variable to read next answer when required
misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;

%% Load database
if chosen_db == 0
    % No database is selected, loading new data is needed
    [data, misc] = loadData(misc, 'FilePath', FilePath, ...
        'NaNThreshold', NaNThreshold, 'Tolerance', tolerance, ...
        'isPdf', false);
    
    % Display available data on screen
    displayData(data, misc)
    
    % Edit dataset
    [data, misc, dataFilename ] = ...
        editData(data, misc, 'FilePath', FilePath);
    
else
    % Select the data
    [data]=load(fullfile( FilePath, 'mat', FileInfo{chosen_db}));
    
    % Duplicate data binary MAT file with a new name based on current
    % project    
    % Save data in binary format
    fprintf(fileID, '     Duplicate %s --> %s ... \n', ...
        FileInfo{chosen_db}, ['DATA_', misc.ProjectName ,'.mat']);
    [misc, dataFilename] = saveDataBinary(data, misc, ...
        'FilePath', FilePath);
        
    % Display available data on screen
    displayData(data, misc)
    
    % Give the possibility to edit the dataset    
    incTest=0;
    MaxFailAttempts=4;
    
    isYesNoCorrect = false;
    while ~isYesNoCorrect
        
        incTest=incTest+1;
        if incTest > MaxFailAttempts ; error(['Too many failed ', ...
                'attempts (', num2str(MaxFailAttempts)  ').']) ; end
        
        fprintf(fileID, '\n');
        fprintf(fileID, '- Do you want to edit the database ? (y/n) \n');
        % read from user input file (use of global variable )?
        if misc.BatchMode.isBatchMode
            choice=eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
            fprintf(fileID, '     %s\n', choice);
        else
            choice = input('     choice >> ','s');
        end
        if isempty(choice)
            continue
        elseif strcmpi(choice,'y') || strcmpi(choice,'yes')
            
            % Increment global variable to read next answer when required
            misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;
            
            % yes, edit the dataset
            [data, misc, dataFilename ] = ...
                editData(data, misc, 'FilePath', FilePath);
            
            isYesNoCorrect =  true;
            
        elseif strcmpi(choice,'n') || strcmpi(choice,'no')
            
            % no, use the data as such
            misc.isDataSimulation = false;
            
            % Increment global variable to read next answer when required
            misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;
            
            isYesNoCorrect =  true;
            
        else
            fprintf(fileID, '\n');
            fprintf(fileID, '     wrong input\n');
            fprintf(fileID, '\n');
        end
        
    end
    
end
%--------------------END CODE ------------------------
end
