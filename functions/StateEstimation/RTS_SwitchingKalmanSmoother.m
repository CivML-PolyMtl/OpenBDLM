function [x, V, VV, S, ...
    x_prior_smoothed, V_prior_smoothed, VV_prior_smoothed, S_prior_smoothed]=...
    RTS_SwitchingKalmanSmoother(data, model, estimation)
%RTS_SWITCHINGKALMANSMOOTHER Perform RTS Switching Kalman smoothing
%
%   SYNOPSIS:
%     [x, V, VV, S, x_prior_smoothed, V_prior_smoothed, VV_prior_smoothed, S_prior_smoothed ]=RTS_SWITCHINGKALMANSMOOTHER(data, model, estimation)
%
%   INPUT:
%      data             - structure (required)
%                         see documentation for details about the fields of
%                         data
%
%      model            - structure (required)
%                         see documentation for details about the fields of
%                         model
%
%      estimation       - structure (required)
%                         see documentation for details about the fields of
%                         estimation
%                         estimation contains previous result from
%                         filtering in estimation.x_M, estimation.V_M,
%                         estimation.VV_M, estimation.S
%
%   OUTPUT:
%      x                - 1×M cell array
%                         Each element in the array is a NxT real array,
%                         which is the smoothed posterior hidden state mean
%                         vector for each time t (t=1,...,T) for one model class
%
%      V                - 1×M cell array
%                         Each element in the array is a NxNxT real array,
%                         which is the smoothed posterior hidden state covariance
%                         matrix for each time t (t=1,...,T) for one model
%                         class
%
%      VV               - 1×M cell array
%                         Each element in the array is a NxNxT real array,
%                         which the smoothed posterior covariance between hidden states 
%                         at time t and time t+1 for each time t (t=1,...,T)
%
%      S                - TxM real valued array
%                         smoothed posterior probability of each model class
%                         for each time t (t=1,...,T)
%
%      x_prior_smoothed - 1×M cell array
%                         Each element in the array is a Nx1 real array,
%                         which is the smoothed posterior hidden state mean
%                         vector for time t=0 for one model class
%
%      V_prior_smoothed - 1×M cell array
%                         Each element in the array is a NxN real array,
%                         which is the smoothed posterior hidden state
%                         covariance matrix for time t=0 for one model class                        
%
%      VV_prior_smoothed- 1×M cell array
%                         Each element in the array is a NxN real array,
%                         which is the smoothed posterior covariance between hidden states 
%                         at time t and time t+1 for time t=0 for one model class
%
%      S_prior_smoothed - 1×M real valued array
%                         smoothed posterior probability of each model class
%                         for time t=0
%
%   DESCRIPTION:
%      RTS_SWITCHINGKALMANSMOOTHER performs Rauch-Tung-Striebel Switching
%      Kalman smoother
%      RTS_SWITCHINGKALMANSMOOTHER perform the smoothing operation
%      It estimates x(t|T) and V(t|T), for each time t (t=1,...,T) 
%      where x and V refers to mean and
%      variance values, respectively and T the time of the last observation
%      RTS_SWITCHINGKALMANSMOOTHER should be called after Switching Kalman
%      Filtering
%
%      In all previous definitions:
%
%           x hidden states mean vector
%           V hidden state covariance matrix
%           VV covariance matrix between states at two consecutive times
%           t is the time (t=0, ..., T)
%           T is the time of the last observation
%           M refers to the number of model class
%           N is the number of hidden states in one model class
%
%   EXAMPLES:
%      [x, V, VV, S, x_prior_smoothed, V_prior_smoothed, VV_prior_smoothed, S_prior_smoothed]=RTS_SWITCHINGKALMANSMOOTHER(data, model, estimation)
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   SUBFUNCTIONS:
%      smooth_update_SKF
%
%   See also STATEESTIMATION, SWITCHINGKALMANFILTER

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
%       October 18, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'estimation', @isstruct );
parse(p,data, model, estimation);

data=p.Results.data;
model=p.Results.model;
estimation=p.Results.estimation;


%% Get timestamps information

% Get timestamps
timestamps = data.timestamps;

% Compute timestep vector
[timesteps]=computeTimeSteps(timestamps);

% Number of timestamps
T = length(timestamps);

%% Get number of model classes
M = model.nb_class;

%% Read model parameter properties
idx_pvalues=size(model.param_properties,2)-1;
idx_pref= size(model.param_properties,2);

[arrayOut]=...
    readParameterProperties(model.param_properties, [idx_pvalues, idx_pref]);

parameter= arrayOut(:,1);
p_ref = arrayOut(:,2);


%% Initialization
x = cell(1,M);
V = cell(1,M);
VV = cell(1,M);
x_jk=cell(1,M);
V_jk=cell(1,M);
VV_jk=cell(1,M);

S_prior_smoothed = zeros(1,M);
x_prior_smoothed = cell(1,M);
V_prior_smoothed = cell(1,M);
VV_prior_smoothed = cell(1,M);

for k=1:M
    ss=size(model.hidden_states_names{1},1);
    x{k} = zeros(ss, T);
    x{k}(:,T)=estimation.x_M{k}(:,T);
    
    V{k} = zeros(ss, ss, T);
    V{k}(:,:,T)=estimation.V_M{k}(:,:,T);
    
    VV{k} = zeros(ss, ss, T);
    
    x_jk{k} = zeros(ss,M);
    V_jk{k} = zeros(ss,ss,M);
    VV_jk{k} = zeros(ss,ss,M);
    
    x_prior_smoothed{k} = zeros(ss);
    V_prior_smoothed{k} = zeros(ss, ss);
    VV_prior_smoothed{k} = zeros(ss, ss);
    
end

S = zeros(T,M);
S(T,:)=estimation.S(T,:);
W=zeros(M,M);

%% Interventions
if isfield(data, 'interventions')
    interventions=find(ismember(data.timestamps,data.interventions));
else
    data.interventions=[];
    interventions=find(ismember(data.timestamps,data.interventions));
end

%% Estimate state for each time t
for t=T-1:-1:0
    S_marginal = zeros(M,M);
    U = zeros(M,M);
    for k=1:M
        A_k = model.A{k}(parameter(p_ref),timestamps(t+1),timesteps(t+1));
        Z_k = model.Z(parameter(p_ref),timestamps(t+1),timesteps(t+1));
        for j=1:M
            Q_k = model.Q{k}{j}(parameter(p_ref), ...
                timestamps(t+1),timesteps(t+1));
            
            if t~=0 && any(t+1==interventions)
                B_=model.B{j}(parameter(p_ref), ...
                    data.timestamps(t),timesteps(t))';
                WB_=model.W{j}(parameter(p_ref),...
                    data.timestamps(t),timesteps(t))';
            else
                B_=0;
                WB_=0;
            end
            
            if t == 0
                xfilt = model.initX{j};
                Vfilt = model.initV{j};
                Sfilt = model.initS{j};
            else
                xfilt = estimation.x_M{j}(:,t);
                Vfilt = estimation.V_M{j}(:,:,t);
                Sfilt = estimation.S(t,j);
            end
            
            
            [x_jk{j}(:,k), V_jk{j}(:,:,k), VV_jk{k}(:,:,j)] = ...
                smooth_update_SKF(x{k}(:,t+1), ...
                V{k}(:,:,t+1), xfilt, ...
                Vfilt, ...
                estimation.V_M{k}(:,:,t+1), ...
                estimation.VV_M{k}(:,:,t+1), ...
                A_k, Q_k,'B',B_,'W',WB_);
            
            U(j,k)=Sfilt*Z_k(j,k);
        end
        U(:,k)=U(:,k)/sum(U(:,k));
        for j=1:M
            S_marginal(j,k)=U(j,k)*S(t+1,k);
        end
    end
    for j=1:M
        if t == 0
            S_prior_smoothed(1,j)=sum(S_marginal(j,:));
        else
            S(t,j)=sum(S_marginal(j,:));
        end
    end
    %% Weights of state components
    for j=1:M
        for k=1:M
            if t == 0
                W(k,j) = S_marginal(j,k)/S_prior_smoothed(1,j);
            else
                W(k,j) = S_marginal(j,k)/S(t,j);
            end
        end
    end
    
    %% Approximate new continuous state
    for j=1:M
        
        if t == 0
            
            x_prior_smoothed{j} = x_jk{j}(:,:) * W(:,j);
            for k=1:M
                m = x_jk{j}(:,k) - x_prior_smoothed{j};
                V_prior_smoothed{j} = V_prior_smoothed{j} + W(k,j)*(V_jk{j}(:,:,k) + m*m');
                VV_prior_smoothed{j} = VV_prior_smoothed{j} + W(k,j)*(VV_jk{j}(:,:,k) + m*m');
            end
                       
        else
            
            x{j}(:,t) = x_jk{j}(:,:) * W(:,j);
            for k=1:M
                m = x_jk{j}(:,k) - x{j}(:,t);
                V{j}(:,:,t) = V{j}(:,:,t) + W(k,j)*(V_jk{j}(:,:,k) + m*m');
                VV{j}(:,:,t) = VV{j}(:,:,t) + W(k,j)*(VV_jk{j}(:,:,k) + m*m');
            end
            
        end
    end
       
end
%--------------------END CODE ------------------------
end

function [xsmooth, Vsmooth, VVsmooth_future] = ...
    smooth_update_SKF(xsmooth_future, Vsmooth_future, xfilt, Vfilt, ...
    Vfilt_future, VVfilt_future, A, Q,varargin)

% One step of the backwards RTS smoothing equations.
% function [xsmooth, Vsmooth, VVsmooth_future] = smooth_update(xsmooth_future, Vsmooth_future, ...
%    xfilt, Vfilt,  Vfilt_future, VVfilt_future, A, B, u)
%
% INPUTS:
% xsmooth_future = E[X_t+1|T]
% Vsmooth_future = Cov[X_t+1|T]
% xfilt = E[X_t|t]
% Vfilt = Cov[X_t|t]
% Vfilt_future = Cov[X_t+1|t+1]
% VVfilt_future = Cov[X_t+1,X_t|t+1]
% A = system matrix for time t+1
% Q = system covariance for time t+1

%
% OUTPUTS:
% xsmooth = E[X_t|T]
% Vsmooth = Cov[X_t|T]
% VVsmooth_future = Cov[X_t+1,X_t|T]

%xpred = E[X(t+1) | t]
args = varargin;
B=0;    % Mean correction term
W=0;    % Covariance correction term
for t=1:2:length(args)
    switch args{t}
        case 'B', B = args{t+1};
        case 'W', W = args{t+1};
        otherwise, error(['unrecognized argument ' args{t}])
    end
end

Vfilt=(Vfilt + Vfilt')/2;

xpred = A*xfilt+B;
Vpred = A*Vfilt*A'+ Q+W; % Vpred = Cov[X(t+1) | t]
J = Vfilt * A'*pinv(Vpred,1E-3); % smoother gain matrix
xsmooth = xfilt + J*(xsmooth_future - xpred);
Vsmooth = Vfilt + J*(Vsmooth_future - Vpred)*J';
VVsmooth_future = VVfilt_future + ...
    (Vsmooth_future - Vfilt_future)*pinv(Vfilt_future)*VVfilt_future;
end
