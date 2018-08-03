function [configFilename] = printConfigurationFile(data, model, estimation, misc, varargin)
%PRINTCONFIGURATIONFILE Create and print a configuration file
%
%   SYNOPSIS:
%     [configconfigFilename] = PRINTCONFIGURATIONFILE(data, model, estimation, misc, varargin)
%
%   INPUT:
%      data                   - structure (required)
%                               see documentation for details about the fields
%                               of data
%
%      model                  - structure (required)
%                               see documentation for details about the fields
%                               of model
%
%      estimation             - structure (required)
%                               see documentation for details about the fields
%                               of estimation
%
%      misc                   - structure (required)
%                               see documentation for details about the fields
%                               of misc
%
%      FilePath               - character (optional)
%                               directory in which to save the file
%                               default : "." (current folder)
%
%   OUTPUT:
%      data                   - structure
%                               see documentation for details about the fields
%                               of data
%
%      model                  - structure
%                               see documentation for details about the fields
%                               of model
%
%      estimation             - structure
%                               see documentation for details about the fields
%                               of estimation
%
%      misc                   - structure
%                               see documentation for details about the fields
%                               of misc
%
%      configconfigFilename         - character
%                               name of the printed configuration file
%
%   DESCRIPTION:
%      PRINTCONFIGURATIONFILE creates a configuration file in the directory
%      specified by "Filepath"
%      Important : PRINTCONFIGURATIONFILE overwrites previous file with
%      same name without notification
%
%   EXAMPLES:
%      [configconfigFilename] = PRINTCONFIGURATIONFILE(data, model, estimation, misc)
%      [configconfigFilename] = ]PRINTCONFIGURATIONFILE(data, model, estimation, misc, 'FilePath', 'config_files')
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   SUBFUNCTIONS:
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
%       April 26, 2018
%
%   DATE LAST UPDATE:
%       July 24, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

validationFct_FilePath = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

defaultFilePath = '.';

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'estimation', @isstruct );
addRequired(p,'misc', @isstruct );
addParameter(p,'FilePath', defaultFilePath, validationFct_FilePath );
parse(p,data, model, estimation, misc, varargin{:});

data=p.Results.data;
model=p.Results.model;
%estimation=p.Results.estimation;
misc=p.Results.misc;
FilePath=p.Results.FilePath;

%% Create specified path if not existing
[isFileExist] = testFileExistence(FilePath, 'dir');
if ~isFileExist
    % create directory
    mkdir(FilePath)
    % set directory on path
    addpath(FilePath)
end

%% Gather information
%Get project name
ProjectName = misc.ProjectName;
% Get number of model class
nb_models = model.nb_class;
% Get number of time series
numberOfTimeSeries = length(data.labels);
% Get training period
trainingPeriod = misc.trainingPeriod;
% Get labels
labels = data.labels;

% Get data filename
dataFilename=['DATA_', ProjectName, '.mat'];

% Get config filename
configFilename = fullfile(FilePath, ['CFG_', ProjectName, '.m'] );

[isFileExist] = testFileExistence(configFilename, 'file');

if isFileExist
    isAnswerCorrect = false;
    while ~isAnswerCorrect
        disp(' ')
        fprintf(['     Configuration file name %s already exists. ' ...
            'Overwrite ? (y/n) \n'], ['CFG_', ProjectName, '.m'])
        choice = input('     choice >> ','s');
        % Remove space and quotes
        choice=strrep(choice,'''','' ); % remove quotes
        choice=strrep(choice,'"','' ); % remove double quotes
        choice=strrep(choice, ' ','' ); % remove spaces
        
        if isempty(choice)
            disp(' ')
            disp('     wrong input --> please make a choice')
            disp(' ')
            continue
        elseif strcmpi(choice,'y') || strcmpi(choice,'yes')
            configFilename = fullfile(FilePath, ['CFG_' ProjectName '.m']);
            isAnswerCorrect =  true;
        elseif strcmpi(choice,'n') || strcmpi(choice,'no')
            [name]=incrementFilename('CFG_new', ...
                'config_files', 'FileExtension', 'm');
            configFilename = fullfile(FilePath, name);
            isAnswerCorrect = true;
        else
            disp(' ')
            disp('     wrong input')
            disp(' ')
            continue
        end
        
    end
else
    configFilename = fullfile(FilePath, ['CFG_' ProjectName '.m']);
end

%% Create configuration file

%Header
ConfigFileTitle = 'OpenBDLM configuration file';
Autogen_str = ['Autogenerated by OpenBDLM on ', datestr(now) ];
nshift_1 = 20;
nshift_2 = 10;

fileID=fopen(configFilename,'w');
fprintf(fileID,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID, '\n');
fprintf(fileID,repmat('%s',1,75),repmat('%',1,1),repmat(' ',1,73), ...
    repmat('%',1,1) );
fprintf(fileID, '\n');
fprintf(fileID,repmat('%s',1,75),repmat('%',1,1),repmat(' ',1,73), ...
    repmat('%',1,1) );
fprintf(fileID, '\n');
fprintf(fileID,repmat('%s',1,75),repmat('%',1,1), repmat(' ',1,nshift_1), ...
    ConfigFileTitle, repmat(' ',1,75-(length(ConfigFileTitle)+2+nshift_1)), ...
    repmat('%',1,1) );
fprintf(fileID, '\n');
fprintf(fileID,repmat('%s',1,75),repmat('%',1,1), repmat(' ',1,nshift_2), ...
    Autogen_str, repmat(' ',1,75-(length(Autogen_str)+2+nshift_2)), ...
    repmat('%',1,1) );
fprintf(fileID, '\n');
fprintf(fileID,repmat('%s',1,75),repmat('%',1,1),repmat(' ',1,73), ...
    repmat('%',1,1) );
fprintf(fileID, '\n');
fprintf(fileID,repmat('%s',1,75),repmat('%',1,1),repmat(' ',1,73), ...
    repmat('%',1,1) );
fprintf(fileID, '\n');
fprintf(fileID,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID, '\n');

%Project name
fprintf(fileID, '\n');
fprintf(fileID,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID, '\n');
fprintf(fileID, '%%%% A - Project name\n');
fprintf(fileID,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID, '\n');
fprintf(fileID,'misc.ProjectName=''%s'';\n',ProjectName);
fprintf(fileID, '\n');

%Data
fprintf(fileID,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID, '\n');
fprintf(fileID, '%%%% B - Data\n');
fprintf(fileID,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID, '\n');
fprintf(fileID,'dat=load(''%s''); \n', dataFilename );
fprintf(fileID,'data.values=dat.values;\n' );
fprintf(fileID,'data.timestamps=dat.timestamps;\n');
fprintf(fileID,'misc.trainingPeriod=[%d,%d];\n',trainingPeriod);
fprintf(fileID,'data.labels={');
for i=1:numberOfTimeSeries
    fprintf(fileID,'''%s''', labels{i});
    if i<numberOfTimeSeries&&numberOfTimeSeries>1
        fprintf(fileID,',');
    end
end
fprintf(fileID,'};\n');
fprintf(fileID,'\n');
% Model structure
% Print model components for each time series and model class
fprintf(fileID,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID, '\n');
fprintf(fileID,'%%%% C - Model structure \n');
fprintf(fileID,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID, '\n');
fprintf(fileID,'%% Components reference numbers\n');
fprintf(fileID,'%% 11: Local level\n');
fprintf(fileID,'%% 12: Local trend\n');
fprintf(fileID,'%% 13: Local acceleration\n');
fprintf(fileID,'%% 21: Local level compatible with local trend\n');
fprintf(fileID,'%% 22: Local level compatible with local acceleration\n');
fprintf(fileID,'%% 23: Local trend compatible with local acceleration\n');
fprintf(fileID,'%% 31: Periodic\n');
fprintf(fileID,'%% 41: Autoregressive\n');
fprintf(fileID,'%% 51: Dynamic regression with hidden component\n');
fprintf(fileID,'%% 52: Static kernel regression\n');
fprintf(fileID,'%% 53: Dynamic kernel regression\n');
fprintf(fileID,'%% 61: Level Intervention\n');
fprintf(fileID, '\n');
% Print model components
fprintf(fileID,'%% Model components\n');
for j=1:nb_models
    fprintf(fileID,'%% Model %s\n', num2str(j));
    fprintf(fileID,'model.components.block{%d}={',j);
    for i=1:numberOfTimeSeries
        fprintf(fileID,'[');
        fprintf(fileID,'%d ',model.components.block{j}{i});
        fprintf(fileID,'] ');
    end
    fprintf(fileID,'};\n');
end
fprintf(fileID,'\n');
% Print model components constrains
fprintf(fileID,['%% Model component constrains | Take the same '...
    ' parameter as model class #1\n']);
for j=2:nb_models
    fprintf(fileID,'model.components.const{%d}={',j);
    for i=1:numberOfTimeSeries
        fprintf(fileID,'[');
        fprintf(fileID,'%d ',model.components.const{j}{i});
        fprintf(fileID,'] ');
    end
    fprintf(fileID,'};\n');
end

% Print model components interdependencies
fprintf(fileID,' \n');
fprintf(fileID,['%% Model inter-components dependence | ' ...
    '{[components form dataset_i depends on components from ' ...
    ' dataset_j]_i,[...]}\n']);
fprintf(fileID,'model.components.ic={');
for j=1:numberOfTimeSeries
    fprintf(fileID,'[');
    fprintf(fileID,'%d ',model.components.ic{1,j});
    fprintf(fileID,'] ');
end
fprintf(fileID,'};\n');
fprintf(fileID, '\n');

%% Print model parameters properties information
fprintf(fileID,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID, '\n');
fprintf(fileID,'%%%% D - Model parameters \n');
fprintf(fileID,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID, '\n');
fprintf(fileID,'model.param_properties={\n');
fprintf(fileID, ['    %% #1             #2         #3       #4  ', ...
    '    #5                  #6          #7      #8      #9    ', ...
    '          #10', '\n']);
fprintf(fileID, ['    %% Param name     Block name Model ', ...
    '   Obs     Bound               Prior       Mean    Std   ', ...
    '  Values          Ref', '\n']);
for i=1:size(model.param_properties,1)
    space=repmat(' ',1,10-length(model.param_properties{i,1}));
    fprintf(fileID, ['\t''%-s''' space ',\t ', ...
        '''%-s'',\t\t''%-s'',\t ''%-s'',\t [ %-5G, %-5G],\t ', ...
        '''%-s'',\t %-2.2G,\t %-2.2G,\t %-8.5G, ' ' ', ...
        '\t %-2.3G %%#%d' '\n'], model.param_properties{i,:},i);
end
fprintf(fileID,'};\n');
fprintf(fileID, '\n');

% fprintf(fileID,' \n');
% fprintf(fileID,repmat('%s',1,75),repmat('%',1,75));
% fprintf(fileID, '\n');
% fprintf(fileID,'%%%% D - Model parameters \n');
% fprintf(fileID,repmat('%s',1,75),repmat('%',1,75));
% fprintf(fileID, '\n');
% fprintf(fileID,'%% Model parameters properties: \n');
% fprintf(fileID,'model.param_properties={\n');
% fprintf(fileID,['%%     |Parameter     |Component |Model # |Observation  '...
%     ' |Bounds min/max        |Prior type' ...
%     ' |Mean prior       |Sdev prior |Parameter #\n']);
% for i=1:size(model.param_properties,1)
%     space=repmat(' ',1,8-length(model.param_properties{i,1}));
%
%     fprintf(fileID,['\t %-s''%-s'',\t''%-s'' ,\t''%-s'',\t'  ...
%         '''%-s'',\t[ %-5G, %-5G],\t ''%-s'',\t %-5G ,\t %-5G %%#%d \n'], ...
%         space, model.param_properties{i,:}, i);
%
% end

% fprintf(fileID,'};\n');
% fprintf(fileID,'\n');
% fprintf(fileID,'%% Model parameters values: \n');
% fprintf(fileID,'model.parameter=[\n');
% fprintf(fileID,'%%|Parameter value    |Parameter # |Parameter\n');
% for i=1:size(model.parameter,1)
%     fprintf(fileID,'%-8.5G \t %%#%d %%%s\n', model.parameter(i),i, model.param_properties{i,1});
% end
% fprintf(fileID,'];\n ');
%
% fprintf(fileID,' \n');
% fprintf(fileID,'%% Model parameters constrains: \n');
% fprintf(fileID,['model.p_ref=[' num2str(model.p_ref) '];\n']);
% fprintf(fileID,' \n');

%% Print initial states
fprintf(fileID,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID, '\n');
fprintf(fileID,'%%%% E - Initial states values \n');
fprintf(fileID,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID, '\n');
for m=1:model.nb_class
    fprintf(fileID,['%% Initial hidden states ', ... 
        'mean for model %s:\n'], num2str(m));
    fprintf(fileID, 'model.initX{ %s }=[', num2str(m) );
    for i=1:size(model.initX{m},1)
        fprintf(fileID, '\t%-6.3G', model.initX{m}(i,:));
    end
    fprintf(fileID,']'';\n');
    fprintf(fileID,'\n');
    
    fprintf(fileID,['%% Initial hidden ', ... 
        'states variance for model %s: \n'], num2str(m));
    
    % Variance only;
    diagV=diag(model.initV{m});
    
    fprintf(fileID, 'model.initV{ %s }=diag([ ', num2str(m) );
    %for i=1:size(model.initV{m},1)
    for i=1:length(diagV)
        fprintf(fileID, '\t%-6.3G', diagV(i,:));
    end
    fprintf(fileID,' ]);\n');
    fprintf(fileID,'\n');
    fprintf(fileID,'%% Initial probability for model %s\n', num2str(m));
    for i=1:size(model.initS{m},1)
        fprintf(fileID,'model.initS{%d}=[%-6.3G];\n', m, model.initS{m});
    end
    fprintf(fileID,'\n');
end

%% Custom anomalies
if isfield(misc, 'custom_anomalies')
    fprintf(fileID,repmat('%s',1,75),repmat('%',1,75));
    fprintf(fileID, '\n');
    fprintf(fileID,'%%%% Custom anomalies :\n');
    fprintf(fileID,repmat('%s',1,75),repmat('%',1,75));
    fprintf(fileID, '\n');
    fprintf(fileID,['misc.custom_anomalies.start_custom_anomalies=[' ...
        num2str(misc.custom_anomalies.start_custom_anomalies) '];\n']);
    fprintf(fileID,['misc.custom_anomalies.duration_custom_anomalies=[' ...
        num2str(misc.custom_anomalies.duration_custom_anomalies) '];\n']);
    fprintf(fileID,['misc.custom_anomalies.amplitude_custom_anomalies=[' ...
        num2str(misc.custom_anomalies.amplitude_custom_anomalies) '];\n']);
    fprintf(fileID,'\n');
end

fprintf('     Configuration file saved in %s. \n', configFilename )

%--------------------END CODE ------------------------
end
