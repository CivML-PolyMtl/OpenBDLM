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
%       August 7, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'misc',  @isstruct);

parse(p,misc);

misc=p.Results.misc;

VersionControlPath=misc.VersionControlPath;

disp(' ')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])
disp('/    Version control')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])

[controlOut]=versionControl(misc, 'FilePath', VersionControlPath);

fprintf('\n');
fprintf('\n');
for i=1:size(controlOut,1)    
    if ~controlOut{i, 2} || ~controlOut{i,3}
       resStr = 'FAIL';
    else
       resStr = 'PASS';
    end
    
    fprintf('==> Version control test %s: %s\n', num2str(i), resStr)   
end
fprintf('\n');
%--------------------END CODE ------------------------
end
