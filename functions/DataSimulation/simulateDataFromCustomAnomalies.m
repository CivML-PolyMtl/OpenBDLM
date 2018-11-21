function [data, model, estimation, misc]=simulateDataFromCustomAnomalies(data, model, misc)
%SIMULATEDATAFROMCUSTOMANOMALIES Perform deterministic data simulation
%
%   SYNOPSIS:
%     [data, model, estimation, misc]=SIMULATEDATAFROMCUSTOMANOMALIES(data, model, estimation, misc)
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
%      SIMULATEDATAFROMCUSTOMANOMALIES performs "deterministic" data
%      simulation. Here, "deterministic" data simulation means that, in case of 
%      switching regime model, SIMULATEDATAFROMCUSTOMANOMALIES uses the 
%      user's defined [timing, duration, amplitude] of anomalies to 
%      control the occurrence of the anomalies.
%      Note however that the rest of the simulation follows a stochastic 
%      process.
%      An anomaly occurs when the probability of being in model
%      two (Pr = M2) equals one.
%
%   EXAMPLES:
%      [data, model, estimation, misc]=SIMULATEDATAFROMCUSTOMANOMALIES(data, model, estimation, misc)
%
%
%   See also SIMULATEDATAFROMTRANSITIONPROBABILITIES, SIMULATEDATA

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
%       May 28, 2018

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

T = length(timestamps);            %Number of timestamps
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

y_obs= zeros(numberOfTimeSeries,T);
y_pred= zeros(numberOfTimeSeries,T);

SS=zeros(1,T);

for j=1:M
    ss=size(model.hidden_states_names{1},1);
    x = zeros(ss,T);
end

elapsed_points=0;
anomaly_counter=0;
ongoing_anomaly=false;

%% Initialize the seed
%rng(12345)

%% Simulate data

% Get index for LTc and/or LAc

Index = strfind(model.hidden_states_names{1}, 'x^{LTc}');
Index_LTc=find(not(cellfun('isempty', Index)));

Index = strfind(model.hidden_states_names{1}, 'x^{LAc}');
Index_LAc=find(not(cellfun('isempty', Index)));


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
    
    % Anomaly start ?
    
    if any(misc.custom_anomalies.start_custom_anomalies==t)
        j=2;
        elapsed_points=0;
        ongoing_anomaly=true;
        anomaly_counter = anomaly_counter+1;
    end
    
    if ongoing_anomaly && elapsed_points < ...
            misc.custom_anomalies.duration_custom_anomalies(anomaly_counter)
        elapsed_points=elapsed_points+1;
    else
        j=1;
    end
    
    % Define matrices
    A_j = model.A{j}(parameter(p_ref),timestamps(t),timesteps(t));
    C_j = model.C{j}(parameter(p_ref),timestamps(t),timesteps(t));
    R_j = model.R{j}(parameter(p_ref),timestamps(t),timesteps(t));
    if i == j
        Q_j = model.Q{i}{j}(parameter(p_ref),timestamps(t),timesteps(t));
    else
        Q_j = zeros(size(x,1)) ;
    end
        
    if t==1
        prevX = model.initX{i};
    else
        prevX = x(:,t-1);
    end
    
    % Prediction step  x_t+1=A.x_t + Q
    
    w=mvnrnd(zeros(length(Q_j),1),Q_j); % process noise
    x(:,t) = A_j*prevX + w'; % prediction
    
    if i == 1 && j == 2
        
        pos_LTc=0;
        pos_LAc=0;
        
        for n=1:numberOfTimeSeries
            
            if any(cell2mat(model.components.block{1,1}(n)) == 21)
                
                pos_LTc=pos_LTc+1;
                
                x(Index_LTc(pos_LTc),t) = ...
                    misc.custom_anomalies.amplitude_custom_anomalies(anomaly_counter);
                
            elseif  any(cell2mat(model.components.block{1,1}(n)) == 22)
                
                pos_LAc=pos_LAc+1;
                
                x(Index_LAc(pos_LAc)-1,t) = ...
                    misc.custom_anomalies.amplitude_custom_anomalies(anomaly_counter);
                x(Index_LAc(pos_LAc),t) = ...
                    misc.custom_anomalies.amplitude_custom_anomalies(anomaly_counter);
                
            elseif any(cell2mat(model.components.block{1,1}(n)) == 23)
                
                pos_LAc=pos_LAc+1;
                
                x(Index_LAc(pos_LAc)-1,t) = ...
                    prevX(Index_LAc(pos_LAc)-1)+ ...
                    misc.custom_anomalies.amplitude_custom_anomalies(anomaly_counter);
                x(Index_LAc(pos_LAc),t) = ...
                    misc.custom_anomalies.amplitude_custom_anomalies(anomaly_counter);
                
            end
            
        end
    end    
    
    % Back to initial trend
    if i == 2 && j == 1
        
        pos_LAc=0;
        
        for n=1:numberOfTimeSeries
            
            if  any(cell2mat(model.components.block{1,1}(n)) == 22) ...
                    || any(cell2mat(model.components.block{1,1}(n)) == 23)
                
                pos_LAc=pos_LAc+1;
                
                x(Index_LAc(pos_LAc)-1,t) = ...
                    model.initX{1,1}(Index_LAc(pos_LAc)-1,1) ;
                x(Index_LAc(pos_LAc),t) = 0;
            end
        end
    end  
    
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
    data.values = [ data.values y_obs(:,i)];
end

% Store model which has been used to simulate the data
if isfield(model, 'ref')
    model = rmfield(model,'ref');
end
model.ref = model;
%--------------------END CODE ------------------------
end
