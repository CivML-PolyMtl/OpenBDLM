%function [xnew, Vnew, VVnew, loglik, pr_model_false_marginal, nis, e] = KF(A, C, Q, R, y, x, V,varargin)
function [xnew, Vnew, VVnew, loglik] = KF(A, C, Q, R, y, x, V,varargin)
% KALMAN_UPDATE Do a one step update of the Kalman filter
% [xnew, Vnew, loglik] = kalman_update(A, C, Q, R, y, x, V, ...)
%
% INPUTS:
% A - the system matrix
% C - the observation matrix
% Q - the system covariance
% R - the observation covariance
% y(:)   - the observation at time t
% x(:) - E[X | y(:, 1:t-1)] prior mean
% V(:,:) - Cov[X | y(:, 1:t-1)] prior covariance
%
% OPTIONAL INPUTS:
% b - mean correction vector
%
% OUTPUTS (where X is the hidden state being estimated)
%  xnew(:) =   E[ X | y(:, 1:t) ]
%  Vnew(:,:) = Var[ X(t) | y(:, 1:t) ]
%  VVnew(:,:) = Cov[ X(t), X(t-1) | y(:, 1:t) ]
%  loglik = log P(y(:,t) | y(:,1:t-1)) log-likelihood of innovatio

%  xpred(:) = E[X_t+1 | y(:, 1:t)]
%  Vpred(:,:) = Cov[X_t+1 | y(:, 1:t)]
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

%% Prediction step
xpred = A*x+B;
Vpred = A*V*A'+Q+W; 
Vpred=(Vpred+Vpred')/2;

%% identify missing data
missing_idx=isnan(y);

%% Update step
e = y - C*xpred;  % error (innovation)
n = length(e);
ss = length(A);
S = C*Vpred*C' + R;
S = (S+S')/2;
Sinv = pinv(S);
Sinv(missing_idx,missing_idx)=0;
ss = length(V);

% Compute log-likelihood
if all(missing_idx)
    loglik=0;
else
    loglik = gaussian_prob(e(~missing_idx), zeros(1,sum(~missing_idx)), S(~missing_idx,~missing_idx), 1);
end

% Compute marginal probability of model falsification (Ianis)

if all(missing_idx)
    pr_model_false_marginal = NaN;
else
    p = normcdf([ C*xpred-abs(e), C*xpred+abs(e)], C*xpred, sqrt(S));
    pr_model_false_marginal=p(2)-p(1);
end

% Compute normalized squared innovations NIS (Ianis)
nis=e'*Sinv*e;


K = Vpred*C'*Sinv; % Kalman gain matrix
e(missing_idx)=0;
xnew = xpred + K*e;
Vnew = Vpred - K*C*Vpred;
Vnew=triu(Vnew)+triu(Vnew,1)';
VVnew = A*V - K*C*A*V;
VVnew=triu(VVnew)+triu(VVnew,1)';

