function [data, model, estimation, misc]=loadConfigurationFile(misc, ConfigFileName)
%LOADCONFIGURATIONFILE Load a new project from a configuration file
%
%   SYNOPSIS:
%     [data, model, estimation, misc]=LOADCONFIGURATIONFILE(ConfigFileName, ConfigFilePath,ProjectFilePath )
%
%   INPUT:
%      misc                 - structure (required)
%                            see documentation for details about the fields
%                            in structure "misc"
%
%      ConfigFileName       - character (required)
%                             Name of the configuration file
%
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
%      LOADCONFIGURATIONFILE loads a project from a configuration file.
%
%   EXAMPLES:
%      [data, model, estimation, misc]=LOADCONFIGURATIONFILE(misc, 'CFG_test1.m')
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also

%   AUTHORS:
%       Ianis Gaudot, Luong Ha Nguyen,  James-A Goulet
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
%       August 9, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

validation_Fct_ProjectInfoFile = @(x) ...
    ischar(x) && ~isempty(x(~isspace(x)));

addRequired(p,'misc', @isstruct );
addRequired(p,'ConfigFileName', validation_Fct_ProjectInfoFile );
parse(p, misc, ConfigFileName);

misc=p.Results.misc;
ConfigFileName=p.Results.ConfigFileName;

%ProjectFilePath=misc.internalVars.ProjectPath;

% Set fileID for logfile
if misc.internalVars.isQuiet
   % output message in logfile
   fileID=fopen(misc.internalVars.logFileName, 'a');  
else
   % output message on screen and logfile using diary command
   fileID=1; 
end

% Save current misc variable about reading mode
InteractiveMode_s= misc.internalVars.InteractiveMode;
ReadFromConfigFileMode_s = misc.internalVars.ReadFromConfigFileMode;
BatchMode_s = misc.internalVars.BatchMode;

%% Load a configuration file
fprintf(fileID,'\n');
fprintf(fileID,['-----------------------------------------', ...
    '----------------------------------------------------- \n']);
disp('     Loading configuration file...');
fprintf(fileID,['-----------------------------------------', ...
    '----------------------------------------------------- \n']);
fprintf(fileID,'\n');
% fprintf(fileID,'     ...in progress \n');
% fprintf(fileID,'\n');

%% Run the configuration file
run(ConfigFileName);

%% Initialize variable estimation as a structure
estimation = struct;

%% Save the project date creation
[misc]=printProjectDateCreation(misc);
%% Build the model
[model, misc] = buildModel(data, model, misc);

% Restore misc variable about reading mode
misc.internalVars.InteractiveMode = InteractiveMode_s;
misc.internalVars.ReadFromConfigFileMode = ReadFromConfigFileMode_s;
misc.internalVars.BatchMode = BatchMode_s;

%% Set default variable
%[misc]=setDefaultConfig(misc, data);

%% Save the project
% saveProject(data, model, estimation, misc,'FilePath', ProjectFilePath);

%--------------------END CODE ------------------------
end
