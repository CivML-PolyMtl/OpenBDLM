function [trainingPeriod]=defineTrainingPeriod(timestamps, varargin)
%DEFINETRAININGPERIOD Compute training period from a timestamp vector
%
%   SYNOPSIS:
%     [trainingPeriod]=DEFINETRAININGPERIOD(timestamps, varargin)
% 
%   INPUT:
%      timestamp        - Nx1 real array (required)
%                         timestamp vector
%                         N: number of samples in the time series
%
%      Percent          - real (optional)
%                         percent of the total duration to define training
%                         period
%                         default: 25 %
% 
%   OUTPUT:
%      trainingPeriod   - 2x1 real array
%                         [day1, day2], day2 > day1
%                         day is number of days since first timestamp
% 
%   DESCRIPTION:
%      DEFINETRAININGPERIOD computes training period from a timestamp vector
%      Training period is defined using two dates, given in number of days
%      since first timestamp
%      DEFINETRAININGPERIOD considers the first day as the
%      start of the training period
%      The duration of the training period is given by the argument
%      "Percent". 
% 
%   EXAMPLES:
%      [trainingPeriod]=DEFINETRAININGPERIOD(timestamps)
%      [trainingPeriod]=DEFINETRAININGPERIOD(timestamps, 'Percent', 45)
% 
%   See also DEFINEREFERENCETIMESTEP
 
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
%       April 19, 2018
% 
%   DATE LAST UPDATE:
%       April 20, 2018
 
%--------------------BEGIN CODE ---------------------- 
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;
defaultPercent = 100.0;
ValidationFcn = @(x)isnumeric(x)&~isempty(x);
addRequired(p,'timestamps', ValidationFcn );
addParameter(p, 'Percent', defaultPercent, @isreal)
parse(p,timestamps, varargin{:});

timestamps=p.Results.timestamps;
Percent = p.Results.Percent;

%% Compute trainingPeriod
% get training duration in days
durationTraining=floor((timestamps(end)-timestamps(1))*(Percent/100)); 

% date end training in days since 0, January
endTraining=timestamps(1)+durationTraining; 

% get index of end training in timestamps vector
[~,I]=min(abs(timestamps-endTraining)); 

% date end training in days since beginning of timestamp vector
endTraining=floor(timestamps(I)-timestamps(1)); 

trainingPeriod = [1, endTraining]; 
%--------------------END CODE ------------------------ 
end
