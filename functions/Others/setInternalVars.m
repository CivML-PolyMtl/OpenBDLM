function [misc]=setInternalVars(UserInput)
%SETINTERNALVARS Read OpenBDLM arguments and set internal variables
%
%   SYNOPSIS:
%     [misc]=SETINTERNALVARS(UserInput)
% 
%   INPUT:
%
%      UserInput       -  character/cell array/empty (required)
% 
%   OUTPUT:
%      misc            - struct
% 
%   DESCRIPTION:
%      SETINTERNALVARS reads OpenBDLM arguments and set internal variables
% 
%   EXAMPLES:
%      [misc]=SETINTERNALVARS(UserInput)
% 
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
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
%       August 27, 2018
% 
%   DATE LAST UPDATE:
%       August 27, 2018
 
%--------------------BEGIN CODE ---------------------- 

%% Read input argument
switch nargin
    case 0
        
        misc.internalVars.InteractiveMode.isInteractiveMode = true;
        misc.internalVars.BatchMode.isBatchMode = false;
        misc.internalVars.ReadFromConfigFileMode. ...
            isReadFromConfigFileMode = false;
        misc.internalVars.BatchMode.Answers = [];
        misc.internalVars.BatchMode.AnswerIndex=NaN;
        
    case 1
        
        if iscell(UserInput)
            
            misc.internalVars.InteractiveMode.isInteractiveMode = false;
            misc.internalVars.BatchMode.isBatchMode = true;
            misc.internalVars.ReadFromConfigFileMode. ...
                isReadFromConfigFileMode = false;
            misc.internalVars.BatchMode.Answers = UserInput;
            misc.internalVars.BatchMode.AnswerIndex=1;
            
        elseif ischar(UserInput)
            
            misc.internalVars.InteractiveMode.isInteractiveMode = false;
            misc.internalVars.BatchMode.isBatchMode = false;
            misc.internalVars.ReadFromConfigFileMode. ...
                isReadFromConfigFileMode = true;
            misc.internalVars.ReadFromConfigFileMode. ...
                ConfigFilename = UserInput;
            misc.internalVars.BatchMode.Answers = [];
            misc.internalVars.BatchMode.AnswerIndex=NaN;
         
        else
            misc = [];

        end
        
    otherwise
        misc = [];       
end

if  ~isempty(misc)
        
    %% Define path (not recommanded to change)
misc.internalVars.DataPath               = 'data';
misc.internalVars.ConfigPath             = 'config_files';
misc.internalVars.ProjectPath            = 'saved_projects';
misc.internalVars.FigurePath             = 'figures';
misc.internalVars.VersionControlPath     = 'version_control';
misc.internalVars.LogPath                = 'log_files';

%% Define project info filename (not recommanded to change)
misc.internalVars.ProjectInfoFilename    = 'ProjectsInfo.mat';
    
end

%--------------------END CODE ------------------------ 
end
