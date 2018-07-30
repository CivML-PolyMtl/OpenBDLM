function welcomeOpenBDLM(varargin)
%WELCOMEOPENBDLM Print welcome message when starting the program
%
%   SYNOPSIS:
%     WELCOMEOPENBDLM
%
%   INPUT:
%      version - character (optional)
%                give the version of the program
%
%   OUTPUT:
%      N/A
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

addParameter(p, 'version', defaultVersion, validationFonction)
parse(p, varargin{:});

version=p.Results.version;

disp(' ')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])
disp(['///////////////////////////',...
    '///////////////OpenBDLM_V', version ,'\\\\\\\\\\\\\\\\\\\\\\\', ...
    '\\\\\\\\\\\\\\\\'])
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])
disp(' ')
disp(['            Structural Health Monitoring ',...
    'using Bayesian Dynamic Linear Models'])
disp(' ')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])

%--------------------END CODE ------------------------
end
