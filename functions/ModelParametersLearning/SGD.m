function [optim, model] = SGD(data, model, misc, varargin)
% INPUTS:
% maxIterations                   - Maximal number of epochs. Defaut is 30.
% Ndata4miniBatch           - Size of mini batch. Defaut is 0.2 of the training
%                             data.
% alpha_split               - Portion of the validation data. Defaut is 0.3.
% optim_mode                - Optimization method can be either MLE or MAP.
%                             Defaut is MLE.
% optimizer                 - optimizer can be Adaptive Moment Estimation (ADAM)
%                             or Momentum (MMT). There are also 2
%                             alternatives; ADAMbeta, MMTbeta. Defaut is MMT.
%                             ADAM    : See Kingma and Lei Ba (2017)
%                             ADAMbeta: See Schaul et al. (2013)
% metric_mode               - metric can be either prediction capacity (predCap)
%                             or log-likelihood (logpdf). Defaut is predCap.
% learningRateDefaut        - Manual tuning learning rate
% learningRate_mode         - Learning rate can be hessian, decay, or defaut.
%                             hessian -> learningRate = 1/abs(hessian)
%                             decay   -> learningRate = learningRateDefaut/sqrt(t)
%                             defaut  -> learningRate = learningRateDefaut.
%                             Defaut is hessian.
% beta_1                    - Average coefficient for the 1st moment (gradient).
%                             Defaut is 0.9.
% beta_2                    - Average coefficient for the 2nd moment
%                             (gradient^2). Defaut is 0.999.
% epsilon                   - Coefficient in ADAM. Defaut is 1E-8.
% termination_tolerance     - Moving control coefficient for metric. Defaut
%                             is 0.95.

% OUTPUTS:
% optim.parameter_opt       - optimal parameters in original space.
% optim.parameterTR_opt     - optimal parameters in transformed space.
% model

% TIPS:
% - THE HEAVILY COMPUTATIONNAL RESOURCE IS REQUIRED FOR THIS ALGORITHM
% - If optimizer is ADAM, learningRate_mode should be either decay or
%   defaut. Also, ADAM work well with a small training set.
% - If optimizer is MMT, learningRate_mode should be hessian.
%   MMT converge fast to the maximum point, but it is require a decent
%   amount of data such > 2000 (data point).
% - ADAM     -> learningRate_mode = defaut
% - ADAMbeta -> learningRate_mode = hessian
% - MMT      -> learningRate_mode = hessian
% - MMTbeta  -> learningRate_mode = hessian
% - predCap is recommended as the metric for optimization process
% - The hyperparameter such as alpha_split, learningRateDefaut, stdInit,
%   beta_1, beta_2, epsilon, termination_tolorance are recommended to set
%   as defaut for an effective performance.

%% Get options from misc structure

trainingPeriod=misc.options.trainingPeriod;
isMAP=misc.options.isMAP;
isPredCap=misc.options.isPredCap;
%isLaplaceApprox = misc.options.isLaplaceApprox;
maxIterations = misc.options.maxIterations;
maxTime = misc.options.maxTime;
%isParallel=misc.options.isParallel;
isMute=misc.options.isMute;

if isMAP
    optim_mode='MAP';
else
    optim_mode='MLE';
end


if isPredCap
    metric_mode='predCap';
else
    metric_mode='logpdf';
end

%% Defaut values
%warning('SGD ALGORITHM IS RECOMMENDED TO RUN ON MULTI-PROCESSORS')
alpha_split             = 0.3;
optimizer               = 'MMT';
learningRate_mode       = 'hessian';
learningRateDefaut      = 5E-3;
stdInit                 = 0.5;
beta_1                  = 0.9;
beta_2                  = 0.999;
epsilon                 = 1E-8;
termination_tolerance   = 0.95;
hessianDefaut           = 1000;

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

%% Data
% Get training period
training_start_idx = day2sampleIndex(trainingPeriod(1), data.timestamps);
training_end_idx = day2sampleIndex(trainingPeriod(2), data.timestamps);

misc.training_start_idx = training_start_idx;
misc.training_end_idx =  training_end_idx;

idxTrain                    = misc.training_start_idx:misc.training_end_idx;
[data_train, data_valid]    = dataSplit(data, idxTrain, alpha_split);
data.dt_ref                 = data_train.dt_ref;
data.dt_steps(1)            = data.dt_ref;
Ndata4miniBatch             = round(0.2*size(data_valid.values,1));
NminiBatch                  = ceil(length(data_train.values)/Ndata4miniBatch);
if NminiBatch<2
    NminiBatch=1;
end
%% If provided, employ user-specific arguments
args    = varargin;
nargs   = length(varargin);
for n = 1:2:nargs
    switch args{n}
        %case 'maxEpoch',            maxIterations             = args{n+1};
        case 'Ndata4miniBatch',     Ndata4miniBatch     = args{n+1};
        case 'validationSet',       alpha_split         = args{n+1};
        %case 'optim_mode',          optim_mode          = args{n+1};
        case 'optimizer',           optimizer           = args{n+1};
        %case 'metric_mode',         metric_mode         = args{n+1};
        case 'learningRate_mode',   learningRate_mode   = args{n+1};
        case 'learningRate',        learningRateDefaut  = args{n+1};
        case 'beta_1',              beta_1              = args{n+1};
        case 'beta_2',              beta_2              = args{n+1};
        case 'epsilon',             epsilon             = args{n+1};
        case 'termination_tolerance',termination_tolerance = args{n+1};
        otherwise, error(['unrecognized argument' args{n}])
    end
end

disp(['     Learning model parameters ', ...
    '(Stochastic gradient descent) ...'])

if ~isMute
    %% Diaplay analysis parameters
    fprintf(fileID, '\n');
    fprintf(fileID, '    \\Start SGD algorithm (finite difference method)\n');
    fprintf(fileID, '\n');
    fprintf(fileID, '      Optimization mode                                       %s\n', optim_mode);
    fprintf(fileID, '      Optimizer                                               %s\n', optimizer);
    fprintf(fileID, '      Metric                                                  %s\n', metric_mode);
    fprintf(fileID, '      Learning Rate mode                                      %s\n', learningRate_mode);
    fprintf(fileID, '      Training period:                                        %s - %s [days]\n', num2str(trainingPeriod(1)), num2str(trainingPeriod(2)) );
    fprintf(fileID, '      Validation set portion:                                 %s [%%]\n', num2str(alpha_split) );
    fprintf(fileID, '      Training set:                                           %s [data points]\n', num2str(size(data_train.values,1)));
    fprintf(fileID, '      Validation set:                                         %s [data points]\n', num2str(size(data_valid.values,1)-size(data_train.values,1)));
    fprintf(fileID, '      Mini batch:                                             %s [data points]\n', num2str(Ndata4miniBatch));
    fprintf(fileID, '      Number of max epoch:                                    %s [epochs]\n', num2str(maxIterations));
    fprintf(fileID, '      Total time limit for calibration:                       %s [min]\n', num2str(maxTime));
    fprintf(fileID, '\n');
%     fprintf(fileID, '    ...in progress\n');
%     fprintf(fileID, '\n');
end
%% Initialize transformed model parameters
%Identify parameters to be optimized
parameter_search_idx    = find(~all(isnan(reshape([model.param_properties{:,5}],2,size(model.param_properties,1))'),2));
nb_param                = length(parameter_search_idx);
delta_grad              = 1E-4*ones(length(model.parameter),1);
parameterRef            = model.parameter;
parameterRefTR          = zeros(length(parameterRef), 1);
transfFunc.TR           = cell(1,nb_param);
transfFunc.InvTR        = cell(1,nb_param);
transfFunc.gradTR2OR    = cell(1,nb_param);
for i = 1 : nb_param
    idx                 = parameter_search_idx(i);
    [transfFunc.TR{i},transfFunc.InvTR{i},transfFunc.gradTR2OR{i},~] = parameter_transformation_fct(model,idx);
    parameterRefTR(idx) = transfFunc.TR{i}(parameterRef(idx));
end
parameterSearchInit   = parameterRef(parameter_search_idx);
parameterSearchInitTR = parameterRefTR(parameter_search_idx);
parameter             = parameterRef;
parameterTR           = parameterRefTR;
model.parameterTR     = parameterTR;
%% Parameter name
name_idx_1='';
name_idx_2='';
for i=parameter_search_idx'
    name_p1{i}=[model.param_properties{i,1}];
    if ~isempty(model.param_properties{i,4})
        temp=model.param_properties{i,4}(1);
    else
        temp='';
    end
    name_p2{i}=[model.param_properties{i,2}, '|M', model.param_properties{i,3},'|',temp];
    name_idx_1=[name_idx_1  name_p1{i} repmat(' ',[1,15-length(name_p1{i})]) ' '];
    name_idx_2=[name_idx_2  name_p2{i} repmat(' ',[1,15-length(name_p2{i})]) ' '];
end

%% Optimization process
logpdf              = zeros(1, maxIterations);
logpdfHist          = zeros(nb_param+1, maxIterations * NminiBatch);
idxMax_loop         = zeros(1, maxIterations * NminiBatch);
parameterSearch     = zeros(nb_param, maxIterations);
parameterSearchTR   = zeros(nb_param, maxIterations);
momentumTR          = zeros(nb_param, maxIterations);
RMSpropTR           = zeros(nb_param, maxIterations);
momentumTRhist      = zeros(nb_param, maxIterations * NminiBatch);
RMSpropTRhist       = zeros(nb_param, maxIterations * NminiBatch);
learningRate        = learningRateDefaut * ones(nb_param, maxIterations * NminiBatch);
gradientTR          = zeros(nb_param, maxIterations * NminiBatch);
hessianTR           = zeros(nb_param, maxIterations * NminiBatch);
zeroGradCount       = zeros(nb_param,1);
paramMoveCount      = ones(nb_param,1);
paramReset          = zeros(nb_param,1);
metricVL            = zeros(1, maxIterations);
metricVLhist        = zeros(nb_param+1, maxIterations * NminiBatch);
mmtHessianTR        = zeros(nb_param, maxIterations);
mmtHessianTRhist    = zeros(nb_param, maxIterations * NminiBatch);
paramChange         = zeros(nb_param, maxIterations);

[metricVL(1),~, ~, logpdf(1)] = metricFct(data_train, data_valid, model, misc, parameter(parameter_search_idx), parameterTR(parameter_search_idx));
parameterSearch(:,1)    = parameterSearchInit;
parameterSearchTR(:,1)  = parameterSearchInitTR;
gradientTR(:,1)         = NaN(nb_param, 1);
hessianTR(:,1)          = NaN(nb_param, 1);

tic; % time counter initialization
Nepoch      = 1;
Nloop       = 0;
time_loop   = 0;
stop_loop = 0;
if ~isMute
    fprintf(fileID, '\n');
    fprintf(fileID, '               Nepoch # %s\n', num2str(Nepoch));
    fprintf(fileID, '               Metric: %s\n', num2str(metricVL(1)));
    fprintf(fileID, '                       %s\n', name_idx_2);
    fprintf(fileID, '      parameter names: %s\n', name_idx_1);
    fprintf(fileID, ['       initial values: ' repmat(['%#-+15.2e' ' '],[1,length(parameterRef)]) '%#-+15.2e\n'],parameterRef(parameter_search_idx));
    fprintf(fileID, '\n');
end
while Nepoch <= maxIterations && time_loop < maxTime*60
    Nepoch                  = Nepoch + 1;
    parameterSearch_loop    = parameter(parameter_search_idx);
    parameterSearchTR_loop  = parameterTR(parameter_search_idx);
    momentumTR_loop         = momentumTR(:,Nepoch - 1);
    RMSpropTR_loop          = RMSpropTR(:, Nepoch - 1);
    loopCounter1epoch       = 0;
    mmtHessianTR_loop       = mmtHessianTR(:, Nepoch-1);
    while loopCounter1epoch < NminiBatch
        Nloop       = Nloop + 1;
        loopCounter1epoch       = loopCounter1epoch + 1;
        % Ramdomly chose the start point for mini batch
        datapointbound          = length(data_train.values) - Ndata4miniBatch;
        rng('shuffle')
        idxDStart               = randi([1, datapointbound], 1);
        idxData4miniBatch       = idxDStart:idxDStart+Ndata4miniBatch;
        [data_miniBatch, data_miniBatchTest]    = dataSplit(data_train, idxData4miniBatch , alpha_split,'getTimeStepRef',0);
        % Parameter setup
        model.parameter(parameter_search_idx)   = parameterSearch_loop;
        model.parameterTR(parameter_search_idx) = parameterSearchTR_loop;
        delta_grad_loop                         = delta_grad(parameter_search_idx);
        param_idx_loop                          = parameter_search_idx;
        parfor p = 1:nb_param
            % First and second derivatives computations
            [~, GlogpdfTR_loop, HlogpdfTR_loop, ~] = logPosteriorPE(data_miniBatch, model, misc,...
                'paramTR_index',param_idx_loop(p),...
                'stepSize4grad',delta_grad_loop(p));
            % Store the 1st and 2nd derivatives
            if isnan(GlogpdfTR_loop)
                gradientTR(p, Nloop) = 0;
            else
                gradientTR(p, Nloop)  = GlogpdfTR_loop;
            end
            hessianTR(p, Nloop)     = HlogpdfTR_loop;
            % Learning rate
            if strcmp(learningRate_mode,'hessian')
                if HlogpdfTR_loop < 0
                    learningRate(p, Nloop)  = -1/HlogpdfTR_loop;
                elseif HlogpdfTR_loop > 0
                    learningRate(p, Nloop)  = 1/HlogpdfTR_loop;
                elseif isnan(HlogpdfTR_loop)
                    learningRate(p, Nloop)=learningRateDefaut/(sqrt(paramMoveCount(p)));
                end
            elseif strcmp(learningRate_mode,'decay')
                learningRate(p, Nloop)=learningRateDefaut/(sqrt(paramMoveCount(p)));
            elseif strcmp(learningRate_mode,'defaut')
                learningRate(p, Nloop) = learningRateDefaut;
            end
        end
        % Learning rate constrains to avoid the exploding gradient problem.
        % See Recurent Neural Network (RNN) for futher details.
        if any(any(isnan(hessianTR(:,Nloop))))
            hessianTR(:,Nloop)=hessianDefaut;
        end
        idx_lr = abs(hessianTR(:,Nloop))<0.001;
        if any(any(idx_lr))
            if Nloop==1
                hessianTR(idx_lr,Nloop)= hessianDefaut ;
            else
                hessianTR(idx_lr,Nloop)= hessianDefaut.*(sqrt(paramMoveCount(idx_lr)));
            end
        end
        idx_lr = abs(learningRate(:,Nloop))>1000;
        if any(any(idx_lr))
            if Nloop==1
                learningRate(idx_lr,Nloop)= learningRateDefaut;
            else
                learningRate(idx_lr,Nloop)= learningRate(idx_lr,Nloop)./sqrt(paramMoveCount(idx_lr));
            end
        end
        
        % Parameter initialization in order to avoid the vanishing gradient
        % problem. See Recurent Neural Network (RNN) for further details.
        if any(abs(gradientTR(:, Nloop))<1E-2)
            idxZeroGrad                     = abs(gradientTR(:, Nloop))<1E-2;
            zeroGradCount(idxZeroGrad)      = zeroGradCount(idxZeroGrad)+1;
            zeroGradCount(~idxZeroGrad)     = 0;
            idxG                            = zeroGradCount>0;
            momentumTR_loop(idxG)           = 0;
            RMSpropTR_loop(idxG)            = 0;
            gradientTR(idxG, Nloop)         = 0;
            paramMoveCount(idxG)            = 1;
            paramReset(idxG)                = paramReset(idxG) + 1;
            parameterRandom                 = mvnrnd(parameterSearchTR(idxG,1),stdInit*diag(ones(size(parameterSearchTR(idxG,1),1),1)));
            parameterSearchTR_loop(idxG)    = parameterRandom';
            for p = 1:nb_param
                parameterSearch_loop(p) = transfFunc.InvTR{p}(parameterSearchTR_loop(p));
            end
            mmtHessianTR_loop(idxG) = 0;
        end
        % Grid search setup
        [parameterSearchTRold_loop,...
            momentumTRold_loop,...
            RMSpropTRold_loop,...
            gradientTRold_loop,...
            learningRateTRold_loop,...
            mmtHessianTRold_loop,...
            hessianTRold_loop]         = paramGrid(parameterSearchTR_loop, momentumTR_loop, RMSpropTR_loop, gradientTR(:, Nloop), learningRate(:, Nloop), mmtHessianTR_loop, hessianTR(:, Nloop));
        parameterSearchNew_loop     = zeros(nb_param, nb_param+1);
        parameterSearchTRNew_loop   = zeros(nb_param, nb_param+1);
        momentumTRNew_loop          = zeros(nb_param, nb_param+1);
        RMSpropTRNew_loop           = zeros(nb_param, nb_param+1);
        funcInvTR                   = transfFunc.InvTR;
        mmtHessianTRNew_loop        = zeros(nb_param, nb_param+1);
        
        % New parameter values computed using ADAM or MMT
        if strcmp(optimizer,'ADAM')
            parfor p =1:nb_param+1
                [parameterSearchNew_loop(:,p),...
                    parameterSearchTRNew_loop(:,p),...
                    momentumTRNew_loop(:,p),...
                    RMSpropTRNew_loop(:,p)] = ADAM(parameterSearchTRold_loop(:,p), momentumTRold_loop(:,p), RMSpropTRold_loop(:,p), gradientTRold_loop(:,p), learningRateTRold_loop(:, p), beta_1, beta_2, epsilon, paramMoveCount, funcInvTR);
            end
        elseif strcmp(optimizer,'MMT')
            parfor p = 1:nb_param+1
                [parameterSearchNew_loop(:,p),...
                    parameterSearchTRNew_loop(:,p),...
                    momentumTRNew_loop(:,p)] = MMT(parameterSearchTRold_loop(:,p), momentumTRold_loop(:,p), gradientTRold_loop(:,p), learningRateTRold_loop(:, p), beta_1, funcInvTR );
            end
        elseif strcmp(optimizer,'ADAMbeta')
            parfor p = 1:nb_param+1
                [parameterSearchNew_loop(:,p),...
                    parameterSearchTRNew_loop(:,p),...
                    momentumTRNew_loop(:,p),...
                    RMSpropTRNew_loop(:,p),...
                    mmtHessianTRNew_loop(:,p)] = ADAMbeta(parameterSearchTRold_loop(:,p), momentumTRold_loop(:,p), mmtHessianTRold_loop(:,p), RMSpropTRold_loop(:,p), gradientTRold_loop(:,p), hessianTRold_loop(:,p), beta_1, beta_2, epsilon, paramMoveCount, funcInvTR);
            end
        elseif strcmp(optimizer,'MMTbeta')
            parfor p = 1:nb_param+1
                [parameterSearchNew_loop(:,p),...
                    parameterSearchTRNew_loop(:,p),...
                    momentumTRNew_loop(:,p),...
                    mmtHessianTRNew_loop(:,p)] = MMTbeta(parameterSearchTRold_loop(:,p), momentumTRold_loop(:,p), mmtHessianTRold_loop(:,p), gradientTRold_loop(:,p), hessianTRold_loop(:,p), beta_1, funcInvTR );
            end
        end
        % Parameter selection for the mini batch
        [metricVLhist(:,Nloop),idxMaxPC, ~, logpdfHist(:,Nloop)] = metricFct(data_miniBatch, data_miniBatchTest, model, misc, parameterSearchNew_loop, parameterSearchTRNew_loop);
        %if strcmp(misc.metric_mode,'predCap')
        if isPredCap
            [idxMaxlogpdf,~]=nanmax(logpdfHist(:,Nloop));
            if idxMaxlogpdf==idxMaxPC
                idxMax_loop(Nloop)=1;
            else
                idxMax_loop(Nloop) = 0;
            end
        else
            idxMax_loop(Nloop) = NaN;
        end
        % Parameter update for the mini batch
        momentumTR_loop  = momentumTRNew_loop(:,end);
        RMSpropTR_loop   = RMSpropTRNew_loop(:,end);
        mmtHessianTR_loop = mmtHessianTRNew_loop(:,end);
        if idxMaxPC ~= nb_param+1
            idxMomentum                  = momentumTRNew_loop(:,idxMaxPC)~=0;
            momentumTR_loop(:)           = 0;
            RMSpropTR_loop(:)            = 0;
            momentumTR_loop(idxMomentum) = momentumTRNew_loop(idxMomentum,idxMaxPC);
            RMSpropTR_loop(idxMomentum)  = RMSpropTRNew_loop(idxMomentum,idxMaxPC);
            paramMoveCount(idxMomentum)  = paramMoveCount(idxMomentum)+1;
            mmtHessianTR_loop(idxMomentum)= mmtHessianTRNew_loop(idxMomentum,idxMaxPC);
        else
            paramMoveCount = paramMoveCount+1;
        end
        parameterSearchTR_loop  = parameterSearchTRNew_loop(:,idxMaxPC);
        parameterSearch_loop    = parameterSearchNew_loop(:,idxMaxPC);
        momentumTRhist(:,Nloop) = momentumTR_loop;
        RMSpropTRhist(:,Nloop)  = RMSpropTR_loop;
        mmtHessianTRhist(:,Nloop)= mmtHessianTR_loop;
    end
    % Metric calculation for each epoch
    [metricVL(Nepoch),~, ~, logpdf(Nepoch)] = metricFct(data_train, data_valid, model, misc, parameterSearch_loop, parameterSearchTR_loop);
    
    if sign(metricVL(Nepoch-1))==-1
        TL_loop = termination_tolerance+1;
    else
        TL_loop = termination_tolerance;
    end
    
    % Parameter update for the training set
    if or(metricVL(Nepoch) > metricVL(Nepoch-1)*TL_loop,logpdf(Nepoch) > logpdf(Nepoch-1)*TL_loop)
        parameterSearch(:,Nepoch)           = parameterSearch_loop;
        parameterSearchTR(:,Nepoch)         = parameterSearchTR_loop;
        parameter(parameter_search_idx)     = parameterSearch(:,Nepoch);
        parameterTR(parameter_search_idx)   = parameterSearchTR(:,Nepoch);
        momentumTR(:,Nepoch)                = momentumTR_loop;
        RMSpropTR(:,Nepoch)                 = RMSpropTR_loop;
        stop_loop = 0;
        mmtHessianTR(:,Nepoch)              = mmtHessianTR_loop;
    else
        stop_loop = stop_loop + 1;
        if stop_loop > 3
            stop_loop=0;
            [metricVL(Nepoch),idxMaxEpochs]   = nanmax(metricVL);
            parameterSearch(:,Nepoch)         = parameterSearch(:,idxMaxEpochs);
            parameterSearchTR(:,Nepoch)       = parameterSearchTR(:,idxMaxEpochs);
            parameter(parameter_search_idx)   = parameterSearch(:,idxMaxEpochs);
            parameterTR(parameter_search_idx) = parameterSearchTR(:,idxMaxEpochs);
            momentumTR(:,Nepoch)              = momentumTR(:,idxMaxEpochs);
            RMSpropTR(:,Nepoch)               = RMSpropTR(:,idxMaxEpochs);
            logpdf(Nepoch)                    = logpdf(idxMaxEpochs);
            metricVL(Nepoch)                  = metricVL(idxMaxEpochs);
            momentumTRhist(:,Nloop)           = momentumTR(:,Nepoch);
            RMSpropTRhist(:,Nloop)            = RMSpropTR(:,Nepoch);
            mmtHessianTR(:, Nepoch)           = mmtHessianTR(:,idxMaxEpochs);
        else
            parameterSearch(:,Nepoch)           = parameterSearch(:,Nepoch-1);
            parameterSearchTR(:,Nepoch)         = parameterSearchTR(:,Nepoch-1);
            parameter(parameter_search_idx)     = parameterSearch(:,Nepoch-1);
            parameterTR(parameter_search_idx)   = parameterSearchTR(:,Nepoch-1);
            momentumTR(:,Nepoch)                = momentumTR(:,1);
            RMSpropTR(:,Nepoch)                 = RMSpropTR(:,1);
            logpdf(Nepoch)                      = logpdf(Nepoch-1);
            metricVL(Nepoch)                    = metricVL(Nepoch-1);
            momentumTRhist(:,Nloop)             = momentumTR(:,Nepoch);
            RMSpropTRhist(:,Nloop)              = RMSpropTR(:,Nepoch);
            mmtHessianTR(:, Nepoch)             = mmtHessianTR(:,1);
        end
    end
    paramChange(:,Nepoch)  = (parameterSearch(:,Nepoch)-parameterSearch(:,Nepoch-1));
    
    if ~isMute
        fprintf(fileID, '\n');
        fprintf(fileID, '--------------------------\n');
        fprintf(fileID, '    Epoch #%s\n', num2str(Nepoch));
        fprintf(fileID, '            Metric: %s\n', num2str(metricVL(Nepoch)));
        fprintf(fileID, '   parameter names: %s\n', name_idx_2);
        fprintf(fileID, ['    current values: ' repmat(['%#-+15.2e' ' '],[1,length(parameter(parameter_search_idx))-1]) '%#-+15.2e\n',...
            '      param change: ' repmat(['%#-+15.2e' ' '],[1,length(parameter(parameter_search_idx))-1]) '%#-+15.2e\n',...
            '  initialize param: ' repmat(['%#-+15.2e' ' '],[1,length(parameter(parameter_search_idx))-1]) '%#-+15.2e\n'],...
            parameter(parameter_search_idx),...
            paramChange(:,Nepoch),...
            paramReset);
        fprintf(fileID, '\n');
    end
    time_loop=toc;
end

%% Selection of the optimal parameters corresponding to the best log-post
[metricVLmax,idxmax]                    = nanmax(metricVL(1:Nepoch));
parameterSearch_opt                     = parameterSearch(:,idxmax);
parameterSearchTR_opt                   = parameterSearchTR(:,idxmax);
parameter_opt                           = parameter;
parameter_opt(parameter_search_idx)     = parameterSearch_opt;
parameterTR_opt                         = parameterTR;
parameterTR_opt(parameter_search_idx)   = parameterSearchTR_opt;

%% Output
optim.parameter_opt         = parameter_opt;
optim.parameterTR_opt       = parameterTR_opt;
optim.metricVLmax           = metricVLmax;
optim.metricVL              = metricVL;
optim.logpdf                = logpdf;
optim.log_lik               = nanmax(logpdf);
optim.Nepoch                = Nepoch;
optim.converged             = 0;
optim.gradientTR            = gradientTR;
optim.learningRate          = learningRate;
optim.hessianTR             = hessianTR;
optim.parameterSearch       = parameterSearch;
optim.parameterSearchTR     = parameterSearchTR;
optim.momentumTR            = momentumTR;
optim.RMSpropTR             = RMSpropTR;
optim.Ndata4miniBatch       = Ndata4miniBatch;
optim.idxMax_loop           = idxMax_loop;
optim.optim_mode            = optim_mode;
optim.beta_1                = beta_1;
optim.beta_2                = beta_2;
optim.epsilon               = epsilon;
optim.learningRateDefaut    = learningRateDefaut;
optim.data_train            = data_train;
optim.data_valid            = data_valid;
optim.data                  = data;
optim.data_train            = data_valid;
optim.misc                  = misc;

%% Write model.parameters in model.param_properties

% Add parameter and p_ref to param_properties
parameter=optim.parameter_opt;

[model.param_properties]=writeParameterProperties(model.param_properties, ...
    [parameter, p_ref], 9);

end

function [data_train, data_valid] = dataSplit(data, idxTrain, alpha_split, varargin)
getTimeStepRef = 1;
timeStepMean   = 0;
args    = varargin;
nargs   = length(varargin);
tol     = 1e-4;
for n = 1:2:nargs
    switch args{n}
        case 'getTimeStepRef',   getTimeStepRef = args{n+1};
        case 'timeStepMean',     timeStepMean   = args{n+1};
        otherwise, error(['Unrecognized argument' args{n}])
    end
end
dataTrainingProcess.values      = data.values(idxTrain,:);
dataTrainingProcess.timestamps  = data.timestamps(idxTrain,:);
NdataTrainingProcess            = size(dataTrainingProcess.values ,1);
NdataValid                      = round(alpha_split*NdataTrainingProcess);

data_train.values       = dataTrainingProcess.values(1:NdataTrainingProcess-NdataValid,:);
data_train.timestamps   = dataTrainingProcess.timestamps(1:NdataTrainingProcess-NdataValid,:);
data_train.nb_steps     = size(data_train.values,1);

data_valid              = dataTrainingProcess;
data_valid.nb_steps     = size(data_valid.values,1);
if getTimeStepRef==1
    data_train.dt_steps         = diff(data_train.timestamps);
    if timeStepMean==1
        data_train.dt_ref = mean(data_train.dt_steps);
    else
        unique_dt_steps             = uniquetol(data_train.dt_steps,tol);
        counts_dt_steps             = [unique_dt_steps,histc(data_train.dt_steps(:),unique_dt_steps)];
        data_train.dt_ref           = counts_dt_steps(find(counts_dt_steps(:,2)==max(counts_dt_steps(:,2)),1,'first'),1);
    end
    data_train.dt_steps = [data_train.dt_ref;data_train.dt_steps];
    data_valid.dt_steps = diff(data_valid.timestamps);
    data_valid.dt_ref   = data_train.dt_ref;
    data_valid.dt_steps = [data_valid.dt_ref; data_valid.dt_steps];
else
    data_train.dt_ref   = data.dt_ref;
    data_train.dt_steps = data.dt_steps(1:NdataTrainingProcess-NdataValid,:);
    data_valid.dt_ref   = data.dt_ref;
    data_valid.dt_steps = data.dt_steps(1:NdataTrainingProcess,:);
end
end

function [xsearch, xsearchTR, momentumTR] = MMT(xsearchTRprev, momentumTRprev, grad, step, beta, fctInvTR)
xsearch     = zeros(length(xsearchTRprev), 1);
momentumTR   = beta*momentumTRprev + (1-beta)*grad;
xsearchTR   = xsearchTRprev + step.*momentumTR;
for p = 1:length(xsearchTRprev)
    xsearch(p) =  fctInvTR{p}(xsearchTR(p));
end
end

function [xsearch, xsearchTR, momentumTR, mmtHessianTR] = MMTbeta(xsearchTRprev, momentumTRprev, mmtHessianTRprev, grad, hess, beta, fctInvTR)
xsearch      = zeros(length(xsearchTRprev), 1);
momentumTR   = beta*momentumTRprev + (1-beta)*grad;
mmtHessianTR = beta*mmtHessianTRprev + (1-beta)*abs(hess);
step         = 1./mmtHessianTR;
step(step==Inf)= 0;
xsearchTR    = xsearchTRprev + step.*momentumTR;
for p = 1:length(xsearchTRprev)
    xsearch(p) =  fctInvTR{p}(xsearchTR(p));
end
end

function [xsearch, xsearchTR, momentumTR, RMSpropTR] = ADAM(xsearchTRprev, momentumTRprev, RMSpropTRprev, grad, step, beta_1, beta_2, epsilon, Niter, fctInvTR)
xsearch         = zeros(length(xsearchTRprev), 1);
momentumTR      = beta_1*momentumTRprev + (1-beta_1)*grad;
RMSpropTR       = beta_2*RMSpropTRprev + (1-beta_2)*grad.^2;
momentumTRcorr  = momentumTR./(1-beta_1.^Niter);
RMSpropTRcorr   = RMSpropTR./(1-beta_2.^Niter);
xsearchTR       = xsearchTRprev + step.*momentumTRcorr./(sqrt(RMSpropTRcorr)+epsilon);
for p = 1:length(xsearchTRprev)
    xsearch(p) =  fctInvTR{p}(xsearchTR(p));
end
end

function [xsearch, xsearchTR, momentumTR, RMSpropTR, mmtHessianTR] = ADAMbeta(xsearchTRprev, momentumTRprev, mmtHessianTRprev, RMSpropTRprev, grad, hess, beta_1, beta_2, epsilon, Niter, fctInvTR)
xsearch         = zeros(length(xsearchTRprev), 1);
momentumTR      = beta_1*momentumTRprev + (1-beta_1)*grad;
mmtHessianTR    = beta_1*mmtHessianTRprev + (1-beta_1)*abs(hess);
RMSpropTR       = beta_2*RMSpropTRprev + (1-beta_2)*grad.^2;
momentumTRcorr  = momentumTR./(1-beta_1.^Niter);
mmtHessTRcorr   = mmtHessianTR./(1-beta_1.^Niter);
RMSpropTRcorr   = RMSpropTR./(1-beta_2.^Niter);
step            = 1./mmtHessTRcorr;
step(step==Inf) = 0;
xsearchTR       = xsearchTRprev + step.*momentumTRcorr./(sqrt(RMSpropTRcorr)+epsilon);
for p = 1:length(xsearchTRprev)
    xsearch(p) =  fctInvTR{p}(xsearchTR(p));
end
end

function [xM, momentumM, RMSpropM, gradM, learningRateM, mmtHessM, hessM]= paramGrid(x, momentum, RMSprop, grad, learningRate, mmtHess, hess)
d             = length(x);
xM            = repmat(x,1,d+1);
momentumM     = [diag(momentum) momentum];
mmtHessM      = [diag(mmtHess) mmtHess];
RMSpropM      = [diag(RMSprop) RMSprop];
gradM         = [diag(grad) grad];
hessM         = [diag(hess) hess];
learningRateM = [diag(learningRate) learningRate];
end
