function [data]=readMultipleCSVFiles(CSVFileList, varargin)
%READMULTIPLECSVFILES Read data from .csv files
%
%   SYNOPSIS:
%     [data]=READMULTIPLECSVFILES(varargin)
%
%   INPUT:
%
%      isOutputFile - logical (optional)
%                     if true, save the data in a DATA_*.mat Matlab file
%                     default: false
%
%      isPlot       - logical (optional)
%                     if true, plot data
%                     default: false
%
%   OUTPUT:
%      data         - structure array
%                     fields of data are timestamps, values, labels
%
%
%   DESCRIPTION:
%      READMULTIPLECSVFILES reads data from multiple .csv files and put
%      the data in the structure data
%      path of the csv file are requested from user input during program
%      execution
%      data contains three fields timestamps, values, labels
%
%   EXAMPLES:
%      [data]=READMULTIPLECSVFILES
%      [data]=READMULTIPLECSVFILES('isPlot', 'true', 'isOutputFile', true)
%
%   EXTERNAL FUNCTIONS CALLED:
%      readSingleCSVFile, plotData, plotDataAvailability,
%      saveDataBinary
%
%   See also READSINGLECSVFILE, PLOTDATA,
%             PLOTDATAAVAILABILITY, SAVEDATABINARY

%   AUTHORS:
%      Ianis Gaudot, Luong Ha Nguyen,, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%      April 10, 2018
%
%   DATE LAST UPDATE:
%      April 18, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications

p = inputParser;
defaultisOutputFile = false;
defaultisPlot = false;

addParameter(p,'isOutputFile',defaultisOutputFile,@islogical);
addParameter(p,'isPlot',defaultisPlot,@islogical);

parse(p, varargin{:} );

isOutputFile=p.Results.isOutputFile;
isPlot=p.Results.isPlot;


% define global variable for user's answers from input file
global isAnswersFromFile AnswersFromFile AnswersIndex

%% Request CSVFileList from user

while(1)
    disp(' ')
    fprintf(['Provide a list of .CSV filename to process ' ...
        '(e.g. {''raw_data/data_Tamar/*.csv'', ''disp_001.csv''}) :  \n'])
    if isAnswersFromFile
        CSVFileList=eval(char(AnswersFromFile{1}(AnswersIndex)));
        disp(CSVFileList)
    else
        CSVFileList=input('     list of filenames >> ');
    end
    
    if ~iscellstr(CSVFileList)
        disp(' ')
        disp('     wrong input -> should be a cell array of character vectors. ')
        disp(' ')
        continue   
    elseif isempty(CSVFileList)
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%')
        disp('                                                         ')
        fprintf([' The list of filenames should provide the location' ...
            '(path + filename) of the ''.csv'' raw data files.\n'])
        fprintf(' Star wildcard (asterisk) is supported.\n')
        fprintf([' The list should be provided using a cell ' ...
            'array of character vectors.\n'])
        fprintf([' Example : {''./raw_data/data_Tamar/*.csv''} looks for '...
        'all files with a ''.csv'' extension in the directory with path ' ...
        '''./raw_data/data_Tamar/'' which is relative to the current' ...
        'working directory.\n '])
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp(' ')
        continue
    else        
        break
    end
end

% Increment global variable to read next answer when required
AnswersIndex = AnswersIndex + 1;

%% Clean the list of CSV files

% Remove empty fields

CSVFileList=CSVFileList(~cellfun(@isempty, CSVFileList));

if isempty(CSVFileList)
    disp(' ')
    disp('WARNING: File list is empty.')
    disp(' ')
    data.timestamps=[];
    data.values=[];
    data.labels=[];
    return
end

%Remove redundant fields
CSVFileList=unique(CSVFileList);

%% Loop over single CSV file and read data
inc=0;
% loop over list of csv files
for i=1:length(CSVFileList)
    
    %  get the path and all info about each file
    InfoFile=dir(CSVFileList{i});
    
    % remove '.' and '..' and '.DS_Store' files from the list of files
    InfoFile=InfoFile(~ismember({InfoFile.name},{'.','..', '.DS_Store'}));
    
    % test the existence of the group of files identified by the search
    % pattern
    if isempty(InfoFile)  % the file does not exist
        disp(' ')
        fprintf('%s is not found.', CSVFileList{i})
        disp(' ')
        continue
    else % the file exists
        
        for j=1:length(InfoFile)
            
            inc=inc+1;
            
            % Get path of the file
            filename=InfoFile(j).name;
            PathFile=which(filename);
            
            % Read the file
            [dat,label] = readSingleCSVFile(PathFile, 'isQuiet', false);
            
            if isempty(dat) && isempty(label)
                %                 disp(' ')
                %                 fprintf('WARNING: Skip file. \n')
            else
                % Store in structure array
                data.timestamps{inc} = dat(:,1);
                data.values{inc} = dat(:,2);
                data.labels{inc} = label;
            end
        end
        
    end
    
end

% Stop if no data have been retained
if ~exist('data', 'var')
    disp(' ')
    disp('WARNING: No valid data have been found.')
    disp(' ')
    data.timestamps=[];
    data.values=[];
    data.labels=[];
    return
    
else
    
    if isPlot
        plotData(data, 'FigurePath', 'figures')
    end
    
    if isOutputFile
        saveDataBinary(data, 'FilePath','processed_data')
    end
    
end
%--------------------END CODE ------------------------
end

