function [misc] = modifyTrainingPeriod(data, model, estimation, misc, varargin)
%MODIFYTRAININGPERIOD Request user to modify training period
%
%   SYNOPSIS:
%     [misc] = MODIFYTRAININGPERIOD(data, model, estimation, misc, varargin)
%
%   INPUT:
%      data             - structure (required)
%                         see documentation for details about the fields of
%                         data
%
%      model            - structure (required)
%                          see documentation for details about the fields of
%                          model
%
%      estimation       - structure (required)
%                         see documentation for details about the fields of
%                         estimation
%
%      misc             - structure (required)
%                         see documentation for details about the fields of
%                         misc
%
%      FilePath         - character (optional)
%                         directory where to save the modifications
%                         save modification in
%                         FilePath/PROJ_'misc.ProjectName'.mat file
%                         default: '.'  (current folder)
%   OUTPUT:
%      misc             - structure (required)
%                         see documentation for details about the fields of
%                         misc
%
%      Updated project file with new training period
%
%   DESCRIPTION:
%      MODIFYTRAININGPERIOD requests user to modify training period
%
%   EXAMPLES:
%      [misc]=MODIFYTRAININGPERIOD(data, model, estimation, misc)
%      [misc]=MODIFYTRAININGPERIOD(data, model, estimation, misc, 'FilePath', 'saved_projects')
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also

%   AUTHORS:
%       Ianis Gaudot, Luong Ha Nguyen, James-A Goulet,
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       June 12, 2018
%
%   DATE LAST UPDATE:
%       July 25, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultFilePath = '.';


validationFonction = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'estimation', @isstruct );
addRequired(p,'misc', @isstruct );
addParameter(p, 'FilePath', defaultFilePath, validationFonction)
parse(p,data, model, estimation, misc, varargin{:});

data=p.Results.data;
model=p.Results.model;
estimation=p.Results.estimation;
misc=p.Results.misc;
FilePath=p.Results.FilePath;

%% Define timestamps
timestamps = data.timestamps;

MaxFailAttempts=4;

%% Get current training period
if isfield(misc, 'trainingPeriod')
    disp(' ')
    disp(['     Current training period: from ' ...
        num2str(misc.trainingPeriod(1)) ' to ' ...
        num2str(misc.trainingPeriod(2)) ' days.'])
    disp(' ')
else
    [trainingPeriod]=defineTrainingPeriod(timestamps);
    misc.trainingPeriod = trainingPeriod;
    disp(' ')
    disp(['     Current training period: from ' ...
        num2str(misc.trainingPeriod(1)) ' to ' ...
        num2str(misc.trainingPeriod(2)) ' days.'])
    disp(' ')
end

incTest=0;
isCorrectAnswer =  false;
while ~isCorrectAnswer
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    disp('     1 ->  Modify training period')
    disp(' ')
    disp('     2 ->  Return to menu')
    disp(' ')
    
    if misc.BatchMode.isBatchMode
        user_inputs.inp_1=eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
        disp(user_inputs.inp_1)
    else
        user_inputs.inp_1 = input('     choice >> ');
    end
    
    if user_inputs.inp_1 == 1
        
        misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
        
        %% Modify current training period
        % Start of training period (in days)
        disp(' ')
        incTest=0;
        isCorrect = false;
        while ~isCorrect
            
            incTest=incTest+1;
            if incTest > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            
            disp('     Start training [days]: ');
            
            if misc.BatchMode.isBatchMode
                startTraining=eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
                disp(startTraining)
            else
                startTraining=input('     choice >> ');
            end
                        
            if isempty(startTraining)
                disp(' ')
                disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
                disp('                                                         ')
                disp(['Give start of the training period in '...
                    'number of days since the first datapoint. '])
                disp(' ')
                disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
                disp(' ')
                continue
            else
                if ischar(startTraining)
                    disp(' ')
                    disp('     wrong input -> not an digit ')
                    disp(' ')
                    continue
                elseif length(startTraining) > 1
                    disp(' ')
                    disp('     wrong input -> should be single value ')
                    disp(' ')
                    continue
                else
                    misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
                    isCorrect = true;
                end
            end
        end
        
        % End of training period (in days)
        disp(' ')       
        incTest=0;
        isCorrect = false;
        while ~isCorrect
            
            incTest=incTest+1;
            if incTest > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            
            disp('     End training [days]: ');
            
            if misc.BatchMode.isBatchMode
                endTraining = eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
                disp(endTraining)
            else
                endTraining=input('     choice >> ');
            end
            
            if isempty(endTraining)
                disp(' ')
                disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
                disp('                                                         ')
                disp(['End of the training period in '...
                    'number of days since the first datapoint. '])
                disp(' ')
                disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
                disp(' ')
                continue
            else
                if ischar(endTraining)
                    disp(' ')
                    disp('     wrong input -> not an digit ')
                    disp(' ')
                    continue
                elseif length(endTraining) > 1
                    disp(' ')
                    disp('     wrong input -> should be single value ')
                    disp(' ')
                    continue
                elseif endTraining <= startTraining
                    disp(' ')
                    disp(['     wrong input -> should be greater '...
                        'than start of training period.'])
                    disp(' ')
                    continue
                else
                    misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
                    isCorrect = true;
                end
            end
        end
        
        break
        
    elseif user_inputs.inp_1 == 2
        misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
        return
        
    else
        disp('     Wrong input.')
        continue
    end
    
    
end

% Record training period
trainingPeriod = [startTraining, endTraining];
misc.trainingPeriod = trainingPeriod;

%% Display the new training period
disp(' ')
disp(['     New training period: from ' ...
    num2str(misc.trainingPeriod(1)) ' to ' ...
    num2str(misc.trainingPeriod(2)) ' days.'])
disp(' ')

%% Save project with updated values
saveProject(data, model, estimation, misc, 'FilePath', FilePath)

%--------------------END CODE ------------------------
end
