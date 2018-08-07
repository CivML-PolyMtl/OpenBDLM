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
%       Luong Ianis Gaudot, Ha Nguyen, James-A Goulet,
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
%       July 26, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications

p = inputParser;

validation_Fct_ProjectIdx = @(x) ...
    ~ischar(x) && ~any(mod(x,1)) && isempty(x(x<1)) && length(x)==1 ;

addRequired(p,'misc', @isstruct );
addRequired(p,'ProjectIdx', validation_Fct_ProjectIdx );

parse(p,misc, ProjectIdx);
ProjectIdx=p.Results.ProjectIdx;

ProjectInfofile=misc.ProjectInfoFilename;
FilePath=misc.ProjectPath;

% Load project info file array
FileContent = load(fullfile(pwd, FilePath,ProjectInfofile));
ProjectInfo = FileContent.ProjectInfo;

if isempty(ProjectInfo)
    disp(' ')
    disp('     There is no saved project to load.')
    data=[];
    model=[];
    estimation=[];
    
    disp(' ')
    return
end

% Get number of saved projects
NumberOfSavedProjects = size(ProjectInfo,1);

% Remove indices out of range
ProjectIdx(ProjectIdx>NumberOfSavedProjects) = [];

if isempty(ProjectIdx)
    disp(' ')
    disp('     wrong input')
    
    data=[];
    model=[];
    estimation=[];
    
    return
else
    
    % Save current misc variable about reading mode
    InteractiveMode_s= misc.InteractiveMode;
    ReadFromConfigFileMode_s = misc.ReadFromConfigFileMode;
    BatchMode_s = misc.BatchMode;
    
    %% Load the project
    load(ProjectInfo{ProjectIdx,3});
    
    % Restore current misc variable about reading mode
    misc.InteractiveMode = InteractiveMode_s;
    misc.ReadFromConfigFileMode = ReadFromConfigFileMode_s;
    misc.BatchMode = BatchMode_s;
    
end
%--------------------END CODE ------------------------
end
