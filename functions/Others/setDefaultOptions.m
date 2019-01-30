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
%       October 18, 2018
 
%--------------------BEGIN CODE ---------------------- 
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'misc', @isstruct );
parse(p, misc);
misc=p.Results.misc;
 
%% Set default options

% Syncronization options
misc.options.NaNThreshold = 100;
misc.options.Tolerance = 10^(-6);

% Optimization options
misc.options.trainingPeriod = [1 Inf];
misc.options.isParallel = false;
misc.options.isMute = false;
misc.options.isMAP = false;
misc.options.maxTime = 60; 

% Newton-Raphson
misc.options.maxIterations = 3;
misc.options.isLaplaceApprox = false;
misc.options.isPredCap = false;
misc.options.NRLevelsLambdaRef = 4;
misc.options.NRTerminationTolerance = 10^(-7);

% Stochastic gradient
misc.options.maxEpochs = 30;
misc.options.SplitPercent = 30;
misc.options.MiniBatchSizePercent = 20;
misc.options.SGTerminationTolerance = 95;
misc.options.Optimizer = 'MMT';

% Hidden states estimation options
misc.options.MethodStateEstimation = 'kalman'; 
misc.options.MaxSizeEstimation = 100;
misc.options.DataPercent = 100;

% Data simulation option
misc.options.Seed = 12345;

% Plot options
misc.options.FigurePosition = [100, 100, 1300, 270];
misc.options.isSecondaryPlot = false;
misc.options.Subsample = 1;
misc.options.Linewidth = 3;
misc.options.ndivx = 4;
misc.options.ndivy = 3;
misc.options.Xaxis_lag = 0;
misc.options.isExportTEX = false;
misc.options.isExportPNG = false;
misc.options.isExportPDF = false;

%--------------------END CODE ------------------------ 
end
