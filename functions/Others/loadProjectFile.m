function [data, model, estimation, misc]=loadProjectFile(misc, ProjectIdx)
%LOADPROJECTFILE Load a project from a project file
%
%   SYNOPSIS:
%     [data, model, estimation, misc]=LOADPROJECTFILE(misc, ProjectIdx)
%
%   INPUT:
%
%      misc                 - structure (required)
%                            see documentation for details about the fields
%
%      ProjectIdx           - integer (required)
%                             This is the indice of the project to delete
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
%      LOADPROJECTFILE  loads a project from a project file
%
%   EXAMPLES:
%      [data, model, estimation, misc]=LOADPROJECTFILE(misc, ProjectIdx)
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also

%   AUTHORS:
%      Ianis Gaudot, Luong Ha Nguyen, James-A Goulet,
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
%       September 6, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications

p = inputParser;

validation_Fct_ProjectIdx = @(x) ...
    ~ischar(x) && ~any(mod(x,1)) && isempty(x(x<1)) && length(x)==1 ;

addRequired(p,'misc', @isstruct );
addRequired(p,'ProjectIdx', validation_Fct_ProjectIdx );

parse(p,misc, ProjectIdx);
ProjectIdx=p.Results.ProjectIdx;

ProjectInfofile=misc.internalVars.ProjectInfoFilename;
ProjectPath=misc.internalVars.ProjectPath;
DataPath = misc.internalVars.DataPath;

% Set fileID for logfile
if misc.internalVars.isQuiet
   % output message in logfile
   fileID=fopen(misc.internalVars.logFileName, 'a');  
else
   % output message on screen and logfile using diary command
   fileID=1; 
end


% Load project info file array
FileContent = load(fullfile(pwd, ProjectPath,ProjectInfofile));
ProjectInfo = FileContent.ProjectInfo;

if isempty(ProjectInfo)
    fprintf(fileID, '\n');
    fprintf(fileID, '     There is no saved project to load.\n');
    data=[];
    model=[];
    estimation=[];
    
    fprintf(fileID, '\n');
    return
end

% Get number of saved projects
NumberOfSavedProjects = size(ProjectInfo,1);

% Remove indices out of range
ProjectIdx(ProjectIdx>NumberOfSavedProjects) = [];

if isempty(ProjectIdx)
    fprintf(fileID, '\n');
    fprintf(fileID, '     wrong input\n');
    
    data=[];
    model=[];
    estimation=[];
    
    return
else
    
    % Save current misc variable about reading mode and quietness
    InteractiveMode_s= misc.internalVars.InteractiveMode;
    ReadFromConfigFileMode_s = misc.internalVars.ReadFromConfigFileMode;
    BatchMode_s = misc.internalVars.BatchMode;
    isQuiet_s = misc.internalVars.isQuiet;
    logFileName_s=misc.internalVars.logFileName;
    
    %% Load the project
    disp('     Loading project...')
    load(ProjectInfo{ProjectIdx,3});
    
    %% Load the data
    dataFilename = ['DATA_', misc.ProjectName,'.mat'];
    data=load(fullfile(DataPath, 'mat', dataFilename));
    
    % Set empty structure for estimation if it does not exist
    if ~exist('estimation', 'var')
        estimation=struct;
    end
    
    % Restore current misc variable about reading mode
    misc.internalVars.InteractiveMode = InteractiveMode_s;
    misc.internalVars.ReadFromConfigFileMode = ReadFromConfigFileMode_s;
    misc.internalVars.BatchMode = BatchMode_s;
    misc.internalVars.isQuiet = isQuiet_s;
    misc.internalVars.logFileName=logFileName_s;
    
end
%--------------------END CODE ------------------------
end
