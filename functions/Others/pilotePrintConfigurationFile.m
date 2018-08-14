function pilotePrintConfigurationFile(data, model, estimation, misc)
%PILOTEPRINTCONFIGURATIONFILE Pilote function to print configuration file
%
%   SYNOPSIS:
%     PILOTEPRINTCONFIGURATIONFILE(data, model, estimation, misc)
%
%   INPUT:
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
%   OUTPUT:
%      N/A
%      Create configuration file and save it in specified directory
%
%   DESCRIPTION:
%      PILOTEPRINTCONFIGURATIONFILE Pilote function to print configuration file
%
%   EXAMPLES:
%      PILOTEPRINTCONFIGURATIONFILE(data, model, estimation, misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%      printConfigurationFile
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also PRINTCONFIGURATIONFILE

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
%       July 27, 2018
%
%   DATE LAST UPDATE:
%       August 9, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'estimation', @isstruct );
addRequired(p,'misc', @isstruct );
parse(p,data, model, estimation, misc );

data=p.Results.data;
model=p.Results.model;
estimation=p.Results.estimation;
misc=p.Results.misc;

ConfigPath=misc.ConfigPath;

% Set fileID for logfile
if misc.isQuiet
    % output message in logfile
    fileID=fopen(misc.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end

fprintf(fileID,'\n');
fprintf(fileID,['-----------------------------------------', ...
    '----------------------------------------------------- \n']);
fprintf(fileID,'/    Export project in configuration file format \n');
fprintf(fileID,['-----------------------------------------', ...
    '----------------------------------------------------- \n']);
fprintf(fileID,'\n');

[~] = printConfigurationFile(data, model, ...
    estimation, misc, 'FilePath', ConfigPath);

%--------------------END CODE ------------------------
end
