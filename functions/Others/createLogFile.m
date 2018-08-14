function [misc]=createLogFile(misc)
%CREATELOGFILE Create log file to print message during program execution
%
%   SYNOPSIS:
%     [misc]=CREATELOGFILE(misc)
%
%   INPUT:

%
%   OUTPUT:

%
%   DESCRIPTION:
%      CREATELOGFILE creates log file to print message during program execution
%
%   EXAMPLES:
%      [misc]=CREATELOGFILE(misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%      testFileExistence
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also TESTFILEEXISTENCE

%   AUTHORS:
%      Ianis Gaudot, Luong Ha Nguyen,James-A Goulet,
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.4.0.813654 (R2018a)
%
%   DATE CREATED:
%       August 8, 2018
%
%   DATE LAST UPDATE:
%       August 8, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p, 'misc', @isstruct)
parse(p, misc);
misc=p.Results.misc;

LogPath = misc.LogPath;

[isExist] = testFileExistence(LogPath, 'dir');

if ~isExist
    mkdir(LogPath)
    addpath(LogPath)
end

datenow_ini=datestr(now);
datenow=strrep(datenow_ini, ' ', '_');
datenow=strrep(datenow, '-', '_');
datenow=strrep(datenow, ':', '_');

logFileName=fullfile(LogPath, ['LOG_',datenow, '.txt']);

if misc.InteractiveMode.isInteractiveMode || ...
        misc.ReadFromConfigFileMode.isReadFromConfigFileMode
    
    FileID=fopen(logFileName, 'a');
    fprintf(FileID, 'OpenBLDM log file created on %s\n', datenow_ini);
    diary(logFileName)
    misc.isQuiet = false;
    misc.logFileName=logFileName;
    
elseif misc.BatchMode.isBatchMode
    
    FileID=fopen(logFileName, 'a');
    fprintf(FileID, 'OpenBLDM log file created on %s\n', datenow_ini);
    misc.isQuiet = true;
    misc.logFileName=logFileName;
    
end

%--------------------END CODE ------------------------
end
