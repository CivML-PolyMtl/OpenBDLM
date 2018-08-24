function [misc]=setDefaultOptions(misc)
%SETDEFAULTOPTIONS Set default options for OpenBDLM
%
%   SYNOPSIS:
%     [misc]=SETDEFAULTOPTIONS(misc)
% 
%   INPUT:
%      misc             - structure (required)
%                         see documentation for details about the fields of
%                         misc
% 
%   OUTPUT:
%      misc             - structure (required)
%                         see documentation for details about the fields of
%                         misc
% 
%   DESCRIPTION:
%      SETDEFAULTOPTIONS sets default options for OpenBDLM
%      SETDEFAULTOPTIONS initializes the field misc.options 
% 
%   EXAMPLES:
%      [misc]=SETDEFAULTOPTIONS(misc)
% 
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
% 
%   SUBFUNCTIONS:
%      N/A
% 
%   See also
 
%   AUTHORS: 
%        Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
% 
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
% 
%   MATLAB VERSION:
%      Tested on 9.4.0.813654 (R2018a)
% 
%   DATE CREATED:
%       August 14, 2018
% 
%   DATE LAST UPDATE:
%       August 14, 2018
 
%--------------------BEGIN CODE ---------------------- 
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'misc', @isstruct );
parse(p, misc);
misc=p.Results.misc;
 
%% Set default options

% Optimization options
misc.options.trainingPeriod = [1,Inf];
misc.options.isParallel = true;
misc.options.maxIterations = 5;
misc.options.maxTime = 60; 
misc.options.isMAP = false;
misc.options.isPredCap = false;
misc.options.isLaplaceApprox = false;
misc.options.isMute = false;

% Hidden states estimation options
misc.options.MethodStateEstimation = 'kalman'; 

% Plot options
%misc.options.isPlot = true;
misc.options.FigurePosition = [100, 100, 1300, 270];
misc.options.isSecondaryPlot = true;
misc.options.Subsample = 1;
misc.options.Linewidth = 1;
misc.options.ndivx = 5;
misc.options.ndivy = 3;
misc.options.isExportTEX = false;
misc.options.isExportPNG = false;
misc.options.isExportPDF = false;

%--------------------END CODE ------------------------ 
end
