function [dat,label]=readSingleCSVFile(FileToRead, varargin)
%READSINGLECSVFILE Read a single OpenBDLM CSV data file
%
%   SYNOPSIS:
%     [dat, label]=READSINGLECSVFILE(FileToRead, varargin)
%
%   INPUT:
%      FileToRead - string of character (required)
%                   name of the file to read
%
%      isQuiet    - logical (optional)
%                   if true, throw detailed warning/error
%                   default: false
%
%   OUTPUT:
%      dat        - Nx2 real array
%                   N is the total number of samples
%                   Column 1 contains the timestamps
%                   Column 2 contains amplitude values
%                   Timestamp are serial date numbers following Matlab
%                   convention
%
%      label      - 1x1 cell array
%                   label contains the reference name of the time-series
%
%   DESCRIPTION:
%      READSINGLECSVFILE reads "comma separated value" (csv) file.
%      The file is a two columns file that should be formatted as follow:
%
%      L1    'name'            ,   '2000-01-01-22-00-00'
%      L2    737422            ,   0.405720714733635
%      L3    737423            ,   0.211094693486129
%      L4    737424            ,   0.54834914800378
%
%      First line of the file is the header.
%      In the header, first field should contain the label of the time
%      series ; second field should contain the date (string) of the first
%      timestamp.
%      Note that the two fields in the header are NOT the label of each column.
%
%   EXAMPLES:
%      [dat, label]=READSINGLECSVFILE('/raw_data/dat001.csv')
%
%   See also READMULTIPLECSVFILES, SAVEDATACSV

%   AUTHORS:
%       Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
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
isQuiet=p.Results.isQuiet;

% Test the existence of the file
[isFileExist] = testFileExistence(FileToRead, 'file');

% Get filename only
[~,FileName,Extension] = fileparts(FileToRead);
FileNameExt = [FileName,Extension];

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
end

%% Open and read the file, throw error if unknown formatting
fileID=fopen(FileToRead, 'r');
try
    header = textscan(fileID,'%s',1,'Delimiter','\n'); % get header
catch
%     disp(' ')
%     if ~isQuiet
%         warning(['Unable to read %s. ', ...
%             'Check formatting.\n'], FileNameExt)
%         disp(' ')
%     end
    dat=[];
    label={};
    return
end

try
    ts_val=textscan(fileID, '%f %f','Delimiter', ',', ...
        'TreatAsEmpty',{'NaN', ''}, 'EmptyValue', NaN , ...
        'ReturnOnError' , false); % get values
catch
%     if ~isQuiet
%         warning(['Unable to read %s. ', ...
%             'Check formatting. \n'], FileNameExt)
%         disp(' ')
%     end
    dat=[];
    label={};
    return
end

if any(isnan(ts_val{1,1}(:)))
    if ~isQuiet
        warning(['Unable to read %s. ', ...
            'Timestamps contains NaN. \n'], FileNameExt)
        disp(' ')
    end
    dat=[];
    label={};
    return
end

header_split=strsplit(header{1,1}{1}, ',');

% Clean reference name
reference_name=strrep(header_split{1},'''','' ); % remove single quotes
reference_name=strrep(reference_name,'"','' ); % remove double quotes
reference_name=strrep(reference_name, ' ','' ); % remove spaces

if isempty(reference_name)
    if ~isQuiet
        warning(['Unable to read %s. ', ...
            'Reference name is empty in header.\n'], ...
            FileNameExt)
        disp(' ')
    end
    dat=[];
    label={};
    return
end

% Clean date of the first sample
% remove quotes
string_date_first_sample=strrep(header_split{2},'''','' );
% remove double quotes
string_date_first_sample=strrep(string_date_first_sample, '"','' );
% remove spaces
string_date_first_sample=strrep(string_date_first_sample, ' ','' );

% Convert serial date to serial date Matlab convention
% (day 1 == January 0, 0000)

% Get delta days
fmt='yyyy-mm-dd-HH:MM:SS';

if isempty(string_date_first_sample) ||  ...
        strcmp(string_date_first_sample, 'N/A')
    delta_days = 0;
else
    try
        delta_days = datenum(string_date_first_sample, ...
            fmt)- ts_val{1,1}(1,1);
    catch
        if ~isQuiet
            warning(['Unable to read %s. ', ...
                'Unknown date format in header. \n'], FileNameExt)
            disp(' ')
        end
        dat=[];
        label={};
        return
    end
    
    if ~strcmp(datestr(string_date_first_sample, fmt), ...
            string_date_first_sample) && ~isQuiet
        warning(['Unable to read %s. ', ...
            'Unknown date format in header. \n'], FileNameExt)
        disp(' ')
        dat=[];
        label={};
        return
    end
      
end

ts_corrected = ts_val{1,1}(:)+delta_days;

% Remove redundancies
[~,ia,ic] = unique(ts_corrected, 'rows');

if length(ia) ~= length(ic)
    if ~isQuiet
        warning(['Timestamp redundancy detected ', ...
            'in %s. Only the first occurrences retained \n'], FileNameExt)
        disp(' ')
    end
end

ts_corrected = ts_corrected(ia);

ts_val{:,1} = ts_corrected ;
ts_val{:,2} = ts_val{:,2}(ia,:) ;

%% Store timestamps and amplitude value
dat=cell2mat(ts_val);
label={reference_name};

% Close file
fclose(fileID);
%--------------------END CODE ------------------------
end
