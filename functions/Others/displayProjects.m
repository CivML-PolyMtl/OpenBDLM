function [ProjectInfo]=displayProjects(varargin)
%DISPLAYPROJECTS displays on screen information about saved projects
%
%   SYNOPSIS:
%     DISPLAYPROJECTS(varargin)
%
%   INPUT:
%      FilePath    - character (optional)
%                    directory where to save the file
%                    default: '.'  (current folder)
%
%   OUTPUT:
%      ProjectInfo - cell array
%                    info about each project
%      
%
%   DESCRIPTION:
%      DISPLAYPROJECTS displays on screen information about saved projects
%      DISPLAYPROJECTS search for Matlab binary PROJ_*.mat file in
%      specified location given by FilePath
%
%   EXAMPLES:
%      displayProjects
%      displayProjects('FilePath', './saved_projects')
%
%   See also INITIALIZEPROJECT, SAVEPROJECT

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
%       June 4, 2018
%
%   DATE LAST UPDATE:
%       June 5, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultFilePath = '.';
addParameter(p,'FilePath', defaultFilePath );
parse(p, varargin{:});

FilePath=p.Results.FilePath;

% Validation of FilePath
if ~ischar(FilePath) || isempty(FilePath(~isspace(FilePath)))
    disp(' ')
    disp('ERROR: Path should be a non-empty character array.')
    disp(' ')
    return
end

[isFileExist] = testFileExistence(FilePath, 'dir');
if ~isFileExist
    % create directory
    mkdir(FilePath)
    % set directory on path
    addpath(FilePath)
end


%% Test existence of the file that contains all information about projects

ProjectsInfoFilename = 'ProjectsInfo.mat';

[isFileExist] = testFileExistence(fullfile(pwd, FilePath, ProjectsInfoFilename), 'file');

if isFileExist
    
    % Load file display info
    FileContent = load(fullfile(pwd, FilePath, ProjectsInfoFilename));
    ProjectInfo = FileContent.ProjectInfo;
    
    if ~isempty(ProjectInfo)
        
        % Sort according to ProjectDateCreation
        [~,I] = sort(datetime(ProjectInfo(:,2), 'Format', 'yyyy-MM-dd hh:mm:ss'));
        % Rearrange array 
        ProjectInfo(:,1) = ProjectInfo(I,1);
        ProjectInfo(:,2) = ProjectInfo(I,2);
        ProjectInfo(:,3) = ProjectInfo(I,3);
        
        
        % Display information
        disp('Saved projects: ')
        disp(' ')
        for i=1:size(ProjectInfo,1)
            fprintf('     %-3s -> %-25s %-10s\t\n', num2str(i), ...
                ProjectInfo{i,1}, ProjectInfo{i,2})
        end
        disp(' ')
      
       save(fullfile(pwd, FilePath, ProjectsInfoFilename), 'ProjectInfo'); 
        
    end
else
    
    ProjectInfo = {};
    
    % create file
    save(fullfile(pwd, FilePath, ProjectsInfoFilename), 'ProjectInfo');
end
%--------------------END CODE ------------------------
end
