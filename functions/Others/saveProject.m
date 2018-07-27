function saveProject(data, model, estimation, misc, varargin)
%SAVEPROJECT Save full project (data, model, estimation, misc) in file
%
%   SYNOPSIS:
%      saveProject(data, model, estimation, misc, varargin)
%
%   INPUT:
%      data         - structure (required)
%                     see documentation for details about the fiels of data
%
%      model        - structure (required)
%                     see documentation for details about the fiels of
%                     model
%
%      estimation   - structure (required)
%                     see documentation for details about the fiels of
%                     estimation
%
%      misc         - structure (required)
%                     see documentation for details about the fiels of misc
%
%      FilePath   - character (optional)
%                   directory where to save the file
%                   default: '.'  (current folder)
%
%   OUTPUT:
%      N/A
%      Matlab binary file with extension .mat saved in FilePath location.
%
%   DESCRIPTION:
%      SAVEPROJECT save full project (data, model, estimation, misc) in a
%      Matlab .mat binary file in specified location given by FilePath
%
%   EXAMPLES:
%      SAVEPROJECT(data, model, estimation, misc)
%      SAVEPROJECT(data, model, estimation, misc, 'FilePath', './saved_projects')
%
%   EXTERNAL FUNCTIONS CALLED:
%      testFileExistence
%
%   See also INITIALIZEPROJECT, TESTFILEEXISTENCE

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
%       April 18, 2018
%
%   DATE LAST UPDATE:
%       June 11, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;
defaultFilePath = '.';

validationFct_FilePath = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p, 'data', @isstruct)
addRequired(p, 'model', @isstruct)
addRequired(p, 'estimation', @isstruct)
addRequired(p, 'misc', @isstruct)
addParameter(p,'FilePath', defaultFilePath, validationFct_FilePath );

parse(p,data, model, estimation, misc, varargin{:});

data=p.Results.data;
model=p.Results.model;
estimation=p.Results.estimation;
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

%% Get project name to name project file
if isfield(misc, 'ProjectName')
    project_name = misc.ProjectName;
else
    disp(' ')
    disp('     ERROR: Unable to read project name from the structure. ')
    disp(' ')
    return
end

if ischar(project_name)
    % Remove space and quotes
    project_name=strrep(project_name,'''','' ); % remove single quotes
    project_name=strrep(project_name,'"','' ); % remove double quotes
    project_name=strrep(project_name, ' ','' ); % remove spaces
end

if isempty(project_name)
    disp(' ')
    disp('     ERROR: Unable to read project name from the structure. ')
    disp(' ')
    return
else
    name_projectfile=['PROJ_', project_name, '.mat'];
    fullname=fullfile(FilePath, name_projectfile);
end

% Gather in a single structure for future saving
dat.data=data;
dat.model=model;
dat.estimation=estimation;
dat.misc=misc;

%% Save binary file in specified location
save(fullname, '-struct', 'dat')
fprintf('     Project saved in %s. \n', fullfile(FilePath, name_projectfile ));


%% Add information specific file if required

ProjectsInfoFilename = 'ProjectsInfo.mat';

% Load file 
FileContent = load(fullfile(pwd, FilePath, ProjectsInfoFilename));
ProjectInfo = FileContent.ProjectInfo;

if ~isempty(ProjectInfo)
    Test_Name = strcmp(ProjectInfo(:,1), project_name);    
    Test_Date = strcmp(ProjectInfo(:,2), project_name);

    if ~any(Test_Name) && ~any(Test_Date)
    
        % add a new line
        ProjectInfo  = [ProjectInfo ; { project_name, ...
            misc.ProjectDateCreation, fullname }];
                
    elseif any(Test_Name) && ~any(Test_Date)
        
        ProjectInfo{Test_Name,2} =  misc.ProjectDateCreation;
        
    end
    % save
    save(fullfile(pwd, FilePath, ProjectsInfoFilename), 'ProjectInfo' );
       
else
    % add a new line
    ProjectInfo  = [ProjectInfo ; { project_name, ...
        misc.ProjectDateCreation, fullname }];
    % save
    save(fullfile(pwd, FilePath, ProjectsInfoFilename), 'ProjectInfo' );
end

%--------------------END CODE ------------------------
end
