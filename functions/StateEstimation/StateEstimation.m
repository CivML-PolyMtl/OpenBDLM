function [estimation]=StateEstimation(data, model, misc, varargin)
%STATEESTIMATION State estimation from switching Kalman filtering/smoothing
%
%   SYNOPSIS:
%     [estimation]=STATEESTIMATION(data,model,estimation, misc, varargin)
%
%   INPUT:
%      data             - structure (required)
%                         see documentation for details about the fields of
%                         data
%                         data contains time series to be filtered
%
%      model            - structure (required)
%                         see documentation for details about the fields of
%                         model
%                         model contains A,C,Q,R matrices to perform
%                         filtering
%                         model also contains hidden states mean and variance
%                         initial values at t=0
%
%      misc             - structure (required)
%                         see documentation for details about the fields of
%                         misc
%
%      isSmooother      - logical (required)
%                         if isSmoother == true, perform both filtering and
%                         smoothing step
%                         default = false
%
%      isMute           - logical (required)
%                         if isQuiet == true, functions runs silently
%                         default = false
%
%
%   OUTPUT:
%      estimation       - structure (required)
%                         see documentation for details about the fields of
%                         estimation
%                         estimation contains the mean and variance of the
%                         filtered/smoothed posterior hidden state estimates
%
%   DESCRIPTION:
%      STATEESTIMATION computes filtered/smoothed posterior hidden state 
%      estimates.
%      STATEESTIMATION uses switching Kalman filtering/smoothing to compute
%      the estimates.
%
%   EXAMPLES:
%      [estimation]=STATEESTIMATION(data,model,estimation, misc)
%      [estimation]=STATEESTIMATION(data,model,estimation, misc, 'isSmoother', false)
%      [estimation]=STATEESTIMATION(data,model,estimation, misc, 'isSmoother', false, 'isQuiet', true)
%
%   EXTERNAL FUNCTIONS CALLED:
%      SwitchingKalmanFilter, RTS_SwitchingKalmanSmoother
%
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also SWITCHINGKALMANFILTER, UDFILTER, RTS_SWITCHINGKALMANSMOOTHER

%   AUTHORS:
%       Luong Ha Nguyen, Ianis Gaudot, James-A Goulet,
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       June 29, 2018
%
%   DATE LAST UPDATE:
%       August 9, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultisSmoother =  false;
defaultisMute =  false;

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'misc', @isstruct );
addParameter(p,'isSmoother', defaultisSmoother, @islogical );
addParameter(p,'isMute', defaultisMute, @islogical );
parse(p,data, model, misc, varargin{:});

data=p.Results.data;
model=p.Results.model;
misc=p.Results.misc;
isSmoother=p.Results.isSmoother;
isMute=p.Results.isMute;


% Set fileID for logfile
if misc.isQuiet
   % output message in logfile
   fileID=fopen(misc.logFileName, 'a');  
else
   % output message on screen and logfile using diary command
   fileID=1; 
end

disp('     Computing hidden states ...');

%% Read model parameter properties
% Current model parameters
idx_pvalues=size(model.param_properties,2)-1;
idx_pref= size(model.param_properties,2);

[arrayOut]=...
    readParameterProperties(model.param_properties, ...
    [idx_pvalues, idx_pref]);

parameter= arrayOut(:,1);
p_ref=arrayOut(:,2);

%% Get timestamps information

% Get timestamps
timestamps = data.timestamps;

% Compute timestep vector
[timesteps]=computeTimeSteps(timestamps);

% Number of timestamps
T = length(timestamps);

%% Get number of time series
numberOfTimeSeries=length(data.labels);

%% Get number of model classes
M = model.nb_class;

%% Kalman/UD filter
[estimation.x_M, estimation.V_M, estimation.VV_M, estimation.S, ...
    estimation.LL,estimation.U,estimation.D]= ...
    SwitchingKalmanFilter(data,model,misc);

if ~isMute
    fprintf(fileID,['     log-likelihood: ', ...
        ' %s \n'], num2str(estimation.LL));
end

%% Kalman smoother
if isSmoother
    [estimation.x_M, estimation.V_M, estimation.VV_M, estimation.S]= ...
        RTS_SwitchingKalmanSmoother(data,model, estimation);
end

%% Collapse multiple model classes in a single one
estimation.x=zeros(size(estimation.x_M{1}));
estimation.V=zeros(size(estimation.x_M{1}));
estimation.y=zeros(numberOfTimeSeries,T);
estimation.Vy=zeros(numberOfTimeSeries,T);

mx=zeros(size(estimation.x_M{1},1),M);
my=zeros(numberOfTimeSeries,M);
for t=1:T
    for j=1:M
        estimation.x(:,t)=...
            estimation.x(:,t)+estimation.S(t,j)*estimation.x_M{j}(:,t);
        
        mx(:,j)=estimation.x_M{j}(:,t);
        
        estimation.V(:,t)=...
            estimation.V(:,t)+estimation.S(t,j)*diag(estimation.V_M{j}(:,:,t));
        
        C_j=model.C{j}(parameter(p_ref),timestamps(t),timesteps(t));
        
        estimation.y(:,t)= ...
            estimation.y(:,t)+estimation.S(t,j)*(C_j*estimation.x_M{j}(:,t));
        
        my(:,j)=(C_j*estimation.x_M{j}(:,t));
        
        estimation.Vy(:,t)= estimation.Vy(:,t)+estimation.S(t,j)* ...
            (diag(C_j*estimation.V_M{j}(:,:,t)*C_j')) ;
    end
    for j=1:M
        estimation.V(:,t)= ...
            estimation.V(:,t)+estimation.S(t,j)*diag((mx(:,j)- ...
            estimation.x(:,t))*(mx(:,j)-estimation.x(:,t))');
        
        estimation.Vy(:,t)= ...
            estimation.Vy(:,t)+estimation.S(t,j)*diag((my(:,j)- ...
            estimation.y(:,t))*(my(:,j)-estimation.y(:,t))');
    end
end
%--------------------END CODE ------------------------
end
