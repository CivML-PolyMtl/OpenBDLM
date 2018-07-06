function [data, dataFilename]=editData(data, varargin)
%EDITDATA Control script to edit dataset (selection, resampling, etc..)
%
%   SYNOPSIS:
%     [data, dataFilename]=EDITDATA(data, varargin)
%
%   INPUT:
%   INPUT:
%      data             - structure (required)
%                          data must contain three fields :
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
%                                   N: number of time series
%                                   M_i: number of samples of time series i
%
%      FilePath         - character (optional)
%                         directory where to save the plot
%                         defaut: '.'  (current folder)
%
%   OUTPUT:
%      data             - structure
%                          data must contain three fields :
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
%                                   N: number of time series
%                                   M_i: number of samples of time series i
%
%      dataFilename -  character
%                      full name of the filename where data are saved
%
%   DESCRIPTION:
%      EDITDATA edits dataset
%      Editing dataset includes, among others:
%
%         - Select some time series
%         - Select data analysis time period
%         - Resampling
%         - Remove missing data
%
%     The updated dataset is saved in the location given by FilePath.
%     The name of the *.MAT file containing the dataset is returned in
%     dataFilename output.
%
%
%   EXAMPLES:
%      [data, dataFilename]=EDITDATA(data)
%      [data, dataFilename]=EDITDATA(data, 'FilePath', 'processed_data')
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
%       July 5, 2018

%--------------------BEGIN CODE ----------------------


%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultFilePath = '.';
validationFct_FilePath = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p,'data', @isstruct );
addParameter(p,'FilePath', defaultFilePath, validationFct_FilePath );
parse(p,data, varargin{:});

data=p.Results.data;
FilePath = p.Results.FilePath;

% define global variable for user's answers from input file
global isAnswersFromFile AnswersFromFile AnswersIndex


PossibleAnswers = [1 2 3 4 5 6];

while(1)
    
    disp(' ')
    disp(['-----------------------------------------', ...
        '-----------------------------------------------------'])
    disp(' / Choose from')
    disp(['-----------------------------------------', ...
        '-----------------------------------------------------'])
    
    disp(' ')
    disp('     1  ->  Select time series')
    disp('     2  ->  Select data analysis time period ')
    disp('     3  ->  Remove missing data')
    disp('     4  ->  Resample')
    disp('     5  ->  Auto-select synchronous time series')
    disp(' ')
    disp('     6  ->  Save database')
    disp(' ')
    
    
    if isAnswersFromFile
        user_inputs.inp_1=eval(char(AnswersFromFile{1}(AnswersIndex)));
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
        AnswersIndex = AnswersIndex +1;
        [dataFilename] = saveDataBinary(data,'FilePath', FilePath);        
        return
    else
        AnswersIndex = AnswersIndex+1;
        
        if user_inputs.inp_1 == 1
            [data]=chooseTimeSeries(data, 'isPlot', true);
            continue
            
        elseif user_inputs.inp_1 == 2
            [data]=selectTimePeriod(data);
            continue
            
        elseif user_inputs.inp_1 == 3
            
            isAnswerCorrect = false;
            while ~isAnswerCorrect
                disp(' ')
                disp(['     Give percentage of missing data (NaN)', ...
                    ' allowed for each timestamp:'])
                if isAnswersFromFile
                    user_inputs.inp_2=eval(char(AnswersFromFile{1} ...
                        (AnswersIndex)));
                    disp(['     ',num2str(user_inputs.inp_2)])
                else
                    user_inputs.inp_2 = input('     choice >> ');
                end
                
                if  isnumeric(user_inputs.inp_2) && ...
                        length(user_inputs.inp_2) ==1
                    
                    [data] = mergeTimeStampVectors (data, ...
                        'NaNThreshold', user_inputs.inp_2);
                    isAnswerCorrect = true;
                else
                    disp('     wrong input')
                    continue
                end
                
                
            end
            
            AnswersIndex=AnswersIndex+1;
            
        elseif user_inputs.inp_1 == 4
            
            isAnswerCorrect = false;
            while ~isAnswerCorrect
                disp(' ')
                disp('     Give time step (in day)')
                if isAnswersFromFile
                    dt_ref=eval(char(AnswersFromFile{1}(AnswersIndex)));
                    disp(['     ',num2str(dt_ref)])
                else
                    dt_ref = input('     choice >> ');
                end
                
                if  isnumeric(dt_ref) && length(dt_ref) ==1
                    [data] =  resampleData(data, 'Timestep', dt_ref);
                    isAnswerCorrect = true;
                else
                    disp('     wrong input')
                    continue
                end
                
            end
            
            AnswersIndex=AnswersIndex+1;
            
        elseif user_inputs.inp_1 == 5
            
            % Remove trailing missing data
            [data] =  removeTrailingNaN(data);
            
            % Extract syncronous time series
            [data]=extractSynchronousRecords(data);
            
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