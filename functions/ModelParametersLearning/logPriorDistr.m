function [logprior, Glogprior, Hlogprior]= logPriorDistr(P, Mu, Sigma, varargin)
% The other distribution will be added later
% From now, the prior distributions are assummed to be the Gaussian
% distribution
%% Default values
nameprior = 'normal';

%% If provided, employ user-specific arguments
args  = varargin;
nargs = length(varargin);
for n = 1:2:nargs
    switch args{n}
        case 'distribution',   nameprior = args{n+1};
        otherwise, error(['unrecognized argument' args{n}])
    end
end

%% Log-prior distribtion
if strcmp(nameprior, 'normal')
    [logprior, Glogprior, Hlogprior] = normalDistr(P, Mu, Sigma);
end

end

% Normal distribution
function [logpdf, gradlogpdf, hesslogpdf] = normalDistr(P, Mu, Sigma)
Z          = (P - Mu)./Sigma;
logpdf     = sum(-log(Sigma) - .5*log(2*pi) - .5*(Z.^2));
gradlogpdf = -Z./Sigma;
hesslogpdf = -1./Sigma;
end