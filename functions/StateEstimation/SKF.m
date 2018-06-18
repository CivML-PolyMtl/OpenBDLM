function [x, V, VV, S, loglik, pr_model_false_full, U,D] = SKF(data,model,misc)
% INPUTS:
% y(:,t)   - the observation at time t
% A - the system matrix
% C - the observation matrix
% Q - the system covariance
% R - the observation covariance
% Z - Transition probabilities for model classes
% init_x - the initial state (column) vector
% init_V - the initial state covariance
% init_S - the initial model class probabilities
%
% OUTPUTS (where X is the hidden state being estimated)
% x(:,t) = E[X(:,t) | y(:,1:t)]
% V(:,:,t) = Cov[X(:,t) | y(:,1:t)]
% loglik = sum{t=1}^T log P(y(:,t))
%

%% Get timestamps
timestamps = data.timestamps;

%% Compute timestep vector
[timesteps]=computeTimeSteps(timestamps);

%% Transform data.values to an array
DataValues = data.values;

T = length(timestamps);
M = model.nb_class;           %Number of model classes

if strcmp(misc.method,'UD')
    U=cell(M,M,T);
    D=cell(M,M,T);
    if isfield(model,'U')     %Online procedure 
        for j=1:M
            for i=1:M
                U{i,j,1}=model.U{i,j,1};
                D{i,j,1}=model.D{i,j,1};
            end
        end
    end
elseif strcmp(misc.method,'kalman')
    U=[];
    D=[];
else
    error('estimation method not recognized | SKF.m')
end

%% Initialization
x = cell(1,M);
V = cell(1,M);
VV = cell(1,M);
x_ij=cell(1,M);
V_ij=cell(1,M);
VV_ij=cell(1,M);
sigma22_idx=find(contains(model.param_properties(:,1),'\sigma_w(22)'),1,'first');

%% Preallocate the matrices A, C, R, Z, Q
A=cell(M,T);
C=cell(M,T);
R=cell(M,T);
Z=cell(1,T);
Q=cell(M,M,T);

pr_model_false=zeros(1,T);

for j=1:M
    ss=size(model.hidden_states_names{1},1);
    x{j} = zeros(ss,T);
    V{j} = zeros(ss, ss,T);
    VV{j} = zeros(ss, ss,T);
    
    x_ij{j} = zeros(ss,M);
    V_ij{j} = zeros(ss,ss,M);
    VV_ij{j} = zeros(ss,ss,M);
end

S = zeros(T,M);
W=zeros(M,M);
LL=zeros(M,M);
pr_model_false_marginal=zeros(M,M);

loglik = 0;
%% Estimate state for each t
for t=1:T
    log_S_marginal = zeros(M,M);
    lik_merge=0;
    pr_model_false_sum = 0;
    
    for j=1:M       % transition model
        if (t==1|(timesteps(t)~=timesteps(1:t-1)))
            A{j,t} = model.A{j}(model.parameter(model.p_ref),timestamps(t),timesteps(t));
            C{j,t} = model.C{j}(model.parameter(model.p_ref),timestamps(t),timesteps(t));
            R{j,t} = model.R{j}(model.parameter(model.p_ref),timestamps(t),timesteps(t));
            Z{t} = model.Z(model.parameter(model.p_ref),timestamps(t),timesteps(t));
        else
            idx=find(timesteps(t)==timesteps(1:t-1),1,'first');
            A{j,t}=A{j,idx};
            C{j,t} = model.C{j}(model.parameter(model.p_ref),timestamps(t),timesteps(t));
            R{j,t}=R{j,idx};
            Z{t}=Z{idx};

        end
        for i=1:M   % starting model
            if (t==1|(timesteps(t)~=timesteps(1:t-1)))
                Q{j,i,t} = model.Q{i}{j}(model.parameter(model.p_ref),timestamps(t),timesteps(t));
            else
                idx=find(timesteps(t)==timesteps(1:t-1),1,'first');
                Q{j,i,t}=Q{j,i,idx};
            end
%         if and(j==1,i==2)
%             Q{j,i,t}=diag(diag(Q{j,j,t}));
%             Q{j,i,t}(2,2)=model.parameter(sigma22_idx)^2*(timesteps(t)^2/data.dt_ref);
%         elseif and(j==2,i==1)
%             QQ = model.Q{j}{j}(model.parameter(model.p_ref),timestamps(t),timesteps(t));
%             Q{j,i,t}=diag(diag(QQ));
%             Q{j,i,t}(2,2)=model.parameter(sigma22_idx)^2*(timesteps(t)^4/(3*data.dt_ref));
%         end
            
            if t==1
                prevX = model.initX{i};
                prevV = model.initV{i};
                prevS = model.initS{i};
                if strcmp(misc.method,'UD')
                    if and(isempty(U{i,j,t}),isempty(D{i,j,t}))
                        error_myUD=1;
                        while error_myUD
                            try
                                [U{i,j,t},D{i,j,t}] = myUD(prevV);
                                if isempty(U{i,j,t})
                                    error_myUD=1;
                                else
                                    error_myUD=0;
                                end
                            catch err
                                disp(['warning:  UD decomposition failed at time step: ' num2str(t) '| SKF.m'])
                                disp(' -> Retry without covariance terms in''prevV''')
                                prevV=diag(diag(prevV));
                            end
                        end
                    end
                end
            else
                prevX = x{i}(:,t-1);
                prevV = V{i}(:,:,t-1);
                prevS = S(t-1,i);
            end
            if strcmp(misc.method,'UD')
                %% UD filter
                [x_ij{j}(:,i), V_ij{j}(:,:,i), VV_ij{j}(:,:,i), U{i,j,t+1}, D{i,j,t+1}, LL(i,j,t)] = UDF(A{j,t},C{j,t},Q{j,i,t},R{j,t}, DataValues(t,:)', prevX, prevV, U{i,j,t}, D{i,j,t});
            else
                %% Kalman filter
                warning('off','all')
                %[x_ij{j}(:,i), V_ij{j}(:,:,i), VV_ij{j}(:,:,i), LL(i,j,t), pr_model_false_marginal(i,j,t), nis(i,j,t), e(i,j,t)] = KF(A{j,t},C{j,t},Q{j,i,t},R{j,t}, DataValues(t,:)', prevX, prevV);
                [x_ij{j}(:,i), V_ij{j}(:,:,i), VV_ij{j}(:,:,i), LL(i,j,t)] = KF(A{j,t},C{j,t},Q{j,i,t},R{j,t}, DataValues(t,:)', prevX, prevV);
                warning('on','all')
            end
            
            if isnan(LL(i,j,t))
                LL(i,j,t)=1;
                loglik=-inf;
                disp(['warning: LL{' num2str(i) ',' num2str(j) '}(t=' num2str(t) ')=nan | SKF.m'])
                break
            end
            
            log_S_marginal(i,j)=LL(i,j,t) + log(Z{t}(i,j)) + log(prevS);
            lik_merge=lik_merge + exp(log_S_marginal(i,j));
                        
            %  Probability of model falsification (Ianis)            
            %pr_model_false_sum = pr_model_false_sum + pr_model_false_marginal(i,j,t)*Z{t}(i,j)*prevS ;
            
            if any(any(isnan(VV_ij{j}(:,:,i))))
                disp(['warning: VV_ij{' num2str(i) ',' num2str(j) '}(t=' num2str(t) ')=nan | SKF.m'])
            end
        end
        if loglik==-inf
            disp(['warning: LL{' num2str(i) ',' num2str(j) '}(t=' num2str(t) ')=-inf | SKF.m'])
            break
        end
    end
    
    %pr_model_false(t)=pr_model_false_sum;
    
    loglik_ind(t)=lik_merge;
    
    if loglik==-inf
        break
    end
    
    loglik=loglik+log(lik_merge);
    if loglik==-inf
        disp('warning: loglik=-inf | SKF.m')
        break
    elseif isnan(loglik)
        disp('warning: loglik=-inf | SKF.m')
    end
    
    S_marginal=exp(log_S_marginal);
    if any(any(S_marginal==0))
        S_marginal=exp(log_S_marginal+(299-max(max(log_S_marginal))));
    end
    if any(any(S_marginal==0))
        S_marginal(S_marginal==0)=1E-100;
    end
    S_norm = sum(sum(S_marginal));
    
    %% posterior for state j at time t
    S_marginal = S_marginal/S_norm;
    for j=1:M
        S(t,j) = sum(S_marginal(:,j));
    end
    S(t,S(t,:)==0)=1E-99;
    
    %% weights of state components
    for j=1:M
        for i=1:M
            W(i,j) = S_marginal(i,j)/S(t,j);
        end
    end
    W(W==0)=1E-99;
    
    if isnan(W(i,j))
        disp(['warning: W(i,j)(t=' num2str(t) ')=nan | SKF.m'])
    end
    
    %% approximate new continuous state
    for j=1:M
        x{j}(:,t) = x_ij{j}(:,:) * W(:,j);
        for i=1:M
            m = x_ij{j}(:,i) - x{j}(:,t);
            V{j}(:,:,t) = V{j}(:,:,t) + W(i,j)*(V_ij{j}(:,:,i) + m*m');
            VV{j}(:,:,t) = VV{j}(:,:,t) + W(i,j)*(VV_ij{j}(:,:,i) + m*m');
        end
    end
end
disp(' ')
pr_model_false_full=mean(pr_model_false(:), 'omitnan');

% figure
% plot(timestamps, squeeze(nis))
% hold on
% plot(timestamps, 3.84*ones(1,length(timestamps)), 'r')
% 
% figure
% normplot(squeeze(e))




