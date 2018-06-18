function [configFilename] = printConfigurationFile(data, model, estimation, misc, varargin)
%PRINTCONFIGURATIONFILE Create and print a configuration file
%
%   SYNOPSIS:
%     [configFilename] = PRINTCONFIGURATIONFILE(data, model, estimation, misc, varargin)
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
%      configFilename         - character
%                               name of the printed configuration file
%
%   DESCRIPTION:
%      PRINTCONFIGURATIONFILE creates a configuration file in the directory
%      specified by "Filepath"
%      Important : PRINTCONFIGURATIONFILE overwrites previous file with
%      same name without notification
%
%   EXAMPLES:
%      [configFilename] = PRINTCONFIGURATIONFILE(data, model, estimation, misc)
%      [configFilename] = ]PRINTCONFIGURATIONFILE(data, model, estimation, misc, 'FilePath', 'config_files')
%
%   EXTERNAL FUNCTIONS CALLED:
%
%   SUBFUNCTIONS:
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
%       April 26, 2018

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

%% Remove space in filename
FilePath = FilePath(~isspace(FilePath));

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
% Get data file
dataFilename = misc.dataFilename;
% isDataSimulation
isDataSimulation = misc.isDataSimulation;

%% %% Gather already existing project name from saved projects
% List files in specified directory
pattern = 'CFG*.m';
fullpattern = fullfile(FilePath, pattern);
info_file=dir(fullpattern);
info_file=info_file(~ismember({info_file.name},{'.','..', '.DS_Store'}));

disp(' ')
if ~isempty(info_file)
    FileInfo= cell(length(info_file),1);
    for i=1:length(info_file)
        FileInfo{i} = info_file(i).name;
    end
end


if ~isempty(info_file)
    if any(ismember(upper(FileInfo), upper(['CFG_', ProjectName, '.m'])))
        fprintf(['Configuration file name %s already exists.' ...
            '\n'], ['CFG_', ProjectName, '.m'])
        isNameCorrect = false;
    else
        isNameCorrect = true;
    end
else
    isNameCorrect = true;
end

if ~isNameCorrect
    isAnswerCorrect = false;
    while ~isAnswerCorrect
        disp(' ')
        disp('Do you want to overwrite ? (y/n)')
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
        elseif strcmp(choice,'y') || strcmp(choice,'yes') ||  ...
                strcmp(choice,'Y') || strcmp(choice,'Yes')  || ...
                strcmp(choice,'YES')
            FileName = fullfile(FilePath, ['CFG_' ProjectName '.m']);
            isAnswerCorrect =  true;
        elseif strcmp(choice,'n') || strcmp(choice,'no') ||  ...
                strcmp(choice,'N') || strcmp(choice,'No')  || ...
                strcmp(choice,'NO')
            [name]=incrementFilename('CFG_new', ...
                'config_files', 'FileExtension', 'm');
            FileName = fullfile(FilePath, name);
            isAnswerCorrect = true;
        else
            disp(' ')
            disp('     wrong input')
            disp(' ')
            continue
        end
        
    end
else
    FileName = fullfile(FilePath, ['CFG_' ProjectName '.m']);
end

%% Create configuration file
fileID=fopen(FileName,'w');

fprintf(fileID,['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ' ...
    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n']);
fprintf(fileID,'%%%% Project file_data reference\n');
fprintf(fileID,'[data, model, estimation, misc]=initializeProject;\n');
fprintf(fileID,'[misc]=printProjectDateCreation(misc);\n');
fprintf(fileID,'misc.ProjectName=''%s'';\n',ProjectName);
fprintf(fileID,'dat=load(''%s''); \n', dataFilename );
fprintf(fileID,'data.values=dat.values;\n' );
fprintf(fileID,'data.timestamps=dat.timestamps;\n');
fprintf(fileID,'misc.trainingPeriod=[%d,%d];\n',trainingPeriod);
fprintf(fileID,'misc.dataFilename=''%s'';\n',dataFilename);
fprintf(fileID,'misc.isDataSimulation=%d;\n',isDataSimulation);
if isfield(misc, 'method') && ~isempty(misc.method)
    fprintf(fileID,'misc.method=''%s'';\n\n',misc.method);
else
    fprintf(fileID,'misc.method=''kalman'';\n\n');
end

fprintf(fileID,'%%%% Data\n');
fprintf(fileID,'data.labels={');
for i=1:numberOfTimeSeries
    fprintf(fileID,'''%s''', labels{i});
    if i<numberOfTimeSeries&&numberOfTimeSeries>1
        fprintf(fileID,',');
    end
end
fprintf(fileID,'};\n\n');

%% Print model components for each time series and model class
fprintf(fileID,['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' ...
    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n']);
fprintf(fileID,'%% BDLM Component reference numbers\n');
fprintf(fileID,['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' ...
    '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n']);
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
fprintf(fileID,['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' ...
    '%%%%%%%%%%%%%%%%%%%%%%%\n\n']);
fprintf(fileID,['%%%% Model components | Choose which ' ...
    'component to employ to build the model\n']);
for j=1:nb_models
    fprintf(fileID,'model.components.block{%d}={',j);
    for i=1:numberOfTimeSeries
        fprintf(fileID,'[');
        fprintf(fileID,'%d ',model.components.block{j}{i});
        fprintf(fileID,'] ');
    end
    fprintf(fileID,'};\n');
end
fprintf(fileID,'\n');
%% Print model components constrains
fprintf(fileID,['%%%% Model component constrains | Take the same '...
    ' parameter as model class #1\n']);
fprintf(fileID,' \n');

for j=2:nb_models
    fprintf(fileID,'model.components.const{%d}={',j);
    for i=1:numberOfTimeSeries
        fprintf(fileID,'[');
        fprintf(fileID,'%d ',model.components.const{j}{i});
        fprintf(fileID,'] ');
    end
    fprintf(fileID,'};\n\n');
end

%% Print model components interdependencies
fprintf(fileID,' \n');
fprintf(fileID,['%%%% Model inter-components dependence | ' ...
    '{[components form dataset_i depends on components form ' ...
    ' dataset_j]_i,[...]}\n']);
fprintf(fileID,'model.components.ic={');
for j=1:numberOfTimeSeries
    fprintf(fileID,'[');
    fprintf(fileID,'%d ',model.components.ic{1,j});
    fprintf(fileID,'] ');
end
fprintf(fileID,'};\n\n');
fprintf(fileID,' \n');

%% Print model parameters information
fprintf(fileID,' \n');
fprintf(fileID,'%%%% Model parameters information :\n');
fprintf(fileID,' \n ');
fprintf(fileID,'model.param_properties={\n');
for i=1:size(model.param_properties,1)
    space=repmat(' ',1,8-length(model.param_properties{i,1}));

    fprintf(fileID,['\t %-s''%-s'',\t''%-s'' ,\t''%-s'',\t'  ...
        '''%-s'',\t[ %-5G, %-5G]\t %%#%d \n'], ...
        space, model.param_properties{i,:}, i);

end
fprintf(fileID,'};\n');

fprintf(fileID,' \n');
fprintf(fileID,'model.parameter=[\n');
for i=1:size(model.parameter,1)
    fprintf(fileID,'%-8.5G \t %%#%d \n', model.parameter(i),i);
end
fprintf(fileID,'];\n ');

fprintf(fileID,' \n');
fprintf(fileID,['model.p_ref=[' num2str(model.p_ref) '];\n']);
fprintf(fileID,' \n');

%% Print initial states
fprintf(fileID,'%%%% Initial states values :\n');
fprintf(fileID,' \n ');
for m=1:model.nb_class
    fprintf(fileID, 'model.initX{ %s }=[\n', num2str(m) );
    for i=1:size(model.initX{m},1)
        fprintf(fileID, '\t%-6.3G \n', model.initX{m}(i,:));
    end
    fprintf(fileID,'];\n');
    
    fprintf(fileID,' \n');
    fprintf(fileID,'model.initV{ %s }=[\n',  num2str(m) );
    for i=1:size(model.initV{m},1)
        fprintf(fileID, '\t%-8.3G', model.initV{m}(i,:));
        fprintf(fileID, '\n');
    end
    fprintf(fileID,'];\n');
    
    fprintf(fileID,' \n');
    for i=1:size(model.initS{m},1)
        fprintf(fileID,'model.initS{%d}=[%-6.3G];\n', m, model.initS{m});
    end
    fprintf(fileID,'\n');
end
fprintf(fileID,'\n');

%% Custom anomalies
if isfield(misc, 'custom_anomalies')
    fprintf(fileID,'%%%% Custom anomalies :\n');
    fprintf(fileID,' \n');
    fprintf(fileID,['misc.custom_anomalies.start_custom_anomalies=[' ...
        num2str(misc.custom_anomalies.start_custom_anomalies) '];\n']);
    fprintf(fileID,['misc.custom_anomalies.duration_custom_anomalies=[' ...
        num2str(misc.custom_anomalies.duration_custom_anomalies) '];\n']);
    fprintf(fileID,['misc.custom_anomalies.amplitude_custom_anomalies=[' ...
        num2str(misc.custom_anomalies.amplitude_custom_anomalies) '];\n']);
    fprintf(fileID,'\n');
end

configFilename = FileName;

fprintf('     New configuration file saved as %s\n', FileName )
%--------------------END CODE ------------------------
end
