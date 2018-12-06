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
%      Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
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
%       December 3, 2018

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

% Extension
if isempty(FileExtension)
    LengthExtension = 0;
else
    LengthExtension = 1+length(FileExtension);
end

% Format
NumberOfZeros=3;
fmt=['%0',num2str(NumberOfZeros),'d'];

MaxIncrementalName=10^(NumberOfZeros)-1;

% List files in directory
files=dir(fullfile( FilePath, ['*', ReferenceName,'*']));

if ~isempty(files)
    num = 0;
    for i=1:length(files)
        
        file  = files(i).name;
        if  length(file) == (length(ReferenceName)+1+NumberOfZeros+ ...
                LengthExtension) && ...
                strcmp(file(1:length(ReferenceName)), ReferenceName)
            
            numc= str2double(file(length(ReferenceName)+2: ...
                length(ReferenceName)+1+NumberOfZeros));
            
            if numc > num
                num = numc;
            end
            
        end
    end
    
    num=num+1; % increment filename
    
    if num > MaxIncrementalName
        disp(' ')
        warning('Impossible to increment filename.')
        disp(' ')
        num=num-1;
    end
    
    if ~isempty(FileExtension(~isspace(FileExtension)))
        filename= ...
            [ ReferenceName, '_' ,  num2str(num,fmt), '.', FileExtension];
    else
        filename=...
            [ ReferenceName,'_' , num2str(num,fmt)];
    end
    
else
    
    num = 1;
    if ~isempty(FileExtension(~isspace(FileExtension)))
        filename=[ ReferenceName, '_' , num2str(num,fmt), '.', FileExtension];
    else
        filename=[ ReferenceName, '_' , num2str(num,fmt)];
    end
    
end
%--------------------END CODE ------------------------
end
