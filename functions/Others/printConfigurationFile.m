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
%       August 20, 2018

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

DataPath = misc.DataPath;

% Set fileID for logfile
if misc.isQuiet
    % output message in logfile
    fileID=fopen(misc.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end

%% Create specified path if not existing
[isFileExist] = testFileExistence(FilePath, 'dir');
if ~isFileExist
    % create directory
    mkdir(FilePath)
    % set directory on path
    addpath(FilePath)
end


disp('     Printing configuration file...')

%% Gather information
%Get project name
ProjectName = misc.ProjectName;
% Get number of model class
nb_models = model.nb_class;
% Get number of time series
numberOfTimeSeries = length(data.labels);
% Get training period
trainingPeriod = misc.options.trainingPeriod;
% Get labels
labels = data.labels;


% Save data
[misc, dataFilename] = saveDataBinary(data, misc, 'FilePath', DataPath, ...
    'isForceOverwrite', true);

% Get config filename
configFilename = fullfile(FilePath, ['CFG_', ProjectName, '.m'] );

[isFileExist] = testFileExistence(configFilename, 'file');

if isFileExist
    isAnswerCorrect = false;
    while ~isAnswerCorrect
        disp(['     Configuration file ', ...
            'name ', ['CFG_', ProjectName, '.m'] ,' already exists. ' ...
            'Overwrite ? (y/n)']);
        choice = input('     choice >> ','s');
        % Remove space and quotes
        choice=strrep(choice,'''','' ); % remove quotes
        choice=strrep(choice,'"','' ); % remove double quotes
        choice=strrep(choice, ' ','' ); % remove spaces
        
        if isempty(choice)
            disp(' ')
            disp('     wrong input')
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

%% Print header
ConfigFileTitle = 'OpenBDLM configuration file';
Autogen_str = ['Autogenerated by OpenBDLM on ', datestr(now) ];
nshift_1 = 20;
nshift_2 = 10;

fileID_CFG=fopen(configFilename,'w');

fprintf(fileID_CFG,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID_CFG, '\n');
fprintf(fileID_CFG,repmat('%s',1,75),repmat('%',1,1), repmat(' ',1,nshift_1), ...
    ConfigFileTitle, repmat(' ',1,75-(length(ConfigFileTitle)+2+nshift_1)), ...
    repmat('%',1,1) );
fprintf(fileID_CFG, '\n');
fprintf(fileID_CFG,repmat('%s',1,75),repmat('%',1,1), repmat(' ',1,nshift_2), ...
    Autogen_str, repmat(' ',1,75-(length(Autogen_str)+2+nshift_2)), ...
    repmat('%',1,1) );
fprintf(fileID_CFG, '\n');
fprintf(fileID_CFG,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID_CFG, '\n');

%% Print project name
fprintf(fileID_CFG, '\n');
fprintf(fileID_CFG,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID_CFG, '\n');
fprintf(fileID_CFG, '%%%% A - Project name\n');
fprintf(fileID_CFG,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID_CFG, '\n');
fprintf(fileID_CFG,'misc.ProjectName=''%s'';\n',ProjectName);
fprintf(fileID_CFG, '\n');

%% Print data
fprintf(fileID_CFG,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID_CFG, '\n');
fprintf(fileID_CFG, '%%%% B - Data\n');
fprintf(fileID_CFG,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID_CFG, '\n');
fprintf(fileID_CFG,'dat=load(''%s''); \n', dataFilename );
fprintf(fileID_CFG,'data.values=dat.values;\n' );
fprintf(fileID_CFG,'data.timestamps=dat.timestamps;\n');
%fprintf(fileID_CFG,'misc.trainingPeriod=[%d,%d];\n',trainingPeriod);
fprintf(fileID_CFG,'data.labels={');
for i=1:numberOfTimeSeries
    fprintf(fileID_CFG,'''%s''', labels{i});
    if i<numberOfTimeSeries&&numberOfTimeSeries>1
        fprintf(fileID_CFG,',');
    end
end
fprintf(fileID_CFG,'};\n');
fprintf(fileID_CFG,'\n');
%% Print model structure
fprintf(fileID_CFG,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID_CFG, '\n');
fprintf(fileID_CFG,'%%%% C - Model structure \n');
fprintf(fileID_CFG,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID_CFG, '\n');
fprintf(fileID_CFG,'%% Components reference numbers\n');
fprintf(fileID_CFG,'%% 11: Local level\n');
fprintf(fileID_CFG,'%% 12: Local trend\n');
fprintf(fileID_CFG,'%% 13: Local acceleration\n');
fprintf(fileID_CFG,'%% 21: Local level compatible with local trend\n');
fprintf(fileID_CFG,'%% 22: Local level compatible with local acceleration\n');
fprintf(fileID_CFG,'%% 23: Local trend compatible with local acceleration\n');
fprintf(fileID_CFG,'%% 31: Periodic\n');
fprintf(fileID_CFG,'%% 41: Autoregressive\n');
fprintf(fileID_CFG,'%% 51: Kernel regression\n');
fprintf(fileID_CFG,'%% 61: Level Intervention\n');
fprintf(fileID_CFG, '\n');
% Print model components
fprintf(fileID_CFG,'%% Model components\n');
for j=1:nb_models
    fprintf(fileID_CFG,'%% Model %s\n', num2str(j));
    fprintf(fileID_CFG,'model.components.block{%d}={',j);
    for i=1:numberOfTimeSeries
        fprintf(fileID_CFG,'[');
        fprintf(fileID_CFG,'%d ',model.components.block{j}{i});
        fprintf(fileID_CFG,'] ');
    end
    fprintf(fileID_CFG,'};\n');
end
fprintf(fileID_CFG,'\n');
% Print model components constraints
fprintf(fileID_CFG,['%% Model component constrains | Take the same '...
    ' parameter as model class #1\n']);
for j=2:nb_models
    fprintf(fileID_CFG,'model.components.const{%d}={',j);
    for i=1:numberOfTimeSeries
        fprintf(fileID_CFG,'[');
        fprintf(fileID_CFG,'%d ',model.components.const{j}{i});
        fprintf(fileID_CFG,'] ');
    end
    fprintf(fileID_CFG,'};\n');
end

% Print model components interdependencies
fprintf(fileID_CFG,' \n');
fprintf(fileID_CFG,['%% Model inter-components dependence | ' ...
    '{[components form dataset_i depends on components from ' ...
    ' dataset_j]_i,[...]}\n']);
fprintf(fileID_CFG,'model.components.ic={');
for j=1:numberOfTimeSeries
    fprintf(fileID_CFG,'[');
    fprintf(fileID_CFG,'%d ',model.components.ic{1,j});
    fprintf(fileID_CFG,'] ');
end
fprintf(fileID_CFG,'};\n');
fprintf(fileID_CFG, '\n');

%% Print model parameters properties

fprintf(fileID_CFG,'\n');
fprintf(fileID_CFG, repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID_CFG, '\n');
fprintf(fileID_CFG, '%%%% D - Model parameters \n');
fprintf(fileID_CFG, repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID_CFG, '\n');
fprintf(fileID_CFG, 'model.param_properties={\n');
format = ['     %-13s %-15s %-6s %-6s ' ...
    '[%-10s],    %-10s   %-8s %-15s %-15s %-6s %-6s\n'];

fprintf(fileID_CFG, ['     %% #1       ', ...
    '    #2             #3      #4  ', ...
    '  #5               #6      ', ...
    '     #7       #8              #9    ', ...
    '          #10', '\n']);
fprintf(fileID_CFG, ['     %% Param name  ', ...
    ' Block name     Model ', ...
    '  Obs   Bound       ', ...
    '     Prior        Mean     Std   ', ...
    '          Values          Ref', '\n']);
for i=1:size(model.param_properties,1)
    fprintf(fileID_CFG, format, ...
        ['''', model.param_properties{i,1},'''', ','], ...
        ['''',model.param_properties{i,2},'''', ','], ...
        ['''',model.param_properties{i,3}, '''', ','], ...
        ['''', model.param_properties{i,4},'''', ','], ...
        strjoin(cellstr(num2str(model.param_properties{i,5})), ...
        ', '), ...
        ['''', model.param_properties{i,6},'''', ','], ...
        [num2str(model.param_properties{i,7}), ','], ...
        [num2str(model.param_properties{i,8}), ','], ...
        [num2str(model.param_properties{i,9}), ','], ...
        num2str(model.param_properties{i,10}), ...
        ['%#', num2str(i)]);
    
end
fprintf(fileID_CFG, '};\n');
fprintf(fileID_CFG, '\n');


%% Print initial states values
fprintf(fileID_CFG,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID_CFG, '\n');
fprintf(fileID_CFG,'%%%% E - Initial states values \n');
fprintf(fileID_CFG,repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID_CFG, '\n');

for m=1:model.nb_class
    % Expected initial hidden states
    fprintf(fileID_CFG,['%% Initial hidden states ', ...
        'mean for model %s:\n'], num2str(m));
    fprintf(fileID_CFG, 'model.initX{ %s }=[', num2str(m) );
    for i=1:size(model.initX{m},1)
        fprintf(fileID_CFG, '\t%-6.3G', model.initX{m}(i,:));
    end
    fprintf(fileID_CFG,']'';\n');
    fprintf(fileID_CFG,'\n');
    
    % Initial hidden states variance (ignore covariance)
    fprintf(fileID_CFG,['%% Initial hidden ', ...
        'states variance for model %s: \n'], num2str(m));
    
    diagV=diag(model.initV{m});
    
    fprintf(fileID_CFG, 'model.initV{ %s }=diag([ ', num2str(m) );
    for i=1:length(diagV)
        fprintf(fileID_CFG, '\t%-6.3G', diagV(i,:));
    end
    fprintf(fileID_CFG,' ]);\n');
    fprintf(fileID_CFG,'\n');
    fprintf(fileID_CFG,'%% Initial probability for model %s\n', num2str(m));
    for i=1:size(model.initS{m},1)
        fprintf(fileID_CFG,'model.initS{%d}=[%-6.3G];\n', m, model.initS{m});
    end
    fprintf(fileID_CFG,'\n');
end

%% Print options
fprintf(fileID_CFG, repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID_CFG, '\n');
fprintf(fileID_CFG, '%%%% F - Options \n');
fprintf(fileID_CFG, repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID_CFG, '\n');
names = fieldnames(misc.options);

for i=1:length(names)
    
    if strcmp(names{i}, 'trainingPeriod') || ...
            strcmp(names{i}, 'FigurePosition')
        fprintf(fileID_CFG, 'misc.options.%s=[%s];\n', names{i},  ...
            strjoin(cellstr(num2str(misc.options.(names{i}))),', '));
        
    elseif strcmp(names{i}, 'MethodStateEstimation')
        
        fprintf(fileID_CFG, 'misc.options.%s=%s;\n', ...
            names{i}, ['''', num2str(misc.options.(names{i})), '''']);
        
    elseif strcmp(names{i}(1:2), 'is')
        
        if misc.options.(names{i})
        
        fprintf(fileID_CFG, 'misc.options.%s=%s;\n', ...
            names{i},  'true');
        
        else
                 fprintf(fileID_CFG, 'misc.options.%s=%s;\n', ...
            names{i},  'false');   
        end
    else
        fprintf(fileID_CFG, 'misc.options.%s=%s;\n', ...
            names{i}, num2str(misc.options.(names{i})));
    end
end



%% Print custom anomalies
if isfield(misc, 'custom_anomalies')
    fprintf(fileID_CFG,repmat('%s',1,75),repmat('%',1,75));
    fprintf(fileID_CFG, '\n');
    fprintf(fileID_CFG,'%%%% Custom anomalies :\n');
    fprintf(fileID_CFG,repmat('%s',1,75),repmat('%',1,75));
    fprintf(fileID_CFG, '\n');
    fprintf(fileID_CFG,[ ...
        'misc.custom_anomalies.start_custom_anomalies=[' ...
        num2str(misc.custom_anomalies.start_custom_anomalies) '];\n']);
    fprintf(fileID_CFG,[...
        'misc.custom_anomalies.duration_custom_anomalies=[' ...
        num2str(misc.custom_anomalies.duration_custom_anomalies) '];\n']);
    fprintf(fileID_CFG,[...
        'misc.custom_anomalies.amplitude_custom_anomalies=[' ...
        num2str(misc.custom_anomalies.amplitude_custom_anomalies) '];\n']);
    fprintf(fileID_CFG,'\n');
end

fclose(fileID_CFG);
fprintf(fileID,'     Configuration file saved in %s. \n', configFilename );

%--------------------END CODE ------------------------
end
