%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program : State_estimationation
% Author : James-A. Goulet
% Date : Feb. 3th 2015
% Last update : May. 18th 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [estimation]=state_estimation(data,model,estimation, misc, varargin)

%% Get timestamps
timestamps = data.timestamps;

%% Compute timestep vector
[timesteps]=computeTimeSteps(timestamps);

numberOfTimeSeries=length(data.labels);            %Number of observations
M = model.nb_class;           %Number of model classes or regime
T =  length(timestamps); % Number of samples

estimation.smooth=0;
disp_flag=1;
args = varargin;
for t=1:2:length(args)
    switch args{t}
        case 'smooth', estimation.smooth = args{t+1};
        case 'disp_flag', disp_flag = args{t+1};
        otherwise, error(['unrecognized argument ' args{t}])
    end
end
if disp_flag==1
    disp('     State estimation in progress...')
    disp(' ')
end

%% Kalman/UD filter
[estimation.x_M, estimation.V_M, estimation.VV_M, estimation.S, estimation.LL,estimation.U,estimation.D]=SKF(data,model,misc);
if disp_flag==1
    disp(['     -> log-likelihood:    ' num2str(estimation.LL)])
end

%% Kalman smoother
if estimation.smooth==1
    [estimation.x_M, estimation.V_M, estimation.VV_M, estimation.S]=RTS_SKS(estimation,data,model);
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
        estimation.x(:,t)=estimation.x(:,t)+estimation.S(t,j)*estimation.x_M{j}(:,t);
        mx(:,j)=estimation.x_M{j}(:,t);
        estimation.V(:,t)=estimation.V(:,t)+estimation.S(t,j)*diag(estimation.V_M{j}(:,:,t));
        
        C_j=model.C{j}(model.parameter(model.p_ref),timestamps(t),timesteps(t));
        estimation.y(:,t)=estimation.y(:,t)+estimation.S(t,j)*(C_j*estimation.x_M{j}(:,t));
        my(:,j)=(C_j*estimation.x_M{j}(:,t));
        estimation.Vy(:,t)=estimation.Vy(:,t)+estimation.S(t,j)*(diag(C_j*estimation.V_M{j}(:,:,t)*C_j')) ;
    end
    for j=1:M
        estimation.V(:,t)=estimation.V(:,t)+estimation.S(t,j)*diag((mx(:,j)-estimation.x(:,t))*(mx(:,j)-estimation.x(:,t))');
        estimation.Vy(:,t)=estimation.Vy(:,t)+estimation.S(t,j)*diag((my(:,j)-estimation.y(:,t))*(my(:,j)-estimation.y(:,t))');
    end
end

if disp_flag==1
    disp('    -> done.')
end
