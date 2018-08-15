function [misc] = saveDataCSV(data, misc, varargin)
%SAVEDATACSV Save time series data in separate .csv files
%
%   SYNOPSIS:
%     [misc] = SAVEDATACSV(data,misc, varargin)
%
%   INPUT:
%       data      - structure (required)
%                   data must contain three fields:
%
%                        'timestamps' is a M×1 array
%
%                        'values' is a MxN  array
%
%                        'labels' is a 1×N cell array
%                         each cell is a character array
%
%                         N: number of time series
%                         M: number of samples
%
%      misc       - structure
%                   see the documentation for details about the
%                   field in misc
%
%      FilePath   - character (optional)
%                   directory where to save the csv files
%                   default: '.'  (current folder)
%
%   OUTPUT:
%
%      misc       - structure
%                   see the documentation for details about the
%                   field in misc
%
%      CSV files with extension .csv saved in the location given by FilePath.
%
%   DESCRIPTION:
%      SAVEDATACSV saves each time series in data in separate *.csv files
%      CSV files are saved in FilePath/DirName/ location
%      SAVEDATACSV request user input to define 'DirName'
%
%   EXAMPLES:
%      SAVEDATACSV(data)
%      SAVEDATACSV(data, 'FilePath', './raw_data/')
%
%   EXTERNAL FUNCTIONS CALLED:
%      verificationDataStructure, incrementFilenamer
%
%   See also VERIFICATIONDATASTRUCTURE, PLOTDATA, PLOTDATAAVAILABILITY,
%            READMULTIPLECSVFILES, INCREMENTFILENAME

%   AUTHORS:
%      Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       April 10, 2018
%
%   DATE LAST UPDATE:
%       July 25, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultFilePath = '.';
validationFct_FilePath = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p,'data', @isstruct );
addRequired(p,'misc', @isstruct );
addParameter(p,'FilePath', defaultFilePath, validationFct_FilePath );
parse(p,data, misc, varargin{:});

data=p.Results.data;
misc=p.Results.misc;
FilePath=p.Results.FilePath;

FilePath_full=fullfile(FilePath, 'csv');

% Set fileID for logfile
if misc.isQuiet
    % output message in logfile
    fileID=fopen(misc.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end

% Validation of structure data
isValid = verificationDataStructure(data);
if ~isValid
    fprintf(fileID,'\n');
    fprintf(fileID,'ERROR: Unable to read the data from the structure.\n');
    fprintf(fileID,'\n');
    return
end

%% Create specified path if not existing
[isFileExist] = testFileExistence(FilePath_full, 'dir');
if ~isFileExist
    % create directory
    mkdir(FilePath_full)
    % set directory on path
    addpath(FilePath)
    addpath(FilePath_full)
end

disp('     Saving database (csv format) ...')

%% Get saving directory name from external input
name_datadir=misc.ProjectName;
fullname=fullfile(FilePath_full, name_datadir);

[isFileExist] = testFileExistence(fullname, 'dir');

if isFileExist
    isAnswerCorrect = false;
    while ~isAnswerCorrect
        disp(['     Directory ', name_datadir , ' already exists. ' ...
            'Overwrite ? (y/n)']);
        choice = input('     choice >> ','s');
        % Remove space and quotes
        choice=strrep(choice,'''','' ); % remove quotes
        choice=strrep(choice,'"','' ); % remove double quotes
        choice=strrep(choice, ' ','' ); % remove spaces
        
        if isempty(choice)
            disp(' ')
            disp('     wrong input')
            disp(' ')
            continue
        elseif strcmpi(choice,'y') || strcmpi(choice,'yes')
            isAnswerCorrect =  true;
        elseif strcmpi(choice,'n') || strcmpi(choice,'no')
            [name_datadir] = incrementFilename('data_new', FilePath_full);
            fullname=fullfile(FilePath_full, name_datadir);
            
            % Create new directory
            mkdir(fullname)
            addpath(fullname)
            isAnswerCorrect = true;
        else
            disp(' ')
            disp('     wrong input')
            disp(' ')
            continue
        end
        
    end
    
else
    
    % Create new directory
    mkdir(fullname)
    addpath(fullname)
    
end

%% Save CSV files in specified location
% Get number of time series
numberOfTimeSeries=size(data.values,2);
% Loop over each time series
for i=1:numberOfTimeSeries
    % Get serial number corresponding to the first timestamp for this time
    % series
    first_timestamps=data.timestamps(1);
    % Convert the serial date to string date
    date_str=datestr(first_timestamps, 'yyyy-mm-dd-HH:MM:SS');
    
    % define the filename based on time series reference name
    sensor_name=data.labels{i};
    file_name = fullfile(fullname , [name_datadir, '_' sensor_name, '.csv' ]);
    
    %create/open csv file
    fid = fopen(file_name, 'w');
    % write csv header
    fprintf(fid, '%s \n', [ sensor_name ', ''' date_str '''']) ;
    % write timestamps, amplitude values in csv file
    dlmwrite( file_name, [data.timestamps(:) data.values(:,i)] , ...
        '-append', 'precision','%f');
    % close file
    fclose(fid);
end
fprintf(fileID,'\n');
fprintf(fileID,'     CSV files saved in %s \n', fullname);
fprintf(fileID,'\n');
%--------------------END CODE ------------------------
end