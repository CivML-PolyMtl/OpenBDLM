function [data, model, estimation, misc, isValid] = readConfigurationFile(FileName, varargin)
%READCONFIGURATIONFILE Read configuration file
%
%   SYNOPSIS:
%     [data, model, estimation, misc, isValid]=READCONFIGURATIONFILE(FileName, varargin)
%
%   INPUT:
%      FileName            - character (required)
%                             path + filename of the configuration file to 
%                             read
%
%      isVerification      - logical (optionnal)
%                             if isVerification = true , verify configuration
%                             file
%                             default : false
%
%   OUTPUT:
%
%      data                - structure
%                            see documentation for details about the fields
%                            in structure "data"
%
%      model               - structure
%                            see documentation for details about the fields
%                            in structure "model"
%
%      estimation         - structure
%                            see documentation for details about the fields
%                            in structure "estimation"
%
%      misc               - structure
%                            see documentation for details about the fields
%                            in structure "misc"
%
%      isValid            - logical
%                           if isValid = true, the file does not contain
%                           recognized errors
%
%   DESCRIPTION:
%      READCONFIGURATIONFILE read configuration file
%      if isVerification = true , verify configuration file before to read
%
%      IMPORTANT: the verification tool aim at detecting the most
%      frequent errors, but it can not detect all possible errors.
%
%   EXAMPLES:
%      [data, model, estimation, misc, isValid]=READCONFIGURATIONFILE('config_files/CFG_TEST1.m')
%      [data, model, estimation, misc, isValid]=READCONFIGURATIONFILE('config_files/CFG_TEST1.m', 'isVerification', true)
%
%   EXTERNAL FUNCTIONS CALLED:
%       verificationmMergedDataset, countModelParameters, testFileExistence
%
%   See also VERIFICATIONMERGEDDATASET, COUNTMODELPARAMETERS,
%            TESTFILEEXISTENCE

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
%       May 28, 2018
%
%   DATE LAST UPDATE:
%       May 30, 2018

%--------------------BEGIN CODE ----------------------


%% Get arguments passed to the function and proceed to some verification
p = inputParser;
validationFct_FileName = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));
defaultisVerification = false;
addRequired(p,'FileName', validationFct_FileName );
addParameter(p,'isVerification', defaultisVerification, @islogical );
parse(p,FileName, varargin{:});
FileName=p.Results.FileName;
isVerification = p.Results.isVerification;

%% Remove space in filename
FileName = FileName(~isspace(FileName));

disp('     Read configuration file...')
if ~isVerification
    run(FileName);
    isValid = true;
else
    
    %% Test if the file exist
    [isFileExist] = testFileExistence(FileName, 'file');
    
    if ~isFileExist
        disp(' ')
        fprintf('     ERROR: the file %s does not exist.\n', FileName)
        disp(' ')
        isValid = false;
        data = [] ; model = [] ; estimation = []; misc = [];
        return
    end
    
    %% Try to execute the file
   try
        run(FileName);
    catch
        disp(' ')
        fprintf(['     ERROR: the file %s can be executed, '...
            'contains error or does not exist.\n'], FileName )
        disp(' ')
        isValid = false;
        data = [] ; model = [] ; estimation = []; misc = [];
        return
    end
    
    %% Verification the timestamp are merged
    [isMerged]=verificationMergedDataset(data);
    
    if ~isMerged
        disp(' ')
        disp(['     ERROR: the time series do not share the '...
            'same timestamp vector.'])
        disp(' ')
        isValid = false;
        return
    end
    
    %% Verify that model.component exist
    
    if ~isfield(model, 'components')
        disp(' ')
        disp('     ERROR: the field model.components is missing.')
        disp(' ')
        isValid = false;
        return
    end
    
    %% Get number of time series
    numberOfTimeSeries = size(data.values,2);
    
    %% Get number of models
    nb_models = size(model.components.block,2);
    
    if nb_models > 2
        disp(' ')
        disp(['     ERROR: A maximum of 2 model classes ' ...
            'is supported.'])
        disp(' ')
        isValid = false;
        return
    end
    
    %% Verification time series dependencies
    if size(model.components.ic,2) ~= numberOfTimeSeries
        disp(' ')
        disp(['     ERROR: The size of the dependency vector ' ...
            'should be the same ' ...
            'than the number of time series.'])
        disp(' ')
        isValid = false;
        return
    end
    
    if numberOfTimeSeries > 1
        
        ForbiddenIndexes=cell(numberOfTimeSeries,1);
        
        for i=1:numberOfTimeSeries
            ForbiddenIndexes{i} = i;
        end
        
        comp_ic = cell(1,numberOfTimeSeries);
        
        for i=1:numberOfTimeSeries
            
            comp_ic{1,i}=model.components.ic{i};
            
            for j=1:length(comp_ic{1,i})
                try
                    ForbiddenIndexes{comp_ic{1,i}(j)}= ...
                        [i ForbiddenIndexes{comp_ic{1,i}(j)} ];
                catch
                end
            end
            
            if ischar(comp_ic{1,i})
                disp(' ')
                disp('     ERROR: Dependency vector should contain integers.')
                disp(' ')
                isValid = false;
                return
            elseif ~isempty(comp_ic{1,i}) && any(rem(comp_ic{1,i},1))
                disp(' ')
                disp('     ERROR: Dependency vector should contain integers.')
                disp(' ')
                isValid = false;
                return
            elseif length(comp_ic{1,i})>numberOfTimeSeries-1
                %|| ~isempty(find([comp_ic{1}] >4,1))
                disp(' ')
                disp(['     ERROR: Dependency vector is larger ' ...
                    'than the number of time series.'])
                disp(' ')
                isValid = false;
                return
                
            elseif any(ismember(comp_ic{1,i}, ForbiddenIndexes{i})) ...
                    || ~isempty(find(comp_ic{1,i}>numberOfTimeSeries,1))
                disp(' ')
                disp(['     ERROR: Conflicts in the ' ...
                    'dependency vector.'])
                disp(' ')
                isValid = false;
                return
            end
            
        end
        
    end
    
    %% Verification components
    comp=cell(nb_models,numberOfTimeSeries);
    
    all_components=[11 12 13 21 22 23 31 41 51 52 53];
    level_components=[11 12 13 21 22 23];
    
    for j=1:nb_models
        
        for i=1:numberOfTimeSeries
            
            comp{j}{i}=model.components.block{j}{i};
            
            if ~all(ismember(comp{j}{i},all_components)) || ...
                    ischar(comp{j}{i}) ||  ...
                    isempty(comp{j}{i})
                disp(' ')
                disp(['     ERROR: at least one component ' ...
                    'is unknown. '])
                disp(' ')
                isValid = false;
                return
            elseif ~all(ismember(comp{j}{i}(1),level_components))
                disp(' ')
                disp(['     ERROR: the first component should be a ' ...
                    'level component (i.e. either 11 12 13 21 22 23 ).'])
                disp(' ')
                isValid = false;
                return
            elseif length(comp{j}{i}) > 1 && ...
                    any(ismember(comp{j}{i}(2:end),level_components))
                disp(' ')
                disp(['     ERROR: only the first component' ...
                    ' should be a level component.'])
                disp(' ')
                isValid = false;
                return
            elseif j == 1 && nb_models>1 && ...
                    any(ismember(comp{j}{i}(1),level_components(1:3)))
                disp(' ')
                disp(['     ERROR: the first component for ' ...
                    'model class 1 should be a level compatible ' ...
                    'component (i.e. only 21 22 23 are supported).'])
                disp(' ')
                isValid = false;
                return
                
            elseif j == 1 && nb_models == 1 && ...
                    any(ismember(comp{j}{i}(1),level_components(4:6)))
                disp(' ')
                disp(['     ERROR: the first component for ' ...
                    'model class 1 should not be a level compatible ' ...
                    'component (i.e. only 11 12 13 are supported).'])
                disp(' ')
                isValid = false;
                return
                
                
            elseif j == 2 && nb_models>1 && comp{1}{i}(1) == 21 && ...
                    comp{j}{i}(1) ~= 12
                disp(' ')
                disp(['     ERROR: the level component ' ...
                    'for the two model classes are not compatibles.'])
                disp(' ')
                isValid = false;
                return
            elseif j == 2 && nb_models>1 && comp{1}{i}(1) == 22 && ...
                    comp{j}{i}(1) ~= 13
                disp(' ')
                disp(['     ERROR: the level ' ...
                    'component for the two model classes are not ' ...
                    'compatibles.'])
                disp(' ')
                isValid = false;
                return
            elseif j == 2 && nb_models>1 && comp{1}{i}(1) == 23 && ...
                    comp{j}{i}(1) ~= 13
                disp(' ')
                disp(['     ERROR: the level component ' ...
                    'for the two model classes are not compatibles.'])
                disp(' ')
                return
            elseif j>1&& length(comp{j}{i})~=length(comp{j-1}{i})
                disp(' ')
                disp(['     ERROR: all model ' ...
                    'classes must have the same number of components.'])
                disp(' ')
                isValid = false;
                return
            end
        end
    end
    
    
    %% Verification model parameters constrains
    const=cell(nb_models,numberOfTimeSeries);
    if nb_models > 1
        
        if ~isfield(model.components, 'const')
            disp(' ')
            disp(['     ERROR: No component constrain vector defined ' ...
                'but there are two model classes.'])
            disp(' ')
            isValid = false;
            return
        end
        
        for j=2:nb_models
            
            for i=1:numberOfTimeSeries
                
                const{j}{i}=model.components.const{j}{i};
                
                if isempty(const{j}{i})
                    
                elseif length(const{j}{i})~=length(comp{j}{i})
                    disp(' ')
                    disp(['     ERROR: the size of the component ' ...
                        'constrain vector must be the same ' ...
                        'than the number of components.'])
                    disp(' ')
                    isValid = false;
                    return
                elseif ischar(const{j}{i})
                    disp(' ')
                    disp(['     ERROR:  the component ' ...
                        'constrain vector should contain integer only.'])
                    disp(' ')
                    isValid = false;
                    return
                elseif ~all(ismember(const{j}{i}, [0,1]))
                    disp(' ')
                    disp(['     ERROR:  the component ' ...
                        'constrain vector should contain 0 or 1 only.'])
                    disp(' ')
                    disp(' ')
                    isValid = false;
                    return
                    
                end
                
            end
        end
        
    end
    
    
    
    %% Verification model parameters
    
    % Count the number of model parameters expected according to the model
    [NumberOfParameters] = countModelParameters(model);
    
    
    if isfield(model, 'param_properties')
        s1=size(model.param_properties,1);
        
        if s1 ~= NumberOfParameters
            disp(' ')
            disp(['     ERROR: the number of parameters defined does not '  ...
                'match with the model.'])
            disp(' ')
            isValid = false;
            return
        end
        
    else
        s1=0;
    end
    
    if isfield(model, 'parameter')
        s2=size(model.parameter,1);
        
        if s2 ~= NumberOfParameters
            disp(' ')
            disp(['     ERROR: the number of parameters defined does not '  ...
                'match with the model.'])
            disp(' ')
            isValid = false;
            return
        end
    else
        s2=0;
    end
    
    if isfield(model, 'p_ref')
        s3=size(model.p_ref,2);
        if s3 ~= NumberOfParameters
            disp(' ')
            disp(['     ERROR: the number of parameters defined does not '  ...
                'match with the model.'])
            disp(' ')
            isValid = false;
            return
        end
    else
        s3=0;
    end
    
    if s1-s2 ~=0 || s2-s3 ~= 0 ||  s1-s3 ~=0
        disp(' ')
        disp(['     ERROR: size compatibility issue with ' ...
            'model parameters. '])
        disp(' ')
        isValid = false;
        return
    end
    
    
    %% Verification initial hidden states
    
    
    % Mean vector values
    if isfield(model, 'initX')
        if nb_models ~= size(model.initX,2)
            disp(' ')
            disp(['     ERROR: incompatibility between ' ...
                'the number of models class and initial state values.'])
            disp(' ')
            isValid = false;
            return
        end
        
        if nb_models == 2
            if size(model.initX{1},1) ~= size(model.initX{2},1)
                disp(' ')
                disp(['     ERROR: the size of mean initial state vector of each ' ...
                    'model class is not equal'])
                disp(' ')
                isValid = false;
                return
            end
        end
        
    end
    
    % Covariance matrices values
    if isfield(model, 'initV')
        if nb_models ~= size(model.initV,2)
            disp(' ')
            disp(['     ERROR: incompatibility between ' ...
                'the number of models class and initial state values.'])
            disp(' ')
            isValid = false;
            return
        end
        
        if nb_models == 2
            if size(model.initV{1},1) ~= size(model.initV{1},2)
                disp(' ')
                disp(['     ERROR: the dimension of state covariance matrix ' ...
                    'of each model class is not equal'])
                disp(' ')
                isValid = false;
                return
            end
            
            if ~issymmetric(model.initV{1}) || ~issymmetric(model.initV{2})
                disp(' ')
                disp(['     ERROR: at least one initial state covariance ' ...
                    'matrices is not symmetric'])
                disp(' ')
                isValid = false;
                return
                
            end
            
        end
        
    end
    
    % Model probability
    if isfield(model, 'initS')
        if nb_models == 1
            
            if model.initS{1} ~=1
                disp(' ')
                disp(['     ERROR: model probability ' ...
                    'should be equal to one.'])
                disp(' ')
                isValid = false;
                return
            end
            
        elseif nb_models == 2
            
            if size(model.initS,2) == 2
                
                if (model.initS{1} + model.initS{2} ) ~=1
                    disp(' ')
                    disp(['     ERROR: sum of initial model probability  ' ...
                        'state vector should be equal to one.'])
                    disp(' ')
                    isValid = false;
                    return
                end
            else
                disp(' ')
                disp(['     ERROR: incomplete initial model probability ' ...
                    'state vector.'])
                disp(' ')
                isValid = false;
                return
            end
            
        end
        
    end
    
    isValid = true;
    
end
%--------------------END CODE ------------------------
end
