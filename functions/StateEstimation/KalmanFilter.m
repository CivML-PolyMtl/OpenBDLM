function [xnew, Vnew, VVnew, loglik]=KalmanFilter(A, C, Q, R,ProdQ,idx_xprod,idx_prod,nb_DKR, nb_PR, nb_SR, parameters, t, t_ref, y, x, x_ref, V,varargin)
%KALMANFILTER Do one step of the Kalman filter (prediction + update at time t)
%
%   SYNOPSIS:
%     [xnew, Vnew, VVnew, loglik]=KALMANFILTER(A, C, Q, R, y, x, V,varargin)
% 
%   INPUT:
%      A                        - real valued array (required)
%                                 transition matrix
%
%      C                        - real valued array (required)
%                                 observation matrix   
%
%      Q                        - real valued array (required)
%                                 process noise covariance matrix 
%
%      R                        - real valued array (required)
%                                 observation noise covariance matrix 
%
%      y                        - real valued array (required)
%                                 available observations a time t 
%
%      x                        - real valued array (required)
%                                 posterior mean vector at time t-1
%
%      V                        - real valued array (required)
%                                 posterior covariance matrix at time t-1
%
%      B                        - real valued array (optionnal)
%                                 mean correction term
%                                 default value = 0
%
%      W                        - real valued array (optionnal)
%                                 covariance correction terms
%                                 default value = 0
%
% 
%   OUTPUT:
%      xnew                     - real valued array (required)
%                                 posterior mean vector at time t
%
%      Vnew                     - real valued array (required)
%                                 posterior covariance matrix at time t
%
%      VVnew                    - real valued array (required)
%
%                                 
%      loglik                   - real 
%                                 log-likelihood at time t
%
%   DESCRIPTION:
%      KALMANFILTER performs one step of the Kalman filter 
%      (prediction and update at time t)
%
%      Given that X(t) is the hidden state random variable, and y(:,t) the
%      vector of observation at time t:
%
%      x(:) = E[X(t-1) | y(:, 1:t-1)]       Posterior hidden state mean at time t-1
%
%      V(:,:) = Cov[X(t-1) | y(:, 1:t-1)]   Posterior hidden state covariance at time t-1
%
%      Prediction equations:
%
%      xpred(:) = A*x(:)                    Predicted hidden state mean at time t 
%      Vpred(:,:) = A*V(:,:)*A' + Q         Predicted hidden state covariance at time t 
%      
%      ypred(:) = C*xpred(:)                Predicted observation at time t
%      r(:) = y - ypred                     Innovation vector at time t
%
%      K = Vpred*C' / C*Vpred*C'+R          Kalman gain
%
%      Update equations:
%      
%      xnew(:) = xpred(:)+K*r(:)            Posterior hidden state mean at time t
%      xnew(:) = E[X(t) | y(:, 1:t)] 
%
%      Vnew(:,:) = (I-K*C)*Vpred(:,:)       Posterior hidden state covariance at time t
%      Vnew(:,:) = Cov[X(t) | y(:, 1:t)]
%
%      Note that VVnew(:,:) = Cov[ X(t), X(t-1) | y(:, 1:t) ]
%
%      Note that loglik(t) = log(N(y(t) ; ypred(:), C*Vpred*C'+R ))
%
%   EXAMPLES:
%      [xnew, Vnew, VVnew, loglik]=KALMANFILTER(A, C, Q, R, y, x, V)
% 
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
% 
%   SUBFUNCTIONS:
%      N/A
% 
%   See also STATEESTIMATION, SWITCHINGKALMANFILTER,
%   RTS_SWITCHINGKALMANSMOOTHER, GETGAUSSIANPROBABILITY
 
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
%       June 28, 2018
% 
%   DATE LAST UPDATE:
%       June 28, 2018
 
%--------------------BEGIN CODE ---------------------- 
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultB    = 0;
defaultW    = 0;
defaultTemp = 0;
addRequired(p,'A', @isnumeric );
addRequired(p,'C', @isnumeric );
addRequired(p,'Q', @isnumeric );
addRequired(p,'R', @isnumeric );
addRequired(p,'ProdQ', @isnumeric );
addRequired(p,'idx_xprod', @isnumeric );
addRequired(p,'idx_prod', @isnumeric );
addRequired(p,'nb_DKR', @isnumeric );
addRequired(p,'nb_PR', @isnumeric );
addRequired(p,'nb_SR', @isnumeric );
addRequired(p,'parameters', @isnumeric );
addRequired(p,'t', @isnumeric );
addRequired(p,'t_ref', @isnumeric );
addRequired(p,'y', @isnumeric );
addRequired(p,'x', @isnumeric );
addRequired(p,'x_ref', @isnumeric );
addRequired(p,'V', @isnumeric );
addParameter(p, 'B', defaultB, @isnumeric)
addParameter(p, 'W', defaultW, @isnumeric)
addParameter(p, 'nb_temp', defaultTemp, @isnumeric)

parse(p,A,C,Q,R,ProdQ,idx_xprod,idx_prod,nb_DKR,nb_PR,nb_SR,parameters,t,t_ref,y,x,x_ref,V,varargin{:});

A=p.Results.A;
C=p.Results.C;
Q=p.Results.Q;
R=p.Results.R;
ProdQ=p.Results.ProdQ;
idx_xprod=p.Results.idx_xprod;
idx_prod=p.Results.idx_prod;
nb_DKR=p.Results.nb_DKR;
nb_PR=p.Results.nb_PR;
nb_SR=p.Results.nb_SR;
parameters=p.Results.parameters;
t=p.Results.t;
t_ref=p.Results.t_ref;
y = p.Results.y;
x=p.Results.x;
x_ref=p.Results.x_ref;
V=p.Results.V;   
B=p.Results.B;
W=p.Results.W;
nb_temp=p.Results.nb_temp;
if ~isempty(parameters)         % To check if NPR/SR component needs to be computed
   l1 = parameters;
   [xpred,Vpred,C] = State_Regression(A,x,V,idx_xprod,idx_prod,l1,Q,ProdQ,x_ref,C,nb_temp); 
%     param = parameters(1:(end-1));
%        if  length(param)==4
%            
%            [xpred,Vpred,C]=Nonlinear_Regression(A,x,V,idx_xprod,idx_prod,l1,param,nb_PR,Q,ProdQ,x_ref,t,t_ref,C);
%            
%        elseif   length(param)==2
%            [xpred,Vpred,C]=Nonlinear_Regression(A,x,V,idx_xprod,idx_prod,l1,param,nb_PR,Q,ProdQ,x_ref,t,t_ref,C);
%        elseif ~isempty(l1) && isempty(param)
%                                                %BD
%            
%        end   
               
elseif isempty(parameters) && ~isempty(idx_prod)    % if NPR is not present, perform Prod based on idx_prod and idx_xprod      %BD
        if      size(idx_prod) > 1 && ~isempty(nb_DKR)
            [xpred,Vpred,C]=ARN();
            [xpred,Vpred,C]=DKR(xpred,Vpred,C);
        elseif  size(idx_prod) == 1 && ~isempty(nb_DKR)
            [xpred,Vpred,C]=DKR();
        else
            [xpred,Vpred,C]=ARN();
        end
else                            % No Prod term present
    %mP = [];sP = [];ProdQ = [];
    xpred = A*(x)+B;
    Vpred = A*(V)*A' + Q + W;
    Vpred = (Vpred+Vpred')/2;
end
%% Cramer-Rao lower bound
% CRB = pinv((C'/R)*C + pinv(Vpred));
% if Vpred < CRB
%      Vpred = CRB;
% end

    
%% Identify missing data
missing_idx=isnan(y);

%% Update step
% error (innovation)
%C(:,idx_xprod(2,end)+2)=[0 1]';
%% Change C matrix
if any(missing_idx)
    index = find(missing_idx);
    C(index,:) = zeros(length(index),length(C));
end

e = y - (C)*xpred;  
n = length(e);
ss = length(A);
S = (C)*Vpred*(C)' + R;
S = (S+S')/2;
Sinv = pinv(S);
Sinv(missing_idx,missing_idx)=0;
i = 1;
Corr = diag(S);
if any(Corr<0)
    check = 1;
else
    i = i + 1;
end
ss = length(V);
% compute loglikelihood
if all(missing_idx)
    loglik=0;
else
    [loglik] = getGaussianProbability(e(~missing_idx), ...
        zeros(1,sum(~missing_idx)), ...
        S(~missing_idx,~missing_idx), 'isLog', true);
end
% Kalman gain matrix
K = Vpred*C'*Sinv; 
e(missing_idx)=0;
% Posterior hidden state mean
xnew = xpred + K*e;

% pmax = 0.99;
% xnew(idx_xprod(2)) = max(xnew(idx_xprod(2)),0);
% xnew(idx_xprod(2)) = min(xnew(idx_xprod(2)),pmax);
% Posterior hidden state covariance
Vnew = Vpred - K*C*Vpred;
Vnew=triu(Vnew)+triu(Vnew,1)';

VVnew = A*V - K*C*A*V;
VVnew=triu(VVnew)+triu(VVnew,1)';

%--------------------END CODE ------------------------ 
end
                                  