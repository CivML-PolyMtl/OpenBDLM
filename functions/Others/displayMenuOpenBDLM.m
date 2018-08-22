function [menuChoices]=displayMenuOpenBDLM(misc)
%DISPLAYMENUOPENBDLM Display OpenBDLM menu
%
%   SYNOPSIS:
%     [menuChoices]=DISPLAYMENUOPENBDLM
%
%   INPUT:
%      misc                - structure
%                             see the documentation for details about the
%                             field in misc
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
%       August 21, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p, 'misc', @isstruct)
parse(p, misc);

misc=p.Results.misc;

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
fprintf(fileID,'/    Choose from \n');
fprintf(fileID,['-----------------------------------------', ...
    '----------------------------------------------------- \n']);

fprintf(fileID,'\n');
fprintf(fileID,'     1  ->  Learn model parameters values \n');
fprintf(fileID,'     2  ->  Estimate initial hidden states values \n');
fprintf(fileID,'     3  ->  Estimate hidden states values \n');
fprintf(fileID,'\n');
fprintf(fileID,['     11 ->  Display and modify ', ...
    'current model parameter values \n']);
fprintf(fileID,['     12 ->  Display and modify current ', ...
    'initial hidden states values \n']);
fprintf(fileID,['     13 ->  Display and modify ', ...
    'current training period \n']);
fprintf(fileID,'     14 ->  Plots \n');
fprintf(fileID,'     15 ->  Display model matrices \n');
fprintf(fileID,'     16 ->  Simulate data \n');
fprintf(fileID,['     17 ->  Export project ', ...
    'in configuration file format \n']);
fprintf(fileID,['     18 ->  Display current ', ...
    'options in configuration file format \n']);
fprintf(fileID,'\n');
fprintf(fileID,'     Type Q to Save and Quit \n');
fprintf(fileID,'\n');

% List possible answers
menuChoices = [1 2 3 11 12 13 14 15 16 17 21 ];

%--------------------END CODE ------------------------
end
