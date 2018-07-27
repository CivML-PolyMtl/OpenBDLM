function [menuChoices]=displayMenuOpenBDLM
%DISPLAYMENUOPENBDLM Display OpenBDLM menu
%
%   SYNOPSIS:
%     [menuChoices]=DISPLAYMENUOPENBDLM
%
%   INPUT:
%      N/A
%
%   OUTPUT:
%      menuChoices - 1xN array of integer
%                    contains index for each choice of the menu
%                    N being the number of available choice
%
%   DESCRIPTION:
%      DISPLAYMENUOPENBDLM displays OpenBDLM menu
%
%   EXAMPLES:
%      [menuChoices]=DISPLAYMENUOPENBDLM
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also OpenBDLM_main

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

disp(' ')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])
disp(' / Choose from')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])

disp(' ')
disp('     1  ->  Learn model parameters values')
disp('     2  ->  Estimate initial hidden states values')
disp('     3  ->  Estimate hidden states values')
disp(' ')
disp('     11 ->  Display and modify current model parameter values')
disp(['     12 ->  Display and modify current ', ...
    ' initial hidden states values'])
disp('     13 ->  Display and modify current training period')
disp('     14 ->  Plots')
disp('     15 ->  Display model matrices')
disp('     16 ->  Simulate data')
disp('     17 ->  Export project in configuration file format')
disp(' ')
disp('     21 ->  Version control')
disp(' ')
disp('     31 ->  Quit')
disp(' ')

% List possible answers
menuChoices = [1 2 3 11 12 13 14 15 16 17 21 31];

%--------------------END CODE ------------------------
end
