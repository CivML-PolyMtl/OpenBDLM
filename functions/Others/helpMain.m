function helpMain
%HELPMAIN Display help for main function
%
%   SYNOPSIS:
%     HELPMAIN()
%
%   INPUT:
%      N/A
%
%   OUTPUT:
%      N/A
%
%   DESCRIPTION:
%      HELPMAIN displays help for main function
%
%   EXAMPLES:
%      HELPMAIN()
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also OPENBDLM_MAIN

%   AUTHORS:
%       Luong Ha Nguyen, Ianis Gaudot, James-A Goulet,
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

disp(' ')
disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%')
disp(' ')
disp('Several choices are possible: ')
disp(' ')
disp(' Type a configuration file name.')
disp([' Type 0 to start the interactive tool' , ...
    ' for creating a new project.'])
disp(' Type # to load the  project number #.')
disp(' Type ''delete_#'' to delete the project number #.')
disp(' Type ''Quit'' to quit.')
disp(' ')
disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%')
disp(' ')
%--------------------END CODE ------------------------
end
