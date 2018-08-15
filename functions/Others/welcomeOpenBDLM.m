function welcomeOpenBDLM(misc, varargin)
%WELCOMEOPENBDLM Print welcome message when starting the program
%
%   SYNOPSIS:
%     WELCOMEOPENBDLM
%
%   INPUT:
%      misc                - structure
%                             see the documentation for details about the
%                             field in misc
%
%      version             - character (optional)
%                             give the version of the program
%
%   OUTPUT:
%      misc                - structure
%                             see the documentation for details about the
%                             field in misc
%
%   DESCRIPTION:
%      WELCOMEOPENBDLM prints welcome message when starting the program
%
%   EXAMPLES:
%      WELCOMEOPENBDLM
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also OPENBDLM_MAIN

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
%       July 27, 2018

%--------------------BEGIN CODE ----------------------


%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultVersion = ' ';

validationFonction = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p, 'misc', @isstruct)
addParameter(p, 'version', defaultVersion, validationFonction)
parse(p, misc, varargin{:});

misc=p.Results.misc;
version=p.Results.version;

if misc.isQuiet
   fileID=fopen(misc.logFileName, 'a');
else
    fileID=1;
end

fprintf(fileID, '\n');
fprintf(fileID, ['-----------------------------------------', ...
    '-----------------------------------------------------\n']);
disp(['     Starting OpenBDLM_V', version, '...' ])
fprintf(fileID,['-----------------------------------------', ...
    '-----------------------------------------------------\n']);
fprintf(fileID,'\n');
fprintf(fileID,['            Structural Health Monitoring ',...
    'using Bayesian Dynamic Linear Models\n']);
fprintf(fileID, '\n');
fprintf(fileID, ['-----------------------------------------', ...
    '-----------------------------------------------------\n']);

%--------------------END CODE ------------------------
end
