function [data, misc, dataFilename]=editData(data, misc, varargin)
%EDITDATA Control script to edit dataset (selection, resampling, etc..)
%
%   SYNOPSIS:
%     [data, misc, dataFilename]=EDITDATA(data, misc, varargin)
%
%   INPUT:
%       data            - structure (required)
%                         data must contain three fields:
%
%                               'timestamps' is a M�1 array
%
%                               'values' is a MxN  array
%
%                               'labels' is a 1�N cell array
%                                each cell is a character array
%
%                                   N: number of time series
%                                   M: number of samples
%
%     misc              - structure
%                           see the documentation for details about the
%                           field in misc
%
%      FilePath         - character (optional)
%                         directory where to save the plot
%                         defaut: '.'  (current folder)
%
%   OUTPUT:
%       data            - structure (required)
%                               data must contain three fields:
%
%                               'timestamps' is a M�1 array
%
%                               'values' is a MxN  array
%
%                               'labels' is a 1�N cell array
%                               each cell is a character array
%
%                               N: number of time series
%                               M: number of samples
%
%   misc                - structure
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
%       July 24, 2018

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

PossibleAnswers = [1 2 3 4 5 6];


%% Save current dataset
misc.dataBeforeEditing = data;


%% Display data editing menu
incTest=0;
while(1)
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    % Plot current data
    close all
    plotData(data, misc, 'FilePath', 'figures', ...
        'isPdf', false,'isSaveFigure', false)
    
    disp(' ')
    disp('- Choose from')
    disp(' ')
    disp('     1  ->  Select time series')
    disp('     2  ->  Select data analysis time period ')
    disp('     3  ->  Remove missing data')
    disp('     4  ->  Resample')
    disp(' ')
    disp('     5  ->  Reset changes')
    disp('     6  ->  Save changes and continue analysis')
    disp(' ')
        
    if misc.BatchMode.isBatchMode
        user_inputs.inp_1=eval(char(misc.BatchMode.Answers{ ...
            misc.BatchMode.AnswerIndex}));
        disp(['     ',num2str(user_inputs.inp_1)])
    else
        user_inputs.inp_1 = input('     choice >> ');
    end
    
    if ~any(ismember( PossibleAnswers, user_inputs.inp_1 )) && ...
            ~isempty(user_inputs.inp_1 )
        disp(' ')
        disp('     wrong input')
        disp(' ')
        continue
        
    elseif user_inputs.inp_1 == 6
        misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex +1;
        
        % Remove original data
        misc=rmfield(misc, 'dataBeforeEditing');
        
        % Save data
        [misc, dataFilename] = saveDataBinary(data,misc, ...
            'FilePath', FilePath);
        
        close all
        return
    else
        misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;
        
        if user_inputs.inp_1 == 1
            [data, misc]=chooseTimeSeries(data, misc, 'isPlot', false);
            incTest=0;
            continue
            
        elseif user_inputs.inp_1 == 2
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
                
                
                disp(' ')
                disp(['     Percentage of missing data ', ...
                    'allowed at each timestamp:'])
                disp(['     (Example: 25 means that, at each ', ...
                    'timestamp maximum 25% of the data can be NaN)'])
                if misc.BatchMode.isBatchMode
                    user_inputs.inp_2= eval(char(misc.BatchMode.Answers{...
                        misc.BatchMode.AnswerIndex}));
                    disp(['     ',num2str(user_inputs.inp_2)])
                else
                    disp(' ')
                    user_inputs.inp_2 = input('     choice >> ');
                end
                
                if  isnumeric(user_inputs.inp_2) && ...
                        length(user_inputs.inp_2) ==1
                    
                    % Convert mat2cell
                    [dataCell]=convertMat2Cell(data);
                    
                    [data, misc] = mergeTimeStampVectors (dataCell, misc, ...
                        'NaNThreshold', user_inputs.inp_2);
                    incTest=0;
                    isAnswerCorrect = true;
                else
                    disp(' ')
                    disp('     wrong input')
                    continue
                end
                
            end
            
            misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;
            
        elseif user_inputs.inp_1 == 4
            
            incTest_2=0;
            isAnswerCorrect = false;
            while ~isAnswerCorrect
                
                incTest_2=incTest_2+1;
                if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                        'attempts (', num2str(MaxFailAttempts)  ').']) ; end
                
                disp(' ')
                disp('     Give time step (in day)')
                if misc.BatchMode.isBatchMode
                    dt_ref=eval(char(misc.BatchMode.Answers{ ...
                        misc.BatchMode.AnswerIndex}));
                    disp(['     ',num2str(dt_ref)])
                else
                    dt_ref = input('     choice >> ');
                end
                
                if  isnumeric(dt_ref) && length(dt_ref) ==1
                    [data, misc] =  resampleData(data, misc, ...
                        'Timestep', dt_ref);
                    incTest=0;
                    isAnswerCorrect = true;
                else
                    disp(' ')
                    disp('     wrong input')
                    continue
                end
                
            end
            
            misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;
            
            
        elseif user_inputs.inp_1 == 5
            
            incTest_2=0;
            isAnswerCorrect = false;
            while ~isAnswerCorrect
                
                incTest_2=incTest_2+1;
                if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                        'attempts (', num2str(MaxFailAttempts)  ').']) ; end
                
                disp(' ')
                disp('     Do you really want to reset the changes ? (y/n)')
                if misc.BatchMode.isBatchMode
                    choice=eval(char(misc.BatchMode.Answers{ ...
                        misc.BatchMode.AnswerIndex}));
                    disp(['     ',num2str(choice)])
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
                    disp('     wrong input')
                    continue
                end
                
            end
            
            misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;
            
        elseif isempty(user_inputs.inp_1 )
            disp(' ')
            disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%')
            disp(' ')
            disp(['Typing # selects the option number # among all', ...
                ' available option to edit the dataset.'])
            disp(' ')
            disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%')
            disp(' ')
            continue
        else
            disp(' ')
            disp('     wrong input.')
            disp(' ')
            continue
            
        end
        
    end
    
end

end