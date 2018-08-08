function [data, model, estimation, misc]=piloteSimulateData(data, model,estimation, misc)
%PILOTESIMULATEDATA Pilote function to simulate data
%
%   SYNOPSIS:
%     [data, model, estimation, misc]=PILOTESIMULATEDATA(data, model, misc)
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
%      PILOTESIMULATEDATA Pilote function to simulate data
%
%   EXAMPLES:
%      [data, model, estimation, misc]=PILOTESIMULATEDATA(data, model,  misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%
%
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also SIMULATEDATA, SAVEPROJECT, PLOTESTIMATIONS

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
%       July 27, 2018

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

DataPath=misc.DataPath;
ProjectPath=misc.ProjectPath;

disp(' ')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])
disp( '/    Simulate data')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])
disp(' ')
disp('     ...in progress')
disp(' ')

isSimulateFromData=false;

if isfield(data, 'values')
    
    %% Save a copy of original project
    isSimulateFromData=true;
    
    % save data, model, estimation, misc
    dataBackup=data;
    modelBackup=model;
    estimationBackup=estimation;
    miscBackup=misc;
    
    %% Create a new project
    % prevent overwriting by incrementing ProjectName
    ProjectName = incrementProjectName(misc, 'new', misc.ProjectPath );
    misc.ProjectName = ProjectName;
    
    %% Store date creation
    [misc] =  printProjectDateCreation(misc);
        
end

%% Simulate data
[data, model, estimation, misc]= ...
    SimulateData(data, model, misc, 'isPlot', true);

%% Save simulated data
[misc, dataFilename] = saveDataBinary(data, misc, ...
    'Filepath', DataPath);
misc.dataFilename = dataFilename;

%% Save data in CSV format
[misc] = saveDataCSV(data, misc, 'FilePath', DataPath);

%% Save new project
saveProject(data, model, estimation, misc, ...
    'FilePath', ProjectPath)

%% Restore the original project
if isSimulateFromData
    % restore original data, model, estimation, misc
    data=dataBackup;
    model=modelBackup;
    estimation=estimationBackup;
    misc=miscBackup;
end

%--------------------END CODE ------------------------
end
