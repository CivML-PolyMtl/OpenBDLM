function [data, misc, dataFilename]=editData(data, misc, varargin)
%EDITDATA Control script to edit dataset (selection, resampling, etc..)
%
%   SYNOPSIS:
%     [data, misc, dataFilename]=EDITDATA(data, misc, varargin)
%
%   INPUT:
%       data            - structure (required)
%                         Two formats are accepted:
%
%                           (1) data must contain three fields :
%
%                               'timestamps' is a 1×N cell array
%                               each cell is a M_ix1 real array
%
%                               'values' is a 1×N cell array
%                               each cell is a M_ix1 real array
%
%                               'labels' is a 1×N cell array
%                               each cell is a character array
%
%                               N: number of time series
%                               M_i: number of samples of time series i
%
%
%                           (2) data must contain three fields:
%
%                               'timestamps' is a M×1 array
%
%                               'values' is a MxN  array
%
%                               'labels' is a 1×N cell array
%                               each cell is a character array
%
%                               N: number of time series
%                               M: number of samples
%
%      misc             - structure (required)
%                           see the documentation for details about the
%                           field in misc
%
%      FilePath         - character (optional)
%                         directory where to save the plot
%                         defaut: '.'  (current folder)
%
%   OUTPUT:
%       data            - structure
%                               data must contain three fields:
%
%                               'timestamps' is a M×1 array
%
%                               'values' is a MxN  array
%
%                               'labels' is a 1×N cell array
%                               each cell is a character array
%
%                               N: number of time series
%                               M: number of samples
%
%       misc            - structure
%                           see the documentation for details about the
%                           field in misc
%
%      dataFilename -  character
%                      full name of the filename where data are saved
%
%   DESCRIPTION:
%      EDITDATA edits dataset
%      Editing dataset includes, among others:
%
%         - select some time series
%         - select data analysis time period
%         - resampling
%         - remove missing data
%
%     The updated dataset is saved in the location given by FilePath.
%     The name of the *.MAT file containing the dataset is returned in
%     dataFilename output.
%
%   EXAMPLES:
%      [data, misc,  dataFilename]=EDITDATA(data, misc)
%      [data, misc, dataFilename]=EDITDATA(data, misc, 'FilePath', 'processed_data')
%
%   EXTERNAL FUNCTIONS CALLED:
%      saveDataBinary, chooseTimeSeries, resampleData, selectTimePeriod,
%      mergeTimeStampVectors
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also SAVEDATABINARY, CHOOSETIMESERIES, RESAMPLEDATA,
%   SELECTTIMEPERIOD, MERGETIMESTAMPVECTORS

%   AUTHORS:
%        Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       July 4, 2018
%
%   DATE LAST UPDATE:
%       October 18, 2018
%
%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultFilePath = '.';
validationFct_FilePath = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p,'data', @isstruct );
addRequired(p,'misc', @isstruct );
addParameter(p,'FilePath', defaultFilePath, validationFct_FilePath );
parse(p,data, misc, varargin{:});

data=p.Results.data;
misc=p.Results.misc;
FilePath = p.Results.FilePath;

MaxFailAttempts=4;

PossibleAnswers = [1 2 3 4 5 6 7];

% Get information from misc
NaNThreshold=misc.options.NaNThreshold;
tolerance= misc.options.Tolerance;

% Set fileID for logfile
if misc.internalVars.isQuiet
    % output message in logfile
    fileID=fopen(misc.internalVars.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end

% if data given in format (2), translate it to format (1)
if ~iscell(data.timestamps) && ~iscell(data.values)
    [data]=convertMat2Cell(data);
end

%% Save current dataset (original data)
misc.dataBeforeEditing = data;

%% Display data editing menu
incTest=0;
while(1)
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    % Plot current data
    close all
    plotDataSummary(data, misc, 'FilePath', 'figures')
    
    fprintf(fileID,'\n');
    fprintf(fileID,'- Choose from\n');
    fprintf(fileID,'\n');
    fprintf(fileID,'     1  ->  Select time series\n');
    fprintf(fileID,'     2  ->  Select data analysis time period \n');
    fprintf(fileID,'     3  ->  Remove missing data\n');
    fprintf(fileID,'     4  ->  Resample\n');
    fprintf(fileID,'     5  ->  Change synchronization options\n');
    fprintf(fileID,'\n');
    fprintf(fileID,'     6  ->  Reset changes\n');
    fprintf(fileID,'     7  ->  Save changes and continue analysis\n');
    fprintf(fileID,'\n');
    
    if misc.internalVars.BatchMode.isBatchMode
        user_inputs.inp_1=eval(char(misc.internalVars.BatchMode.Answers{ ...
            misc.internalVars.BatchMode.AnswerIndex}));
        fprintf(fileID,'     %s\n',num2str(user_inputs.inp_1));
    else
        user_inputs.inp_1 = input('     choice >> ');
    end
    
    if ~any(ismember( PossibleAnswers, user_inputs.inp_1 )) && ...
            ~isempty(user_inputs.inp_1 )
        fprintf(fileID,'\n');
        fprintf(fileID,'     wrong input\n');
        fprintf(fileID,'\n');
        continue
        
    elseif user_inputs.inp_1 == 7
        misc.internalVars.BatchMode.AnswerIndex = ...
            misc.internalVars.BatchMode.AnswerIndex +1;
        
        % Remove original data
        misc=rmfield(misc, 'dataBeforeEditing');
        
        % Test that data timestamps have been merged
        [isMerged]=verificationMergedDataset(data);
        
        if iscell(data.timestamps) && iscell(data.values) && isMerged
            [data] = convertCell2Mat(data);
        elseif iscell(data.timestamps) && iscell(data.values) && ~isMerged
            % If not, merge data timestampps
            disp('     Synchronizing time series ...')
            [data, misc] = mergeTimeStampVectors(data, misc, ...
                'NaNThreshold', NaNThreshold, 'tolerance', tolerance);
        end
                
        % Plot data summary
        close all
        plotDataSummary(data, misc, 'FilePath', 'figures')
        
        % Save data
        [misc, dataFilename] = saveDataBinary(data,misc, ...
            'FilePath', FilePath, 'isForceOverwrite', true);
        
        %        close all
        return
    else
        misc.internalVars.BatchMode.AnswerIndex = ...
            misc.internalVars.BatchMode.AnswerIndex+1;
        
        if user_inputs.inp_1 == 1
            % Choose some time series
            [data, misc]=chooseTimeSeries(data, misc);
            
            % Merge the timestamp vectors of the selected time series if
            % needed
            [isMerged]=verificationMergedDataset(data);
            
            if ~isMerged
                disp('     Synchronizing time series ...')
                [data, misc] = mergeTimeStampVectors(data, misc, ...
                    'NaNThreshold', NaNThreshold, 'tolerance', tolerance);
            end
            
            incTest=0;
            continue
            
        elseif user_inputs.inp_1 == 2
            
            % Merge the timestamp vectors of the selected time series if
            % needed
            [isMerged]=verificationMergedDataset(data);
            if iscell(data.timestamps) && iscell(data.values) && isMerged
                [data] = convertCell2Mat(data);
            elseif iscell(data.timestamps) && iscell(data.values) && ~isMerged
                % If not, merge data timestampps
                disp('     Synchronizing time series ...')
                [data, misc] = mergeTimeStampVectors(data, misc, ...
                    'NaNThreshold', NaNThreshold, 'tolerance', tolerance);
            end
            
            % Select period of analysis
            [data, misc]=selectTimePeriod(data, misc);
            
            incTest=0;
            continue
            
        elseif user_inputs.inp_1 == 3
            
            incTest_2=0;
            isAnswerCorrect = false;
            while ~isAnswerCorrect
                
                incTest_2=incTest_2+1;
                if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                        'attempts (', num2str(MaxFailAttempts)  ').']) ; end
                
                fprintf(fileID,'\n');
                fprintf(fileID,['     Percentage of missing data ', ...
                    'allowed at each timestamp:\n']);
                fprintf(fileID,['     (Example: 25 means that, at each ', ...
                    'timestamp maximum 25%% of the data can be NaN)\n']);
                if misc.internalVars.BatchMode.isBatchMode
                    user_inputs.inp_2= eval(char(misc.internalVars.BatchMode.Answers{...
                        misc.internalVars.BatchMode.AnswerIndex}));
                    fprintf(fileID,'     %s', num2str(user_inputs.inp_2));
                else
                    fprintf(fileID,'\n');
                    user_inputs.inp_2 = input('     choice >> ');
                end
                
                if  isnumeric(user_inputs.inp_2) && ...
                        length(user_inputs.inp_2) ==1
                    
                    % Convert mat2cell
                    if ~iscell(data.timestamps) && ~iscell(data.values)
                        [data]=convertMat2Cell(data);
                    end
                    
                    [data, misc] = mergeTimeStampVectors (data, misc, ...
                        'NaNThreshold', user_inputs.inp_2, ...
                        'tolerance', tolerance);
                    incTest=0;
                    isAnswerCorrect = true;
                else
                    fprintf(fileID,'\n');
                    fprintf(fileID,'     wrong input\n');
                    fprintf(fileID,'\n');
                    continue
                end
                
            end
            
            misc.internalVars.BatchMode.AnswerIndex = ...
                misc.internalVars.BatchMode.AnswerIndex+1;
            
        elseif user_inputs.inp_1 == 4
            
            % Merge the timestamp vectors of the selected time series if
            % needed
            [isMerged]=verificationMergedDataset(data);
            if iscell(data.timestamps) && iscell(data.values) && isMerged
                [data] = convertCell2Mat(data);
            elseif iscell(data.timestamps) && iscell(data.values) && ~isMerged
                % If not, merge data timestampps
                disp('     Synchronizing time series ...')
                [data, misc] = mergeTimeStampVectors(data, misc, ...
                    'NaNThreshold', NaNThreshold, 'tolerance', tolerance);
            end
            
            incTest_2=0;
            isAnswerCorrect = false;
            while ~isAnswerCorrect
                
                incTest_2=incTest_2+1;
                if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                        'attempts (', num2str(MaxFailAttempts)  ').']) ; end
                
                fprintf(fileID,'\n');
                fprintf(fileID,'     Provide time step (in days)\n');
                if misc.internalVars.BatchMode.isBatchMode
                    dt_ref=eval(char(misc.internalVars.BatchMode.Answers{ ...
                        misc.internalVars.BatchMode.AnswerIndex}));
                    fprintf(fileID,'     %s',num2str(dt_ref));
                else
                    dt_ref = input('     choice >> ');
                end
                
                if  isnumeric(dt_ref) && length(dt_ref) ==1
                    [data, misc] =  resampleData(data, misc, ...
                        'Timestep', dt_ref);
                    incTest=0;
                    isAnswerCorrect = true;
                else
                    fprintf(fileID,'\n');
                    fprintf(fileID,'     wrong input');
                    fprintf(fileID,'\n');
                    continue
                end
                
            end
            
            misc.internalVars.BatchMode.AnswerIndex = ...
                misc.internalVars.BatchMode.AnswerIndex+1;
            
        elseif user_inputs.inp_1 == 5
            
            % Change time synchronization options
            % Synchronization options control how the merging of the
            % timestamps vector of each time series is done
            % Merging timestamps is required for further analysis
            
            % Change the amount of missing data allowed at each timestamp
            incTest_2=0;
            isCorrectAnswer =  false;
            while ~isCorrectAnswer
                
                incTest_2=incTest_2+1;
                if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                        'attempts (', num2str(MaxFailAttempts)  ').']) ; end
                fprintf(fileID,'\n');
                fprintf(fileID,'     Provide a NaN threshold value (in %%): \n');
                if misc.internalVars.BatchMode.isBatchMode
                    NaNThreshold=eval(char(misc.internalVars.BatchMode.Answers...
                        {misc.internalVars.BatchMode.AnswerIndex}));
                    fprintf(fileID, '     %s\n', num2str(choice));
                else
                    NaNThreshold = input('     choice >> ');
                end
                
                if  isnumeric(NaNThreshold) && length(NaNThreshold) ==1 && ...
                        NaNThreshold >= 0 && NaNThreshold <= 100
                    misc.options.NaNThreshold = NaNThreshold;
                    isCorrectAnswer =  true;
                else
                    fprintf(fileID,'\n');
                    fprintf(fileID,'     wrong input \n');
                    continue
                end
                
            end
            
            % Change the tolerance
            % timestamps +/- tolerance are considered equal
            
            incTest_2=0;
            isCorrectAnswer =  false;
            while ~isCorrectAnswer
                
                incTest_2=incTest_2+1;
                if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                        'attempts (', num2str(MaxFailAttempts)  ').']) ; end
                fprintf(fileID,'\n');
                fprintf(fileID,'     Provide a tolerance value (in days): \n');
                if misc.internalVars.BatchMode.isBatchMode
                    tolerance=eval(char(misc.internalVars.BatchMode.Answers...
                        {misc.internalVars.BatchMode.AnswerIndex}));
                    fprintf(fileID, '     %s\n', num2str(choice));
                else
                    tolerance = input('     choice >> ');
                end
                    
                if  isnumeric(tolerance) && length(tolerance) ==1 && ...
                        tolerance >= 0
                    
                    misc.options.Tolerance = tolerance;
                    isCorrectAnswer =  true;
                else
                    fprintf(fileID,'\n');
                    fprintf(fileID,'     wrong input \n');
                    continue
                end
                
            end
            
        elseif user_inputs.inp_1 == 6
            
            incTest_2=0;
            isAnswerCorrect = false;
            while ~isAnswerCorrect
                
                incTest_2=incTest_2+1;
                if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                        'attempts (', num2str(MaxFailAttempts)  ').']) ; end
                
                fprintf(fileID,'\n');
                fprintf(fileID,['     Do you really want ', ...
                    'to reset the changes ? (y/n)\n']);
                if misc.internalVars.BatchMode.isBatchMode
                    choice=eval(char(misc.internalVars.BatchMode.Answers{ ...
                        misc.internalVars.BatchMode.AnswerIndex}));
                    fprintf(fileID,'     %s', choice);
                else
                    choice = input('     choice >> ', 's');
                end
                
                if  strcmpi(choice,'y') || strcmpi(choice,'yes')
                    data = misc.dataBeforeEditing;
                    isAnswerCorrect = true;
                elseif strcmpi(choice,'n') || strcmpi(choice,'no')
                    incTest=0;
                    isAnswerCorrect = true;
                else
                    fprintf(fileID,'\n');
                    fprintf(fileID,'     wrong input\n');
                    fprintf(fileID,'\n');
                    continue
                end
                
            end
            
            misc.internalVars.BatchMode.AnswerIndex = ...
                misc.internalVars.BatchMode.AnswerIndex+1;
            
        elseif isempty(user_inputs.inp_1 )
            continue
        else
            fprintf(fileID,'\n');
            fprintf(fileID,'     wrong input.\n');
            fprintf(fileID,'\n');
            continue
            
        end
        
    end
    
end

end