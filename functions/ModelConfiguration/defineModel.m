function [model]=defineModel(data, misc)
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
%
%   DESCRIPTION:
%      DEFINEMODEL requests user to define model
%
%   EXAMPLES:
%      [model, misc]=DEFINEMODEL(data, misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   See also

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
%       April 20, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'data', @isstruct );
addRequired(p,'misc', @isstruct );
parse(p,data, misc);

data=p.Results.data;
misc=p.Results.misc;

if ~misc.isDataSimulation
    % Validation of structure data
    isValid = verificationDataStructure(data);
    if ~isValid
        disp(' ')
        disp('ERROR: Unable to read the data from the structure.')
        disp(' ')
        model = [];
        return
    end
end

% define global variable for user's answers from input file
global isAnswersFromFile AnswersFromFile AnswersIndex

% display loaded data
displayData(data)

% Get number of time series in dataset
numberOfTimeSeries = length(data.labels);

module = 0;
%% Define time series dependencies
if numberOfTimeSeries > 1
    
    ForbiddenIndexes=cell(numberOfTimeSeries,1);
    
    for i=1:numberOfTimeSeries
        ForbiddenIndexes{i} = i;
    end
    
    comp_ic = cell(1,numberOfTimeSeries);
    
    disp(' ')
    module=module+1;
    
    for i=1:numberOfTimeSeries
        isCorrect=false;
        while ~isCorrect
            disp([ num2str(module) '  -  Identifies dependence between' ...
                ' time series; use [0] to indicate no dependence'])
            if isAnswersFromFile
                comp_ic{1,i}=eval(char(AnswersFromFile{1}(AnswersIndex)));
                if length( comp_ic{1,i}(:)) ~=1
                    disp(['     [' sprintf('%d,', comp_ic{1,i}(1:end-1) ) ...
                        num2str(comp_ic{1,i}(end)) ']'])
                else
                    disp(['     [' num2str(comp_ic{1,i}(end)) ']'])
                end
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
                disp(' ')
                disp(['%%%%%%%%%%%%%%%%%%%%%%%%%' ...
                    '> HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%'])
                disp(' ')
                disp([' Mention here whether some time series'...
                    ' depend on other time series.  '])
                disp(' ')
                disp(['%%%%%%%%%%%%%%%%%%%%%%%%%' ...
                    '> HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%'])
                disp(' ')
                continue
            elseif ischar(comp_ic{1,i})
                disp(' ')
                disp('     wrong input -> should be integers')
                disp(' ')
                continue
            elseif ~isempty(comp_ic{1,i}) && any(rem(comp_ic{1,i},1))
                disp(' ')
                disp('     wrong input -> should be integers')
                disp(' ')
                continue
            elseif length(comp_ic{1,i})>numberOfTimeSeries-1
                % || ~isempty(find([comp_ic{1}] >4,1))
                disp(' ')
                disp('     wrong input -> invalid input')
                disp(' ')
                continue
                
            elseif any(ismember(comp_ic{1,i}, ForbiddenIndexes{i})) ...
                    || ~isempty(find(comp_ic{1,i}>numberOfTimeSeries,1))
                disp(' ')
                disp(['     wrong input -> conflicts in the ' ...
                    'dependency vector.'])
                disp(' ')
                continue
                
                
                
            else
                if comp_ic{1,i} == 0
                    comp_ic{1,i}=[];
                end
                
                isCorrect=true;
            end
        end
        AnswersIndex = AnswersIndex+1;
    end
else
    comp_ic={[]};
end

%% Get number of model class
disp(' ')
module=module+1;
isCorrect = false;
while ~isCorrect
    disp( ['- How many model classes do ' ...
        'you want for each time-series? '])
    if isAnswersFromFile
        nb_models=eval(char(AnswersFromFile{1}(AnswersIndex)));
        disp(['     ', nb_models])
    else
        nb_models=input('     choice >> ');
    end
    if isempty(nb_models)
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%')
        disp('                                                         ')
        disp([' Bayesian dynamic linear modelling enables to run more' ...
            'than one model class to interpret time series with' ...
            'switching dynamics.'])
        disp([' This section allows to choose the number of model' ...
            'class to process each time series.'])
        disp(' A maximum of 2 model classes is supported. ')
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%')
        disp(' ')
        continue
    elseif length(nb_models) > 1
        disp(' ')
        disp('     wrong input -> should be a single integer')
        disp(' ')
        continue
    elseif ischar(nb_models)|| rem(nb_models,1)~=0 || sign(nb_models) == -1
        disp(' ')
        disp('     wrong input -> not a positive integer')
        disp(' ')
        continue
    elseif nb_models > 2
        disp(' ')
        disp(['     wrong input -> more than 2 model classes ' ...
            'is not supported.'])
        disp(' ')
        continue
    else
        isCorrect = true;
    end
end
AnswersIndex = AnswersIndex+1;


%% Identify model components for each model class and time series
disp(' ')
disp('     --------------------------------------------------------')
disp('     BDLM Component reference numbers')
disp('     --------------------------------------------------------')
disp('     11: Local level')
disp('     12: Local trend')
disp('     13: Local acceleration')
disp('     21: Local level compatible with local trend')
disp('     22: Local level compatible with local acceleration')
disp('     23: Local trend compatible with local acceleration')
disp('     31: Periodic')
disp('     41: Autoregressive process (AR(1))')
disp('     51: Dynamic regression with hidden component')
disp('     52: Static kernel regression')
disp('     53: Dynamic kernel regression')
disp('     --------------------------------------------------------')
disp(' ')


all_components=[11 12 13 21 22 23 31 41 51 52 53];
level_components=[11 12 13 21 22 23];

module=module+1;

comp=cell(nb_models,numberOfTimeSeries);

for j=1:nb_models
    if nb_models>1
        disp(['    Model class #' num2str(j)])
    end
    for i=1:numberOfTimeSeries
        isCorrect = false;
        while ~isCorrect
            disp(['- Identify components for each' ...
                ' model class and observation; e.g. [11 31 41]'])
            if isAnswersFromFile
                comp{j}{i}=eval(char(AnswersFromFile{1}(AnswersIndex)));
                if length(comp{j}{i}(:)) ~=1
                    disp(['     [' sprintf('%d,', comp{j}{i}(1:end-1) ) ...
                        num2str(comp{j}{i}(end)) ']'])
                else
                    disp(['     [' num2str(comp{j}{i}(end)) ']'])
                end
            else
                comp{j}{i}=input(['     time serie #' num2str(i) ' >> ']);
            end
            if isempty(comp{j}{i})
                disp(' ')
                disp(['%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%' ...
                    '%%%%%%%%%%%%%%'])
                disp(' ')
                disp([' Bayesian dynamic linear modelling requires' ...
                    'a user''s defined model structure. '])
                disp([' The structure of the model is defined' ...
                    'using components. '])
                disp(' There is one reference number per components.')
                disp([' For instance, [11 31 41] builds a model with' ...
                    'a local level, a periodic component,' ...
                    'and an AR(1) process.'])
                disp(' ')
                disp([' The first six components are used to describe' ...
                    'the baseline of the time series (level components).'])
                disp([' Compatibility rules for the level components' ...
                    'apply between model classes. '])
                disp(' ')
                disp([' Default model parameters values are assigned ' ...
                    'to each model component.'])
                disp(' ')
                disp(['%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%' ...
                    '%%%%%%%%%%%%%%'])
                disp(' ')
            elseif ischar(comp{j}{i})
                disp(' ')
                disp('     wrong input -> should be integers')
                disp(' ')
                continue
            elseif ~all(ismember(comp{j}{i},all_components))
                disp(' ')
                disp(['     wrong input -> at least one component' ...
                    ' is unknown '])
                disp(' ')
                continue
            elseif ~all(ismember(comp{j}{i}(1),level_components))
                disp(' ')
                disp(['     wrong input -> first component should be a' ...
                    ' level component (i.e. either 11 12 13 21 22 23 )'])
                disp(' ')
                continue
            elseif length(comp{j}{i}) > 1 && ...
                    any(ismember(comp{j}{i}(2:end),level_components))
                disp(' ')
                disp(['     wrong input -> only the first component' ...
                    ' should be a level component'])
                disp(' ')
                continue
            elseif j == 1 && nb_models>1 && ...
                    any(ismember(comp{j}{i}(1),level_components(1:3)))
                disp(' ')
                disp(['     wrong input -> the first component for' ...
                    ' model class 1 should be a level compatible' ...
                    ' component (i.e. either 21 22 23 )'])
                disp(' ')
                continue
            elseif j == 1 && nb_models == 1 && ...
                    any(ismember(comp{j}{i}(1),level_components(4:6)))
                disp(' ')
                disp(['     wrong input -> the first component for ' ...
                    'model class 1 should not be a level compatible ' ...
                    'component (i.e. only 11 12 13 are supported).'])
                disp(' ')
                continue
            elseif j == 2 && nb_models>1 && comp{1}{i}(1) == 21 && ...
                    comp{j}{i}(1) ~= 12
                disp(' ')
                disp(['     wrong input -> the level component' ...
                    ' for the two model classes are not compatibles'])
                disp(' ')
                continue
            elseif j == 2 && nb_models>1 && comp{1}{i}(1) == 22 && ...
                    comp{j}{i}(1) ~= 13
                disp(' ')
                disp(['     wrong input -> the level' ...
                    ' component for the two model classes are not' ...
                    ' compatibles'])
                disp(' ')
                continue
            elseif j == 2 && nb_models>1 && comp{1}{i}(1) == 23 && ...
                    comp{j}{i}(1) ~= 13
                disp(' ')
                disp(['     wrong input -> the level component ' ...
                    'for the two model classes are not compatibles'])
                disp(' ')
                continue
            elseif j>1&& length(comp{j}{i})~=length(comp{j-1}{i})
                disp(' ')
                disp(['     wrong input -> all model' ...
                    ' classes must have the same number of components'])
                disp(' ')
                continue
            else
                isCorrect=true;
                AnswersIndex = AnswersIndex+1;
            end
        end
    end
end

%% Identify constrained components
const=cell(nb_models,numberOfTimeSeries);
disp(' ')
if nb_models>1
    module=module+1;
    for j=2:nb_models
        disp(['    Model class #' num2str(j)])
        for i=1:numberOfTimeSeries
            isCorrect = false;
            while ~isCorrect
                disp(['- Identify shared parameters' ...
                    ' between the components of the model' ...
                    ' class #1; e.g. [0 1 1]'])
                if isAnswersFromFile
                    const{j}{i}=eval(char(AnswersFromFile{1}(AnswersIndex)));
                    
                    if length(const{j}{i}(:)) ~= 1
                    disp(['     [' sprintf('%d,', const{j}{i}(1:end-1) ) ...
                        num2str(const{j}{i}(end)) ']'])
                    else
                         disp(['     [' num2str(const{j}{i}(end)) ']'])
                    end
                else
                    const{j}{i}=input(['     time serie #' num2str(i) ...
                        ' >> ']);
                end
                if isempty(const{j}{i})
                    disp(' ')
                    disp(['%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%' ...
                        '%%%%%%%%%%%%%%%%%%%'])
                    disp(' ')
                    disp([' For a given component and two model ' ...
                        'classes, sharing model parameters implies of' ...
                        'having the same parameters for the' ...
                        'two model classes.  '])
                    disp([' Sharing parameters between the same component' ...
                        'of different model classes enables to reduce' ...
                        'the total number of model parameters.'])
                    disp(' ')
                    disp(['%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%' ...
                        '%%%%%%%%%%%%%%%%%%%'])
                    disp(' ')
                elseif length(const{j}{i})~=length(comp{j}{i})
                    disp(' ')
                    disp(['     wrong input -> the number of ' ...
                        'constraint parameters must be the same ' ...
                        'as the number of components'])
                    disp(' ')
                    continue
                elseif ischar(const{j}{i})
                    disp(' ')
                    disp('     wrong input -> should be integers')
                    disp(' ')
                    continue
                elseif ~all(ismember(const{j}{i}, [0,1]))
                    disp(' ')
                    disp('     wrong input -> should be 0 or 1')
                    disp(' ')
                    continue
                else
                    isCorrect = true;
                    AnswersIndex = AnswersIndex+1;
                end
            end
        end
    end
end



model.nb_class = nb_models;


% Model blocks
for j=1:nb_models
    str_3 = ""; %strings;
    for i=1:numberOfTimeSeries
        str_1 = sprintf('%d ', comp{j}{i});
        str_2 = sprintf('[%s] ', str_1 );
        str_3 = [str_3 str_2];
    end
    str_4 = sprintf('model.components.block{%d}={%s};', j, strjoin(str_3) );
    eval(str_4)
end


% Model constrains
for j=2:nb_models
    str_3 = ""; %strings;
    for i=1:numberOfTimeSeries
        str_1 = sprintf('%d ', const{j}{i});
        str_2 = sprintf('[%s] ', str_1 );
        str_3 = [str_3 str_2];
    end
    str_4 = sprintf('model.components.const{%d}={%s};', j, strjoin(str_3) );
    eval(str_4)
end

% Observations interdependencies
str_3 = ""; %strings;
for j=1:numberOfTimeSeries
    str_1=sprintf('%d ',comp_ic{1,j});
    str_2 = sprintf('[%s] ', str_1 );
    str_3 = [str_3 str_2];
end
str_4=sprintf('model.components.ic={%s};', strjoin(str_3));
eval(str_4)

%--------------------END CODE ------------------------
end
