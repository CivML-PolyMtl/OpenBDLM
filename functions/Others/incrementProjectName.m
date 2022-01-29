function [ProjectName]=incrementProjectName(misc, ReferenceName, FilePath)
%INCREMENTPROJECTNAME Increment project name to avoid overwriting
%
%   SYNOPSIS:
%     [misc]=INCREMENTPROJECTNAME(misc,ReferenceName, FilePath)
%
%   INPUT:
%      misc          - structure (required)
%
%      ReferenceName - character (required)
%                      Name without increment
%
%      FilePath      - character (required)
%                      Saving directory for projects
%
%   OUTPUT:
%      ProjectName   - character
%                      Project name to consider to avoid overwriting others
%                      file
%
%   DESCRIPTION:
%      INCREMENTPROJECTNAME increments project name to avoid overwriting
%      INCREMENTPROJECTNAME gathers existing project name from project files
%      saved in FilePath
%
%   EXAMPLES:
%      [misc]=INCREMENTPROJECTNAME(misc,'new_', './saved_projects')
%
%   See also INCREMENTFILENAME

%   AUTHORS:
%      Ianis Gaudot, James-A Goulet, Luong Ha Nguyen
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       April 25, 2018
%
%   DATE LAST UPDATE:
%       September 17, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

validationFct_FilePath = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p,'misc', @isstruct );
addRequired(p,'ReferenceName', validationFct_FilePath );
addRequired(p,'FilePath', validationFct_FilePath );

parse(p,misc, ReferenceName, FilePath);

misc=p.Results.misc;
ReferenceName=p.Results.ReferenceName;
FilePath=p.Results.FilePath;


%% Gather already existing project name from saved projects
% Load file that contains info about already saved projects

ProjectsInfoFilename = misc.internalVars.ProjectInfoFilename;

% Load file 
FileContent = load(fullfile(pwd, FilePath, ProjectsInfoFilename));
ProjectInfo = FileContent.ProjectInfo;

if ~isempty(ProjectInfo)   
    Index_Name = strfind(upper(ProjectInfo(:,1)),upper(ReferenceName) );
    Test_Name = find(not(cellfun('isempty', Index_Name)));
    ProjectInfo = ProjectInfo(Test_Name,1);
end

%ProjectInfo = ProjectInfo(Test_Name,1);

if ~isempty(ProjectInfo)
    res_1=strsplit(ProjectInfo{end}, '_');
    num=str2double(res_1{end});
    num=num+1; % increment filename    
    ProjectName=[ ReferenceName,'_' , num2str(num,'%03d')];
else
    num = 1;
    ProjectName=[ ReferenceName, '_' , num2str(num,'%03d')];
end
%--------------------END CODE ------------------------
end
