function [data, model, estimation, misc]=loadInteractive(misc)
%LOADINTERACTIVE Load a new project using interactive mode
%
%   SYNOPSIS:
%     [data, model, estimation, misc]=LOADINTERACTIVE(misc, varargin)
%
%   INPUT:
%      misc                 - structure (required)
%                            see documentation for details about the fields
%                            in structure "misc"
%   OUTPUT:
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
%   DESCRIPTION:
%      LOADINTERACTIVE loads a new project from scratch using interactive mode
%
%   EXAMPLES:
%      [data, model, estimation, misc]=LOADINTERACTIVE(misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%       chooseProjectName, chooseIsDataSimulation,
%       printProjectDateCreation, DataLoader, ModelConfiguration,
%       SimulateData, saveDataBinary, saveDataCSV, saveProject,
%       printConfigurationFile
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also CHOOSEPROJECTNAME, CHOOSEISDATASIMULATION,
%   PRINTPROJECTDATECREATION, DATALOADER, MODELCONFIGURATION, SIMULATEDATA,
%   SAVEDATABINARY, SAVEDATACSV, SAVEPROJECT, PRINTCONFIGURATIONFILE

%   AUTHORS:
%       Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.4.0.813654 (R2018a)
%
%   DATE CREATED:
%       July 26, 2018
%
%   DATE LAST UPDATE:
%       July 27, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'misc', @isstruct );
parse(p, misc);

misc=p.Results.misc;

DataPath=misc.DataPath;
ProjectFilePath=misc.ProjectPath;
ConfigFilePath=misc.ConfigPath;

%% Initialize data, model, estimation
data=struct;
model=struct;
estimation=struct;

% Set fileID for logfile
if misc.isQuiet
    % output message in logfile
    fileID=fopen(misc.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end


fprintf(fileID,['-----------------------------------------', ...
    '-----------------------------------------------------\n']);
disp('     Starting a new project...');
fprintf(fileID,['-----------------------------------------', ...
    '-----------------------------------------------------\n']);
fprintf(fileID,'\n');

%% Choose project name
[misc] =  chooseProjectName(misc, ...
    'FilePath', ProjectFilePath);

%% Choose if project or data simulation
[misc] =  chooseIsDataSimulation(misc);

%% Store date creation
[misc] =  printProjectDateCreation(misc);

if ~misc.isDataSimulation
    %% Load data
    [data, misc, dataFilename ] = DataLoader(misc, ...
        'FilePath', DataPath);
    misc.dataFilename = dataFilename;
end

%% Configure the model
[data, model, estimation, misc] = ...
    ModelConfiguration(data, model, estimation, misc);

if misc.isDataSimulation
    
    %% Simulate data
    [data, model, estimation, misc]= ...
        SimulateData(data, model, misc, 'isPlot', true);
    
    %% Save data in binary format
    [misc, dataFilename] = saveDataBinary(data, misc, ...
        'FilePath', DataPath);
    misc.dataFilename = dataFilename;
    
    %% Save data in CSV format
    [misc] = saveDataCSV(data, misc, 'FilePath', DataPath);
    
    %% Save project
    saveProject(data, model, estimation, misc, ...
        'FilePath', ProjectFilePath)
       
else
    
    %% Save project
    saveProject(data, model, estimation, misc, ...
        'FilePath', ProjectFilePath)
    
end

%% Create config file
[~] = printConfigurationFile(data, model, estimation, misc, ...
    'FilePath', ConfigFilePath);

%--------------------END CODE ------------------------
end
