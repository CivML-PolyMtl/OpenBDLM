function saveDataCSV(data,varargin)
%SAVEDATACSV Save time series data in separate .csv files
%
%   SYNOPSIS:
%     SAVEDATACSV(data,varargin)
%
%   INPUT:
%      data       - structure (required)
%                   data must contain three fields :
%
%                       'timestamps' is a 1×N cell array
%                       each cell is a M_ix1 real array
%
%                       'values' is a 1×N cell array
%                       each cell is a M_ix1 real array
%
%                       'labels' is a 1×N cell array
%                       each cell is a character array
%
%                 N: number of time series
%                 M_i: number of samples of time series i
%
%
%      FilePath   - character (optional)
%                   directory where to save the csv files
%                   default: '.'  (current folder)
%
%   OUTPUT:
%      CSV files with extension .csv saved in FilePath/DirName/ location.
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
%       April 17, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultFilePath = '.';
validationFct_FilePath = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p,'data', @isstruct );
addParameter(p,'FilePath', defaultFilePath, validationFct_FilePath );
parse(p,data, varargin{:});

data=p.Results.data;
FilePath=p.Results.FilePath;

% define global variable for user's answers from input file
global isAnswersFromFile AnswersFromFile AnswersIndex

% Validation of structure data
isValid = verificationDataStructure(data);
if ~isValid
    disp(' ')
    disp('ERROR: Unable to read the data from the structure.')
    disp(' ')
    return
end

%% Remove space in filename
%FilePath = FilePath(~isspace(FilePath));

%% Create specified path if not existing
[isFileExist] = testFileExistence(FilePath, 'dir');
if ~isFileExist
    % create directory
    mkdir(FilePath)   
    % set directory on path
    addpath(FilePath)
end

%% Get saving directory name from external input
isNameCorrect = false;
while ~isNameCorrect
    disp(' ')
    fprintf(['- Enter the name of the subdirectory in which ' ...
        'to save the CSV files (max 25 characters):\n'])
    % read from user input file (use of global variable )?
    if isAnswersFromFile
        database_name=eval(char(AnswersFromFile{1}(AnswersIndex)));
        disp(['     ', database_name])
    else
        database_name=input('     directory name >> ','s');
    end
    
    % Remove space and quotes
    database_name=strrep(database_name,'''','' ); % remove single quotes
    database_name=strrep(database_name,'"','' ); % remove double quotes
    database_name=strrep(database_name, ' ','' ); % remove spaces
    
    if isempty(database_name)
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%')
        disp(' ')
        disp(' Choose the name of subdirectory in which to save the files.')
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%')
        disp(' ')
    elseif length(database_name)>25
        disp('     wrong input -> string > 25 characters')
    else
        name_datadir=database_name;
        fullname=fullfile(FilePath, name_datadir);
        
        if exist(fullname, 'dir') == 7
            disp(' ')
            fprintf('Directory %s already exists. Overwrite ?\n', fullname)
            
            isYesNoCorrect = false;
            while ~isYesNoCorrect
                choice = input('     (y/n) >> ','s');
                if isempty(choice)
                    disp(' ')
                    disp('     wrong input --> please make a choice')
                    disp(' ')
                elseif strcmp(choice,'y') || strcmp(choice,'yes') ||  ...
                        strcmp(choice,'Y') || strcmp(choice,'Yes')  || ...
                        strcmp(choice,'YES')
                    
                    isYesNoCorrect =  true;
                    isNameCorrect = true;
                    
                    % Remove dir
                    warning('off')
                    rmdir(fullname, 's')
                    warning('on')
                    % Create new directory
                    mkdir(fullname)
                    addpath(fullname)
                    
                elseif strcmp(choice,'n') || strcmp(choice,'no') ||  ...
                        strcmp(choice,'N') || strcmp(choice,'No')  || ...
                        strcmp(choice,'NO')
                    
                    
                    [name_datadir] = incrementFilename('data_new', FilePath);
                    fullname=fullfile(FilePath, name_datadir);
                    
                    % Create new directory
                    mkdir(fullname)
                    addpath(fullname)
                    
                    isYesNoCorrect =  true;
                    isNameCorrect = true;
                    
                else
                    disp(' ')
                    disp('     wrong input')
                    disp(' ')
                end
                
            end
        else
            
            % Create new directory
            mkdir(fullname)
            addpath(fullname)
            
            isNameCorrect = true;
        end
    end
end

% Increment global variable to read next answer when required
AnswersIndex = AnswersIndex + 1;

%% Save CSV files in specified location
% Get number of time series
numberOfTimeSeries=length(data.values);
% Loop over each time series
for i=1:numberOfTimeSeries
    % Get serial number corresponding to the first timestamp for this time
    % series
    first_timestamps=data.timestamps{i}(1);
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
    dlmwrite( file_name, [data.timestamps{i}(:) data.values{i}(:)] , ...
        '-append', 'precision','%f');
    % close file
    fclose(fid);
end

fprintf('     CSV files saved in %s \n', fullname);
% disp('->done.')
disp(' ')
%--------------------END CODE ------------------------
end