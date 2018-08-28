function [data, model, estimation, misc]=initializeProject
%INITIALIZEPROJECT Initialize a project
%
%   SYNOPSIS:
%     [data, model, estimation, misc]=INITIALIZEPROJECT
%
%   OUTPUT:
%      data          - structure
%                     see documentation for details about the fields of data
%
%      model         - structure
%                     see documentation for details about the fields of
%                     model
%
%      estimation    - structure
%                     see documentation for details about the fields of
%                     estimation
%
%      misc          - structure
%                     see documentation for details about the fields of misc
%
%   DESCRIPTION:
%      INITIALIZEPROJECT initialize a project
%      INITIALIZEPROJECT request the user to provide a reference name for
%      the new project and to choose whether the project is about data
%      simulation
%
%   EXAMPLES:
%      [data, model, estimation, misc] = INITIALIZEPROJECT
%
%   See also SAVEPROJECT, LOADPROJECT, DISPLAYPROJECTS

%   AUTHORS:
%      Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       April 18, 2018
%
%   DATE LAST UPDATE:
%       April 19, 2018

%--------------------BEGIN CODE ----------------------

%% Create empty structure data, option, model, estimation
misc = struct;
data = struct;
model = struct;
estimation = struct;

%--------------------END CODE ------------------------
end
