function saveProject(model, estimation, misc, varargin)
%SAVEPROJECT Save the structure variables model, estimation, misc in project file
%
%   SYNOPSIS:
%      saveProject(model, estimation, misc, varargin)
%
%   INPUT:
%
%      model                - structure (required)
%                             see documentation for details about the
%                             fields of model
%
%      estimation           - structure (required)
%                             see documentation for details about the
%                             fields of estimation
%
%      misc                 - structure (required)
%                            see documentation for details about the
%                            fields of misc
%
%      FilePath             - character (optional)
%                             directory where to save the Project file
%                             default: '.'  (current folder)
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
%      SAVEPROJECT(model, estimation, misc)
%      SAVEPROJECT(model, estimation, misc, 'FilePath', './saved_projects')
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
%       December 3, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;
defaultFilePath = '.';

validationFct_FilePath = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p, 'model', @isstruct)
addRequired(p, 'estimation', @isstruct)
addRequired(p, 'misc', @isstruct)
addParameter(p,'FilePath', defaultFilePath, validationFct_FilePath );

parse(p, model, estimation, misc, varargin{:});

model=p.Results.model;
estimation=p.Results.estimation;
misc=p.Results.misc;
FilePath=p.Results.FilePath;

MaxSizeEstimation = misc.options.MaxSizeEstimation;
ProjectsInfoFilename = misc.internalVars.ProjectInfoFilename;

% Set fileID for logfile
if misc.internalVars.isQuiet
    % output message in logfile
    fileID=fopen(misc.internalVars.logFileName, 'a');
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

%% Get project name to name project file
if isfield(misc, 'ProjectName')
    project_name = misc.ProjectName;
else
    disp(' ')
    error('Unable to read project name from the structure.');
end

if ischar(project_name)
    % Remove space and quotes
    project_name=strrep(project_name,'''','' ); % remove single quotes
    project_name=strrep(project_name,'"','' ); % remove double quotes
    project_name=strrep(project_name, ' ','' ); % remove spaces
end

if isempty(project_name)
    disp(' ')
    error('Unable to read project name from the structure.');
else
    name_projectfile=['PROJ_', project_name, '.mat'];
    fullname=fullfile(FilePath, name_projectfile);
end


% Get the size of estimation variable in Mb

EstimationInfo=whos('estimation');
EstimationSize=EstimationInfo.bytes/1000000;

isSaveEstimation = true;
if EstimationSize > MaxSizeEstimation
    % Create empty structure
    estimation=struct;    
    isSaveEstimation = false;
end

% Gather in a single structure for future saving
dat.model=model;
dat.estimation=estimation;
dat.misc=misc;

%% Save project binary file in specified location
disp('     Saving project...')
if ~isSaveEstimation
    warning(['Estimations are not saved ', ...
        'because size (%s Mb) > threshold (%s Mb) set in ', ...
        'misc.options.MaxSizeEstimation \n'], num2str(EstimationSize), ...
        num2str(MaxSizeEstimation));   
end

save(fullname, '-struct', 'dat')
fprintf(fileID, '     Project saved in %s. \n', ...
    fullfile(FilePath, name_projectfile ));

%% Add information specific file if required
% Test existence of the file that contains all information about projects
[isFileExist] = ...
    testFileExistence(fullfile(pwd, FilePath, ProjectsInfoFilename), 'file');
% If not existing create the file
if ~isFileExist
    ProjectInfo = {};
    % create file
    save(fullfile(pwd, FilePath, ProjectsInfoFilename), 'ProjectInfo');
end

% Load the file
FileContent = load(fullfile(pwd, FilePath, ProjectsInfoFilename));
ProjectInfo = FileContent.ProjectInfo;

if ~isempty(ProjectInfo)
    Test_Name = strcmp(ProjectInfo(:,1), project_name);
    Test_Date = strcmp(ProjectInfo(:,2), project_name);
    
    if ~any(Test_Name) && ~any(Test_Date)
        
        % add a new line
        ProjectInfo  = [ProjectInfo ; { project_name, ...
            misc.internalVars.ProjectDateCreation, fullname }];
        
    elseif any(Test_Name) && ~any(Test_Date)
        % overwrite project but change date of creation
        ProjectInfo{Test_Name,2} =  misc.internalVars.ProjectDateCreation;
        
    end
    % save
    save(fullfile(pwd, FilePath, ProjectsInfoFilename), 'ProjectInfo' );
    
else
    % add a new line
    ProjectInfo  = [ProjectInfo ; { project_name, ...
        misc.internalVars.ProjectDateCreation, fullname }];
    % save
    save(fullfile(pwd, FilePath, ProjectsInfoFilename), 'ProjectInfo' );
end

%--------------------END CODE ------------------------
end
