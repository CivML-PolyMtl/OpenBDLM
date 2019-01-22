function [model, misc]=defineModel(data, misc)
%DEFINEMODEL Request user's input to define model
%
%   SYNOPSIS:
%     [model, misc]=DEFINEMODEL(data, misc)
%
%   INPUT:
%      data                - structure (required)
%                            data contains three fields :
%
%                              'timestamps' is a 1×N cell array
%                              each cell is a M_ix1 real array
%
%                              'values' is a 1×N cell array
%                              each cell is a M_ix1 real array
%
%                              'labels' is a 1×N cell array
%                              each cell is a character array
%
%                    N: number of time series
%                    M_i: number of samples of time series i
%
%      misc                - structure (required)
%                            see documentation for details about the fields
%                            in structure "misc"
%
%   OUTPUT:
%      model               - structure
%                            see documentation for details about the fields
%                            in structure "model"
%
%      misc                - structure (required)
%                            see documentation for details about the fields
%                            in structure "misc"
%
%   DESCRIPTION:
%      DEFINEMODEL requests user's input to define model
%
%   EXAMPLES:
%      [model, misc]=DEFINEMODEL(data, misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   See also MODELCONFIGURATION, CONFIGUREMODELFORDATAREAL, 
%            CONFIGUREMODELFORDATASIMULATION

%   AUTHORS:
%      Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       April 20, 2018
%
%   DATE LAST UPDATE:
%       December 3, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'data', @isstruct );
addRequired(p,'misc', @isstruct );
parse(p,data, misc);

data=p.Results.data;
misc=p.Results.misc;

MaxFailAttempts = 4;

% Set fileID for logfile
if misc.internalVars.isQuiet
    % output message in logfile
    fileID=fopen(misc.internalVars.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end

if ~misc.internalVars.isDataSimulation
    % Validation of structure data
    isValid = verificationDataStructure(data);
    if ~isValid
        disp (' ')
        error('Unable to read the data from the structure.\n');
    end
end

% display loaded data
displayData(data, misc)

% Get number of time series in dataset
numberOfTimeSeries = length(data.labels);

%% Define time series dependencies
if numberOfTimeSeries > 1
    
    ForbiddenIndexes=cell(numberOfTimeSeries,1);
    
    for i=1:numberOfTimeSeries
        ForbiddenIndexes{i} = i;
    end
    
    comp_ic = cell(1,numberOfTimeSeries);
        
    for i=1:numberOfTimeSeries
        
        incTest=0;
        isCorrect=false;
        while ~isCorrect
            
            incTest=incTest+1;
            if incTest > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            fprintf(fileID,'\n');
            fprintf(fileID,['- Identifies dependence between' ...
                ' time series; use [0] to indicate no dependence\n']);
            if misc.internalVars.BatchMode.isBatchMode
                comp_ic{1,i}=eval(char(misc.internalVars.BatchMode.Answers{...
                    misc.internalVars.BatchMode.AnswerIndex}));
                
                fprintf(fileID, ['     [%s] ', ...
                    '\n'], strjoin(cellstr(num2str(comp_ic{1,i}(:))),', '));
                
            else
                comp_ic{1,i}=input(['    time serie #' num2str(i) ...
                    ' depends on time series # >> ']);
            end
            
            if ~isempty(comp_ic{1,i})
                for j=1:length(comp_ic{1,i})
                    try
                        ForbiddenIndexes{comp_ic{1,i}(j)}=  ...
                            [i ForbiddenIndexes{comp_ic{1,i}(j)} ];
                    catch
                    end
                end
            end
            
            if isempty(comp_ic{1,i})
                continue
            elseif ischar(comp_ic{1,i})
                fprintf(fileID,'\n');
                fprintf(fileID,'     wrong input -> should be integers\n');
                fprintf(fileID,'\n');
                continue
            elseif ~isempty(comp_ic{1,i}) && any(rem(comp_ic{1,i},1))
                fprintf(fileID,'\n');
                fprintf(fileID,'     wrong input -> should be integers\n');
                fprintf(fileID,'\n');
                continue
            elseif length(comp_ic{1,i})>numberOfTimeSeries-1
                fprintf(fileID,'\n');
                fprintf(fileID,'     wrong input -> invalid input\n');
                fprintf(fileID,'\n');
                continue
                
            elseif any(ismember(comp_ic{1,i}, ForbiddenIndexes{i})) ...
                    || ~isempty(find(comp_ic{1,i}>numberOfTimeSeries,1))
                fprintf(fileID,'\n');
                fprintf(fileID,['     wrong input -> conflicts in the ' ...
                    'dependency vector.\n']);
                fprintf(fileID,'\n');
                continue
                
            else
                if comp_ic{1,i} == 0
                    comp_ic{1,i}=[];
                end
                
                isCorrect=true;
            end
        end
        misc.internalVars.BatchMode.AnswerIndex = ...
            misc.internalVars.BatchMode.AnswerIndex+1;
    end
else
    comp_ic={[]};
end

%% Get number of model class
fprintf(fileID,'\n');
incTest=0;
isCorrect = false;
while ~isCorrect
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    fprintf(fileID, ['- How many model classes do ' ...
        'you want for each time-series? \n']);
    if misc.internalVars.BatchMode.isBatchMode
        nb_models=eval(char(misc.internalVars.BatchMode.Answers{...
            misc.internalVars.BatchMode.AnswerIndex}));
        fprintf(fileID,'     %s', num2str(nb_models));
    else
        nb_models=input('     choice >> ');
    end
    if isempty(nb_models)
        continue
    elseif length(nb_models) > 1
        fprintf(fileID,'\n');
        fprintf(fileID,'     wrong input -> should be a single integer\n');
        fprintf(fileID,'\n');
        continue
    elseif ischar(nb_models)|| rem(nb_models,1)~=0 || sign(nb_models) == -1
        fprintf(fileID,'\n');
        fprintf(fileID,'     wrong input -> not a positive integer\n');
        fprintf(fileID,'\n');
        continue
    elseif nb_models > 2
        fprintf(fileID,'\n');
        fprintf(fileID,['     wrong input -> more than 2 model classes ' ...
            'is not supported.\n']);
        fprintf(fileID,'\n');
        continue
    else
        isCorrect = true;
    end
end
misc.internalVars.BatchMode.AnswerIndex = ...
    misc.internalVars.BatchMode.AnswerIndex+1;
fprintf(fileID,'\n');
%% Identify model components for each model class and time series
fprintf(fileID,'\n');
fprintf(fileID,['     -------------------------', ...
    '-------------------------------\n']);
fprintf(fileID,'     BDLM Component reference numbers\n');
fprintf(fileID,['     -------------------', ...
    '-------------------------------------\n']);
fprintf(fileID,'     11: Local level \n');
fprintf(fileID,'     12: Local trend \n');
fprintf(fileID,'     13: Local acceleration \n');
fprintf(fileID,'     21: Local level compatible with local trend \n');
fprintf(fileID,['     22: Local level compatible ', ...
    'with local acceleration \n']);
fprintf(fileID,['     23: Local trend compatible ', ...
    'with local acceleration \n']);
fprintf(fileID,'     31: Periodic \n');
fprintf(fileID,'     41: Autoregressive process (AR(1)) \n');
fprintf(fileID,'     51: Kernel regression \n');
fprintf(fileID,'     61: Level Intervention \n');
fprintf(fileID,['     ---------------------------', ...
    '-----------------------------\n']);
fprintf(fileID,'\n');

all_components=[11 12 13 21 22 23 31 41 51 61];
level_components=[11 12 13 21 22 23];

comp=cell(nb_models,numberOfTimeSeries);

for j=1:nb_models
    if nb_models>1
        fprintf(fileID,'\n');
        fprintf(fileID,'- Model class # %s \n', num2str(j));
    end
    for i=1:numberOfTimeSeries
        
        incTest=0;
        isCorrect = false;
        while ~isCorrect
            
            incTest=incTest+1;
            if incTest > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            fprintf(fileID,'\n');
            fprintf(fileID,['- Identify components for ' ...
                'time series #%s; e.g. [11 31 41]\n'], num2str(i));
            if misc.internalVars.BatchMode.isBatchMode
                comp{j}{i}=eval(char(misc.internalVars.BatchMode.Answers{...
                    misc.internalVars.BatchMode.AnswerIndex}));
                
                fprintf(fileID, ['     [%s] ', ...
                    '\n'], strjoin(cellstr(num2str(comp{j}{i}(:))),', '));
                
            else
                comp{j}{i}=input('     choice >> ');
            end
            if isempty(comp{j}{i})
                continue
            elseif ischar(comp{j}{i})
                fprintf(fileID,'\n');
                fprintf(fileID,'     wrong input -> should be integers\n');
                fprintf(fileID,'\n');
                continue
            elseif ~all(ismember(comp{j}{i},all_components))
                fprintf(fileID,'\n');
                fprintf(fileID,['     wrong input -> at ', ...
                    'least one component' ...
                    ' is unknown \n']);
                fprintf(fileID,' ');
                continue
            elseif ~all(ismember(comp{j}{i}(1),level_components))
                fprintf(fileID,'\n');
                fprintf(fileID,['     wrong input -> first ', ...
                    'component should be a' ...
                    ' level component (i.e. either 11 12 13 21 22 23)\n']);
                fprintf(fileID,'\n');
                continue
            elseif length(comp{j}{i}) > 1 && ...
                    any(ismember(comp{j}{i}(2:end),level_components))
                fprintf(fileID,'\n');
                fprintf(fileID,['     wrong input -> ', ...
                    'only the first component' ...
                    ' should be a level component\n']);
                fprintf(fileID,'\n');
                continue
            elseif j == 1 && nb_models>1 && ...
                    any(ismember(comp{j}{i}(1),level_components(1:3)))
                fprintf(fileID,'\n');
                fprintf(fileID,['     wrong input -> the ', ...
                    'first component for' ...
                    ' model class 1 should be a level compatible' ...
                    ' component (i.e. either 21 22 23 )\n']);
                fprintf(fileID,'\n');
                continue
            elseif j == 1 && nb_models == 1 && ...
                    any(ismember(comp{j}{i}(1),level_components(4:6)))
                fprintf(fileID,'\n');
                fprintf(fileID,['     wrong input -> the ', ...
                    'first component for ' ...
                    'model class 1 should not be a level compatible ' ...
                    'component (i.e. only 11 12 13 are supported).\n']);
                fprintf(fileID,'\n');
                continue
            elseif j == 2 && nb_models>1 && comp{1}{i}(1) == 21 && ...
                    comp{j}{i}(1) ~= 12 && comp{j}{i}(1) ~= 21
                fprintf(fileID,'\n');
                fprintf(fileID,['     wrong input -> the ', ...
                    'level component' ...
                    ' for the two model classes are not compatibles']);
                fprintf(fileID,'\n');
                continue
            elseif j == 2 && nb_models>1 && comp{1}{i}(1) == 22 && ...
                    comp{j}{i}(1) ~= 13 && comp{j}{i}(1) ~= 22
                fprintf(fileID,'\n');
                fprintf(fileID,['     wrong input -> the level' ...
                    ' component for the two model classes are not' ...
                    ' compatibles\n']);
                fprintf(fileID,'\n');
                continue
            elseif j == 2 && nb_models>1 && comp{1}{i}(1) == 23 && ...
                    comp{j}{i}(1) ~= 13 && comp{j}{i}(1) ~= 23
                fprintf(fileID,'\n');
                fprintf(fileID,['     wrong input -> the ', ...
                    'level component ' ...
                    'for the two model classes are not compatibles\n']);
                fprintf(fileID,'\n');
                continue
            elseif j>1&& length(comp{j}{i})~=length(comp{j-1}{i})
                fprintf(fileID,'\n');
                fprintf(fileID,['     wrong input -> all model' ...
                    ' classes must have the same number of components\n']);
                fprintf(fileID,'\n');
                continue
            else
                isCorrect=true;
                misc.internalVars.BatchMode.AnswerIndex = ...
                    misc.internalVars.BatchMode.AnswerIndex+1;
            end
        end
    end
end

%% Identify constrained components
const=cell(nb_models,numberOfTimeSeries);
if nb_models>1
    for j=2:nb_models
        %fprintf(fileID,'- Model class # %s\n', num2str(j));
        for i=1:numberOfTimeSeries
            
            incTest=0;
            isCorrect = false;
            while ~isCorrect
                incTest=incTest+1;
                if incTest > MaxFailAttempts
                    error(['Too many failed ', ...
                        'attempts (', num2str(MaxFailAttempts)  ').'])
                end
                fprintf(fileID,'\n');
                fprintf(fileID,['- Identify the shared parameters' ...
                    ' between the components of the model' ...
                    ' classes 1 and 2 for time ', ...
                    ' series #%s ; e.g. [0 1 1]\n'], ...
                    num2str(i));
                if misc.internalVars.BatchMode.isBatchMode
                    const{j}{i}=eval(char(misc.internalVars.BatchMode.Answers{ ...
                        misc.internalVars.BatchMode.AnswerIndex}));
                    
                    fprintf(fileID, ['     [%s] ', ...
                        '\n'], strjoin(cellstr(num2str(const{j}{i}(:))),', '));
                    
                else
                    const{j}{i}=input('     choice >>');
                end
                if isempty(const{j}{i})
                    continue
                elseif length(const{j}{i})~=length(comp{j}{i})
                    fprintf(fileID,'\n');
                    fprintf(fileID,['     wrong input -> the number of ' ...
                        'constraint parameters must be the same ' ...
                        'as the number of components\n']);
                    fprintf(fileID,'\n');
                    continue
                elseif ischar(const{j}{i})
                    fprintf(fileID,'\n');
                    fprintf(fileID,['     wrong input -> ', ...
                        'should be integers\n']);
                    fprintf(fileID,'\n');
                    continue
                elseif ~all(ismember(const{j}{i}, [0,1]))
                    fprintf(fileID,'\n');
                    fprintf(fileID,['     wrong input -> ', ...
                        'should be 0 or 1\n']);
                    fprintf(fileID,'\n');
                    continue
                else
                    isCorrect = true;
                    misc.internalVars.BatchMode.AnswerIndex = ...
                        misc.internalVars.BatchMode.AnswerIndex+1;
                end
            end
        end
    end
end
fprintf(fileID,'\n');


model.nb_class = nb_models;

% Model blocks
for j=1:nb_models
    str_3 = ' '; %strings;
    for i=1:numberOfTimeSeries
        str_1 = sprintf('%d ', comp{j}{i});
        str_2 = strjoin([{'['} str_1 {']'}]);
        str_3 = [str_3 ' ' str_2];
    end
    str_4 = sprintf('model.components.block{%d}={%s};', j, str_3 );
    eval(str_4)
end


% Model constrains
for j=2:nb_models
    str_3 = ''; %strings;
    for i=1:numberOfTimeSeries
        str_1 = sprintf('%d ', const{j}{i});
        str_2 = strjoin([{'['} str_1 {']'}]);
        str_3 = [str_3 ' ' str_2];
    end
    str_4 = sprintf('model.components.const{%d}={%s};', j, str_3 );
    eval(str_4)
end

% Observations interdependencies
str_3 = ''; %strings;
for j=1:numberOfTimeSeries
    str_1 = sprintf('%d ', comp_ic{1,j});
    str_2 = strjoin([{'['} str_1 {']'}]);
    str_3 = [str_3 ' ' str_2];
end
str_4=sprintf('model.components.ic={%s};', str_3);
eval(str_4)

%--------------------END CODE ------------------------
end
