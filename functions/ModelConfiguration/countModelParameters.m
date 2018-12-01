function [NumberOfParameters]=countModelParameters(model)
%COUNTMODELPARAMETERS Count the number of parameters needed for a model
%
%   SYNOPSIS:
%     [NumberOfParameters]=COUNTMODELPARAMETERS(model)
%
%   INPUT:
%      model              - structure (required)
%
%   OUTPUT:
%      NumberOfParameters - integer
%
%   DESCRIPTION:
%      COUNTMODELPARAMETERS counts the number of parameter needed for a
%      defined model
%
%   EXAMPLES:
%      [NumberOfParameters]=COUNTMODELPARAMETERS(model)
%
%   See also

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
%       May 29, 2018
%
%   DATE LAST UPDATE:
%       June 4, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'model', @isstruct );
parse(p,model);

model=p.Results.model;

%% Initialize number of model parameters to 0
NumberOfParameters= 0;

%% Get number of model classes
nb_models = size(model.components.block,2);
if nb_models == 2
    NumberOfParameters= NumberOfParameters + 2;
end

%% Get number of time series

numberOfTimeSeries = size(model.components.block{nb_models},2);

NumberOfParameters= NumberOfParameters + nb_models*numberOfTimeSeries;

components=[11 12 13 21 22 23 31 41 51];

%% Count the number of model parameters from components
isDynamicRegression = false;
for i=1:numberOfTimeSeries
    if nb_models == 2
        
        % Count parameters for local trend component
        v_LT = ismember(model.components.block{1}{i}, components(4));
        if any(v_LT)
            if model.components.const{2}{i}(v_LT) == 1
                NumberOfParameters= NumberOfParameters + 3;
            else
                NumberOfParameters= NumberOfParameters + 3*nb_models;
            end
        end
        
        % Count parameters for local acceleration component
        v_LA = ismember(model.components.block{1}{i}, components(5:6));
        if any(v_LA)
            if model.components.const{2}{i}(v_LA) == 1
                NumberOfParameters= NumberOfParameters + 4;
            else
                NumberOfParameters= NumberOfParameters + 4*nb_models;
            end
        end
        
        
        % Count parameters for periodic components
        v_P = ismember(model.components.block{1}{i}, components(7));
        if any(v_P)
            pos=find(model.components.const{2}{i}(v_P) == 1,1 );
            if ~isempty(pos)
                NumberOfParameters= NumberOfParameters +  ...
                    length(v_P(v_P==true))*2;
            else
                NumberOfParameters= NumberOfParameters + ...
                    length(v_P(v_P==true))*2*nb_models;
            end
        end
        
        % Count parameters for autoregressive components
        v_AR = ismember(model.components.block{1}{i}, components(8));
        if any(v_AR)
            pos=find(model.components.const{2}{i}(v_AR) == 1,1 );
            if ~isempty(pos)
                NumberOfParameters= NumberOfParameters + ...
                    length(v_AR(v_AR==true))*2;
            else
                NumberOfParameters= NumberOfParameters + ...
                    length(v_AR(v_AR==true))*2*nb_models;
            end
        end
                
      
        end       
        
        % Count parameters for kernel regression
        v_KR = ismember(model.components.block{1}{i}, components(11));
        if any(v_KR)
            pos=find(model.components.const{2}{i}(v_KR) == 1,1 );
            if ~isempty(pos)
                NumberOfParameters= NumberOfParameters + ...
                    length(v_KR(v_KR==true))*3;
            else
                NumberOfParameters= NumberOfParameters + ...
                    length(v_KR(v_KR==true))*3*nb_models;
            end
        end  
        
        
        
    if nb_models == 1
        
        % Count number of paramaters for baseline
        v_baseline = ismember(model.components.block{1}{i}, components(1:3));
        if any(v_baseline)
            NumberOfParameters= NumberOfParameters + 1;
        end
        
        % Count parameters for periodic components
        v_P = ismember(model.components.block{1}{i}, components(7));
        if any(v_P)
            NumberOfParameters= NumberOfParameters + ...
                length(v_P(v_P==true))*2;
        end
        
        
        % Count parameters for autoregressive components
        v_AR = ismember(model.components.block{1}{i}, components(8));
        if any(v_AR)
            NumberOfParameters= NumberOfParameters + ...
                length(v_AR(v_AR==true))*2;
        end
        
                
        % Count parameters for kernel regression
        v_KR = ismember(model.components.block{1}{i}, components(11));
        if any(v_KR)
                NumberOfParameters= NumberOfParameters + ...
                    length(v_KR(v_KR==true))*3;
        end
        
        
    else
        
        disp(' ')
        disp('     ERROR: The number of model classes > 2.')
        disp(' ')
        
    end
    
end

%% Dependencies between time series

if numberOfTimeSeries > 1
    for i=1:numberOfTimeSeries
        
        if ~isempty(model.components.ic{i})
            for j=1:length(model.components.ic{i})
                index=model.components.block{1}{model.components.ic{i}(j)};
                
                v_P_AR = ismember(index, components(7:8));
                
                if any(v_P_AR)
                    NumberOfParameters= NumberOfParameters + ...
                        length(v_P_AR(v_P_AR==true))*nb_models;
                end
                
            end
        end
    end
    
end


%% Exception message for dynamic regression
if  isDynamicRegression
    disp(' ')
    fprintf(['     Inportant note about dynamic regression component: ', ...
        'the model parameters counting ', ...
        'is based on the assumption of %d control ', ...
        'points for the dynamic regression component. '], nb_control_points)
    disp(' ')
end
%--------------------END CODE ------------------------
end
