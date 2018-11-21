function [data, misc, dataFilename]=DataLoader(misc)
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
%   OUTPUT:
%       data                - structure 
%                               data must contain three fields :
%
%                               'timestamps' is a M×1 array
%
%                               'values' is a M×N array
%
%                               'labels' is a 1×N cell array
%                               each cell is a character array
%
%                               N: number of time series
%                               M: number of samples
%
%     misc                  - structure
%                             see the documentation for details about the
%                             field in misc
%
%     dataFilename          -  character
%
%   DESCRIPTION:
%      DATALOADER:
%           - loads an existing processed database (DATA_*.mat file)
%           - creates a new database (DATA_*.mat file) from .csv files
%
%   EXAMPLES:
%      [data, misc, dataFilename] = DATALOADER(misc)
%      [data, misc, dataFilename] = DATALOADER(misc, 'FilePath', 'processed_data')
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
%       October 16, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications

p = inputParser;
addRequired(p, 'misc', @isstruct)
parse(p, misc);

misc=p.Results.misc;

FilePath = misc.internalVars.DataPath;

% Set fileID for logfile
if misc.internalVars.isQuiet
    % output message in logfile
    fileID=fopen(misc.internalVars.logFileName, 'a');
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
    
    if misc.internalVars.BatchMode.isBatchMode
        chosen_db= ...
            eval(char(misc.internalVars.BatchMode.Answers{...
            misc.internalVars.BatchMode.AnswerIndex}));
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
misc.internalVars.BatchMode.AnswerIndex = ...
    misc.internalVars.BatchMode.AnswerIndex+1;

%% Load database
if chosen_db == 0
    % No database is selected, loading new data is needed
    [dataOrig, misc] = loadData(misc);
    
    % Display available data on screen
    displayData(dataOrig, misc)
    
    % Edit dataset
    [data, misc, dataFilename ] = ...
        editData(dataOrig, misc, 'FilePath', FilePath);
    
else
    % Select the data
    [data]=load(fullfile( FilePath, 'mat', FileInfo{chosen_db}));
    
    % Reshape data
    
    % Duplicate data binary MAT file with a new name based on current
    % project    
    % Save data in binary format
    fprintf(fileID, '     Duplicate %s --> %s ... \n', ...
        FileInfo{chosen_db}, ['DATA_', misc.ProjectName ,'.mat']);
    [misc, dataFilename] = saveDataBinary(data, misc, ...
        'FilePath', FilePath);
        
    % Display available data on screen
    displayData(data, misc)
    
    % Plot data summary
    plotDataSummary(data, misc, 'FilePath', 'figures')
    
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
        if misc.internalVars.BatchMode.isBatchMode
            choice=eval(char(misc.internalVars.BatchMode.Answers{misc.internalVars.BatchMode.AnswerIndex}));
            fprintf(fileID, '     %s\n', choice);
        else
            choice = input('     choice >> ','s');
        end
        if isempty(choice)
            continue
        elseif strcmpi(choice,'y') || strcmpi(choice,'yes')
            
            % Increment global variable to read next answer when required
            misc.internalVars.BatchMode.AnswerIndex = misc.internalVars.BatchMode.AnswerIndex+1;
            
            % yes, edit the dataset
            [data, misc, dataFilename ] = ...
                editData(data, misc, 'FilePath', FilePath);
            
            isYesNoCorrect =  true;
            
        elseif strcmpi(choice,'n') || strcmpi(choice,'no')
            
            %plotDataSummary(data, misc, 'FilePath', 'figures')
            
            % no, use the data as such
            misc.internalVars.isDataSimulation = false;
            
            % Increment global variable to read next answer when required
            misc.internalVars.BatchMode.AnswerIndex = misc.internalVars.BatchMode.AnswerIndex+1;
            
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
