function [misc]=chooseProjectName(misc, varargin)
%CHOOSEPROJECTNAME Request user's input to choose a project name
%   SYNOPSIS:
%     [misc]=CHOOSEPROJECTNAME(misc, varargin)
% 
%   INPUT:
%      misc     - structure (required)
%
%      FilePath - character (optional)
%                 saving directory for the project file
%                 default: '.' (current directory)
%   OUTPUT:
%      misc     - structure
%
%   DESCRIPTION:
%      CHOOSEPROJECTNAME request user's input to choose a project name
%      CHOOSEPROJECTNAME verifies that the provided project name does not 
%      already exist from previously saved projects located in the
%      "FilePath" location given in argument. 
%
%   EXAMPLES:
%      [misc]=CHOOSEPROJECTNAME(misc)
%      [misc]=CHOOSEPROJECTNAME(misc, 'FilePath', 'saved_projects')
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
%       April 27, 2018
% 
%   DATE LAST UPDATE:
%       April 27, 2018
 
%--------------------BEGIN CODE ---------------------- 
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

validationFct_FilePath = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

defaultFilePath = '.';

addRequired(p,'misc', @isstruct );
addParameter(p,'FilePath', defaultFilePath, validationFct_FilePath );

parse(p,misc, varargin{:});
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

% define global variable for user's answers from input file
global isAnswersFromFile AnswersFromFile AnswersIndex    
 
%% Gather already existing project name from saved projects
% List files in specified directory
% pattern = 'PROJ*.mat';
% fullpattern = fullfile(FilePath, pattern);
% info_file=dir(fullpattern);
% info_file=info_file(~ismember({info_file.name},{'.','..', '.DS_Store'}));
% 
% disp(' ')
% if ~isempty(info_file)
%     ProjectInfo= cell(length(info_file),1);
%     
%     for i=1:length(info_file)
%         dat=load(fullfile(FilePath, info_file(i).name));
%         ProjectInfo{i} = dat.misc.ProjectName;
%     end
% end 

ProjectsInfoFilename = 'ProjectsInfo.mat';

% Load file display info 
FileContent = load(fullfile(FilePath, ProjectsInfoFilename));    
ProjectInfo = FileContent.ProjectInfo;


%% Get project name from user's input
isNameCorrect = false;
while ~isNameCorrect
    disp(' ')
    disp('- Enter a project name (max 25 characters):')
    % read from user input file (use of global variable )?
    if isAnswersFromFile
        project_name=eval(char(AnswersFromFile{1}(AnswersIndex)));
        disp(['     ',project_name])
    else
        project_name=input('     choice >> ','s');
    end
    
    if ischar(project_name)
        % Remove space and quotes
        project_name=strrep(project_name,'''','' ); % remove single quotes
        project_name=strrep(project_name,'"','' ); % remove double quotes
        project_name=strrep(project_name, ' ','' ); % remove spaces
    end
    
    if isempty(project_name)
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%')
        disp(' ')
        disp(' Choose the name of the project.')
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%')
        disp(' ')
    elseif length(project_name)>25
        disp('     wrong input -> string > 25 characters')
    else
        
        if ~isempty(ProjectInfo)
        
         Test_Name = strcmp(ProjectInfo(:,1), project_name);
               
        if any(Test_Name)
            fprintf(['     Project name %s already exists.' ...
                ' Provide another name. \n'], project_name)
            isNameCorrect = false;
        else
            isNameCorrect = true;
        end
        else            
            isNameCorrect = true;
        end
    end
end

%% Store project name
misc.ProjectName = project_name;

% Increment global variable to read next answer when required
AnswersIndex = AnswersIndex + 1;
%--------------------END CODE ------------------------ 
end
