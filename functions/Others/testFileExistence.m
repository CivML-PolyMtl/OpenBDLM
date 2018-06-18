function [isFileExist]=testFileExistence(FileName, FileType)
%TESTFILEEXISTENCE Test existence of a file
%
%   SYNOPSIS:
%     [isExist]=TESTFILEEXISTENCE(FilePath, FileType)
% 
%   INPUT:
%      FileName - character (required)
%                 Indicate absolute path of the file
%
%      FileType - character (required)
%                 Indicate the file type, is either 'file' or 'dir'
% 
%   OUTPUT:
%      isExist  - logical
%                 if isExist = true , the file exists in the specified
%                 FilePath
% 
%   DESCRIPTION:
%      TESTFILEEXISTENCE tests existence of a file given in FileName
%      Important: the absolute path of FileName should be specified.
% 
%   EXAMPLES:
%      [isExist]=TESTFILEEXISTENCE('./home/saved_projects', 'dir')
%      [isExist]=TESTFILEEXISTENCE('./home/test.m', 'file')
% 
%   See also 

%   AUTHORS: 
%      Ianis Gaudot
% 
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
% 
%   DATE CREATED:
%       April 24, 2018
% 
%   DATE LAST UPDATE:
%       April 24, 2018
 
%--------------------BEGIN CODE ---------------------- 

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;
validationFct_FileName = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

validationFct_Type = @(x) (ischar(x) && ...
    ~isempty(x(~isspace(x)))) && ...
    (strcmp(x, 'file') || strcmp(x, 'dir'));

addRequired(p, 'FileName', validationFct_FileName)
addRequired(p, 'FileType', validationFct_Type)
 
parse(p,FileName, FileType);

FileName=p.Results.FileName;
FileType=p.Results.FileType;


%% Remove space
FileName = FileName(~isspace(FileName));
FileType = FileType(~isspace(FileType));

%% Convert relative to absolute path
if isempty(strfind(FileName, '/')) && isempty(strfind(FileName, '\'))
    FileName=fullfile(pwd, FileName);
end

%% Verify presence of the file
if strcmp(FileType, 'file')
    if exist(FileName, FileType) == 2
       isFileExist = true; 
    else
       isFileExist = false ;
    end
elseif strcmp(FileType, 'dir')
    if exist(FileName, FileType) == 7
       isFileExist = true; 
    else
       isFileExist = false ;
    end
end
%--------------------END CODE ------------------------ 
end
