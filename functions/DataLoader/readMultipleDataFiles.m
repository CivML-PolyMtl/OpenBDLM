function [dataOrig, misc]=readMultipleDataFiles(misc)
%READMULTIPLEDATAFILES Read multiple CSV and MAT OpenBDLM data files
%
%   SYNOPSIS:
%     [dataOrig, misc]=READMULTIPLEDATAFILES(misc)
%
%   INPUT:
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
%      READMULTIPLEDATAFILES reads data from multiple data files in CSV and
%      MAT format and put the data in the structure dataOrig
%      path of the files are requested from user input during program
%      execution
%      The structure dataOrig contains three fields timestamps, values, labels
%
%   EXAMPLES:
%      [dataOrig, misc]=READMULTIPLEDATAFILES(misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%      readSingleCSVFile, readSingleMATFile, plotData, plotDataAvailability,
%      saveDataBinary
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also READSINGLECSVFILE, READSINGLEMATFILE, PLOTDATA,
%        PLOTDATAAVAILABILITY, SAVEDATABINARY

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
%       December 5, 2018
%
%   DATE LAST UPDATE:
%       December 5, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;
addRequired(p, 'misc', @isstruct);
parse(p, misc );
misc=p.Results.misc;

MaxFailAttempts=4;

%% Request FileList from user
if misc.internalVars.BatchMode.isBatchMode
    incTest=0;
    while(1)
        
        incTest=incTest+1;
        if incTest > MaxFailAttempts ; error(['Too many failed ', ...
                'attempts (', num2str(MaxFailAttempts)  ').']) ; end
        
        disp(' ')
        fprintf(['- Provide a list of CSV and/or MAT filename to process ' ...
            '(e.g. {''raw_data/data_Tamar/*.csv'', ' ...
            '''DATA_DAT001.mat''}) :\n'])
        FileList=eval(char(misc.internalVars.BatchMode.Answers{...
            misc.internalVars.BatchMode.AnswerIndex}));
        disp(FileList)
        
        if ~iscellstr(FileList)
            disp(' ')
            disp(['     wrong input -> ', ...
                'should be a cell array of character vectors. '])
            disp(' ')
            continue
        elseif isempty(FileList)
            disp(' ')
            disp(['     wrong input -> ', ...
                'should be a cell array of character vectors. '])
            disp(' ')
            continue
            
        else
            
            %% Clean the list of files
            
            % Remove empty fields
            FileList=FileList(~cellfun(@isempty, FileList));
            
            if isempty(FileList)
                disp(' ')
                warning('File list is empty.')
                disp(' ')
                dataOrig.timestamps=[];
                dataOrig.values=[];
                dataOrig.labels=[];
                return
            end
            
            %Remove redundant fields
            FileList=unique(FileList);
            
            %% Loop over single file and read data
            inc=0;
            % loop over list of csv files
            for i=1:length(FileList)
                
                %  get the path and all info about each file
                InfoFile=dir(FileList{i});
                
                % remove '.' and '..' and '.DS_Store' files from the list of files
                InfoFile=InfoFile(~ismember({InfoFile.name}, ...
                    {'.','..', '.DS_Store'}));
                
                % test the existence of the group of files identified by the search
                % pattern
                if isempty(InfoFile)  % the file does not exist
                    disp(' ')
                    warning('%s is not found.', FileList{i})
                    disp(' ')
                    continue
                else % the file exists
                    
                    for j=1:length(InfoFile)
                                                
                        % Get path of the file
                        filename=InfoFile(j).name;
                        PathFile=which(filename);
                        
                        if isempty(PathFile)
                            PathFile=filename;
                        end
                        
                        % Try to read the file as a CSV
                        [dat,label] = ...
                            readSingleCSVFile(PathFile, 'isQuiet', false);
                        
                        if isempty(dat) && isempty(label)
                            % Try to read the file as MAT
                            [dat,label] = ...
                                readSingleMATFile(PathFile, ...
                                'isQuiet', false);
                        end
                        
                        if ~isempty(dat) && ~isempty(label)
                            
                            pos=0;
                            for k = 2:size(dat,2)
                                pos=pos+1;
                                inc=inc+1;
                                % Store in structure array
                                dataOrig.timestamps{inc} = dat(:,1);
                                dataOrig.values{inc} = dat(:,k);
                                dataOrig.labels{inc} = label{pos};
                            end
                            
                        else
                            warning(['Unable to read %s. ', ...
                                'Check formatting.\n'],  PathFile)
                            disp(' ')
                        end
                        
                    end
                    
                end
                
                
            end
            
        end
        
        if ~exist('dataOrig', 'var')
            continue
        else
            % Increment global variable to read next answer when required
            misc.internalVars.BatchMode.AnswerIndex = ...
                misc.internalVars.BatchMode.AnswerIndex + 1;
            break
        end
        
    end
    
else
    
    while(1)
        % Open GUI to select multiple .*CSV files
        Info = uipickfiles('Prompt', 'Choose .csv raw data files', ...
            'REFilter', '\.csv$|\.mat$');
        
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
            
            % Try to read the file as a CSV
            [dat,label] = readSingleCSVFile(PathFile, 'isQuiet', false);
            
            if isempty(dat) && isempty(label)
                % Try to read the file as MAT
                [dat,label] = readSingleMATFile(PathFile, 'isQuiet', ...
                    false);
            end
            
            if ~isempty(dat) && ~isempty(label)
                
                pos=0;
                for k = 2:size(dat,2)
                    pos=pos+1;
                    inc=inc+1;
                    % Store in structure array
                    dataOrig.timestamps{inc} = dat(:,1);
                    dataOrig.values{inc} = dat(:,k);
                    dataOrig.labels{inc} = label{pos};
                end
                
            else
                warning(['Unable to read %s. ', ...
                    'Check formatting.\n'],  PathFile)
                disp(' ')
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
