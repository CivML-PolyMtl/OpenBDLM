function [x, V, VV, S, loglik,U,D]=SwitchingKalmanFilter(data, model, misc)
%SWITCHINGKALMANFILTER Perform Switching Kalman filtering of time series
%
%   SYNOPSIS:
%      [x, V, VV, S, loglik,U,D]=SWITCHINGKALMANFILTER(data, model, misc)
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
%   OUTPUT:
%      x                - 1×M cell array
%                         M refers to the number of model class in the
%                         model
%                         Each element in the array is a NxT real array,
%                         which is the filtered posterior hidden state mean vector 
%                         for each time t (t=1,...,T) for one model class
%                         
%      V                - 1×M cell array
%                         M refers to the number of model class in the
%                         model
%                         Each element in the array is a NxNxT real array,
%                         which is the filtered posterior hidden state covariance 
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
%                         filtered posterior probability of each model class
%
%     loglik            - real value
%                         full log-likelihood
%                         sum of the log-likelihood computed at each time t
%
%     U                 - real-valued array
%
%     D                 - real-valued array                         
% 
%   DESCRIPTION:
%      SWITCHINGKALMANFILTER performs Switching Kalman filtering of time 
%      series.
%      SWITCHINGKALMANFILTER allows to process non-stationary time series
%      (with switching dynamics) by including several model classes.
%      One model class is a given model structure (i.e a given dynamics)
%      The probability of each model class is given at each time t.
%
%      A special case of Kalman filtering named UD filtering is also 
%      implemented in SWITCHINGKALMANFILTER.
%      UD filtering avoids numerical issues which may occur with classical
%      Kalman filtering.
% 
%   EXAMPLES:
%      [x, V, VV, S, loglik,U,D]=SWITCHINGKALMANFILTER(data, model, misc)
% 
%   EXTERNAL FUNCTIONS CALLED:
%      KalmanFilter, UDFilter
% 
%   SUBFUNCTIONS:
%      N/A
% 
%   See also STATESTIMATION, KALMANFILTER, UDFILTER
 
%   AUTHORS: 
%       Luong Ha Nguyen, Ianis Gaudot, James-A Goulet
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
%       August 21, 2018
 
%--------------------BEGIN CODE ---------------------- 
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'misc', @isstruct );
parse(p,data, model, misc);

data=p.Results.data;
model=p.Results.model;
misc=p.Results.misc;

%% options from misc
MethodStateEstimation=misc.options.MethodStateEstimation;


%% Get timestamps information

% Get timestamps
timestamps = data.timestamps;

% Compute timestep vector
[timesteps]=computeTimeSteps(timestamps);

% Compute reference timestep
[referencetimestep] = defineReferenceTimeStep(timestamps);

% Number of timestamps
T = length(timestamps);

%% Get observations
DataValues = data.values;

%% Get number of model classes
M = model.nb_class;         

%% Get method to use for filtering 'kalman' or 'UD'
if strcmp(MethodStateEstimation,'UD')
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
elseif strcmp(MethodStateEstimation,'kalman')
    U=[];
    D=[];
else
    error(['    Error: estimation method not ', ...
        'recognized | SwitchingKalmanFilter.m'])
end

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
x_ij=cell(1,M);
V_ij=cell(1,M);
VV_ij=cell(1,M);
sigma22_idx=find(strcmp(model.param_properties(:,1), ...
    '\sigma_w(22)'),1,'first');

%% Preallocate the matrices A, C, R, Z, Q
A=cell(M,T);
C=cell(M,T);
R=cell(M,T);
Z=cell(1,T);
Q=cell(M,M,T);

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
LL=zeros(M,M,T);

loglik = 0;

%% Interventions
if isfield(data, 'interventions')   
    interventions=find(ismember(data.timestamps,data.interventions));
else
    data.interventions=[];
    interventions=find(ismember(data.timestamps,data.interventions));
end

%% Estimate state for each t
for t=1:T
    log_S_marginal = zeros(M,M);
    lik_merge=0;
    for j=1:M       % transition model
        if (t==1 | (timesteps(t)~=timesteps(1:t-1)))
            A{j,t} = model.A{j}(parameter(...
                p_ref),data.timestamps(t),timesteps(t));
            C{j,t} = model.C{j}(parameter(...
                p_ref),data.timestamps(t),timesteps(t));
            R{j,t} = model.R{j}(parameter(...
                p_ref),data.timestamps(t),timesteps(t));
            Z{t} = model.Z(parameter(...
                p_ref),data.timestamps(t),timesteps(t));
            B=model.B{j}(parameter(...
                p_ref),data.timestamps(t),timesteps(t))';
            WB=model.W{j}(parameter(...
                p_ref),data.timestamps(t),timesteps(t));
        else
            idx=find(timesteps(t)==timesteps(1:t-1),1,'first');
%             if any([model.components.block{:}{:}]==51)
%                 A{j,t}=model.A{j}(parameter(...
%                     p_ref),data.timestamps(t),timesteps(t));
%             else
%                 A{j,t}=A{j,idx};
%             end
            
            for model_loop = 1:M 
               extract_model = model.components.block{model_loop};
               if any([extract_model{:}]==51)
                   A{j,t}=model.A{j}(parameter(...
                       p_ref),data.timestamps(t),timesteps(t));
               else
                   A{j,t}=A{j,idx};
               end
           end
            
            C{j,t} = model.C{j}(parameter(...
                p_ref),data.timestamps(t),timesteps(t));
            R{j,t}=R{j,idx};
            Z{t}=Z{idx};
            
        end
        for i=1:M   % starting model
            if (t==1 | (timesteps(t)~=timesteps(1:t-1)))
                Q{j,i,t} = model.Q{j}{i}(parameter(p_ref), ...
                    data.timestamps(t),timesteps(t));
            else
                idx=find(timesteps(t)==timesteps(1:t-1),1,'first');
                Q{j,i,t}=Q{j,i,idx};
            end
%             if and(j==1,i==2)
%                 Q{j,i,t}=diag(diag(Q{j,j,t}));
%                 Q{j,i,t}(2,2)=parameter(...
%                     sigma22_idx)^2*(timesteps(t)^2/referencetimestep);
%             elseif and(j==2,i==1)
%                 QQ = model.Q{j}{j}(parameter(...
%                     p_ref),data.timestamps(t),timesteps(t));
%                 Q{j,i,t}=diag(diag(QQ));
%                 Q{j,i,t}(2,2)=parameter(...
%                     sigma22_idx)^2*(timesteps(t)^4/(3*referencetimestep));
%             end
            
            if t==1
                prevX = model.initX{i};
                prevV = model.initV{i};
                prevS = model.initS{i};
                if strcmp(MethodStateEstimation,'UD')
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
                            catch 
                                disp(['warning:  UD decomposition failed ', ...
                                    ' at time step: ' num2str(t) '| SKF.m'])
                                disp([' -> Retry without covariance ', ...
                                    'terms in''prevV'''])
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
            if strcmp(MethodStateEstimation,'UD')
                %% UD filter
                [x_ij{j}(:,i), V_ij{j}(:,:,i), VV_ij{j}(:,:,i), ...
                    U{i,j,t+1}, D{i,j,t+1}, LL(i,j,t)] = ...
                    UDFilter(A{j,t},C{j,t},Q{j,i,t},R{j,t}, ...
                    DataValues(t,:)', prevX, prevV, U{i,j,t}, D{i,j,t});
            else
                %% Kalman filter
                warning('off','all')
                if any(t==interventions)
                    B_=B;
                    WB_=WB;
                else
                    B_=0;
                    WB_=0;
                end
                [x_ij{j}(:,i), V_ij{j}(:,:,i), VV_ij{j}(:,:,i), LL(i,j,t)] = ...
                    KalmanFilter(A{j,t},C{j,t},Q{j,i,t},R{j,t}, ...
                    DataValues(t,:)', prevX, prevV,'B',B_,'W',WB_);
                warning('on','all')
            end
            
            if isnan(LL(i,j,t))
                LL(i,j,t)=1;
                loglik=-inf;
%                                 disp(['warning: LL{ ', ...
%                 '' num2str(i) ',' num2str(j) '}(t=' num2str(t) '', ...
%                 ')=nan | SKF.m'])
                break
            end
            
            log_S_marginal(i,j)=LL(i,j,t) + log(Z{t}(i,j)) + log(prevS);
            S_marginal_ij=exp(log_S_marginal(i,j));
            if S_marginal_ij==0
                S_marginal_ij=1E-300;
            end
            lik_merge=lik_merge + S_marginal_ij;
            if any(any(isnan(VV_ij{j}(:,:,i))))
%                                  disp(['warning: VV_ij{', ...
%                 '' num2str(i) ',' num2str(j) '}(t=' num2str(t) ')=nan ', ...
%                     ' | SKF.m'])
            end
        end
        if loglik==-inf
%                          disp(['warning: LL{', ...
%                              '' num2str(i) ',' num2str(j) '}(t=', ...
%                              '' num2str(t) ')=-inf | SKF.m'])
            break
        end
    end
    if loglik==-inf
        break
    end
    
    loglik=loglik+log(lik_merge);
    if loglik==-inf
        %         disp('warning: loglik=-inf | SKF.m')
        break
    elseif isnan(loglik)
        %         disp('warning: loglik=-inf | SKF.m')
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
    
    %% Weights of state components
    for j=1:M
        for i=1:M
            W(i,j) = S_marginal(i,j)/S(t,j);
        end
    end
    W(W==0)=1E-99;
    
    if isnan(W(i,j))
        %         disp(['warning: W(i,j)(t=' num2str(t) ')=nan | SKF.m'])
    end
    
    %% Approximate new continuous state
    for j=1:M
        x{j}(:,t) = x_ij{j}(:,:) * W(:,j);
        for i=1:M
            m = x_ij{j}(:,i) - x{j}(:,t);
            V{j}(:,:,t) = V{j}(:,:,t) + W(i,j)*(V_ij{j}(:,:,i) + m*m');
            VV{j}(:,:,t) = VV{j}(:,:,t) + W(i,j)*(VV_ij{j}(:,:,i) + m*m');
        end
    end
end
%--------------------END CODE ------------------------ 
end
