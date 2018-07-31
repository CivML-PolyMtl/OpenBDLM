function [misc, dataFilename] = saveDataBinary(data, misc, varargin)
%SAVEDATABINARY Save data in a binary Matlab .mat file
%
%   SYNOPSIS:
%     [misc, dataFilename] =  SAVEDATABINARY(data, misc, varargin)
%
%   INPUT:
%       data        - structure (required)
%                     data must contain three fields:
%
%                          'timestamps' is a M�1 array
%
%                          'values' is a MxN  array
%
%                          'labels' is a 1�N cell array
%                           each cell is a character array
%
%                           N: number of time series
%                           M: number of samples
%
%      misc         - structure
%                     see the documentation for details about the
%                     field in misc
%
%      FilePath     - character (optional)
%                   directory where to save the file
%                   default: '.'  (current folder)
%   OUTPUT:
%
%      misc         - structure
%                     see the documentation for details about the
%                     field in misc
%      dataFilename -  character
%                      full name of the filename where data are saved
%
%   DESCRIPTION:
%      SAVEDATABINARY saves data in Matlab binary file with extension .mat
%      The name of the file is user's defined during program execution.
%
%   EXAMPLES:
%      [misc, dataFilename] = SAVEDATABINARY(data, misc)
%      [misc, dataFilename] = SAVEDATABINARY(data, misc, 'FilePath', './processed_data/')
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

% Validation of structure data
isValid = verificationDataStructure(data);
if ~isValid
    disp(' ')
    disp('ERROR: Unable to read the data from the structure.')
    disp(' ')
    return
end

%% Create specified path if not existing
[isFileExist] = testFileExistence(FilePath, 'dir');
if ~isFileExist
    % create directory
    mkdir(FilePath)   
    % set directory on path
    addpath(FilePath)
end

ProjectName=misc.ProjectName;
fullname = fullfile(FilePath, ['DATA_', ProjectName, '.mat'] );

[isFileExist] = testFileExistence(fullname, 'file');

if isFileExist
    isAnswerCorrect = false;
    while ~isAnswerCorrect
        disp(' ')
        fprintf(['     Data file name %s already exists. ' ...
        'Overwrite ? (y/n) \n'], ['DATA_', ProjectName, '.mat'])
        choice = input('     choice >> ','s');
        % Remove space and quotes
        choice=strrep(choice,'''','' ); % remove quotes
        choice=strrep(choice,'"','' ); % remove double quotes
        choice=strrep(choice, ' ','' ); % remove spaces
        
        if isempty(choice)
            disp(' ')
            disp('     wrong input --> please make a choice')
            disp(' ')
            continue
        elseif strcmpi(choice,'y') || strcmpi(choice,'yes') 
            %fullname = fullfile(FilePath, ['CFG_' ProjectName '.m']);
            isAnswerCorrect =  true;
        elseif strcmpi(choice,'n') || strcmpi(choice,'no') 
            [name]=incrementFilename('DATA_new', FilePath, ...
                        'FileExtension','mat');
            fullname = fullfile(FilePath, name);
            isAnswerCorrect = true;
        else
            disp(' ')
            disp('     wrong input')
            disp(' ')
            continue
        end
        
    end
end

dataFilename = fullname;

%% Save binary file in specified location
save(fullname, '-struct', 'data')
disp(' ')            
fprintf('     Database saved in %s. \n', fullname);
disp(' ')
%--------------------END CODE ------------------------
end
