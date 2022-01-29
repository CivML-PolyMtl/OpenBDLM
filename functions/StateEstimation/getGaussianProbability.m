function [prob]=getGaussianProbability(x, m, C, varargin)
%GETGAUSSIANPROBABILITY Evaluate a multivariate Gaussian density
%
%   SYNOPSIS:
%     [prob]=GETGAUSSIANPROBABILITY(x, m, C, varargin)
% 
%   INPUT:
%      x        - real valued array (required)
%                  multivariate Gaussian density is evaluated at x
%
%      m        - real valued array (required)
%                 mean vector of the target Gaussian distribution
%
%      C        - real valued array (required)
%                 covariance matrix of the target Gaussian distribution
%
%      isLog    - logical (optional)
%                 if isLog = true , return the logarithme of the probability
%                 default value = true
% 
%   OUTPUT:
%      prob     - real 
%                 Gaussian probability
%                 if isLog = true, return log-probability
% 
%   DESCRIPTION:
%      GETGAUSSIANPROBABILITY evaluates a multivariate Gaussian density 
%      of mean m and covariance C at position x
%      If isLog = true, logarithme of the probability is returned to avoid
%      underflo issue
% 
%   EXAMPLES:
%      [prob]=GETGAUSSIANPROBABILITY(x, m, C)
%      [prob]=GETGAUSSIANPROBABILITY(x, m, C, 'isLog', false)
% 
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
% 
%   SUBFUNCTIONS:
%      N/A
% 
%   See also KALMANFILTER
 
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

defaultisLog = true;
addRequired(p,'x', @isnumeric );
addRequired(p,'m', @isnumeric );
addRequired(p,'C', @isnumeric );
addParameter(p, 'isLog', defaultisLog, @islogical)
parse(p,x,m,C,varargin{:});

x=p.Results.x; 
m=p.Results.m;
C=p.Results.C;
isLog=p.Results.isLog;

if length(m)==1 % scalar
    x = x(:)';
end
[d, N] = size(x);

m = m(:);

% replicate the mean across columns
M = m*ones(1,N); 
denom = (2*pi)^(d/2)*sqrt(abs(det(C)));
warning('off','all')
 % Chris Bregler's trick
mahal = sum(((x-M)'/C).*(x-M)',2);   
warning('on','all')
if any(mahal<0)
    warning('mahal < 0 => C is not psd')
    prob=nan;
    return
end

if isLog
    prob = -0.5*mahal - log(denom);
else
    prob = exp(-0.5*mahal) / (denom+eps);
end
 
%--------------------END CODE ------------------------ 
end
