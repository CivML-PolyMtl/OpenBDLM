function [data, model, estimation, misc]=learnModelParameters(data, model, estimation, misc, varargin)
%LEARNMODELPARAMETERS Learn Bayesian dynamic linear model parameters
%
%   SYNOPSIS:
%     [data, model, estimation, misc]=LEARNMODELPARAMETERS(data, model, estimation, misc, varargin)
%
%   INPUT:
%      data             - structure (required)
%                         see documentation for details about the fields of
%                         data
%
%      model            - structure (required)
%                         see documentation for details about the fields of
%                         model
%
%      estimation       - structure (required)
%                         see documentation for details about the fields of
%                         estimation
%
%      misc             - structure (required)
%                         see documentation for details about the fields of
%                         misc
%
%      Method           - character (optional)
%                         Give the name of the optimization method to use
%                         'Method' can be either 'NR' (stand for
%                         Newton-Raphson) or 'SGA' (stands for Stochastic
%                         Gradient Ascent)
%                         default is 'Method' = 'NR'
%
%      FilePath         - character (optional)
%                         directory where to save the modifications
%                         Modifications are saved directly in project file
%                         located in FilePath/PROJ_'misc.ProjectName'.mat
%                         file
%                         default: '.'  (current folder)
%
%   OUTPUT:
%      data             - structure (required)
%                         see documentation for details about the fields of
%                         data
%
%      model            - structure (required)
%                         see documentation for details about the fields of
%                         model
%
%      estimation       - structure (required)
%                         see documentation for details about the fields of
%                         estimation
%
%      misc             - structure (required)
%                         see documentation for details about the fields of
%                         misc
%
%   DESCRIPTION:
%      LEARNMODELPARAMETERS learn parameters of the Bayesian dynamic linear
%      model using gradient based optimization approaches.
%
%      LEARNMODELPARAMETERS supports two optimization methods :
%               1- Newton-Raphson (argument 'Method' sets to 'NR')
%               2- Stochastic Gradient Ascent (argument 'Method' sets to 'SGA')
%
%      LEARNMODELPARAMETERS saves the optimized parameters values in the
%      project file with name PROJ_'misc.ProjectName'.mat located in
%      location specified by the argument 'FilePath'.
%
%   EXAMPLES:
%      [data, model, estimation, misc]=LEARNMODELPARAMETERS(data, model, estimation, misc, 'FilePath', 'saved_projects', 'Method', 'SGA')
%      [data, model, estimation, misc]=LEARNMODELPARAMETERS(data, model, estimation, misc, 'Method', 'NR')
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also

%   AUTHORS:
%       Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       June 13, 2018
%
%   DATE LAST UPDATE:
%       June 13, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultMethod = 'NR';
defaultFilePath = '.';

validationFonctionMethod = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x))) && (strcmp(x,'NR') || strcmp(x,'SGA'))  ;

validationFonction = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'estimation', @isstruct );
addRequired(p,'misc', @isstruct );
addParameter(p, 'Method', defaultMethod, validationFonctionMethod)
addParameter(p, 'FilePath', defaultFilePath, validationFonction)
parse(p,data, model, estimation, misc, varargin{:});

data=p.Results.data;
model=p.Results.model;
estimation=p.Results.estimation;
misc=p.Results.misc;
Method = p.Results.Method;
FilePath=p.Results.FilePath;

%% Learn model parameters

if strcmp(Method, 'NR')
    %% Model parameters optimization using Newton-Raphson technique
   
    % Define the maximal number of iteration for learning initial hidden
    % states values (multi-pass technique)
    iteration_limit_initValues=0;
    
    % Start optimization procedure with multi-pass
    loop=0;
    while(1)
        
        loop=loop+1;
        
        % Save the previous initial hidden states values computed by default
        % or computed using smoother
        model.initX_prev=model.initX;
        model.initV_prev=model.initV;
        model.initS_prev=model.initS;
        
        [optim, model] = NewtonRaphson(data, model, misc);
        
        %model.parameter(model.p_ref)=optim.parameter_opt(model.p_ref);
        %model.parameterTR(model.p_ref)= optim.parameterTR_opt(model.p_ref);
        
        misc  = optim.misc;
        
        % Save the previous log-likelihood from Newton-Raphson
        log_lik_loop=optim.log_lik;
        
        if all(optim.converged)|| loop >= iteration_limit_initValues
            % Stop if the number of iteration_limit_initValues is reached
            break
        end
        
        % Estimate initial hidden states values using smoother on a subset
        % of the data
        [model]=computeInitialHiddenStates(data, model, estimation, misc, ...
            'FilePath', 'saved_projects', 'Percent', 25);
        
        misc.optim_mode = optim.optim_mode;
        
        % Calculate log-posterior with initial value x_t optimized using SKS
        [log_lik_testInitValues,~,~,~]=logPosteriorPE(optim.data_train, ...
            model, misc, 'getlogpdf', 1);
        
        % Make sure that we end up with the better log-likelihood using
        % these values
        % otherwise we re-use the previous initial values x_t
        if log_lik_testInitValues<log_lik_loop
            model.initX=model.initX_prev;
            model.initV=model.initV_prev;
            model.initS=model.initS_prev;
        end
        
        
    end
        
elseif strcmp(Method, 'SGA')
    %% Model parameters optimization using Stochastic Gradient Ascent approach
    
    [optim, model] = SGD(data, model, misc);
    
    %model.parameter(model.p_ref)=optim.parameter_opt(model.p_ref);
    %model.parameterTR(model.p_ref)= optim.parameterTR_opt(model.p_ref);
    
    misc  = optim.misc;
    
end

% Remove extra field from structure model
model = rmfield(model,'parameter');
model = rmfield(model,'parameterTR');
model = rmfield(model,'p_ref');

%--------------------END CODE ------------------------
end
