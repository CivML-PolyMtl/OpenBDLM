function [model, misc]= modifyInitialHiddenStates(data, model, estimation, misc, varargin)
%MODIFYINITIALHIDDENSTATES Request user to modify initial hidden states
%
%   SYNOPSIS:
%     [model, misc] = MODIFYINITIALHIDDENSTATES(data, model, estimation, misc, varargin)
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
%                         Modifications are saved directly in project file
%                         located in FilePath/PROJ_'misc.ProjectName'.mat file
%                         default: '.'  (current folder)
%
%   OUTPUT:
%      model            - structure (required)
%                          see documentation for details about the fields of
%                          model
%
%      misc             - structure (required)
%                         see documentation for details about the fields of
%                         misc
%
%
%      Updated project file with new initial hidden states values
%
%   DESCRIPTION:
%      MODIFYINITIALHIDDENSTATES modifies initial hidden states values
%      MODIFYINITIALHIDDENSTATES modifies the mean and variance of
%      initial hidden state values
%
%   EXAMPLES:
%      [model, misc] = MODIFYINITIALHIDDENSTATES(data, model, estimation, misc)
%      [model, misc] = MODIFYINITIALHIDDENSTATES(data, model, estimation, misc, 'FilePath', 'saved_projects')
%
%   EXTERNAL FUNCTIONS CALLED:
%      saveProject
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
%       June 11, 2018
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

MaxFailAttempts=4;

% Set fileID for logfile
if misc.internalVars.isQuiet
    % output message in logfile
    fileID=fopen(misc.internalVars.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end

%% Display current values
fprintf(fileID, ['     #     |state variable    |observation    '...
    '   |E[x_0]    |var[x_0] \n']);

format = ('     %-5s %-18s %-18s %-10s %-10s\n');

for i=1:length(model.initX{1})
    
    fprintf(fileID, format, ...
        num2str(i, '%03d' ), ...
        model.hidden_states_names{1}{i,1}, ...
        model.hidden_states_names{1}{i,3}, ...
        num2str(model.initX{1}(i)), ...
        num2str(model.initV{1}(i,i)));
end

incTest=0;
isCorrectAnswer =  false;
while ~isCorrectAnswer
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    fprintf(fileID,'\n');
    fprintf(fileID,'     1   ->  Modify a initial value\n');
    fprintf(fileID,['     2   ->  Export initial values ', ...
        ' in config file format\n']);
    fprintf(fileID,'\n');
    fprintf(fileID,'     Type R to return to the previous menu\n');
    fprintf(fileID,'\n');
    
    if misc.internalVars.BatchMode.isBatchMode
        user_inputs.inp_2 =  ...
            eval(char(misc.internalVars.BatchMode.Answers{...
            misc.internalVars.BatchMode.AnswerIndex}));
        user_inputs.inp_2 = num2str(user_inputs.inp_2);
        
        if ischar(user_inputs.inp_2)
            fprintf(fileID, '     %s  \n', user_inputs.inp_2);
        else
            fprintf(fileID, '     %s  \n', num2str(user_inputs.inp_2));
        end
        
    else
        user_inputs.inp_2 =  input('     choice >> ', 's');
    end
    
    % Remove space and simple/double quotes
    user_inputs.inp_2=strrep(user_inputs.inp_2,'''',''); 
    user_inputs.inp_2=strrep(user_inputs.inp_2,'"','' ); 
    user_inputs.inp_2=strrep(user_inputs.inp_2, ' ','' ); 
    
    
    if ischar(user_inputs.inp_2) && length(user_inputs.inp_2) == 1 && ...
            strcmpi(user_inputs.inp_2, 'R')
        
        misc.internalVars.BatchMode.AnswerIndex= ...
            misc.internalVars.BatchMode.AnswerIndex+1;
        return
        
    elseif round(str2double(user_inputs.inp_2)) == 1
        misc.internalVars.BatchMode.AnswerIndex = ...
            misc.internalVars.BatchMode.AnswerIndex+1;
        
        %% Providing index of the variable to modify
        incTest_2=0;
        isCorrect = false;
        while ~isCorrect
            incTest_2=incTest_2+1;
            if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            
            fprintf(fileID,'     Modify variable #\n');
            
            if misc.internalVars.BatchMode.isBatchMode
                user_inputs.inp_3 = ...
                    eval(char(misc.internalVars.BatchMode.Answers{...
                    misc.internalVars.BatchMode.AnswerIndex}));
                fprintf(fileID, '     %s\n', num2str(user_inputs.inp_3));
            else
                user_inputs.inp_3 =  input('     choice >> ');
            end
            
            if  ~isempty(user_inputs.inp_3) && ...
                    rem(user_inputs.inp_3,1) == 0 && ...
                    (user_inputs.inp_3 > 0) && ...
                    user_inputs.inp_3 <= length(model.initX{1})
                
                isCorrect = true;
                misc.internalVars.BatchMode.AnswerIndex = ...
                    misc.internalVars.BatchMode.AnswerIndex +1;
            else
                fprintf(fileID,'     Wrong input.\n');
                continue
            end
            
        end
        
        %% Providing new expected value
        incTest_2=0;
        isCorrect = false;
        while ~isCorrect
            
            incTest_2=incTest_2+1;
            if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            
            fprintf(fileID,'     New E[x_0] : \n');
            
            if misc.internalVars.BatchMode.isBatchMode
                user_inputs.inp_4 = ...
                    eval(char(misc.internalVars.BatchMode.Answers{...
                    misc.internalVars.BatchMode.AnswerIndex}));
                fprintf(fileID, '     %s\n', num2str(user_inputs.inp_4));
            else
                user_inputs.inp_4 =  input('     choice >> ');
            end
            
            if  ~isempty(user_inputs.inp_4) && ~ischar(user_inputs.inp_4)
                
                isCorrect = true;
                misc.internalVars.BatchMode.AnswerIndex = ...
                    misc.internalVars.BatchMode.AnswerIndex +1;
            else
                fprintf(fileID,'     Wrong input.\n');
                continue
            end
            
        end
        
        %% Providing new variance value
        incTest_2=0;
        isCorrect = false;
        while ~isCorrect
            
            incTest_2=incTest_2+1;
            if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            
            fprintf(fileID,'     New var[x_0] : \n');
            
            if misc.internalVars.BatchMode.isBatchMode
                user_inputs.inp_5 = ...
                    eval(char(misc.internalVars.BatchMode.Answers{...
                    misc.internalVars.BatchMode.AnswerIndex}));
                fprintf(fileID, '     %s', user_inputs.inp_5);
            else
                user_inputs.inp_5 =  input('     choice >> ');
            end
            
            if  ~isempty(user_inputs.inp_5) && ...
                    ~ischar(user_inputs.inp_5) && user_inputs.inp_5 >= 0
                
                isCorrect = true;
                misc.internalVars.BatchMode.AnswerIndex = ...
                    misc.internalVars.BatchMode.AnswerIndex+1;
            else
                fprintf(fileID,'     Wrong input.\n');
                continue
            end
            
        end
        
        % Modify values
        for i=1:model.nb_class
            model.initX{i}(user_inputs.inp_3)=user_inputs.inp_4;
            D=diag(model.initV{1});
            D(user_inputs.inp_3)=user_inputs.inp_5;
            model.initV{i}=diag(D);
        end
        
        return
        
    elseif round(str2double(user_inputs.inp_2)) == 2
        
        %% Display in configuration file format
        fprintf(fileID, '\n');
        fprintf(fileID, repmat('%s',1,75),repmat('%',1,75));
        fprintf(fileID, '\n');
        fprintf(fileID,'%%%% E - Initial states values \n');
        fprintf(fileID, repmat('%s',1,75),repmat('%',1,75));
        fprintf(fileID, '\n');
        
        for m=1:model.nb_class
            % Expected initial hidden states
            fprintf(fileID, ['%% Initial hidden states ', ...
                'mean for model %s:\n'], num2str(m));
            fprintf(fileID, 'model.initX{ %s }=[', num2str(m) );
            for i=1:size(model.initX{m},1)
                fprintf(fileID, '\t%-6.3G', model.initX{m}(i,:));
            end
            fprintf(fileID, ']'';\n');
            fprintf(fileID, '\n');
            
            % Initial hidden states variance (ignore covariance)
            fprintf(fileID, ['%% Initial hidden ', ...
                'states variance for model %s: \n'], num2str(m));
            
            diagV=diag(model.initV{m});
            
            fprintf(fileID, 'model.initV{ %s }=diag([ ', num2str(m) );
            for i=1:length(diagV)
                fprintf(fileID, '\t%-6.3G', diagV(i,:));
            end
            fprintf(fileID, ' ]);\n');
            fprintf(fileID, '\n');
            fprintf(fileID, '%% Initial probability for model %s\n', ...
                num2str(m));
            for i=1:size(model.initS{m},1)
                fprintf(fileID, 'model.initS{%d}=[%-6.3G];\n', ...
                    m, model.initS{m});
            end
            fprintf(fileID, '\n');
        end
        
        misc.internalVars.BatchMode.AnswerIndex= ...
            misc.internalVars.BatchMode.AnswerIndex+1;
        return
        
    else
        fprintf(fileID,'     Wrong input.\n');
        continue
    end
    
end
%--------------------END CODE ------------------------
end
