function [xnew, Vnew, VVnew, U_post, D_post, loglik]=UDFilter(A, C, Q, R, y, x, V, U_post, D_post)
%UDFILTER Do one step of the UD filter (prediction + update at time t) 
%
%   SYNOPSIS:
%      [xnew, Vnew, VVnew, U_post, D_post, loglik]=UDFILTER(A, C, Q, R, y, x, V, U_post, D_post)
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
%      U_post                   - real valued array (required)
%                                 
%
%      D_post                   - real valued array (required)
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
%      U_post                   - real valued array 
%                                 
%      D_post                   - real valued array   
%
%      loglik                   - real 
%                                 log-likelihood at time t
% 
%   DESCRIPTION:
%      UDFILTER performs one step of the UD filter (prediction + update at time t)
%      UDFILTER uses function initially developed by Brian Moore.
% 
%   EXAMPLES:
%      [xnew, Vnew, VVnew, U_post, D_post, loglik]=UDFILTER(A, C, Q, R, y, x, V, U_post, D_post)
% 
%   EXTERNAL FUNCTIONS CALLED:
%      myUD
% 
%   SUBFUNCTIONS:
%      bierman_m,  thornton, KalmanGainCalc,myUnitTriSysSol
%      
%   See also SWITCHINGKALMANFILTER, MYUD
 
%   AUTHORS: 
%       Luong Ha Nguyen, Ianis Gaudot, James-A Goulet
%
%       Inspired from the initial code of Brian Moore
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
%       December 3, 2018
 
%--------------------BEGIN CODE ---------------------- 
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'A', @isnumeric );
addRequired(p,'C', @isnumeric );
addRequired(p,'Q', @isnumeric );
addRequired(p,'R', @isnumeric );
addRequired(p,'y', @isnumeric );
addRequired(p,'x', @isnumeric );
addRequired(p,'V', @isnumeric );   
addRequired(p,'U_post', @isnumeric );
addRequired(p,'D_post', @isnumeric ); 
 
parse(p,A,C,Q,R,y,x,V,U_post, D_post);

A=p.Results.A;
C=p.Results.C;
Q=p.Results.Q;
R=p.Results.R;
y = p.Results.y;
x=p.Results.x;      
V=p.Results.V;   
U_post=p.Results.U_post;
D_post=p.Results.D_post; 


%% Prediction
xpred = A*x;
Vpred = A*V*A';
Vpred=(Vpred+Vpred')/2;
Vpred=Vpred+Q;


try [Uq,Dq] = myUD(Q, 'isError', false);
catch
    warning('UD decomposition failed error.')
end
[x_prior,U_prior,D_prior] = thornton(x,U_post,D_post,Uq,Dq,A);

D_prior(D_prior>realmax('double'))=realmax('double');

missing_idx=isnan(y);
V_prior=U_prior*D_prior*U_prior';
if all(missing_idx)
    loglik=0;
else
    if any(any(isinf(Q)))
        xpred(end)=y(end);
        V_prior(end,:)=0;
        V_prior(:,end)=0;
        V_prior(end,end)=0;
    end
    
    idx_ll=~missing_idx;
    y_pred=C(idx_ll,:)*xpred;
    Vy_pred=C(idx_ll,:)*V_prior*C(idx_ll,:)'+R(idx_ll,idx_ll);
    loglik = getGaussianProbability(y(idx_ll),y_pred, Vy_pred, 'isLog', true);
end
if all(missing_idx)
    xnew=x_prior;
    U_post=U_prior;
    D_post=D_prior;
else
    for i=find(~missing_idx')
        [x_prior,U_prior,D_prior] = bierman_m(y(i),R(i,i),C(i,:),x_prior,U_prior,D_prior);
    end
    xnew=x_prior;
    U_post=U_prior;
    D_post=D_prior;
end


%% Update
Vnew=U_post*D_post*U_post';
K=KalmanGainCalc(Vpred,R,C);
K(:,missing_idx)=0;
VVnew = A*V - K*C*A*V;
VVnew=triu(VVnew)+triu(VVnew,1)';

%--------------------END CODE ------------------------ 
end

function [x_post U_post D_post] = bierman_m(z,R,H,x_prior,U_prior,D_prior)
%--------------------------------------------------------------------------
% Syntax:  [x_post U_post D_post] = bierman(z,R,H,x_prior,U_prior,D_prior);
%
% Inputs:       z is a scalar measurement
%               R is the variance of z
%               H is a row vector of length length(x_prior)
%               x_prior is the apriori state estimate
%               [U_prior D_prior] = myUD(P_prior);
%               
% Outputs:      x_post is the aposteriori state estimate
%               [U_post D_post] = myUD(P_post);
%
% Description:  This function performs the Bierman square root Kalman
%               filter scalar measurement update. That is, it performs
%
%               K = P_prior * H' / (H * P_prior * H' + R);
%               x_post = x_prior + K * (z - H * x_prior);
%               P_post = (I - K*H) * P_prior;
%
%               but returns x_post, U_post, and D_post, where
%               [U_post D_post] = myUD(P_post);
%
% Author:       Brian Moore
%               brimoor@umich.edu
%
% Date:         June 28, 2012
%--------------------------------------------------------------------------

x_post = x_prior;
U_post = U_prior; 
D_post = D_prior;
a = U_post' * H';
b = D_post * a;
dz = z - H * x_prior; 
alpha = R; 
gamma = 1 / alpha; 
  for j = 1:length(x_prior)
  beta   = alpha; 
  alpha  = alpha + a(j) * b(j); 
  lambda = -a(j) * gamma; 
  gamma  = 1 / alpha; 
  D_post(j,j) = beta * gamma * D_post(j,j); 
    for i = 1:j-1 
    beta = U_post(i,j); 
    U_post(i,j) = beta + b(i) * lambda; 
    b(i) = b(i) + b(j) * beta; 
    end
  end
x_post = x_post + gamma * dz * b;
end

function [x_prior U_prior D_prior] = thornton(x_post,U_post,D_post,Uq,Dq,varargin)
%--------------------------------------------------------------------------
% Syntax: [x_prior U_prior D_prior]=thornton(x_post,U_post,D_post,Uq,Dq);
%         [x_prior U_prior D_prior]=thornton(x_post,U_post,D_post,Uq,Dq,A);
%
% Inputs:       x_post is the aposteriori state estimate
%               [U_post D_post] = myUD(P_post);
%               [Uq Dq] = myUD(Q);
%               A is the state transition matrix (can exclude when A is an
%               identity matrix)
%
% Outputs:      x_prior is the apriori state estimate
%               [U_prior D_prior] = myUD(P_prior);
%
% Description:  This function performs the Thornton square root Kalman
%               filter time update, which employs the modified weighted QR
%               decomposition. That is, it performs
%
%               x_prior = A * x_post;
%               P_prior = A * P_post * A' + Q;
%
%               but returns x_prior, U_prior, and D_prior, where
%               [U_prior D_prior] = myUD(P_prior);
%
% Author:       Brian Moore
%               brimoor@umich.edu
%
% Date:         June 28, 2012
%--------------------------------------------------------------------------

tol = 1e-55;

n = length(x_post);
sigma = 0; %#ok
dinv = 0; %#ok
i = 0; %#ok
j = 0; %#ok
k = 0; %#ok

a1 = zeros(1,n);
a2 = zeros(1,n);
v1 = zeros(1,n);
v2 = zeros(1,n);
D_prior = zeros(n);

if nargin == 6
    A = varargin{1};
    
    x_prior = A * x_post;

    % Form U_prior = A * U_post
    U_prior = A;
    for i = 1:n
        for j = n:-1:1
            sigma = U_prior(i,j);
            for k = 1:(j-1)
                sigma = sigma + U_prior(i,k) * U_post(k,j);
            end
            U_prior(i,j) = sigma;
        end
    end
else
    x_prior = x_post;
    U_prior = U_post;
end

for j = n:-1:1
    sigma = 0;
    for k = 1:n
        v1(k) = U_prior(j,k);
        a1(k) = D_post(k,k) * v1(k);
        sigma = sigma + v1(k) * a1(k);
    end
    for k = 1:n
        v2(k) = Uq(j,k);
        a2(k) = Dq(k,k) * v2(k);
        sigma = sigma + v2(k) * a2(k);
    end
    U_prior(j,j) = sigma;
    if sigma < tol
        error('New error covariance matrix is not positive definite');
    end
    dinv = 1 / sigma;
    for k = 1:(j-1)
        sigma = 0;
        for i = 1:n
            sigma = sigma + U_prior(k,i) * a1(i);
        end
        for i = 1:n
            sigma = sigma + Uq(k,i) * a2(i);
        end
        sigma = sigma * dinv;
        for i = 1:n
            U_prior(k,i) = U_prior(k,i) - sigma * v1(i);
        end
        for i = 1:n
            Uq(k,i) = Uq(k,i) - sigma * v2(i);
        end
        U_prior(j,k) = sigma;
    end
end

for j = 1:n
    D_prior(j,j) = U_prior(j,j);
    U_prior(j,j) = 1;
    for i = 1:(j-1)
        U_prior(i,j) = U_prior(j,i);
        U_prior(j,i) = 0;
    end
end
end


function [K isSingular] = KalmanGainCalc(P,R,varargin)
%
% Computes the Kalman Gain K from the formula K = P*H'*(H*P*H'+R)^(-1)
% WITHOUT explicitly inverting H*P*H'+R by computing its unit Cholesky
% Decomposition and then applying backsubstitutions on the resulting
% triangular factors.
%

if nargin ~= 3
    try
        [U D] = myUD(P+R);
        isSingular = 'false';
        X1 = myUnitTriSysSol(U,P','upper');
        X2 = X1;
        for i = 1:size(X2,1)
            for j = 1:size(X2,2)
                X2(i,j) = X2(i,j) / D(i,i);
            end
        end
        X3 = myUnitTriSysSol(U',X2,'lower');
        K = X3';
    catch %#ok
        isSingular = 'true';
        K = zeros(size(P,1),size(R,2));
    end
else
    H = varargin{1};
    try
        [U D] = myUD(H*P*H'+R);
        isSingular = 'false';
        X1 = myUnitTriSysSol(U,H*P','upper');
        X2 = X1;
        for i = 1:size(X2,1)
            for j = 1:size(X2,2)
                X2(i,j) = X2(i,j) / D(i,i);
            end
        end
        X3 = myUnitTriSysSol(U',X2,'lower');
        K = X3';
    catch %#ok
        isSingular = 'true';
        K = zeros(size(P,1),size(R,2));
    end
end
end

function X = myUnitTriSysSol(T,Y,mode)
%--------------------------------------------------------------------------
% Syntax:       X = myUnitTriSysSol(U,Y,'upper');
%               X = myUnitTriSysSol(L,Y,'lower');
%
% Inputs:       When mode == 'upper':
%               U is an N x N unit upper triangular matrix, and Y is an
%               N x P matrix.
%
%               When mode == 'lower':
%               L is an N x N unit lower triangular matrix, and Y is an
%               N x P matrix.
%
% Outputs:      X is the N x P matrix such that X = U^(-1) * Y;
%
% Description:  This function solves the linear, unit triangular system of
%               equations Y = T * X using backsubstitution, and returns
%               X such that X = T^(-1) * Y; (for T = U or T = L)
%
% Author:       Brian Moore
%               brimoor@umich.edu
%
% Date:         July 12, 2012
%--------------------------------------------------------------------------

[m n] = size(T);
if (m ~= n)
    error('Input matrix must be square');
end

[m p] = size(Y);

if (m ~= n)
    error('U and Y must have same inner dimensions');
end

X = zeros(n,p);

if strcmpi(mode,'upper')
    for j = 1:p
        for i = n:(-1):1
            X(i,j) = Y(i,j);
            for k = (i+1):n
                X(i,j) = X(i,j) - T(i,k) * X(k,j);
            end
        end
    end
elseif strcmpi(mode,'lower')
    for j = 1:p
        for i = 1:n
            X(i,j) = Y(i,j);
            for k = 1:(i-1)
                X(i,j) = X(i,j) - T(i,k) * X(k,j);
            end
        end
    end
end
end



