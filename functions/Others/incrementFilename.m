function [filename]=incrementFilename(ReferenceName, FilePath, varargin)
%INCREMENTFILENAME Increment filename to prevent overwriting
%
%   SYNOPSIS:
%     [filename]=INCREMENTFILENAME(ReferenceName, FilePath, varargin)
%
%   INPUT:
%      ReferenceName - character (required)
%                      Name of the file without extension and increment                 
%
%      FilePath      - character (required)
%                      Name of the directory in which to save the file 
%
%      FileExtension - character (optional)
%                      Extension of the file 
%                      defaut = '' (no extension)
%        
%   OUTPUT:
%      filename      - character
%                      Full name of the file
%                      filaneme = "ReferenceName" + "." + "FileExtension"
%
%   DESCRIPTION:
%      INCREMENTFILENAME numerically increments over previously existing 
%      file with "ReferenceName" pattern to prevent overwriting
%
%   EXAMPLES:
%      [filename] = INCREMENTFILENAME('DATA_', 'processed_data', 'FileExtension', 'mat')
%      [filename] = INCREMENTFILENAME('DATA_', 'raw_data')
%
%   See also SAVEDATABINARY, SAVEDATACSV, PLOTDATA

%   AUTHORS:
%      Ianis Gaudot, Luong Ha Nguyen, James-A Goulet,
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       April 16, 2018
%
%   DATE LAST UPDATE:
%       April 17, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultFileExtension = '';

validationFct_FilePath = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

validationFct_FileExtension = @(x) ischar(x);

addRequired(p,'ReferenceName', validationFct_FilePath );
addRequired(p,'FilePath', validationFct_FilePath );
addParameter(p,'FileExtension', defaultFileExtension, ...
    validationFct_FileExtension);
parse(p,ReferenceName, FilePath, varargin{:});

ReferenceName=p.Results.ReferenceName;
FileExtension = p.Results.FileExtension;
FilePath=p.Results.FilePath;

% List files in directory
files=dir(fullfile( FilePath, ['*', ReferenceName,'*']));

if ~isempty(files)    
    res_1=strsplit(files(end).name, '.');
    res_2=strsplit(res_1{1}, '_');
    num=str2double(res_2{end});
    num=num+1; % increment filename
    if ~isempty(FileExtension(~isspace(FileExtension)))
        filename=[ ReferenceName, '_' ,  num2str(num,'%03d'), '.', FileExtension];
    else
        filename=[ ReferenceName,'_' , num2str(num,'%03d')];
    end
else
    num = 1;
    if ~isempty(FileExtension(~isspace(FileExtension)))
        filename=[ ReferenceName, '_' , num2str(num,'%03d'), '.', FileExtension];
    else
        filename=[ ReferenceName, '_' , num2str(num,'%03d')];
    end
end
%--------------------END CODE ------------------------
end
