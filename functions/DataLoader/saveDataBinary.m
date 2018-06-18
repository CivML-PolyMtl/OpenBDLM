function [dataFilename] = saveDataBinary(data,varargin)
%SAVEDATABINARY Save data in a binary Matlab .mat file
%
%   SYNOPSIS:
%     [dataFilename] =  SAVEDATABINARY(data, varargin)
%
%   INPUT:
%      data         - structure (required)
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
%      FilePath     - character (optional)
%                   directory where to save the file
%                   default: '.'  (current folder)
%   OUTPUT:
%      dataFilename -  character
%                      full name of the filename where data are saved
%
%   DESCRIPTION:
%      SAVEDATABINARY saves data in Matlab binary file with extension .mat
%      The name of the file is user's defined during program execution.
%
%   EXAMPLES:
%      [dataFilename] = SAVEDATABINARY(data)
%      [dataFilename] = SAVEDATABINARY(data, 'FilePath', './processed_data/')
%
%   EXTERNAL FUNCTIONS CALLED:
%      verificationDataStructure
%
%   See also VERIFICATIONDATASTRUCTURE, PLOTDATA, PLOTDATAAVAILABILITY,
%            READMULTIPLECSVFILES

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


%% Get file name from external input
isNameCorrect = false;
while ~isNameCorrect    
    disp(' ')
    disp('- Enter a database reference name (max 25 characters):')
    % read from user input file (use of global variable )?
    if isAnswersFromFile
        database_name=eval(char(AnswersFromFile{1}(AnswersIndex)));
        disp(['     ',database_name])
    else
        database_name=input('     database name >> ','s');
    end
    
    if ischar(database_name)
    % Remove space and quotes
    database_name=strrep(database_name,'''','' ); % remove single quotes
    database_name=strrep(database_name,'"','' ); % remove double quotes
    database_name=strrep(database_name, ' ','' ); % remove spaces
    end
    
    if isempty(database_name)
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%')
        disp(' ')
        disp(' Choose the name of the database.')
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%')
        disp(' ')
    elseif length(database_name)>25
        disp('     wrong input -> string > 25 characters')
    else
        name_datafile=['DATA_', database_name, '.mat'];
        fullname=fullfile(FilePath, name_datafile);
        
        if exist(fullname, 'file') == 2
            disp(' ')
            fprintf('File %s already exists. Overwrite ?\n', fullname)           
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

                elseif strcmp(choice,'n') || strcmp(choice,'no') ||  ...
                        strcmp(choice,'N') || strcmp(choice,'No')  || ...
                        strcmp(choice,'NO')
                    
                    [name] = incrementFilename('DATA_new', FilePath, ...
                        'FileExtension','mat');
                    fullname=fullfile(FilePath, name);
                    
                    isYesNoCorrect =  true;
                    isNameCorrect = true;
                    
                else
                    disp(' ')
                    disp('     wrong input')
                    disp(' ')
                end
                
            end
        else
            
            isNameCorrect = true;
            
        end
        
    end
end

% Increment global variable to read next answer when required
AnswersIndex = AnswersIndex + 1;

dataFilename = fullname;

%% Save binary file in specified location
save(fullname, '-struct', 'data')
disp(' ')            
fprintf('     New database saved in %s \n', fullname);
disp(' ')
%--------------------END CODE ------------------------
end
