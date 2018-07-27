function [x, V, VV, S]=RTS_SwitchingKalmanSmoother(data, model, estimation)
%RTS_SWITCHINGKALMANSMOOTHER Perform RTS Switching Kalman smoothing
%
%   SYNOPSIS:
%     [x, V, VV, S]=RTS_SWITCHINGKALMANSMOOTHER(data, model, estimation)
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
%                         M refers to the number of model class in the
%                         model
%                         Each element in the array is a NxT real array,
%                         which is the smoothed posterior hidden state mean 
%                         vector for each time t (t=1,...,T) for one model class
%                         
%      V                - 1×M cell array
%                         M refers to the number of model class in the
%                         model
%                         Each element in the array is a NxNxT real array,
%                         which is the smoothed posterior hidden state covariance 
%                         matrix for each time t (t=1,...,T) for one model 
%                         class
%
%      VV               - 1×M cell array
%                         M refers to the number of model class in the
%                         model
%                         Each element in the array is a NxNxT real array,
%
%      S                - TxM real valued array 
%                         M refers to the number of model class in the
%                         model
%                         smoothed posterior probability of each model class
% 
%   DESCRIPTION:
%      RTS_SWITCHINGKALMANSMOOTHER performs Rauch-Tung-Striebel Switching
%      Kalman smoother
%      RTS_SWITCHINGKALMANSMOOTHER perform the smoothing operation 
%      It estimates x(t|1:T) and V(t|1:T), where x and V refers to mean and
%      variance values, respectively and T the time of the last observation
%      RTS_SWITCHINGKALMANSMOOTHER should be called after Switching Kalman
%      Filtering that performs the filtering step
% 
%   EXAMPLES:
%      [x, V, VV, S]=RTS_SWITCHINGKALMANSMOOTHER(data, model, estimation)
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
%       July 23, 2018
 
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
 
%% Initialization
x = cell(1,M);
V = cell(1,M);
VV = cell(1,M);
x_jk=cell(1,M);
V_jk=cell(1,M);
VV_jk=cell(1,M);

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
end

S = zeros(T,M);
S(T,:)=estimation.S(T,:);
W=zeros(M,M);

%% Interventions
if isfield(data, 'interventions')   
   % Non empty cell ?
   isIntervention = cellfun('isempty', data.interventions);
    
   if isIntervention
        interventions=find(ismember(data.timestamps,data.interventions{1}));       
   end
else
    data.interventions{1}=[];
    interventions=find(ismember(data.timestamps,data.interventions{1}));
end

%% Estimate state for each time t
for t=T-1:-1:1
    S_marginal = zeros(M,M);
    U = zeros(M,M);
    for k=1:M
        A_k = model.A{k}(model.parameter(model.p_ref),timestamps(t+1),timesteps(t+1));
        Z_k = model.Z(model.parameter(model.p_ref),timestamps(t+1),timesteps(t+1));
        for j=1:M
            Q_k = model.Q{k}{j}(model.parameter(model.p_ref),timestamps(t+1),timesteps(t+1));

            if any(t+1==interventions)
                B_=model.B{j}(model.parameter(model.p_ref),data.timestamps(t),timesteps(t))';
                WB_=model.W{j}(model.parameter(model.p_ref),data.timestamps(t),timesteps(t))';
            else
                B_=0;
                WB_=0;
            end
            [x_jk{j}(:,k), V_jk{j}(:,:,k), VV_jk{k}(:,:,j)] = smooth_update_SKF(x{k}(:,t+1), V{k}(:,:,t+1), estimation.x_M{j}(:,t), estimation.V_M{j}(:,:,t), estimation.V_M{k}(:,:,t+1), estimation.VV_M{k}(:,:,t+1), A_k, Q_k,'B',B_,'W',WB_);
            U(j,k)=estimation.S(t,j)*Z_k(j,k);
        end
        U(:,k)=U(:,k)/sum(U(:,k));
        for j=1:M
            S_marginal(j,k)=U(j,k)*S(t+1,k);
        end
    end
    for j=1:M
        S(t,j)=sum(S_marginal(j,:));
    end
    %% Weights of state components
    for j=1:M
        for k=1:M
            W(k,j) = S_marginal(j,k)/S(t,j);
        end
    end
    
    %% Approximate new continuous state
    for j=1:M
        x{j}(:,t) = x_jk{j}(:,:) * W(:,j);
        for k=1:M
            m = x_jk{j}(:,k) - x{j}(:,t);
            V{j}(:,:,t) = V{j}(:,:,t) + W(k,j)*(V_jk{j}(:,:,k) + m*m');
            VV{j}(:,:,t) = VV{j}(:,:,t) + W(k,j)*(VV_jk{j}(:,:,k) + m*m');
        end
    end
end

%--------------------END CODE ------------------------ 
end

function [xsmooth, Vsmooth, VVsmooth_future] = smooth_update_SKF(xsmooth_future, Vsmooth_future, xfilt, Vfilt, Vfilt_future, VVfilt_future, A, Q,varargin)
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
J = Vfilt * A'*pinv(Vpred); % smoother gain matrix
xsmooth = xfilt + J*(xsmooth_future - xpred);
Vsmooth = Vfilt + J*(Vsmooth_future - Vpred)*J';
VVsmooth_future = VVfilt_future + (Vsmooth_future - Vfilt_future)*pinv(Vfilt_future)*VVfilt_future;
end
