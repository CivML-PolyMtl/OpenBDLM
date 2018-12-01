function [dataOrig, misc]=readMultipleCSVFiles(misc)
%READMULTIPLECSVFILES Read data from .csv files
%
%   SYNOPSIS:
%     [data, misc]=READMULTIPLECSVFILES(misc)
%
%   INPUT:
%
%      misc          - structure
%                      see the documentation for details about the
%                      field in misc
%
%   OUTPUT:
%      dataOrig     - structure array
%                     dataOrig must contain three fields :
%
%                           'timestamps' is a 1×N cell array
%                            each cell is a M_ix1 real array
%
%                           'values' is a 1×N cell array
%                            each cell is a M_ix1 real array
%
%                           'labels' is a 1×N cell array
%                            each cell is a character array
%
%                               N: number of time series
%                               M_i: number of samples of time series i
%
%      misc         - structure
%                     see the documentation for details about the
%                     field in misc
%
%   DESCRIPTION:
%      READMULTIPLECSVFILES reads data from multiple .csv files and put
%      the data in the structure data
%      path of the csv file are requested from user input during program
%      execution
%      data contains three fields timestamps, values, labels
%
%   EXAMPLES:
%      [data, misc]=READMULTIPLECSVFILES(misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%      readSingleCSVFile, plotData, plotDataAvailability,
%      saveDataBinary
%
%   See also READSINGLECSVFILE, PLOTDATA,
%             PLOTDATAAVAILABILITY, SAVEDATABINARY

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
%      April 10, 2018
%
%   DATE LAST UPDATE:
%      July 24, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;
addRequired(p, 'misc', @isstruct);
parse(p, misc );
misc=p.Results.misc;

MaxFailAttempts=4;

%% Request CSVFileList from user
if misc.internalVars.BatchMode.isBatchMode
    incTest=0;
    while(1)
        
        incTest=incTest+1;
        if incTest > MaxFailAttempts ; error(['Too many failed ', ...
                'attempts (', num2str(MaxFailAttempts)  ').']) ; end
        
        disp(' ')
        fprintf(['- Provide a list of .CSV filename to process ' ...
            '(e.g. {''raw_data/data_Tamar/*.csv'', ''disp_001.csv''}) :  \n'])
        CSVFileList=eval(char(misc.internalVars.BatchMode.Answers{...
            misc.internalVars.BatchMode.AnswerIndex}));
        disp(CSVFileList)
        %     else
        %         CSVFileList=input('     list of filenames >> ');
        %     end
        
        if ~iscellstr(CSVFileList)
            disp(' ')
            disp(['     wrong input -> ', ...
                'should be a cell array of character vectors. '])
            disp(' ')
            continue
        elseif isempty(CSVFileList)
            disp(' ')
            disp(['     wrong input -> ', ...
                'should be a cell array of character vectors. '])
            disp(' ')
            continue
            
        else
            
            
            %% Clean the list of CSV files
            
            % Remove empty fields
            CSVFileList=CSVFileList(~cellfun(@isempty, CSVFileList));
            
            if isempty(CSVFileList)
                disp(' ')
                disp('WARNING: File list is empty.')
                disp(' ')
                dataOrig.timestamps=[];
                dataOrig.values=[];
                dataOrig.labels=[];
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
                InfoFile= InfoFile(~ismember({InfoFile.name}, ...
                    {'.','..', '.DS_Store'}));
                
                % test the existence of the group of files identified by the search
                % pattern
                if isempty(InfoFile)  % the file does not exist
                    disp(' ')
                    fprintf('     %s is not found.', CSVFileList{i})
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
                        else
                            % Store in structure array
                            dataOrig.timestamps{inc} = dat(:,1);
                            dataOrig.values{inc} = dat(:,2);
                            dataOrig.labels{inc} = label;
                        end
                    end
                    
                end
                
                
            end
            
        end
        
        if ~exist('dataOrig', 'var')
            continue
        else
            % Increment global variable to read next answer when required
            misc.internalVars.BatchMode.AnswerIndex = misc.internalVars.BatchMode.AnswerIndex + 1;
            break
        end
        
    end
    
else
    
    while(1)
        % Open GUI to select multiple .*CSV files
        Info = uipickfiles('Prompt', 'Choose .csv raw data files', ...
            'Filter', '*.csv');
        
        if iscell(Info)
            IndexC = strfind(Info, '.DS_Store');
            Index = find(not(cellfun('isempty', IndexC)));
            if ~isempty(Index)
                Info{Index} = [];
            end
        end
        
        if ~iscell(Info) || isempty(Info(~cellfun(@isempty, Info)))
            error('No valid files were selected.')
            %continue
        end
        
        inc=0;
        for j=1:length(Info)
            %inc=inc+1;
            PathFile = Info{j};
            
            % Read the file
            [dat,label] = readSingleCSVFile(PathFile, 'isQuiet', false);
            
            %if isempty(dat) && isempty(label)

            %else
            if ~isempty(dat) && ~isempty(label)
                inc=inc+1;
                % Store in structure array
                dataOrig.timestamps{inc} = dat(:,1);
                dataOrig.values{inc} = dat(:,2);
                dataOrig.labels{inc} = label;
            end
            
        end
        
        if ~exist('dataOrig', 'var')
            continue
        else
            break
        end
        
    end
    
end
%--------------------END CODE ------------------------
end

