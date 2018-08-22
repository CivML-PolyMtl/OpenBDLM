function piloteVersionControl(misc)
%PILOTEVERSIONCONTROL Pilote function for version control
%
%   SYNOPSIS:
%     PILOTEVERSIONCONTROL(misc)
%
%   INPUT:
%      misc             - structure (required)
%                         see documentation for details about the fields of
%                         misc
%   OUTPUT:
%      N/A
%   DESCRIPTION:
%      PILOTEVERSIONCONTROL Pilote function for version control
%
%   EXAMPLES:
%      PILOTEVERSIONCONTROL(misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%      versionControl
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also

%   AUTHORS:
%       Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.4.0.813654 (R2018a)
%
%   DATE CREATED:
%       July 27, 2018
%
%   DATE LAST UPDATE:
%       August 9, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'misc',  @isstruct);

parse(p,misc);

misc=p.Results.misc;

VersionControlPath=misc.VersionControlPath;

% Set fileID for logfile
if misc.isQuiet
    % output message in logfile
    fileID=fopen(misc.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end

fprintf(fileID,'\n');
fprintf(fileID,['-----------------------------------------', ...
    '----------------------------------------------------- \n']);
fprintf(fileID,'/    Version control \n');
fprintf(fileID,['-----------------------------------------', ...
    '----------------------------------------------------- \n']);

%% Notice user that we are about to permanently remove folder content
disp(' ')
disp(['WARNING: Running version control will permanently remove all ', ...
    'previously saved PROJ_, CFG_, DATA_, and LOG_ files.'])
disp('Do you want to continue ? (y/n)');

isYesNoCorrect= false;
while ~isYesNoCorrect
    choice = input('     choice >> ','s');
    if isempty(choice)
        disp(' ')
        disp('     wrong input')
        disp(' ')
    elseif strcmpi(choice,'y') || strcmpi(choice,'yes')
        
        isYesNoCorrect =  true;
        
    elseif strcmpi(choice,'n') || strcmpi(choice,'no')
        return
    else
        disp(' ')
        disp('     wrong input')
        disp(' ')
    end
    
end

%% Run version control
[~]=versionControl(misc, 'FilePath', VersionControlPath);

close all;
%--------------------END CODE ------------------------
end
