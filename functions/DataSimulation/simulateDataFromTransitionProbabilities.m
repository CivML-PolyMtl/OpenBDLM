function [data, model, estimation, misc]=simulateDataFromTransitionProbabilities(data, model, misc)
%SIMULATEDATAFROMTRANSITIONPROBABILITIES Perform stochastic data simulation
%
%   SYNOPSIS:
%     [data, model, estimation, misc]=SIMULATEDATAFROMTRANSITIONPROBABILITIES(data, model, misc)
%
%   INPUT:
%      data         - structure (required)
%                     see documentation for details about the fields of data
%
%      model        - structure (required)
%                     see documentation for details about the fields of
%                     model
%
%      misc         - structure (required)
%                     see documentation for details about the fields of misc
%
%   OUTPUT:
%      data         - structure (required)
%                     see documentation for details about the fields of data
%
%      model        - structure (required)
%                     see documentation for details about the fields of
%                     model
%
%      estimation   - structure (required)
%                     see documentation for details about the fields of
%                     estimation
%
%      misc         - structure (required)
%                     see documentation for details about the fields of misc
%
%   DESCRIPTION:
%      SIMULATEDATAFROMTRANSITIONPROBABILITIES performs "stochastic" data
%      simulation. Here, "stochastic" data simulation means that, in case of 
%      switching regime model, SIMULATEDATAFROMTRANSITIONPROBABILITIES uses 
%      the values in the transition probabilities matrix Z and in the switching 
%      process noise covariance matrices Q12, Q21  to simulate the data.
%      In other words, SIMULATEDATAFROMTRANSITIONPROBABILITIES performs the
%      prediction step of the (switching) Kalman filter at each time step
%      to simulate the data.
%
%   EXAMPLES:
%      [data, model, estimation, misc]=SIMULATEDATAFROMTRANSITIONPROBABILITIES(data, model, misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%      computeTimeSteps
%
%   See also SIMULATEDATA, SIMULATEDATAFROMCUSTOMANOMALIES

%   AUTHORS:
%      Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       April 25, 2018
%
%   DATE LAST UPDATE:
%       April 25, 2018

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

%% Get timestamps
timestamps = data.timestamps;

%% Compute timestep vector
[timesteps]=computeTimeSteps(timestamps);

T = length(timestamps);            %Nuuber of timestamps
M = model.nb_class;           %Number of model classes or regime
numberOfTimeSeries=length(data.labels);            %Number of observations


%% Read model parameter properties
idx_pvalues=size(model.param_properties,2)-1;
idx_pref= size(model.param_properties,2);

[arrayOut]=...
    readParameterProperties(model.param_properties, [idx_pvalues, idx_pref]);

parameter= arrayOut(:,1);
p_ref = arrayOut(:,2);

%% Initialization
rng(12345)

y_obs= zeros(numberOfTimeSeries,T);
y_pred= zeros(numberOfTimeSeries,T);

SS=zeros(1,T);

for j=1:M
    ss=size(model.hidden_states_names{1},1);
    x = zeros(ss,T);
end

%% Simulate data
for t=1:T
    
    if t == 1
        i=1 ; % we assume that starting regime (i) is the first regime
    end
    
    % Store regime index
    if i == 1
        SS(t)= 1;
    else
        SS(t)=0;
    end
    
    % Get transition probabilities matrix for this time step
    Z = model.Z(parameter(p_ref),timestamps(t),timesteps(t));
    
    % Get transition regime (j) from Z
    
    % Add original regime index for clarity
    mat = [ Z(i,:) ; 1:M ];
    
    % Sort transition probabiltiies
    [~,I]=sort(mat(1,:) , 'descend');   % sort
    mat_sort = mat(:,I);
    
    while 1
        if size(mat_sort,2) == 1
            % there is only one regime possible
            j = mat_sort(2,1);
            break
        end
        
        % Normalize transition probabilities
        mat_sort = [ mat_sort(1,:)./(sum(mat_sort(1,:))) ; mat_sort(2,:)];
        
        % Generate random number in uniform distribution (0,1)
        ru=rand;
        
        if ru < mat_sort(1,1)
            j = mat_sort(2,1);
            break
        else
            mat_sort(:,1)= []; % reject regime
        end
        
    end
    
    A_j = model.A{j}(parameter(p_ref), timestamps(t),timesteps(t));
    C_j = model.C{j}(parameter(p_ref), timestamps(t),timesteps(t));
    R_j = model.R{j}(parameter(p_ref), timestamps(t),timesteps(t));
    Q_j = model.Q{i}{j}(parameter(p_ref), timestamps(t),timesteps(t));
    
    if t==1
        prevX = model.initX{i};
    else
        prevX = x(:,t-1);
    end
    
    % Prediction step  x_t+1=A.x_t + Q
    w=mvnrnd(zeros(length(Q_j),1),Q_j); % process noise
    x(:,t) = A_j*prevX + w'; % prediction
    
    % Compute y_pred=C.x
    y_pred(:,t) = C_j*x(:,t);
    
    % Observation y_obs=C.x + R
    v = mvnrnd(zeros(numberOfTimeSeries,1),R_j); % observation noise
    
    y_obs(:,t) = C_j*x(:,t) + v' ;
    
    i=j;
end

% Save hidden states for plot_estimate
estimation.ref = [x' SS'];

% Add NaN if applicable
y_obs=y_obs';

if isfield(data, 'values')
    for i=1:numberOfTimeSeries
        y_obs(isnan(data.values(:,i)),i)=NaN; % add NaN
    end
end

% Fill data with y_obs (simulated data)
data.values = [];
for i=1:numberOfTimeSeries
    data.values = [data.values y_obs(:,i)];
end

% Store model which has been used to simulate the data
if isfield(model, 'ref')
    model = rmfield(model,'ref');
end

model.ref = model;

%--------------------END CODE ------------------------
end
