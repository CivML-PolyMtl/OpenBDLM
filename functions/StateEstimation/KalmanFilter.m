function [xnew, Vnew, VVnew, loglik]=KalmanFilter(A, C, Q, R, y, x, V,varargin)
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

defaultB = 0;
defaultW = 0;
addRequired(p,'A', @isnumeric );
addRequired(p,'C', @isnumeric );
addRequired(p,'Q', @isnumeric );
addRequired(p,'R', @isnumeric );
addRequired(p,'y', @isnumeric );
addRequired(p,'x', @isnumeric );
addRequired(p,'V', @isnumeric );
addParameter(p, 'B', defaultB, @isnumeric)
addParameter(p, 'W', defaultW, @isnumeric)
parse(p,A,C,Q,R,y,x,V,varargin{:});

A=p.Results.A;
C=p.Results.C;
Q=p.Results.Q;
R=p.Results.R;
y = p.Results.y;
x=p.Results.x;      
V=p.Results.V;   
B=p.Results.B;
W=p.Results.W;

%% Prediction step
% Predicted hidden state mean
xpred = A*x+B;
% Predicted hidden state covariance
Vpred = A*V*A'+Q+W; 
Vpred=(Vpred+Vpred')/2;

%% Identify missing data
missing_idx=isnan(y);

%% Update step
% error (innovation)
e = y - C*xpred;  
n = length(e);
ss = length(A);
S = C*Vpred*C' + R;
S = (S+S')/2;
Sinv = pinv(S);
Sinv(missing_idx,missing_idx)=0;
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
% Posterior hidden state covariance
Vnew = Vpred - K*C*Vpred;
Vnew=triu(Vnew)+triu(Vnew,1)';
VVnew = A*V - K*C*A*V;
VVnew=triu(VVnew)+triu(VVnew,1)';

%--------------------END CODE ------------------------ 
end
