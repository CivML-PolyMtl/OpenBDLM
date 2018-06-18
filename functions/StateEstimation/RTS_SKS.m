function [x, V, VV, S] = RTS_SKS(estimation,data,model)


%% Get timestamps
timestamps = data.timestamps;

%% Compute timestep vector
[timesteps]=computeTimeSteps(timestamps);

T = size(estimation.S,1); %Number of time stamps
M = model.nb_class;           %Number of model classes

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

%% estimationate state for each t
for t=T-1:-1:1
    S_marginal = zeros(M,M);
    U = zeros(M,M);
    for k=1:M
        A_k = model.A{k}(model.parameter(model.p_ref),timestamps(t+1),timesteps(t+1));
        Z_k = model.Z(model.parameter(model.p_ref),timestamps(t+1),timesteps(t+1));
        for j=1:M
            Q_k = model.Q{k}{j}(model.parameter(model.p_ref),timestamps(t+1),timesteps(t+1));

            [x_jk{j}(:,k), V_jk{j}(:,:,k), VV_jk{k}(:,:,j)] = smooth_update_SKF(x{k}(:,t+1), V{k}(:,:,t+1), estimation.x_M{j}(:,t), estimation.V_M{j}(:,:,t), estimation.V_M{k}(:,:,t+1), estimation.VV_M{k}(:,:,t+1), A_k, Q_k);
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
    %% weights of state components
    for j=1:M
        for k=1:M
            W(k,j) = S_marginal(j,k)/S(t,j);
        end
    end
    
    %% approximate new continuous state
    for j=1:M
        x{j}(:,t) = x_jk{j}(:,:) * W(:,j);
        for k=1:M
            m = x_jk{j}(:,k) - x{j}(:,t);
            V{j}(:,:,t) = V{j}(:,:,t) + W(k,j)*(V_jk{j}(:,:,k) + m*m');
            VV{j}(:,:,t) = VV{j}(:,:,t) + W(k,j)*(VV_jk{j}(:,:,k) + m*m');
        end
    end
end
end

function [xsmooth, Vsmooth, VVsmooth_future] = smooth_update_SKF(xsmooth_future, Vsmooth_future, xfilt, Vfilt, Vfilt_future, VVfilt_future, A, Q)
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

Vfilt=(Vfilt + Vfilt')/2;

xpred = A*xfilt;
Vpred = A*Vfilt*A'+ Q; % Vpred = Cov[X(t+1) | t]
J = Vfilt * A'*pinv(Vpred); % smoother gain matrix
xsmooth = xfilt + J*(xsmooth_future - xpred);
Vsmooth = Vfilt + J*(Vsmooth_future - Vpred)*J';
VVsmooth_future = VVfilt_future + (Vsmooth_future - Vfilt_future)*pinv(Vfilt_future)*VVfilt_future;
end