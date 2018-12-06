function displayModelMatrices(data, model, estimation, misc, TimestampIndex)
%DISPLAYMODELMATRICES Display A,C, Q, R matrices for a given timestamp
%
%   SYNOPSIS:
%     DISPLAYMODELMATRICES(data, model, estimation, misc, TimestampIndex)
%
%   INPUT:
%      data                  - structure (required)
%                              see documentation for details about the
%                              fields of estimation
%
%      model                 - structure (required)
%                              see documentation for details about the
%                              fields of estimation
%
%      estimation            - structure (required)
%                              see documentation for details about the
%                              fields of estimation
%
%      misc                  - structure (required)
%                              see documentation for details about the 
%                              fiels of misc
%
%      TimestampIndex        - integer (required)
%                              timestamp index 
%
%   OUTPUT:
%      N/A
%      Print messages on screen
%
%   DESCRIPTION:
%      DISPLAYMODELMATRICES displays on screen A,C, Q, R matrices at a 
%      given timestamp
%
%   EXAMPLES:
%      DISPLAYMODELMATRICES(data, model, estimation, misc, 1)
%      DISPLAYMODELMATRICES(data, model, estimation, misc, 365)
%
%   EXTERNAL FUNCTIONS CALLED:
%      computeTimeStep
%
%   See also INITIALIZEPROJECT, COMPUTETIMESTEP

%   AUTHORS:
%      James-A Goulet, Ianis Gaudot, Luong Ha Nguyen
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       April 24, 2018
%
%   DATE LAST UPDATE:
%       December 3, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

Validation_Fcn_Integer = @(x) mod(x,1) == 0;

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'estimation', @isstruct );
addRequired(p,'misc', @isstruct );
addRequired(p,'TimestampIndex', Validation_Fcn_Integer );
parse(p,data, model, estimation,  misc, TimestampIndex);

data=p.Results.data;
model=p.Results.model;
%estimation=p.Results.estimation;
%misc=p.Results.misc;
TimestampIndex = p.Results.TimestampIndex;

%% Read model parameter properties
idx_pvalues=size(model.param_properties,2)-1;
idx_pref= size(model.param_properties,2);

[arrayOut]=...
    readParameterProperties(model.param_properties, ...
    [idx_pvalues, idx_pref]);

parameter= arrayOut(:,1);
p_ref = arrayOut(:,2);

%% Verify merged dataset

% Validation of structure data
isValid = verificationDataStructure(data);
if ~isValid
    disp(' ')
    error('Unable to read the data from the structure.')
end

%% Get timestamps
timestamps = data.timestamps;

%% Compute timestep vector
[timesteps]=computeTimeSteps(timestamps);

for m=1:model.nb_class
    disp(' ')
    disp('------------------')
    disp([' Model class #' num2str(m)])
    disp('------------------')
    disp(' ')
    name1=[];
    for i=1:size(model.hidden_states_names{1},1)
        name1= ...
            [name1,{model.hidden_states_names{m}{i,2}, ...
            model.hidden_states_names{m}{i,3}(1)}];
    end
    disp(['       ' sprintf('M%s|%s      ',name1{:})])
    disp(['   ' sprintf('%10s',model.hidden_states_names{1}{:,1})])
    M=model.A{m}(parameter(p_ref), ...
        timestamps(TimestampIndex),timesteps(TimestampIndex));
    
    %% Display transition matrix A
    for i=1:size(M,1)
        if i==1
            disp(['    A=[' sprintf('%-10.3G',M(i,:))]);
        elseif i==size(M,1)
            disp(['       ' sprintf('%-10.3G',M(i,:)) '];']);
            
        else
            disp(['       ' sprintf('%-10.3G',M(i,:))]);
        end
    end
    disp(' ')
    M=model.C{m}(parameter(p_ref), ...
        timestamps(TimestampIndex),timesteps(TimestampIndex));
    %% Display observation matrix C
    for i=1:size(M,1)
        if i==1 && size(M,1) ~= 1
            disp(['    C=[' sprintf('%-10.2G',M(i,:))]);           
        elseif i==1 && size(M,1) == 1
            disp(['    C=[' sprintf('%-10.2G',M(i,:))  '];' ]);
        elseif i==size(M,1) && size(M,1) ~= 1
            disp(['       ' sprintf('%-10.2G',M(i,:)) '];']);            
        else
            disp(['       ' sprintf('%-10.2G',M(i,:))]);
        end
    end
    disp(' ')
    M=model.Q{m}{m}(parameter(p_ref), ...
        timestamps(TimestampIndex),timesteps(TimestampIndex));
     %% Display process noise covariance matrix Q
    for i=1:size(M,1)
        if i==1
            disp([' Q_' num2str(m) ...
                num2str(m) '=[' sprintf('%-10.2G',M(i,:))]);
        elseif i==size(M,1)
            disp(['       ' sprintf('%-10.2G',M(i,:)) '];']);
            
        else
            disp(['       ' sprintf('%-10.2G',M(i,:))]);
        end
    end
    if model.nb_class>1
        for j=setdiff(1:model.nb_class,m)
            disp(' ')
            M=model.Q{m}{j}(parameter(p_ref), ...
                timestamps(TimestampIndex),timesteps(TimestampIndex));
            for i=1:size(M,1)
                if i==1 && size(M,1) ~= 1
                    disp([' Q_' num2str(m) num2str(j) ...
                        '=[' sprintf('%-10.2G',M(i,:))]);                    
                elseif i==1 && size(M,1) == 1
                    disp([' Q_' num2str(m) num2str(j) ...
                        '=[' sprintf('%-10.2G',M(i,:)) '];' ] ); 
                elseif i==size(M,1) && size(M,1) ~= 1
                    disp(['       ' sprintf('%-10.2G',M(i,:)) '];']);
                else
                    disp(['       ' sprintf('%-10.2G',M(i,:))]);
                end
            end
        end
    end
end
disp(' ')
disp([' ' sprintf('%-s  ',data.labels{:})])
M=model.R{m}(parameter(p_ref), ...
    timestamps(TimestampIndex),timesteps(TimestampIndex));
 %% Display measurements noise covariance matrix R
for i=1:size(M,1)
    if i==1 && size(M,1) ~= 1
        disp(['    R=[' sprintf('%-11.2G',M(i,:))]);
    elseif i==1 && size(M,1) == 1
        disp(['    R=[' sprintf('%-11.2G',M(i,:)) '];' ]);
    elseif i==size(M,1) && size(M,1) ~= 1
        disp(['       ' sprintf('%-11.2G',M(i,:)) '];']);
    else
        disp(['       ' sprintf('%-11.2G',M(i,:))]);
    end
end
%--------------------END CODE ------------------------
end
