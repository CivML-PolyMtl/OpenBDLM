function deleteProject(misc, ProjectIdx)
%DELETEPROJECT Delete existing project file(s)
%
%   SYNOPSIS:
%     DELETEPROJECT(misc, ProjectIdx)
%
%   INPUT:
%      misc                 - structure (required)
%                            see documentation for details about the fields
%                            in structure "misc"
%
%      ProjectIdx           - 1xM array of integer (required)
%                             This is the indices of the project to delete
%
%   OUTPUT:
%      N/A
%      Deleted existing project files.
%
%   DESCRIPTION:
%      DELETEPROJECT deletes project file(s).
%      The projects to delete are identified by the argument ProjectIdx.
%      The location of the file(s) to delete is read from the FilePath.
%
%   EXAMPLES:
%      DELETEPROJECT(misc, 2)
%      DELETEPROJECT(misc, [2,5,6])
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also

%   AUTHORS:
%       Ianis Gaudot, Luong Ha Nguyen, James-A Goulet,
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

validation_Fct_ProjectIdx = @(x) ...
    ~ischar(x) && ~any(mod(x,1)) && isempty(x(x<1));

addRequired(p,'misc', @isstruct );
addRequired(p,'ProjectIdx', validation_Fct_ProjectIdx );

parse(p,misc, ProjectIdx);

misc=p.Results.misc;
ProjectIdx=p.Results.ProjectIdx;

FilePath = misc.ProjectPath;
ProjectInfofile = misc.ProjectInfoFilename;

% Load project info file array
FileContent = load(fullfile(pwd, FilePath,ProjectInfofile));
ProjectInfo = FileContent.ProjectInfo;

% Get number of saved projects
NumberOfSavedProjects = size(ProjectInfo,1);

% Remove indices out of range
ProjectIdx(ProjectIdx>NumberOfSavedProjects) = [];

if isempty(ProjectIdx)
    disp(' ')
    disp('     wrong input')
    disp(' ')
    return
else
    % Gather names of project to remove
    ProjectList = ProjectInfo(ProjectIdx,1);
    fprintf(['     Are you sure you want to delete ', ...
        'the following projects: ']);
    fprintf('%s, ', ProjectList{1:end});
    fprintf('?\n')
    
    isYesNoCorrect= false;
    while ~isYesNoCorrect
        choice = input('     (y/n) >> ','s');
        if isempty(choice)
            disp(' ')
            disp('     wrong input')
            disp(' ')
        elseif strcmpi(choice,'y') || strcmpi(choice,'yes')
            
            % Delete project file
            delete(ProjectInfo{ProjectIdx,3});
            
            % Delete info in FileInfo
            ProjectInfo(ProjectIdx,:) = [];
            save(fullfile(pwd, FilePath, ...
                ProjectInfofile), 'ProjectInfo' );
            disp(' ')
            disp('     The projects files have been deleted')
            disp(' ')
            
            isYesNoCorrect =  true;
            
        elseif strcmpi(choice,'n') || strcmpi(choice,'no')
            disp(' ')
            fprintf('     No project files have been deleted.\n')
            disp(' ')
            isYesNoCorrect =  true;          
        else
            disp(' ')
            disp('     wrong input')
            disp(' ')
        end
        
    end
       
end

%--------------------END CODE ------------------------
end
