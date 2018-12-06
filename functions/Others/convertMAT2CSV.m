function convertMAT2CSV(FileName, varargin)
%CONVERTMAT2CSV Convert a OpenBDLM DATA_*.mat file to OpenBDLM CSV file(s)
%
%   SYNOPSIS:
%     CONVERTMAT2CSV(FileName, varargin)
%
%   INPUT:
%      FileName    - character (required)
%                    name of a OpenBDLM DATA_*.mat file
%
%      FilePath    - character (optional)
%                    directory where to save the CSV files
%                    default: '.'  (current folder)
%
%   OUTPUT:
%      CSV file created in FilePath
%
%   DESCRIPTION:
%      CONVERTMAT2CSV converts DATA_*.mat to CSV files
%      CSV files are saved in FilePath/ProjectName/
%      ProjectName are taken from FileName, assuming that FileName =
%      'DATA_ProjectName.mat'
%
%
%   EXAMPLES:
%      convertMAT2CSV('DATA_TEST.mat')
%      convertMAT2CSV('DATA_TEST.mat', 'FilePath', '/data/csv')
%
%   EXTERNAL FUNCTIONS CALLED:
%      verificationDataStructure
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also VERIFICATIONDATASTRUCTURE

%   AUTHORS:
%        Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.4.0.813654 (R2018a)
%
%   DATE CREATED:
%       December 4, 2018
%
%   DATE LAST UPDATE:
%       December 4, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultFilePath = '.';
validationFct_FilePath = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p,'FileName', validationFct_FilePath );
addParameter(p,'FilePath', defaultFilePath, validationFct_FilePath );
parse(p,FileName, varargin{:});

FileName=p.Results.FileName;
FilePath=p.Results.FilePath;

%% Test the file existence
[isFileExist]=testFileExistence(FileName, 'file');

if ~isFileExist
    error('The file %s is not found', FileName)
end

%% Create the output directory

% Try to catch the name from the file
[~,name,~] = fileparts(FileName);

namesplit=strsplit(name, '_');

if length(namesplit) == 1 || length(namesplit) > 2
    [name_datadir] = incrementFilename('data_new', FilePath);
else
    name_datadir = namesplit{2};
    fullname=fullfile(FilePath, name_datadir);
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
                [name_datadir] = ...
                    incrementFilename('data_new', FilePath);
                isAnswerCorrect = true;
            else
                disp(' ')
                disp('     wrong input')
                disp(' ')
                continue
            end
            
        end
        
    end
    
end

% Create the output directory
fullname=fullfile(FilePath, name_datadir);
mkdir(fullname)
addpath(fullname)

%% Load the file
data=load(FileName);

% Validation of structure data
isValid = verificationDataStructure(data);
if ~isValid
    disp(' ')
    error('Unable to read the data from the structure.');
end

disp('     Converting MAT to CSV format ...')

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
    file_name = fullfile(fullname , ...
        [name_datadir, '_' sensor_name, '.csv' ]);
    
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
disp(['     CSV file(s) saved in ', fullname]);
disp(' ')
%--------------------END CODE ------------------------
end
