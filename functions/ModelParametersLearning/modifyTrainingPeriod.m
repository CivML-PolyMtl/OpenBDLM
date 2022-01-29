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
%       August 9, 2018

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

% Set fileID for logfile
if misc.internalVars.isQuiet
    % output message in logfile
    fileID=fopen(misc.internalVars.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end

%% Define timestamps
timestamps = data.timestamps;

MaxFailAttempts=4;

%% Get current training period
if isfield(misc, 'trainingPeriod')
    fprintf(fileID,'\n');
    fprintf(fileID,['     Current training period: from ' ...
        num2str(misc.options.trainingPeriod(1)) ' to ' ...
        num2str(misc.options.trainingPeriod(2)) ' days.\n']);
    fprintf(fileID,'\n');
else
    [trainingPeriod]=defineTrainingPeriod(timestamps);
    misc.options.trainingPeriod = trainingPeriod;
    fprintf(fileID,'\n');
    fprintf(fileID,['     Current training period: from ' ...
        num2str(misc.options.trainingPeriod(1)) ' to ' ...
        num2str(misc.options.trainingPeriod(2)) ' days.\n']);
    fprintf(fileID,'\n');
end

incTest=0;
isCorrectAnswer =  false;
while ~isCorrectAnswer
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    fprintf(fileID,'     1 ->  Modify training period \n');
    fprintf(fileID,'\n');
    fprintf(fileID,'     Type R to return to the previous menu \n');
    fprintf(fileID,'\n');
    
    if misc.internalVars.BatchMode.isBatchMode
        user_inputs.inp_1=eval(char(misc.internalVars.BatchMode.Answers{misc.internalVars.BatchMode.AnswerIndex}));
        user_inputs.inp_1 = num2str(user_inputs.inp_1);
        if ischar(user_inputs.inp_1)
            fprintf(fileID, '     %s  \n', user_inputs.inp_1);
        else
            fprintf(fileID, '     %s  \n', num2str(user_inputs.inp_1));
        end
        
        
    else
        user_inputs.inp_1 = input('     choice >> ', 's');
    end
    
        % Remove space and simple/double quotes
        user_inputs.inp_1=strrep(user_inputs.inp_1,'''',''); 
        user_inputs.inp_1=strrep(user_inputs.inp_1,'"','' ); 
        user_inputs.inp_1=strrep(user_inputs.inp_1, ' ','' ); 
    
    
    %if ~ischar(user_inputs.inp_1) && user_inputs.inp_1 == 1
    if round(str2double(user_inputs.inp_1)) == 1
        
        misc.internalVars.BatchMode.AnswerIndex=misc.internalVars.BatchMode.AnswerIndex+1;
        
        %% Modify current training period
        % Start of training period (in days)
        fprintf(fileID,'\n');
        incTest=0;
        isCorrect = false;
        while ~isCorrect
            
            incTest=incTest+1;
            if incTest > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            
            fprintf(fileID,'     Start training [days]:\n');
            
            if misc.internalVars.BatchMode.isBatchMode
                startTraining=eval(char(misc.internalVars.BatchMode.Answers{misc.internalVars.BatchMode.AnswerIndex}));
                fprintf(fileID,'     %s\n', startTraining);
            else
                startTraining=input('     choice >> ');
            end
                        
            if isempty(startTraining)
                continue
            else
                if ischar(startTraining)
                    fprintf(fileID,'\n');
                    fprintf(fileID,'     wrong input -> not an digit \n');
                    fprintf(fileID,'\n');
                    continue
                elseif length(startTraining) > 1
                    fprintf(fileID,'\n');
                    fprintf(fileID,['     ', ...
                        'wrong input -> should be single value \n']);
                    fprintf(fileID,'\n');
                    continue
                else
                    misc.internalVars.BatchMode.AnswerIndex=misc.internalVars.BatchMode.AnswerIndex+1;
                    isCorrect = true;
                end
            end
        end
        
        % End of training period (in days)
        fprintf(fileID,'\n');     
        incTest=0;
        isCorrect = false;
        while ~isCorrect
            
            incTest=incTest+1;
            if incTest > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            
            fprintf(fileID,'     End training [days]: \n');
            
            if misc.internalVars.BatchMode.isBatchMode
                endTraining = eval(char(misc.internalVars.BatchMode.Answers{misc.internalVars.BatchMode.AnswerIndex}));
                fprintf(fileID,'     %s\n', num2str(endTraining));
            else
                endTraining=input('     choice >> ');
            end
            
            if isempty(endTraining)
                continue
            else
                if ischar(endTraining)
                    fprintf(fileID,'\n');
                    fprintf(fileID,'     wrong input -> not an digit \n');
                    fprintf(fileID,'\n');
                    continue
                elseif length(endTraining) > 1
                    fprintf(fileID,'\n');
                    fprintf(fileID,['     wrong input -> ', ...
                        ' should be single value \n']);
                    fprintf(fileID,'\n');
                    continue
                elseif endTraining <= startTraining
                    fprintf(fileID,'\n');
                    fprintf(fileID,['     wrong input -> ', ...
                        'should be greater '...
                        'than start of training period.\n']);
                    fprintf(fileID,'\n');
                    continue
                else
                    misc.internalVars.BatchMode.AnswerIndex=misc.internalVars.BatchMode.AnswerIndex+1;
                    isCorrect = true;
                end
            end
        end
        
        break
        
    elseif ischar(user_inputs.inp_1) && strcmpi(user_inputs.inp_1, 'R') ...
            && length(user_inputs.inp_1) ==1
        misc.internalVars.BatchMode.AnswerIndex=misc.internalVars.BatchMode.AnswerIndex+1;
        return
        
    else
        fprintf(fileID, '\n');
        fprintf(fileID,'     Wrong input.\n');
        fprintf(fileID, '\n');
        continue
    end
    
    
end

% Record training period
trainingPeriod = [startTraining, endTraining];
misc.options.trainingPeriod = trainingPeriod;

%% Display the new training period
fprintf(fileID,'\n');
fprintf(fileID,['     New training period: from ' ...
    num2str(misc.options.trainingPeriod(1)) ' to ' ...
    num2str(misc.options.trainingPeriod(2)) ' days.\n']);
fprintf(fileID,'\n');

%% Save project with updated values
%saveProject(data, model, estimation, misc, 'FilePath', FilePath)

%--------------------END CODE ------------------------
end
