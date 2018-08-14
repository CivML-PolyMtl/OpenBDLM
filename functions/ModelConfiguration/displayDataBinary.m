function [FileInfo] = displayDataBinary(misc, varargin)
%DISPLAYDATABINARY Display the list of DATA_*.mat files
%
%   SYNOPSIS:
%      [FileInfo] = DISPLAYDATABINARY(misc, varargin)
%
%   INPUT:
%      misc          - structure
%                      see the documentation for details about the
%                      field in misc
%
%      FilePath     - character (optional)
%                     directory where to save the file
%                     default: '.'  (current folder)
%
%   OUTPUT:
%      FileInfo     - cell array of string
%                     name of each file
%
%
%   DESCRIPTION:
%      DISPLAYDATABINARY displays the list of DATA_*.mat files in the
%      specified location given by FilePath
%
%   EXAMPLES:
%      [FileInfo] = DISPLAYDATABINARY(misc)
%      [FileInfo] = DISPLAYDATABINARY(misc, 'FilePath', 'processed_data')
%
%   See also CHOOSEDATABINARY, SAVEPROJECT

%   AUTHORS:
%        Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
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
%       August 10, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultFilePath = '.';

validationFct_FilePath = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p, 'misc', @isstruct);
addParameter(p,'FilePath', defaultFilePath, validationFct_FilePath );
parse(p, misc, varargin{:});

FilePath=p.Results.FilePath;

FilePath_full=fullfile(FilePath, 'mat');


% Set fileID for logfile
if misc.isQuiet
    % output message in logfile
    fileID=fopen(misc.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
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

%% List files in specified directory
pattern = 'DATA*.mat';
fullpattern = fullfile(FilePath_full, pattern);

info_file=dir(fullpattern);
info_file=info_file(~ismember({info_file.name},{'.','..', '.DS_Store'}));

if ~isempty(info_file)
    FileInfo=cell(length(info_file),1);
    %% Display saved databases
    for i=1:length(info_file)
        FileInfo{i} = info_file(i).name;
        fprintf(fileID, '     %-3s -> %-25s\t\n', num2str(i), info_file(i).name);
    end
else
    FileInfo =[];
end
disp(' ')
%--------------------END CODE ------------------------
end
