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
%% Reference data set for Periodic Dependence
data=p.Results.data;
%% Get observations
if ~any(ismember(model.S,'SR'))
    dependency = 0;
else
    dependency = 1;
end
if dependency == 1
    len = length(find(ismember(model.S,'SR')));
    if len == 1
        x_ref = linspace(-25,20,model.components.nb_SR_p)';
        model.x_ref = x_ref;
    elseif len == 2
        x_ref(:,1) = linspace(-10,10,model.components.nb_SR_p)'; % LL-water
        x_ref(:,2) = linspace(-25,20,model.components.nb_SR_p)'; % AR-water
        model.x_ref = x_ref;
    elseif len == 3
    x_ref(:,1) = linspace(-10,10,model.components.nb_SR_p)'; % LL-water
    x_ref(:,2) = linspace(-25,20,model.components.nb_SR_p)'; % LT+KR+AR-water
    x_ref(:,3) = linspace(-16,15,model.components.nb_SR_p)'; % AR-water
    model.x_ref = x_ref;
    end

else
    Data_reference = data.values(:,1);
    sig=.001;
    nb_ref = model.components.nb_SR_p;
    x_ref=(prctile(Data_reference,linspace(0,100,nb_ref)))';      %Reference values of the control points
    model.x_ref = x_ref;
end
%%
model=p.Results.model;
misc=p.Results.misc;
isSmoother=p.Results.isSmoother;
isMute=p.Results.isMute;


% Set fileID for logfile
if misc.internalVars.isQuiet
   % output message in logfile
   fileID=fopen(misc.internalVars.logFileName, 'a');  
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
        if ~isempty(model.idx_prod)   %BD
            if size(x_ref,2) == 1
                len = size(C_j,1)-1;
                C_j(:,model.idx_prod(end)-model.components.nb_SR_p) =[1;zeros(len,1)];
            elseif size(x_ref,2) == 2   % method 2
                N_SR         = length(x_ref);
                idx_xprod    = model.idx_xprod;
                idx_prod2    = [idx_xprod(2,N_SR)+1   idx_xprod(2,end)+1];
                prod         = [idx_prod2(1)+1  idx_prod2(2)+1];
                len          = length(prod);
                C_j(:,prod)  = [ones(1,len);zeros(size(C_j,1)-1,len)];
            elseif size(x_ref,2) == 3
                N_SR         = length(x_ref);
                idx_xprod    = model.idx_xprod;
                idx_prod2    = [idx_xprod(2,N_SR)+1  idx_xprod(2,2*N_SR)+1      idx_xprod(2,3*N_SR)+1];
                prod         = [idx_prod2(1)+1  idx_prod2(2)+1  idx_prod2(3)+1];
                len          = length(prod);
                C_j(:,prod)  = [ones(1,len);zeros(size(C_j,1)-1,len)];
            end
        end
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
