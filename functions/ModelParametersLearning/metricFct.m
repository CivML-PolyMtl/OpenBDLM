function [metricVL, idxMaxM, logpdf_test, logpdf_train] = metricFct(data_train, data_test, model, misc, parameterSearch, parameterSearchTR)
parameter_search_idx = ~all(isnan(reshape([model.param_properties{:,5}],2,size(model.param_properties,1))'),2);
Nsamples             = size(parameterSearch,2);
%if strcmp(option.miscmetric_mode,'predCap')
if misc.options.isPredCap
    modelStored          = cell(2*Nsamples,1);
    dataStored           = cell(2*Nsamples,1);
    model4loop           = model;
    logpdf               = zeros(1, 2*Nsamples);
    for s = 1 : Nsamples
        model4loop.parameter(parameter_search_idx)      = parameterSearch(:,s);
        model4loop.parameterTR(parameter_search_idx,s)  = parameterSearchTR(:,s);
        modelStored{s} = model4loop;
        dataStored{s}  = data_test; 
    end
    for s = 1:Nsamples
        model4loop.parameter(parameter_search_idx)      = parameterSearch(:,s);
        model4loop.parameterTR(parameter_search_idx,s)  = parameterSearchTR(:,s);
        modelStored{s+Nsamples} = model4loop;
        dataStored{s+Nsamples}  = data_train;
    end
    parfor s = 1 : 2*Nsamples
        try
            [logpdf(s), ~, ~,~]  = logPosteriorPE(dataStored{s}, modelStored{s}, misc, 'getlogpdf', 1);
        catch err
            logpdf(s) = -Inf;
       end
    end
    logpdf(~isreal(logpdf))             = -Inf;
    logpdf(~isreal(logpdf))             = -Inf;
    logpdf_test                         = logpdf(1:Nsamples);
    logpdf_train                        = logpdf(Nsamples+1:2*Nsamples);
    idxTestInf                          = find(logpdf_test==-Inf);
    idxTrainInf                         = find(logpdf_train == -Inf); 
    metricVL                            = logpdf_test - logpdf_train;
    metricVL([idxTestInf idxTrainInf])  = -Inf;
%elseif strcmp(option.metric_mode, 'logpdf')
else
    modelStored     = cell(Nsamples, 1);
    dataStored      = cell(Nsamples, 1);
    model4loop      = model;
    for s = 1: Nsamples
        model4loop.parameter(parameter_search_idx) = parameterSearch(:,s);
        model4loop.parameterTR(parameter_search_idx) = parameterSearchTR(:,s);
        modelStored{s} = model4loop;
        dataStored{s}  = data_train;
    end
    parfor s = 1 : Nsamples
        try
            [logpdf(s), ~, ~,~]  = logPosteriorPE(dataStored{s}, modelStored{s}, misc, 'getlogpdf', 1);
        catch err
            logpdf(s) =-Inf;
        end
    end
    logpdf(~isreal(logpdf)) = -Inf;
    logpdf(~isreal(logpdf)) = -Inf;
    metricVL                = logpdf;
    logpdf_train            = logpdf;
    logpdf_test             = NaN(length(logpdf),1); 
end
[~,idxMaxM] = nanmax(metricVL);
end