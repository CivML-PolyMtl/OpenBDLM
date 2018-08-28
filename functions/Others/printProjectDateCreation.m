function [misc]=printProjectDateCreation(misc)
%PRINTPROJECTDATECREATION Print date creation of the project
%
%   SYNOPSIS:
%     [misc]=PRINTPROJECTDATECREATION(misc)
% 
%   INPUT:
%      misc - structure (required)
% 
%   OUTPUT:
%      misc - structure
% 
%   DESCRIPTION:
%      Prints date creation of the project
% 
%   EXAMPLES:
%      [misc]=PRINTPROJECTDATECREATION(misc)
% 
%   See also 
 
%   AUTHORS: 
%     Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
% 
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
% 
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
% 
%   DATE CREATED:
%       April 27, 2018
% 
%   DATE LAST UPDATE:
%       April 27, 2018
 
%--------------------BEGIN CODE ----------------------     
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;
addRequired(p,'misc', @isstruct );
parse(p,misc);

misc=p.Results.misc;    

%% Store date of the creation of the project
misc.internalVars.ProjectDateCreation=datestr(now);
 
%--------------------END CODE ------------------------ 
end
