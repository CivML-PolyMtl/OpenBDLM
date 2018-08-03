function piloteDeleteProject(misc)
%PILOTEDELETEPROJECT Pilote function to delete project(s)
%
%   SYNOPSIS:
%     PILOTEDELETEPROJECT(misc)
% 
%   INPUT:
%      input_1 - Description
% 
%   OUTPUT:
%      N/A
% 
%   DESCRIPTION:
%      PILOTEDELETEPROJECT Pilote function to delete project(s)
% 
%   EXAMPLES:
%      PILOTEDELETEPROJECT(misc)
% 
%   EXTERNAL FUNCTIONS CALLED:
%      deleteProject
% 
%   SUBFUNCTIONS:
%      N/A
%      Name of subfunction_1
% 
%   See also DELETEPROJECT
 
%   AUTHORS: 
%       Ianis Gaudot,  Luong Ha Nguyen, James-A Goulet
% 
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
% 
%   MATLAB VERSION:
%      Tested on 9.4.0.813654 (R2018a)
% 
%   DATE CREATED:
%       July 31, 2018
% 
%   DATE LAST UPDATE:
%       July 31, 2018
 
%--------------------BEGIN CODE ---------------------- 
   
%% Get arguments passed to the function and proceed to some verifications

p = inputParser;
addRequired(p,'misc', @isstruct );
parse(p,misc);

misc=p.Results.misc;

FilePath = misc.ProjectPath;
ProjectInfofile = misc.ProjectInfoFilename;

MaxFailAttempts=4;

% Load project info file array
FileContent = load(fullfile(pwd, FilePath,ProjectInfofile));
ProjectInfo = FileContent.ProjectInfo;

disp(' ')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])
disp('/    Delete project(s)')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])

if isempty(ProjectInfo)
    disp(' ')
    disp('     There is no saved project to delete.')
    disp(' ')
    return
end

%% Request the user to choose some time series
incTest=0;
while(1)
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    disp(' ')
    fprintf('- Choose the project index to delete (e.g [1 3 4]) : \n');
    if misc.BatchMode.isBatchMode
        ProjectIdx= ...
            eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
        disp(['     ', num2str(ProjectIdx) ])
    else
        ProjectIdx = input('     choice >> ');
    end
    
    ProjectIdx=unique(ProjectIdx);
    
    if isempty(ProjectIdx)
        disp(' ')
        disp(['     %%%%%%%%%%%%%%%%%%%%%%%%% ', ...
            ' > HELP < %%%%%%%%%%%%%%%%%%%%%%%%'])
        disp(' ')
        disp('     Choosing [1,2] will delete projects #1 and #2.')
        disp(' ')
        disp(['     %%%%%%%%%%%%%%%%%%%%%%%%% ', ...
            ' > HELP < %%%%%%%%%%%%%%%%%%%%%%%%'])
        disp(' ')
        continue
    elseif ischar(ProjectIdx) || any(mod(ProjectIdx,1)) || ...
            ~isempty(ProjectIdx(ProjectIdx<1))
        disp('     wrong input -> should be positive integers')
        continue
    else        
        break
    end
end

%% Delete project
deleteProject(misc, ProjectIdx)

% Increment global variable to read next answer when required
misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;

%--------------------END CODE ------------------------ 
end
