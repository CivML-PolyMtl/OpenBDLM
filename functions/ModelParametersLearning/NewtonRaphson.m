function [optim, model]=NewtonRaphson(data, model, misc)
%NEWTONRAPHSON Learn BDLM models parameters using the Newton-Raphson technique
%
%   SYNOPSIS:
%     [optim]=NEWTONRAPHSON(data, model, misc)
%
%   INPUT:
%     data             - structure (required)
%                        see documentation for details about the fields of
%                        data
%
%     model            - structure (required)
%                        see documentation for details about the fields of
%                        model
%
%     misc             - structure (required)
%                        see documentation for details about the fields of
%                        misc
%   OUTPUT:
%     optim            - structure
%                        * optim.parameter_OR_opt: optimal parameters in
%                          original space
%                        * optim.parameter_TR_opt: optimal parameters in
%                          transformed space.
%                        * optim.covParamTR_matrix: parameter covariance
%                          matrix in transformed space. The parameter 
%                          covariance matrix is computed using the Laplace 
%                          Approximation arount the point estimate.
%
%     model            - structure (required)
%                           see documentation for details about the fields of
%                           model
%
%   DESCRIPTION:
%      NEWTONRAPHSON is an implementation of the Newton-Raphson
%      algorithm to learn the model parameters of the Bayesian dynamic
%      linear models.
%      NEWTONRAPHSON can either perform Maximum Likelihood Estimation (MLE) 
%      or Maximum A Posteriori estimation (MAP). MAP required a valid prior
%      for each model parameter to learn.
%      The MLE (MAP) Newton-Raphson technique is used to iteratively
%      search for the maximum of the log-likelihood (log-posterior) using
%      numerical derivatives.
%
%      NEWTONRAPHSON computes point estimate (MLE or MAP) of the model 
%      parameters. It may also provide confidence intervals around the point 
%      estimate using the Laplace approximation, assuming that the function 
%      around the optimized parameter value can be approximated using a 
%      gaussian distribution.
%      Note that computing the Laplace approximation can significantly
%      increases the computation time for high dimensional problem.
%
%      For bounded model parameters ([a,b], [0,Inf]), NEWTONRAPHSON works in
%      transformed space.
%
%      WARNING: Newton-Raphson technique is sensitive to the initial model
%      parameters values. Newton-Raphson can reach a local maximum, instead
%      of the global maximum of that function, which is the solution
%      (if a global maximum exists).
%      Always re-run the optimizations several times, with different
%      starting model parameters values, in order to
%      check that the proposed solution is stable.
%
%   EXAMPLES:
%      [optim]=NEWTONRAPHSON(data, model, misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%      logPosteriorPE, logPriorDistr, LaplaceApproximation,
%        parameter_transformation_fct
%
%   SUBFUNCTIONS:
%
%   See also LOGPOSTERIORPE, LOGPRIORDISTR, LAPLACEAPPROXIMATION,
%   PARAMETER_TRANSFORMATION_FCT

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
%       June 22, 2018
%
%   DATE LAST UPDATE:
%       August 21, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'misc', @isstruct );

parse(p,data, model,  misc);

data=p.Results.data;
model=p.Results.model;
misc=p.Results.misc;

%% Read current options from misc.options structure
trainingPeriod=misc.options.trainingPeriod;
%isMAP=misc.options.isMAP;
%isPredCap=misc.options.isPredCap;
isLaplaceApprox = misc.options.isLaplaceApprox;
maxIterations = misc.options.maxIterations;
maxTime = misc.options.maxTime;
%isParallel=misc.options.isParallel;
isMute=misc.options.isMute;

% Set fileID for logfile
if misc.isQuiet
    % output message in logfile
    fileID=fopen(misc.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end

%% Read model parameter properties
% Current model parameters
idx_pvalues=size(model.param_properties,2)-1;
idx_pref= size(model.param_properties,2);

[arrayOut]=...
    readParameterProperties(model.param_properties, [idx_pvalues, idx_pref]);

parameter= arrayOut(:,1);
p_ref=arrayOut(:,2);

% Assign model.parameters
model.parameter=parameter;
model.p_ref=p_ref;

%% Resize the dataset according to the chosen training period
% Get timestamp vector
timestamps = data.timestamps;
% Get training period
training_start_idx = day2sampleIndex(trainingPeriod(1), timestamps);
training_end_idx = day2sampleIndex(trainingPeriod(2), timestamps);

%% Interventions
if ~isfield(data, 'interventions')
    data.interventions=[];
end

% Resize timestamps
data_train.timestamps = timestamps(training_start_idx:training_end_idx);
data_train.interventions      = data.interventions;

% Get timestep training vector
[data_train.dt_steps]=computeTimeSteps(data_train.timestamps);
data_train.nb_steps = length(training_start_idx:training_end_idx);

% Compute reference timestep during training
[data_train.dt_ref] = defineReferenceTimeStep(data_train.timestamps);

%Define time step vector
data_train.dt_steps           = [data_train.dt_ref;data_train.dt_steps];
% data.dt_ref                   = data_train.dt_ref ;
% data.dt_steps(1)              = data.dt_ref;

%Get data values
DataValues = data.values;
% Resize data values
for i=1:size(data.values,2)
    data_train.values(:,i) = ...
        DataValues(training_start_idx:training_end_idx,i);
end


%% Identify parameters to be optimized
parameter_search_idx    = find(~all(isnan(reshape( ...
    [model.param_properties{:,5}],2,size(model.param_properties,1))'),2));
nb_param                = length(parameter_search_idx);

%% Initialize transformed model parameters
parameter_OR            = model.parameter;
parameter_TR            = zeros(length(model.parameter),1);
transfFunc.TR           = cell(1,nb_param);
transfFunc.InvTR        = cell(1,nb_param);
transfFunc.gradTR2OR    = cell(1,nb_param);
for i = 1 : nb_param
    idx                 = parameter_search_idx(i);
    [transfFunc.TR{i},transfFunc.InvTR{i},transfFunc.gradTR2OR{i},~] =  ...
        parameter_transformation_fct(model,idx);
    parameter_TR(idx)   = transfFunc.TR{i}(parameter_OR(idx));
end
% parameterTR_ref = parameter_TR;
model.parameterTR   = parameter_TR;

%% Analysis parameters
nb_levels_lambda_ref    = 4;
convergence_tolerance   = 1E-7;

disp('     Learning model parameters (Newton-Raphson) ...')

if ~isMute
    fprintf(fileID, '\n');
    fprintf(fileID, ['    \\Start Newton-Raphson maximization ', ...
        ' algorithm (finite difference method)\n']);
    fprintf(fileID, '\n');
    fprintf(fileID, ['      Training period:', ...
        '                                      ',...
        ' ' num2str(trainingPeriod(1)) '-',...
        ''  num2str(trainingPeriod(2)) ' [days]\n']);
    fprintf(fileID, ['      Maximal number of iteration:', ...
        '                          ',...
        ' ' num2str(maxIterations), '\n']);
    fprintf(fileID, ['      Total time limit for calibration :', ...
        '                    ',...
        ' ' num2str(maxTime) ' [min]\n']);
    fprintf(fileID, ['      Convergence criterion:', ...
        '                                ',...
        ' ' num2str(convergence_tolerance) '*LL\n']);
    fprintf(fileID, ['      Nb. of search levels for \\lambda:', ...
        '                     ',...
        ' ' num2str(nb_levels_lambda_ref) '*2\n']);
    fprintf(fileID, '\n');
end

%% Matrices & parameter initilization
hessian_fail_hist        = zeros(1,numel(parameter_search_idx));
optimization_fail        = zeros(1,numel(parameter_search_idx));
converged                = zeros(1,numel(parameter_search_idx));
dll                      = 1E6*ones(1,numel(parameter_search_idx));
grad_p_TR                = zeros(size(parameter_OR));
hessian_p_TR             = zeros(size(parameter_OR));
std_p                    = zeros(size(parameter_OR));
std_p_TR                 = abs(parameter_TR);
delta_grad               = 1E-3*ones(size(parameter_OR));
%% Log-likelihood initialization
[logpdf_0, ~, ~,~] = logPosteriorPE(data_train, model, misc, 'getlogpdf', 1);
if isinf(logpdf_0)
    fprintf(fileID, 'warning LL0=-inf\n');
end
if ~isMute
    fprintf(fileID, '           Initial LL: %s\n', num2str(logpdf_0));
end
name_idx_1='';
name_idx_2='';
for i=parameter_search_idx'
    name_p1{i}=[model.param_properties{i,1}];
    if ~isempty(model.param_properties{i,4})
        temp=model.param_properties{i,4}(1);
    else
        temp='';
    end
    name_p2{i}=[model.param_properties{i,2}, '|M', ...
        model.param_properties{i,3},'|',temp];
    name_idx_1=[name_idx_1  name_p1{i} ...
        repmat(' ',[1,15-length(name_p1{i})]) ' '];
    name_idx_2=[name_idx_2  name_p2{i} ...
        repmat(' ',[1,15-length(name_p2{i})]) ' '];
end
if ~isMute
    fprintf(fileID, '                       %s \n', name_idx_2);
    fprintf(fileID, '      parameter names: %s \n', name_idx_1);
    fprintf(fileID, ['       initial values: ' repmat(['%#-+15.2e' ' '], ...
        [1,length(parameter_OR)])],parameter_OR(parameter_search_idx));
end

%% NR Optimization loops
tic; % time counter initialization
time_loop=0;
search_loop=1;
while and(search_loop<=maxIterations, ...
        time_loop<(maxTime*60))
    if ~isMute
        fprintf(fileID, '\n');
    end
    parameter_OR_ref = parameter_OR;
    parameter_TR_ref = parameter_TR;
    %% Select the parameter which previously led to the highest change in LL
    rand_sample = rand;
    dll_cumsum  = cumsum(dll)/sum(dll);
    dll_rank    = dll_cumsum-rand_sample;
    dll_rank(dll_rank<0) = inf;
    % Remove the parameters that have small impact on log-likelihood
    dll_rank(hessian_fail_hist>10) = Inf;
    if all(dll_rank == Inf)
        param_idx = find(~converged,1,'first');
    else
        param_idx = find((dll_cumsum-rand_sample)==min(dll_rank),1,'first');
    end
    param_idx_loop = parameter_search_idx(param_idx);
    param          = parameter_OR_ref(param_idx_loop);
    param_TR       = parameter_TR_ref(param_idx_loop);
    if ~isMute
        fprintf(fileID, '--------------------------\n');
        fprintf(fileID, '    Loop #%s : %s | %s \n', ...
            num2str(search_loop), name_p2{param_idx_loop}, ...
            name_p1{param_idx_loop});
    end
    H_test       = 1;
    loop_count   = 1;
    skip_loop_H  = 0;
    hessian_fail = 0;
    % loop until the hessian can be calculated
    while H_test
        loop_count=loop_count +1;
        if loop_count >5 || hessian_fail
            if ~isMute
                fprintf(fileID, ['           Warning:>5 failed ',...
                    'attempts to compute the Hessian \n']);
            end
            skip_loop_H = 1;
            hessian_fail_hist(param_idx)        = ...
                hessian_fail_hist(param_idx)+1;
            parameter_OR(param_idx_loop)        = ...
                parameter_OR_ref(param_idx_loop);
            parameter_TR(param_idx_loop)        = ...
                parameter_TR_ref(param_idx_loop);
            if hessian_fail_hist(param_idx)>3
                if ~isMute
                    fprintf(fileID, ['           Warning: ', ...
                        '3nd discontinued fails ', ...
                        'to compute the Hessian  -> converged=1\n']);
                end
                converged(param_idx) = 1;
            end
            dll(param_idx) = abs(convergence_tolerance*logpdf_0);
            break
        end
        
        model.parameter   = parameter_OR;
        model.parameterTR = parameter_TR;
        
        [~, GlogpdfTR_loop, HlogpdfTR_loop, delta_grad_loop] = ...
            logPosteriorPE(data_train, model, misc,...
            'paramTR_index',param_idx_loop,...
            'stepSize4grad',delta_grad(param_idx_loop));
        
        delta_grad(param_idx_loop) = delta_grad_loop;
        if hessian_fail_hist(param_idx) > 0
            hessian_fail_hist(param_idx) = 0;
        end
        if HlogpdfTR_loop < 0
            hessian_p_TR(param_idx_loop) = HlogpdfTR_loop;
            grad_p_TR(param_idx_loop)    = GlogpdfTR_loop;
            delta_p_TR                   = - GlogpdfTR_loop/HlogpdfTR_loop;
            H_test                       = 0;
        elseif HlogpdfTR_loop > 0
            hessian_p_TR(param_idx_loop) = HlogpdfTR_loop;
            grad_p_TR(param_idx_loop)    = GlogpdfTR_loop;
            if model.param_properties{param_idx_loop,5}(1)==0 && ...
                    model.param_properties{param_idx_loop,5}(2)==inf && ...
                    abs(param)<1E-7
                delta_p_TR = sign(GlogpdfTR_loop)*0.25*param_TR;
            else
                %Gradient descent must be used to reach the maxima
                delta_p_TR = 0.1*GlogpdfTR_loop/HlogpdfTR_loop;
            end
            if ~isMute
                fprintf(fileID, ['           Warning: ', ...
                    'Hessian is positive\n']);
            end
            H_test = 0;
        elseif isnan(HlogpdfTR_loop)
            H_test       = 1;
            hessian_fail = 1;
        end
    end
    if skip_loop_H ~= 1
        std_p_TR_loop = sqrt(-1/hessian_p_TR(param_idx_loop));
        %Linearized Laplace approximation of parameter standard deviation
        std_p_loop    = ...
            abs(transfFunc.gradTR2OR{param_idx}(param_TR))*std_p_TR_loop;
        if hessian_p_TR(param_idx_loop) < 0
            std_p(param_idx_loop)    = std_p_loop;
            std_p_TR(param_idx_loop) = std_p_TR_loop;
        else
            std_p(param_idx_loop)    = NaN;
            std_p_TR(param_idx_loop) = NaN;
        end
        delta_p = transfFunc.InvTR{param_idx}(param_TR+delta_p_TR) - param;
        if ~isMute
            fprintf(fileID, '       delta_param: %s \n', num2str(delta_p));
        end
        try
            %% LL test
            parameter_TR(param_idx_loop) = param_TR + delta_p_TR;
            parameter_OR(param_idx_loop) = ...
                transfFunc.InvTR{param_idx}(parameter_TR(param_idx_loop));
            model.parameter              = parameter_OR;
            model.parameterTR            = parameter_TR;
            [logpdf_test, ~, ~,~]        = ...
                logPosteriorPE(data_train, model, misc, 'getlogpdf', 1);
        catch
            logpdf_test = -inf;
        end
        loop_converged = 1;
        delta_p_TR_ref = delta_p_TR;
    else
        % Optimization has failed the actual parameter -> move to next parameter
        loop_converged = 0;
    end
    %% Check the validity of delta_p
    n                = 0;
    reverse          = 0;
    n_ref            = 0;
    nb_levels_lambda = nb_levels_lambda_ref;
    while loop_converged
        n=n+1;
        if logpdf_test>logpdf_0
            loop_converged       = 0;
            converged(param_idx) = and(~isnan(std_p(param_idx_loop)), ...
                abs(logpdf_test - logpdf_0)<abs(convergence_tolerance*logpdf_0));
            % Record the change in the log-likelihood
            dll(param_idx)       = logpdf_test - logpdf_0;
            if dll(param_idx)<abs(convergence_tolerance*logpdf_0)
                if isnan(std_p(param_idx_loop))
                    dll(param_idx) = 10*abs(convergence_tolerance*logpdf_0);
                else
                    dll(param_idx) = abs(convergence_tolerance*logpdf_0);
                end
            end
            logpdf_0                            = logpdf_test;
            parameter_TR_ref(param_idx_loop)    = parameter_TR(param_idx_loop);
            parameter_OR_ref(param_idx_loop)    = parameter_OR(param_idx_loop);
            if ~isMute
                fprintf(fileID, ['    log-likelihood :', ...
                    ' %s\n'], num2str(logpdf_0));
                fprintf(fileID, ['    param change   :', ...
                    ' %s -> %s\n'], num2str(param),...
                    num2str(parameter_OR(param_idx_loop)));
                fprintf(fileID, '\n');
                fprintf(fileID, '                    %s\n', name_idx_2);
                fprintf(fileID, '   parameter names: %s\n', name_idx_1);
                fprintf(fileID, ['    current values: ', ...
                    '' repmat(['%#-+15.2e' ' '], ...
                    [1,length(parameter_OR(parameter_search_idx))-1]) ...
                    '%#-+15.2e\n',...
                    '  current f.o. std: ' repmat(['%#-+15.2e' ' '],...
                    [1,length(parameter_OR(parameter_search_idx))-1]) ...
                    '%#-+15.2e\n',...
                    '      previous dLL: ' repmat(['%#-+15.2e' ' '],...
                    [1,length(parameter_OR(parameter_search_idx))-1]) ...
                    '%#-+15.2e\n',...
                    '         converged: ' repmat(['%#-+15.2e' ' '],...
                    [1,length(parameter_OR(parameter_search_idx))-1]) ...
                    '%#-+15.2e\n'],...
                    parameter_OR(parameter_search_idx),...
                    std_p(parameter_search_idx),...
                    dll,...
                    converged);
                
            end
            optimization_fail=optimization_fail*0;
            
            if converged(param_idx)
                break
            else
                converged(param_idx)=0;
            end
            
        else
            converged(param_idx)=0;
            if n>nb_levels_lambda
                if ~isMute
                    fprintf(fileID, '\n');
                    fprintf(fileID, ['      ...optimization ', ...
                        ' loop has failed\n']);
                end
                parameter_OR(param_idx_loop) = ...
                    parameter_OR_ref(param_idx_loop);
                parameter_TR(param_idx_loop) = ...
                    parameter_TR_ref(param_idx_loop);
                optimization_fail(param_idx) = ...
                    optimization_fail(param_idx)+1;
                if optimization_fail(param_idx)>3
                    converged(param_idx) = 1;
                    dll(param_idx)       = abs(convergence_tolerance*logpdf_0);
                else
                    dll(param_idx) = 2*abs(convergence_tolerance*logpdf_0);
                end
                break
            elseif n < nb_levels_lambda
                delta_p_TR  = delta_p_TR/(2^n);
                delta_p     = ...
                    transfFunc.InvTR{param_idx}(param_TR + ...
                    delta_p_TR)-param;
                
                if ~isMute
                    fprintf(fileID, ['           Warning: ', ...
                        'log-likelihood has ',...
                        'decreased -> delta_param: %s ', ...
                        '(delta_p_TR=delta_p_TR/(2^%s))\n'], ...
                        delta_p, num2str(n));
                end
            elseif n == nb_levels_lambda
                if reverse == 0
                    reverse     = 1;
                    n           = n_ref;
                    delta_p_TR  = -delta_p_TR_ref;
                    delta_p     = transfFunc.InvTR{param_idx} ...
                        (param_TR+delta_p_TR) - param;
                elseif reverse == 1
                    reverse          = 0;
                    n_ref            = n;
                    nb_levels_lambda = 2*nb_levels_lambda_ref;
                    delta_p_TR       = delta_p_TR_ref;
                    delta_p          = transfFunc.InvTR{param_idx} ...
                        (param_TR+delta_p_TR)-param;
                end
                if ~isMute
                    fprintf(fileID, ['           Warning: ', ...
                        'log-likelihood has ',...
                        'decreased -> delta_param: %s ', ...
                        '(delta_p_TR=-delta_p_TR)\n'], num2str(delta_p));
                end
                
            end
            try
                %% LL test
                parameter_TR(param_idx_loop) = param_TR + delta_p_TR;
                parameter_OR(param_idx_loop) = ...
                    transfFunc.InvTR{param_idx}(parameter_TR(...
                    param_idx_loop));
                model.parameter              = parameter_OR;
                model.parameterTR            = parameter_TR;
                [logpdf_test, ~, ~,~]        = ...
                    logPosteriorPE(data_train, model, misc,'getlogpdf', 1);
            catch
                logpdf_test=-inf;
            end
        end
    end
    search_loop=search_loop+1;
    if all(optimization_fail>0)
        if ~isMute
            fprintf(fileID, '\n');
            fprintf(fileID, ['          WARNING: the optimization ', ...
                'has failed ',...
                'for every parameter\n']);
        end
        break
    elseif all(converged)
        if ~isMute
            fprintf(fileID, '\n');
            fprintf(fileID, ['             DONE: the optimization ', ...
                'has converged ', ...
                'for all parameters\n']);
        end
        break
    end
    time_loop=toc;
end
if ~isMute
    if ~or(all(optimization_fail),all(converged))
        fprintf(fileID, '\n');
        fprintf(fileID, '\n');
        fprintf(fileID, '\n');
        if time_loop>(maxTime*60)
            fprintf(fileID, ['          WARNING : the ', ...
                'optimization has reached  ', ...
                'the maximum allowed time (',...
                '%s [min]) ',...
                'without convergence \n'], ...
                num2str(maxTime));
        else
            fprintf(fileID, ['          WARNING : the ', ...
                'optimization has reached the ',...
                ' maximum number of loops (',...
                '%s) without convergence \n'], ...
                num2str(maxIterations));
        end
    end
end

if ~isMute
    %% Display final results
    fprintf(fileID, '\n');
    fprintf(fileID, ' ----------------------\n');
    fprintf(fileID, '    Final results\n');
    fprintf(fileID, ' ----------------------\n');
    fprintf(fileID, '   log-likelihood: %s\n', num2str(logpdf_0));
    fprintf(fileID, '                   %s\n', name_idx_2);
    fprintf(fileID, '  parameter names: %s\n', name_idx_1);
    fprintf(fileID, ['   current values: ' repmat(['%#-+15.2e' ' '], ...
        [1,length(parameter_OR(parameter_search_idx))-1]) '%#-+15.2e\n',...
        ' current f.o. std: ' repmat(['%#-+15.2e' ' '], ...
        [1,length(parameter_OR(parameter_search_idx))-1]) '%#-+15.2e\n'],...
        parameter_OR(parameter_search_idx),...
        std_p(parameter_search_idx));
end
%% Outputs
optim.parameter_opt         = parameter_OR;
optim.parameterTR_opt       = parameter_TR;
optim.std_parameter_TR_opt  = std_p;
optim.hessian_p_TR_opt      = hessian_p_TR(parameter_search_idx);
optim.std_parameter_TR_opt  = std_p_TR;
optim.converged             = converged;
optim.search_loop           = search_loop;
optim.log_lik               = logpdf_0;
optim.data                  = data;
optim.data_train            = data_train;
optim.misc                  = misc;

%% Laplace Approximation
%if all(converged) && isLaplaceApprox
if isLaplaceApprox
    fprintf(fileID, '    Laplace Approximation...\n');
    [covParamTR_matrix, hessParamTR_matrix, hessParamOR_matrix] = ...
        LaplaceApproximation(data, model, misc,...
        parameter_TR,...
        parameter_OR,...
        transfFunc.gradTR2OR,...
        parameter_search_idx,...
        std_p_TR);
    
    % Store results
    optim.covParamTR_matrix     = covParamTR_matrix;
    optim.hessParamTR_matrix    = hessParamTR_matrix;
    optim.hessParamOR_matrix    = hessParamOR_matrix;
end

%% Write model.parameters in model.param_properties

% Add parameter and p_ref to param_properties
parameter=optim.parameter_opt;
[model.param_properties]=writeParameterProperties(model.param_properties, ...
    [parameter, p_ref], 9);

%--------------------END CODE ------------------------
end


function [covParamTR_matrix, hessParamTR_matrix, hessParamOR_matrix] = ...
    LaplaceApproximation(data, model, misc, pTR, pOR, func_gradTR2OR, ...
    search_idx, std_p_TR)
if size(model.param_properties,2)>6
    % mean
    logpriorMu               = [model.param_properties{:,7}];
    % standard deviation
    logpriorSig              = [model.param_properties{:,8}];
    % distribution name
    logpriorName             = {model.param_properties{:,6}};
    prior_empty = 0;
else
    prior_empty = 1;
end
nb_param                 = length(search_idx);
gradParamTR_matrix       = zeros(nb_param,nb_param);
hessParanTR_prior_matrix = zeros(nb_param,nb_param);
% stepsize for the numerical hessian
delta_diff               = 1E-6*ones(nb_param,1);
for p = 1 : nb_param
    idx = search_idx(p);
    gradParamTR_matrix(p,p) = func_gradTR2OR{p}(pTR(idx));
    if prior_empty
        hessParanTR_prior_matrix(p,p) = 0;
    else
        [~, ~, hessParanTR_prior_matrix(p,p)]      = ...
            logPriorDistr(pTR(idx), logpriorMu(idx), logpriorSig(idx), ...
            'distribution',logpriorName{idx});
    end
    
    if pOR(idx)<5E-3
        delta_diff(p) = 1E-4;
    end
end

loglikH             = @(p) loglik4hessian (p, data, model, misc, search_idx);

hessParamOR_matrix  =  numerical_hessian( pOR(search_idx), loglikH, ...
    'stepSize',delta_diff);

hessParamTR_matrix  = gradParamTR_matrix' * hessParamOR_matrix * ...
    gradParamTR_matrix + hessParanTR_prior_matrix;

if ~any(any(isnan(hessParamTR_matrix)))
    covParamTR_matrix   = inv(-hessParamTR_matrix);
    if any(any(diag(covParamTR_matrix<0)))
        if ~any(any(isnan(std_p_TR(search_idx))))
            covParamTR_matrix   = diag(std_p_TR(search_idx).^2);
        else
            fprintf(fileID, ['     Warning: Covariance matrix ', ...
                'cannot be computed.\n']);
            covParamTR_matrix = NaN(nb_param, nb_param);
        end
    end
end
end

function  LL = loglik4hessian (p, data, model, misc, search_idx)
model.parameter(search_idx) = p;

% Insert parameter values in param_properties
[model.param_properties]=...
    writeParameterProperties(model.param_properties, ...
    [p, model.p_ref], 9);

[~,~,~,~,LL,~,~]            = SwitchingKalmanFilter(data,model,misc);
end

