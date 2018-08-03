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
%   See also BDLM, SAVEPROJECT

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
%       July 20, 2018

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


%% Display current values
disp(['     #  |state variable    |observation    '...
    '         |E[x_0]         |var[x_0] '])
for i=1:length(model.initX{1})
    disp([repmat('     0',1,2-length(num2str(i))) num2str(i) '  '  ...
        model.hidden_states_names{1}{i,1} ...
        repmat(' ',1,19-length(model.hidden_states_names{1}{i,1})) ...
        model.hidden_states_names{1}{i,3} ...
        repmat(' ',1,25-length(model.hidden_states_names{1}{i,3})) ...
        sprintf('%-10.5G',model.initX{1}(i)) ...
        repmat(' ',1,6) sprintf('%-10.5G',model.initV{1}(i,i))])
end

incTest=0;
isCorrectAnswer =  false;
while ~isCorrectAnswer
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    disp(' ')
    disp('     1   ->  Modify a initial value')
    disp('     2   ->  Export initial values in config file format')
    disp(' ')
    disp('     Type ''R'' to return to the previous menu')
    disp(' ')
    
    if misc.BatchMode.isBatchMode
        user_inputs.inp_2 =  ...
            eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
        disp(user_inputs.inp_2)
    else
        user_inputs.inp_2 =  input('     choice >> ');
    end
    
    if ischar(user_inputs.inp_2) && length(user_inputs.inp_2) == 1 && ...
            strcmpi(user_inputs.inp_2, 'R')
        
        misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
        return
        
    elseif user_inputs.inp_2==1
        misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex +1;
        
        incTest_2=0;
        isCorrect = false;
        while ~isCorrect
            incTest_2=incTest_2+1;
            if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            
            disp('     Modify variable # ')
            
            if misc.BatchMode.isBatchMode
                user_inputs.inp_3 = ...
                    eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
                disp(user_inputs.inp_3)
            else
                user_inputs.inp_3 =  input('     choice >> ');
            end
            
            if  ~isempty(user_inputs.inp_3) && ...
                    rem(user_inputs.inp_3,1) == 0 && ...
                    (user_inputs.inp_3 > 0) && ...
                    user_inputs.inp_3 <= length(model.initX{1})
                
                isCorrect = true;
                misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex +1;
            else
                disp('     Wrong input.')
                continue
            end
            
        end
        
        incTest_2=0;
        isCorrect = false;
        while ~isCorrect
            
            incTest_2=incTest_2+1;
            if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            disp('     New E[x_0] : ')
            
            if misc.BatchMode.isBatchMode
                user_inputs.inp_4 = ...
                    eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
                disp(user_inputs.inp_4)
            else
                user_inputs.inp_4 =  input('     choice >> ');
            end
            
            if  ~isempty(user_inputs.inp_4) && ~ischar(user_inputs.inp_4)
                
                isCorrect = true;
                misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex +1;
            else
                disp('     Wrong input.')
                continue
            end
            
        end
        
        incTest_2=0;
        isCorrect = false;
        while ~isCorrect
            
            incTest_2=incTest_2+1;
            if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            
            disp('     New var[x_0] : ')
            
            if misc.BatchMode.isBatchMode
                user_inputs.inp_5 = ...
                    eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
                disp(user_inputs.inp_5)
            else
                user_inputs.inp_5 =  input('     choice >> ');
            end
            
            if  ~isempty(user_inputs.inp_5) && ...
                    ~ischar(user_inputs.inp_5) && user_inputs.inp_5 >= 0
                
                isCorrect = true;
                misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;
            else
                disp('     Wrong input.')
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
        
        % Save project
        disp(' ')
        saveProject(data, model, estimation, misc, 'FilePath', FilePath)
        
        return
        
    elseif user_inputs.inp_2==2
        
        for m=1:model.nb_class
            disp(' ')
            disp(['model.initX{' num2str(m) '}=['])
            for i=1:size(model.initX{m},1)
                disp(sprintf(['\t%-6.3G'], model.initX{m}(i,:)));
            end
            disp('];')
            disp(' ')
            disp(['model.initV{' num2str(m) '}=['])
            for i=1:size(model.initV{m},1)
                disp(sprintf(['\t%-8.3G'], model.initV{m}(i,:)));
            end
            disp('];')
            disp(' ')
            for i=1:size(model.initS{m},1)
                disp(sprintf('model.initS{%d}=[%-6.3G];',  ...
                    m, model.initS{m}));
            end
        end
        
        misc.BatchMode.AnswerIndex=misc.BatchMode.AnswerIndex+1;
        return
        
    else
        disp('     Wrong input.')
        continue
    end
    
end
%--------------------END CODE ------------------------
end
