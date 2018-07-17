function [model] = modifyModelParameters(data, model, estimation, misc, varargin)
%MODIFYMODELPARAMETERS Request user to modify model parameters values
%
%   SYNOPSIS:
%     [model] = MODIFYMODELPARAMETERS(data, model, estimation, misc, varargin)
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
%      Updated project file with new model parameters values
%
%   DESCRIPTION:
%      MODIFYMODELPARAMETERS modifies model parameters (values, domain)
%
%   EXAMPLES:
%      [model] = MODIFYMODELPARAMETERS(data, model, estimation, misc)
%      [model] = MODIFYMODELPARAMETERS(data, model, estimation, misc, 'FilePath', 'saved_projects')
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
%       July 10, 2018

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

% define global variable for user's answers from input file
global isAnswersFromFile AnswersFromFile AnswersIndex


%% Display current values
disp(['#   |Parameter    |Component |Model # |Observation '...
    '        |Current value |Bounds min/max |Prior type' ...
    ' |Mean prior |Sdev prior |Constraint'])
for i=1:length(model.parameter)
    i_ref=model.p_ref(i);
    if i~=i_ref
        contraint=['@' num2str(i_ref)];
    else
        contraint='';
    end

    format = '%-4s %-13s %-10s %-8s %-20s %-14s %-15s %-11s %-11s %-11s %-10s\n';
        
    fprintf(format, ...
       ['0',num2str(i)], ...
       model.param_properties{i,1}, ...
       model.param_properties{i,2}, ...
       model.param_properties{i,3}, ...
       model.param_properties{i,4}, ...
       num2str(model.parameter(i_ref)), ...
       [num2str(model.param_properties{i,5}(1)), '/', num2str(model.param_properties{i,5}(2)) ], ...
       model.param_properties{i_ref,6}, ...
       num2str(model.param_properties{i_ref,7}), ...
       num2str(model.param_properties{i_ref,8}), ...
       contraint ...
       )    
end



isCorrectAnswer = false;
while ~isCorrectAnswer
    
    disp(' ')
    disp('     1   ->  Modify a parameter value')
    disp('     2   ->  Modify a parameter prior')
    disp('     3   ->  Constrain a parameter to another')
    disp(['     4   ->  Export current  ' ...
        'parameter properties in config file format'])
    disp(' ')
    disp('     5   ->  Return to menu  ')
    disp(' ')
    
    if isAnswersFromFile
        user_inputs.inp_1 = ...
            eval(char(AnswersFromFile{1}(AnswersIndex)));
        disp(user_inputs.inp_1)
    else
        user_inputs.inp_1 =  input('     choice >> ');
    end
    
    
    if user_inputs.inp_1 == 1
        
        AnswersIndex=AnswersIndex+1;
        
        isCorrect = false;
        while ~isCorrect
            disp('     Modify parameter # ')
            if isAnswersFromFile
                user_inputs.inp_2 = ...
                    eval(char(AnswersFromFile{1}(AnswersIndex)));
                disp(user_inputs.inp_2)
            else
                user_inputs.inp_2 =  input('     choice >> ');
            end
            
            if rem(user_inputs.inp_2,1) == 0 && (user_inputs.inp_2 > 0) && ...
                    user_inputs.inp_2 <= length(model.param_properties)
                AnswersIndex=AnswersIndex+1;
                isCorrect = true;
            else
                disp('    Wrong input.')
                continue
            end
            
        end
        
        isCorrect = false;
        while ~isCorrect
            disp('     New value :')
            if isAnswersFromFile
                user_inputs.inp_3 = ...
                    eval(char(AnswersFromFile{1}(AnswersIndex)));
                disp(user_inputs.inp_3)
            else
                user_inputs.inp_3 =  input('     choice >> ');
            end
            
            if isnumeric(user_inputs.inp_3) && length(user_inputs.inp_3) ==1
                AnswersIndex=AnswersIndex+1;
                isCorrect = true;
            else
                disp('    Wrong input.')
                continue
            end
            
        end
        
        isCorrect = false;
        while ~isCorrect
            disp('     New bounds : ')
            if isAnswersFromFile
                user_inputs.inp_4 = ...
                    eval(char(AnswersFromFile{1}(AnswersIndex)));
                
                disp(['     [' sprintf('%d,', user_inputs.inp_4(1:end-1) ) ...
                    num2str(user_inputs.inp_4(end)) ']'])
                
            else
                user_inputs.inp_4 =  input('     choice >> ');
            end
            
            if isnumeric(user_inputs.inp_4) && length(user_inputs.inp_4) ==2
                AnswersIndex=AnswersIndex+1;
                isCorrect = true;
            else
                disp('    Wrong input.')
                continue
            end
            
        end
        
        % Change parameter values
        if ~isempty(user_inputs.inp_3)
            model.parameter(user_inputs.inp_2)=user_inputs.inp_3;
        end
        if ~isempty(user_inputs.inp_4)
            model.param_properties{user_inputs.inp_2,5}=user_inputs.inp_4;
        end
        disp(' ')
        % Save project
        saveProject(data, model, estimation, misc, 'FilePath', FilePath)
        
        isCorrectAnswer = true;
    
        
    elseif user_inputs.inp_1 ==2            

        AnswersIndex=AnswersIndex+1;
        
        isCorrect = false;
        while ~isCorrect
            disp('     Modify prior for parameter # ')
            if isAnswersFromFile
                user_inputs.inp_2 = ...
                    eval(char(AnswersFromFile{1}(AnswersIndex)));
                disp(user_inputs.inp_2)
            else
                user_inputs.inp_2 =  input('     choice >> ');
            end
            
            if rem(user_inputs.inp_2,1) == 0 && (user_inputs.inp_2 > 0) && ...
                    user_inputs.inp_2 <= length(model.param_properties)
                AnswersIndex=AnswersIndex+1;
                isCorrect = true;
            else
                disp('    Wrong input.')
                continue
            end
            
        end
        
        isCorrect = false;
        while ~isCorrect
            disp('     New prior type :')
            if isAnswersFromFile
                user_inputs.inp_3 = ...
                    eval(char(AnswersFromFile{1}(AnswersIndex)));
                disp(user_inputs.inp_3)
            else
                user_inputs.inp_3 =  input('     choice >> ');
            end
            
            if ischar(user_inputs.inp_3)
                AnswersIndex=AnswersIndex+1;
                isCorrect = true;
            else
                disp('    Wrong input.')
                continue
            end
            
        end
        
                isCorrect = false;
        while ~isCorrect
            disp('     New prior mean :')
            if isAnswersFromFile
                user_inputs.inp_4 = ...
                    eval(char(AnswersFromFile{1}(AnswersIndex)));
                disp(user_inputs.inp_4)
            else
                user_inputs.inp_4 =  input('     choice >> ');
            end
            
            if isnumeric(user_inputs.inp_4) && length(user_inputs.inp_4) ==1
                AnswersIndex=AnswersIndex+1;
                isCorrect = true;
            else
                disp('    Wrong input.')
                continue
            end
            
        end
        
        
        isCorrect = false;
        while ~isCorrect
            disp('     New prior standard deviation :')
            if isAnswersFromFile
                user_inputs.inp_5 = ...
                    eval(char(AnswersFromFile{1}(AnswersIndex)));
                disp(user_inputs.inp_5)
            else
                user_inputs.inp_5 =  input('     choice >> ');
            end
            
            if isnumeric(user_inputs.inp_5) && length(user_inputs.inp_5) ==1
                AnswersIndex=AnswersIndex+1;
                isCorrect = true;
            else
                disp('    Wrong input.')
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
        % Save project
        saveProject(data, model, estimation, misc, 'FilePath', FilePath)
        
        isCorrectAnswer = true;
        
        
        

    elseif user_inputs.inp_1 ==3
        
        AnswersIndex=AnswersIndex+1;
        isCorrect = false;
        while ~isCorrect
            disp('     Constrain parameter # ')
            if isAnswersFromFile
                user_inputs.inp_2 = ...
                    eval(char(AnswersFromFile{1}(AnswersIndex)));
                disp(user_inputs.inp_2)
            else
                user_inputs.inp_2 =  input('     choice >> ');
            end
            
            if rem(user_inputs.inp_2,1) == 0 && (user_inputs.inp_2 > 0) && ...
                    user_inputs.inp_2 <= length(model.param_properties)
                AnswersIndex=AnswersIndex+1;
                isCorrect = true;
            else
                disp('    Wrong input.')
                continue
            end
            
        end
        
        isCorrect = false;
        while ~isCorrect
            disp('     to parameter # ')
            if isAnswersFromFile
                user_inputs.inp_3 = ...
                    eval(char(AnswersFromFile{1}(AnswersIndex)));
                disp(user_inputs.inp_3)
            else
                user_inputs.inp_3 =  input('     choice >> ');
            end
            
            if all(rem(user_inputs.inp_3,1)) == 0 && all(user_inputs.inp_3 > 0) && ...
                    all( user_inputs.inp_3 <= length(model.param_properties))
                AnswersIndex=AnswersIndex+1;
                isCorrect = true;
            else
                disp('    Wrong input.')
                continue
            end
            
        end
        
        % Change values
        model.p_ref(user_inputs.inp_2)=user_inputs.inp_3;
        model.param_properties{user_inputs.inp_2,5}=[nan,nan];
        disp(' ')
        % Save project
        saveProject(data, model, estimation, misc, 'FilePath', FilePath)
        
        
        isCorrectAnswer = true;
        
    elseif user_inputs.inp_1 ==4
        disp(' ')
        disp('model.param_properties={')
        for i=1:size(model.param_properties,1)
            space=repmat(' ',1,8-length(model.param_properties{i,1}));
            disp(sprintf(['\t''%-s''' space ',\t ''%-s'',\t  '...
                ' ''%-s'',\t ''%-s'',\t '...
                '[ %-5G, %-5G],\t ''%-s'',\t %-5G ,\t %-5G   %%#%d'], ...
                model.param_properties{i,:},i));
        end
        disp('};')
        disp(' ')
        disp('model.parameter=[')
        for i=1:size(model.parameter,1)
            disp(sprintf('%-8.5G \t %%#%d \t%%%-s',  ...
                model.parameter(i),i,model.param_properties{i,1}));
        end
        disp(']; ')
        disp(' ')
        disp(['model.p_ref=[' num2str(model.p_ref) '];'])
        disp(' ')
        
        isCorrectAnswer = true;
        
    elseif user_inputs.inp_1 ==5
        AnswersIndex=AnswersIndex+1;
        return
    else
        disp('     Wrong input.')
        continue
    end
end
%--------------------END CODE ------------------------
end
