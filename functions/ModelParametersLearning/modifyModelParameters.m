function [model, misc] = modifyModelParameters(data, model, estimation, misc, varargin)
%MODIFYMODELPARAMETERS Request user to modify model parameters values
%
%   SYNOPSIS:
%     [model, misc] = MODIFYMODELPARAMETERS(data, model, estimation, misc, varargin)
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
%      Updated project file with new model parameters values
%
%   DESCRIPTION:
%      MODIFYMODELPARAMETERS modifies model parameters (values, domain)
%
%   EXAMPLES:
%      [model, misc] = MODIFYMODELPARAMETERS(data, model, estimation, misc)
%      [model, misc] = MODIFYMODELPARAMETERS(data, model, estimation, misc, 'FilePath', 'saved_projects')
%
%   EXTERNAL FUNCTIONS CALLED:
%      saveProject
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also SAVEPROJECT

%   AUTHORS:
%        Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
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
%       July 31, 2018

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

%% Read model parameter properties
idx_pvalues=size(model.param_properties,2)-1;
idx_pref= size(model.param_properties,2);

[arrayOut]=...
    readParameterProperties(model.param_properties, ...
    [idx_pvalues, idx_pref]);

parameter= arrayOut(:,1);
p_ref = arrayOut(:,2);

%% Display current values
disp(['     #   |Parameter    |Component |Model # |Observation '...
    '|Current value |Bounds min/max |Prior type' ...
    ' |Mean prior |Sdev prior |Constraint'])
for i=1:length(parameter)
    i_ref=p_ref(i);
    if i~=i_ref
        contraint=['@' num2str(i_ref)];
    else
        contraint='';
    end
    
    format = ['     %-4s %-13s %-10s %-8s ' ...
        '%-12s %-14s %-15s %-11s %-11s %-11s %-10s\n'];
    
    fprintf(format, ...        
        num2str(i, '%03d' ), ...
        model.param_properties{i,1}, ...
        model.param_properties{i,2}, ...
        model.param_properties{i,3}, ...
        model.param_properties{i,4}, ...
        num2str(parameter(i_ref)), ...
        [num2str(model.param_properties{i,5}(1)), '/', ...
        num2str(model.param_properties{i,5}(2)) ], ...
        model.param_properties{i_ref,6}, ...
        num2str(model.param_properties{i_ref,7}), ...
        num2str(model.param_properties{i_ref,8}), ...
        contraint ...
        )
end

incTest=0;
isCorrectAnswer = false;
while ~isCorrectAnswer
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    disp(' ')
    disp('     1   ->  Modify a parameter value')
    disp('     2   ->  Modify a parameter prior')
    disp('     3   ->  Constrain a parameter to another')
    disp(['     4   ->  Export current  ' ...
        'parameter properties in config file format'])
    disp(' ')
    disp('     Type ''R'' to return to the previous menu')
    disp(' ')
    
    if misc.BatchMode.isBatchMode
        user_inputs.inp_1 = ...
            eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
        disp(user_inputs.inp_1)
    else
        user_inputs.inp_1 =  input('     choice >> ');
    end
    
    if ischar(user_inputs.inp_1) && length(user_inputs.inp_1) == 1 && ...
            strcmpi(user_inputs.inp_1, 'R')
        
        misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
        return
        
    elseif user_inputs.inp_1 == 1
        
        misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
        
        %% Provide the index of the parameter to modify              
        incTest_2=0;
        isCorrect = false;
        while ~isCorrect
            
            incTest_2=incTest_2+1;
            if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            
            
            disp('     Modify parameter # ')
            if misc.BatchMode.isBatchMode
                user_inputs.inp_2 = ...
                    eval(char(misc.BatchMode.Answers{...
                    misc.BatchMode.AnswerIndex}));
                disp(user_inputs.inp_2)
            else
                user_inputs.inp_2 =  input('     choice >> ');
            end
            
            if ~isempty(user_inputs.inp_2) && ...
                    rem(user_inputs.inp_2,1) == 0 && ...
                    (user_inputs.inp_2 > 0) && ...
                    user_inputs.inp_2 <= length(model.param_properties)
                misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
                isCorrect = true;
            else
                disp('     Wrong input.')
                continue
            end
            
        end
        
        %misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
        
        %% Provide the new value of the parameter
        incTest_2=0;
        isCorrect = false;
        while ~isCorrect
                        
            incTest_2=incTest_2+1;
            if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            
            
            disp('     New value :')
            if misc.BatchMode.isBatchMode
                user_inputs.inp_3 = ...
                    eval(char(misc.BatchMode.Answers{...
                    misc.BatchMode.AnswerIndex}));
                disp(user_inputs.inp_3)
            else
                user_inputs.inp_3 =  input('     choice >> ');
            end
            
            if ~isempty(user_inputs.inp_3) && ...
                    isnumeric(user_inputs.inp_3) && ...
                    length(user_inputs.inp_3) ==1
                misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
                isCorrect = true;
            else
                disp('     Wrong input.')
                continue
            end
            
        end
        
        %% Provide the new model parameter constraints 
        incTest_2=0;
        isCorrect = false;
        while ~isCorrect
            
            incTest_2=incTest_2+1;
            if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            
            disp('     New bounds : ')
            if misc.BatchMode.isBatchMode
                user_inputs.inp_4 = ...
                    eval(char(misc.BatchMode.Answers{...
                    misc.BatchMode.AnswerIndex}));
                
                disp(['     [' sprintf('%d,', ...
                    user_inputs.inp_4(1:end-1) ) ...
                    num2str(user_inputs.inp_4(end)) ']'])
                
            else
                user_inputs.inp_4 =  input('     choice >> ');
            end
            
            if ~isempty(user_inputs.inp_4) && ...
                    isnumeric(user_inputs.inp_4) && ...
                    length(user_inputs.inp_4) ==2
                misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
                isCorrect = true;
            else
                disp('     Wrong input.')
                continue
            end            
        end
        
        % Change parameter values
        if ~isempty(user_inputs.inp_3)
            parameter(user_inputs.inp_2)=user_inputs.inp_3;
        end
        if ~isempty(user_inputs.inp_4)
            model.param_properties{user_inputs.inp_2,5}=user_inputs.inp_4;
        end
        disp(' ')
        
        isCorrectAnswer = true;
        
    elseif user_inputs.inp_1 ==2
        
        %% Provide the index of the parameter for which to modify the prior
        
        misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
        
        incTest_2=0;
        isCorrect = false;
        while ~isCorrect
            
            incTest_2=incTest_2+1;
            if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            
            
            disp('     Modify prior for parameter # ')
            if misc.BatchMode.isBatchMode
                user_inputs.inp_2 = ...
                    eval(char(misc.BatchMode.Answers{...
                    misc.BatchMode.AnswerIndex}));
                disp(user_inputs.inp_2)
            else
                user_inputs.inp_2 =  input('     choice >> ');
            end
            
            if ~ischar(user_inputs.inp_2) && ...
                    ~isempty(user_inputs.inp_2) && ...
                    rem(user_inputs.inp_2,1) == 0 && ...
                    (user_inputs.inp_2 > 0) && ...
                    user_inputs.inp_2 <= length(model.param_properties)
                misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
                isCorrect = true;
            else
                disp('     Wrong input.')
                continue
            end
            
        end
        
        %% Provide the type of prior
        incTest_2=0;
        isCorrect = false;
        while ~isCorrect
            
            incTest_2=incTest_2+1;
            if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            
            disp('     New prior type :')
            if misc.BatchMode.isBatchMode
                user_inputs.inp_3 = ...
                    eval(char(misc.BatchMode.Answers{...
                    misc.BatchMode.AnswerIndex}));
                disp(user_inputs.inp_3)
            else
                user_inputs.inp_3 =  input('     choice >> ');
            end
            
            if ~isempty(user_inputs.inp_3) && ...
                    ischar(user_inputs.inp_3)
                misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
                isCorrect = true;
            else
                disp('     Wrong input.')
                continue
            end
            
        end
        
        %% Provide the new mean of the prior
        incTest_2=0;
        isCorrect = false;
        while ~isCorrect
            
            incTest_2=incTest_2+1;
            if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            
            disp('     New prior mean :')
            if misc.BatchMode.isBatchMode
                user_inputs.inp_4 = ...
                    eval(char(misc.BatchMode.Answers{...
                    misc.BatchMode.AnswerIndex}));
                disp(user_inputs.inp_4)
            else
                user_inputs.inp_4 =  input('     choice >> ');
            end
            
            if ~isempty(user_inputs.inp_4) && ...
                    isnumeric(user_inputs.inp_4) && ...
                    length(user_inputs.inp_4) ==1
                misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
                isCorrect = true;
            else
                disp('     Wrong input.')
                continue
            end
            
        end
        
        %% Provide the new standard deviation
        incTest_2=0;
        isCorrect = false;
        while ~isCorrect
            
            incTest_2=incTest_2+1;
            if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            
            disp('     New prior standard deviation :')
            if misc.BatchMode.isBatchMode
                user_inputs.inp_5 = ...
                    eval(char(misc.BatchMode.Answers{...
                    misc.BatchMode.AnswerIndex}));
                disp(user_inputs.inp_5)
            else
                user_inputs.inp_5 =  input('     choice >> ');
            end
            
            if ~isempty(user_inputs.inp_5) && ...
                    isnumeric(user_inputs.inp_5) && ...
                    length(user_inputs.inp_5) ==1
                misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
                isCorrect = true;
            else
                disp('     Wrong input.')
                continue
            end
            
        end
        
        % Change prior values
        if ~isempty(user_inputs.inp_3)
            model.param_properties{user_inputs.inp_2,6}=user_inputs.inp_3;
        end
        if ~isempty(user_inputs.inp_4)
            model.param_properties{user_inputs.inp_2,7}=user_inputs.inp_4;
        end
        if ~isempty(user_inputs.inp_5)
            model.param_properties{user_inputs.inp_2,8}=user_inputs.inp_5;
        end
        
        disp(' ')
                
        isCorrectAnswer = true;
        
        
    elseif user_inputs.inp_1 ==3
        %% Provide the index of the parameter(s) to constrain
        misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
        incTest_2=0;
        isCorrect = false;
        while ~isCorrect
            
            incTest_2=incTest_2+1;
            if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            
            disp('     Constrain parameter # ')
            if misc.BatchMode.isBatchMode
                user_inputs.inp_2 = ...
                    eval(char(misc.BatchMode.Answers{...
                    misc.BatchMode.AnswerIndex}));
                disp(user_inputs.inp_2)
            else
                user_inputs.inp_2 =  input('     choice >> ');
            end
            
            if ~isempty(user_inputs.inp_2) && ...
                    rem(user_inputs.inp_2,1) == 0 && ...
                    (user_inputs.inp_2 > 0) && ...
                    user_inputs.inp_2 <= length(model.param_properties)
                misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
                isCorrect = true;
            else
                disp('     Wrong input.')
                continue
            end
            
        end
        
        %misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
        
        incTest_2=0;
        isCorrect = false;
        while ~isCorrect
            
            incTest_2=incTest_2+1;
            if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            
            disp('     to parameter # ')
            if misc.BatchMode.isBatchMode
                user_inputs.inp_3 = ...
                    eval(char(misc.BatchMode.Answers{ ...
                    misc.BatchMode.AnswerIndex}));
                disp(user_inputs.inp_3)
            else
                user_inputs.inp_3 =  input('     choice >> ');
            end
            
            if ~isempty(user_inputs.inp_3) && ...
                    all(rem(user_inputs.inp_3,1)) == 0 && ...
                    all(user_inputs.inp_3 > 0) && ...
                    all( user_inputs.inp_3 <= length(model.param_properties))
                misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
                isCorrect = true;
            else
                disp('     Wrong input.')
                continue
            end
            
        end
        
        % Change values
        p_ref(user_inputs.inp_2)=user_inputs.inp_3;
        model.param_properties{user_inputs.inp_2,5}=[nan,nan];
        disp(' ')       
        
        isCorrectAnswer = true;
        
    elseif user_inputs.inp_1 == 4
        %% Display parameter properties in configuration file format
        fprintf(repmat('%s',1,75),repmat('%',1,75));
        fprintf('\n');
        fprintf('%%%% D - Model parameters \n');
        fprintf(repmat('%s',1,75),repmat('%',1,75));
        fprintf('\n');
        fprintf('model.param_properties={\n');
        fprintf(['    %% #1             #2         #3       #4  ', ...
            '    #5                  #6          #7      #8      #9    ', ...
            '          #10', '\n']);
        fprintf(['    %% Param name     Block name Model ', ...
            '   Obs     Bound               Prior       Mean    Std   ', ...
            '  Values          Ref', '\n']);
        for i=1:size(model.param_properties,1)
            space=repmat(' ',1,10-length(model.param_properties{i,1}));
            fprintf(['\t''%-s''' space ',\t ', ...
                '''%-s'',\t\t''''%-s'',\t ''%-s'',\t [ %-5G, %-5G],\t ', ...
                '''%-s'',\t %-2.2G,\t %-2.2G,\t %-8.5G, ' ' ', ...
                '\t %-2.3G %%#%d' '\n'], model.param_properties{i,:},i);
        end
        fprintf('};\n');
        fprintf('\n');
        
        misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
        isCorrectAnswer = true;
        
    else
        disp('     Wrong input.')
        continue
    end
end

%% Write parameter properties
[model.param_properties]= ...
    writeParameterProperties(model.param_properties, ...
    [parameter, p_ref], size(model.param_properties,2)-1);

%% Save project
saveProject(data, model, estimation, misc, 'FilePath', FilePath)

%--------------------END CODE ------------------------
end
