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
%       December 8, 2018

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

% Format
NumberOfZeros=3;
fmt=['%0',num2str(NumberOfZeros),'d'];

MaxIncrementalName=10^(NumberOfZeros)-1;

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

if ~isempty(ProjectInfo)
    num=0;
    for i=1:length(ProjectInfo)
        
        file  = ProjectInfo{i};
        if  length(file) == (length(ReferenceName)+1+NumberOfZeros) && ...
                strcmp(file(1:length(ReferenceName)), ReferenceName)
            
            numc= str2double(file(length(ReferenceName)+2: ...
                length(ReferenceName)+1+NumberOfZeros));
            
            if numc > num
                num = numc;
            end
            
        end
        
    end
        
    num=num+1; % increment filename
    
    if num > MaxIncrementalName
        disp(' ')
        warning('Impossible to increment filename.')
        disp(' ')
        num=num-1;
    end
    
    ProjectName=[ ReferenceName, '_' , num2str(num,fmt)];
    
else
    num = 1;
    ProjectName=[ ReferenceName, '_' , num2str(num,fmt)];
    
end
%--------------------END CODE ------------------------
end
