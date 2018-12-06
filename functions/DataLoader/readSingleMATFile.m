function [dat,label]=readSingleMATFile(FileToRead, varargin)
%READSINGLEMATFILE Read a single OpenBDLM MAT data file
%
%   SYNOPSIS:
%     [output_1,output_2, output_3]=READSINGLEMATFILE(input_1,input_2)
%
%   INPUT:
%      input_1 - Description
%      input_2 - Description
%
%   OUTPUT:
%      output_1 - Description
%      output_2 - Description
%      output_3 - Description
%
%   DESCRIPTION:
%      Description with READSINGLEMATFILE in upper case when mentionned
%      Description with READSINGLEMATFILE in upper case when mentionned
%      Description with READSINGLEMATFILE in upper case when mentionned
%
%   EXAMPLES:
%      Line 1 of example
%      Line 2 of example
%      Line 3 of example
%
%   EXTERNAL FUNCTIONS CALLED:
%      READSINGLEMATFILE_1
%      READSINGLEMATFILE_2
%
%   SUBFUNCTIONS:
%      Name of subfunction_1
%      Name of subfunction_1
%
%   See also READSINGLEMATFILE_1 READSINGLEMATFILE_2

%   AUTHORS:
%      Ianis Gaudot, Luong Ha Nguyen,  James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.4.0.813654 (R2018a)
%
%   DATE CREATED:
%       December 5, 2018
%
%   DATE LAST UPDATE:
%       December 5, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

validationFct_FileToRead = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

defaultisQuiet = true;
addRequired(p,'FileToRead', validationFct_FileToRead );
addParameter(p,'isQuiet', defaultisQuiet, @islogical );
parse(p,FileToRead, varargin{:});

FileToRead=p.Results.FileToRead;
%isQuiet=p.Results.isQuiet;

% Test the existence of the file
[isFileExist] = testFileExistence(FileToRead, 'file');

% Get filename only
%[~,FileName,Extension] = fileparts(FileToRead);
%FileNameExt = [FileName,Extension];

if ~isFileExist || isempty(FileToRead)  
%     if ~isQuiet && ~isempty(FileToRead)
%         warning(['Unable to read %s. ', ...
%             'Check formatting.\n'],  FileNameExt)
%         disp(' ')
%     elseif ~isQuiet && isempty(FileToRead)
%         warning('Filename is empty.')
%         disp(' ')
%     end
    dat=[];
    label={};
    return
      
else
    
    %% Load the file
    data=load(FileToRead);
    
    % Validation of structure data
    isValid = verificationDataStructure(data);
    if ~isValid
%         if ~isQuiet
%             warning(['Unable to read %s. ', ...
%                 'Check formatting.\n'], FileNameExt)
%             disp(' ')
%         end
        dat=[];
        label={};
        return
        
    else
        
        numberOfTimeSeries=size(data.values,2);
        numberOfDataPoints=size(data.values,1);
        
        dat=zeros(numberOfDataPoints, numberOfTimeSeries+1);
        
        dat(:,1) =  data.timestamps;
        dat(:,2:end) = data.values;
        label = data.labels;
        
    end
    
    
    
end

%--------------------END CODE ------------------------
end
