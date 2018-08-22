function [logpdf, Glogpdf, Hlogpdf, delta_grad] = logPosteriorPE(data, model, misc, varargin)
% INPUTS:
% getlogpdf            -  Only log-poseterior is evaluated (1), otherwise
%                         (0). Defaut is 0.
% loglik_contribution  -  Gradient & hessian of log-likelihood are required
%                         for each evaluation. True = 1 and false = 0.
%                         Defaut is 0.
% delta_grad           -  Step size of gradient & hessian evaluations
%                         delta_grad_OR = delta_grad * abs(model.parameter)
% paramTR_index        -  The index of the parameter being estimated.
%
% OUTPUTS:
% logpdf     -  log-postoterior.
% Glogpdf    -  Gradient of the log-posterior.
% Hlogpdf    -  Hessian of the log-posterior.
% delta_grad -  Last step size of gradient & hessian evaluations.

%% Defaut values
getlogpdf           = 0;
loglik_contribution = 0;
param_idx_loop      = 0;
delta_grad          = 1E-3;
%% If provided, employ user-specific arguments
args    = varargin;
nargs   = length(varargin);
for n = 1:2:nargs
    switch args{n}
        case 'getlogpdf',           getlogpdf         = args{n+1};
        case 'loglik_contribution', loglik_contribution = args{n+1};
        case 'paramTR_index',       param_idx_loop      = args{n+1};
        case 'stepSize4grad',       delta_grad          = args{n+1};
        otherwise, error(['Unrecognized argument' args{n}])
    end
end

%% Get options
isMAP=misc.options.isMAP;

%% Log-Prior
parameter_search_idx    = ...
    find(~all(isnan(reshape([model.param_properties{:,5}],2,...
    size(model.param_properties,1))'),2));

nb_param                = length(parameter_search_idx);
Jacob_TR                = zeros(nb_param,nb_param);
logPrior                = 0;
logPrior_loop           = zeros(nb_param,1);
GlogPrior_loop          = zeros(nb_param,1);
HlogPrior_loop          = zeros(nb_param,1);

if isMAP
    logpriorMu_test              = ...
        [model.param_properties{parameter_search_idx,7}];
    logpriorSig_test             = ...
        [model.param_properties{parameter_search_idx,8}];
    logpriorName_test            = ...
        {model.param_properties{parameter_search_idx,6}};
    
    if any(isnan(logpriorMu_test)) || any(isnan(logpriorSig_test)) || ...
            any(~strcmp(logpriorName_test, 'normal'))
        
        Jacob_TR = diag(ones(nb_param,1));
        
    else
        
            logpriorMu              = [model.param_properties{:,7}];
            logpriorSig             = [model.param_properties{:,8}];
            logpriorName            = {model.param_properties{:,6}};
                
        for i = 1:nb_param
            idx                 = parameter_search_idx(i);
            [~,~,grad_TR2OR,~]  = parameter_transformation_fct(model,idx);
            Jacob_TR(i,i)       = grad_TR2OR (model.parameterTR(idx));
            if Jacob_TR(i,i) == Inf
                Jacob_TR(i,i) = realmax('single');
            elseif Jacob_TR(i,i) == -Inf
                Jacob_TR(i,i) = realmin('single');
            end
            [logPrior_loop(i), GlogPrior_loop(i), HlogPrior_loop(i)]= ...
                logPriorDistr(model.parameterTR(idx), logpriorMu(idx), ...
                logpriorSig(idx),'distribution',logpriorName{idx});
            logPrior = logPrior + logPrior_loop(i);
        end
        
    end
    
else
    Jacob_TR = diag(ones(nb_param,1));
end

%% Log-likehood

% Insert parameter values in param_properties
[model.param_properties]=writeParameterProperties(model.param_properties, ...
    [model.parameter, model.p_ref], 9);

[~,~,~,~,loglik,~,~] = SwitchingKalmanFilter(data,model,misc);
log_lik_0            = loglik;

if getlogpdf
    logpdf  = loglik + log(abs(det(Jacob_TR))) + logPrior;
    Glogpdf = NaN;
    Hlogpdf = NaN;
else
    if param_idx_loop == 0
        error('Warning: Index for the optimizing parameter is not assigned ')
    end
    [~,~,grad_TR2OR,~]                            = parameter_transformation_fct(model, param_idx_loop);
    [Gloglik, Hloglik, fail_gradHess, delta_grad] = gradHess(data, model, misc,...
        model.parameterTR(param_idx_loop),...
        model.parameter(param_idx_loop),...
        log_lik_0, grad_TR2OR, delta_grad, param_idx_loop);
    if fail_gradHess
        if loglik_contribution
            loglik  = -Inf;
            Gloglik = NaN;
            Hloglik = NaN;
        else
            if isnan(Gloglik)
                Gloglik = 0;
            end
            Hloglik = NaN;
        end
    end
    Glogpdf = Gloglik + sum(GlogPrior_loop);
    Hlogpdf = Hloglik + sum(HlogPrior_loop);
    logpdf  = loglik  + log(abs(det(Jacob_TR))) + logPrior;
end
end
%% Gradient & Hessian of Log-likelihood
function [grad, hessian, fail_gradHess, delta_grad] = gradHess(data, model, misc,...
    pTR, pOR, log_lik_0, grad_TR2OR,...
    delta_grad, param_idx_loop)
hessian_test = 1;
loop         = 0;
while hessian_test
    loop = loop + 1;
    if loop > 5
        if grad==0
            grad    = NaN;
        end
        hessian         = NaN;
        fail_gradHess   = 1;
        break
    else
        fail_gradHess = 0;
    end
    [delta_grad, fail_delta_grad, log_lik_1, log_lik_2] = StepSizeOptimization(model, data, misc,...
        pOR, log_lik_0, delta_grad,...
        param_idx_loop);
    delta_grad_OR = delta_grad*abs(pOR);
    
    if  fail_delta_grad
        grad          = NaN;
        hessian       = NaN;
        fail_gradHess = 1;
        break
    else
        if any(~isreal([log_lik_0,log_lik_1,log_lik_2]))
            disp('           Warning: LL is complex -> LL=real(LL)')
            log_lik_0 = real(log_lik_0);
            log_lik_1 = real(log_lik_1);
            log_lik_2 = real(log_lik_2);
        end
        grad     = ((log_lik_2 - log_lik_1)/(2*delta_grad_OR))*grad_TR2OR(pTR);
        hessian  = ((log_lik_2 - 2*log_lik_0 + log_lik_1)/(delta_grad_OR^2))*grad_TR2OR(pTR)^2;
        
        if hessian == 0||grad==0
            delta_grad   = delta_grad * 2;
            hessian_test = 1;
        else
            hessian_test = 0;
        end
    end
end
end

%% Optimization stepsize for gradien and hessian
function [delta_grad, fail_delta_grad, log_lik_1, log_lik_2] = StepSizeOptimization(model, data, misc,...
    pOR, log_lik_0, delta_grad,...
    param_idx_loop)
gradThreshold_inf   = 1E-2;
gradThreshold_sup   = 1E-2;
stepSize_test       = 1;
delta_grad_OR       = delta_grad*abs(pOR);
loop                = 0;
while stepSize_test
    loop = loop + 1;
    if loop > 5
        fail_delta_grad = 1;
        log_lik_1       = NaN;
        log_lik_2       = NaN;
        break
    else
        fail_delta_grad = 0;
    end
    % Log-likehood calculation
    delta_grad_OR           = boundaryConditionValidity(model, pOR, delta_grad_OR, param_idx_loop);
    log_lik_s               = zeros(1,2);
    p_LL                    = [model.parameter,model.parameter];
    p_LL(param_idx_loop,1)  = pOR - delta_grad_OR;
    p_LL(param_idx_loop,2)  = pOR + delta_grad_OR;
    model_store             = cell(1,2);
    m_1                     = model;
    m_2                     = model;
    m_1.parameter           = p_LL(:,1);
    m_2.parameter           = p_LL(:,2);
    
    % Insert parameter values in param_properties
    [m_1.param_properties]=writeParameterProperties(m_1.param_properties, ...
        [m_1.parameter, model.p_ref], 9);
    
    [m_2.param_properties]=writeParameterProperties(m_2.param_properties, ...
        [m_2.parameter, model.p_ref], 9);
    
    model_store{1}          = m_1;
    model_store{2}          = m_2;
    if misc.options.isParallel
        parfor i=1:2
            % LL calcultation
            [~,~,~,~,log_lik_s(i),~,~]=SwitchingKalmanFilter(data,model_store{i},misc);
        end
    else
        for i=1:2
            % LL calcultation
            [~,~,~,~,log_lik_s(i),~,~]=SwitchingKalmanFilter(data,model_store{i},misc);
        end
    end
    log_lik_1=log_lik_s(1);
    log_lik_2=log_lik_s(2);
    
    % Size-step optimization ensure that the gradient can not change too rapidly or slowly
    if abs((log_lik_2 - log_lik_1))<=(gradThreshold_inf*delta_grad_OR) % Gradient Lipschitz
        delta_grad_OR   = 2*delta_grad_OR;
        delta_grad      = delta_grad_OR/abs(pOR);
        
    elseif abs((log_lik_2 - log_lik_1)/log_lik_0)>=gradThreshold_sup
        delta_grad_OR   = delta_grad_OR/2;
        delta_grad      = delta_grad_OR/abs(pOR);
    else
        stepSize_test   = 0;
        delta_grad      = delta_grad_OR/abs(pOR);
    end
end
end

%% Validation of boundary
function delta_grad_OR = boundaryConditionValidity(model, pOR, delta_grad_OR, param_idx_loop)
min_p = model.param_properties{param_idx_loop,5}(1);
max_p = model.param_properties{param_idx_loop,5}(2);

if or((pOR - delta_grad_OR)<min_p,((pOR + delta_grad_OR)>max_p))
    % self-adaptation step size for each type of parameters
    if model.param_properties{param_idx_loop,5}(1)==0&&model.param_properties{param_idx_loop,5}(2)==inf
        if (pOR-delta_grad_OR)<min_p
            delta_grad_OR = (pOR-min_p)/10;
        else
            delta_grad_OR = (max_p-pOR)/10;
        end
    else
        if (pOR-delta_grad_OR)<min_p
            delta_grad_OR = (pOR-min_p)/2;
        else
            delta_grad_OR = (max_p-pOR)/2;
        end
    end
end
end