function [data, model, estimation, misc]=ModelConfiguration(data, model, estimation, misc)
%MODELCONFIGURATION Configure model for BDLM analysis
%
%   SYNOPSIS:
%     [data, model, estimation, misc]=MODELCONFIGURATION(data, model, estimation, misc)
%
%   INPUT:
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
%      0) for data simulation only: define data labels, and timestamp vector
%      1) get information from data timestamp vector
%      2) define training dataset
%      3) define dependencies between time series
%      4) choose number of model class for each time series
%      5) choose  model components for each time series
%
%   EXAMPLES:
%      [data, model, estimation, misc]=MODELCONFIGURATION(data, model, estimation, misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%      verificationDataStructure, configureModelForDataReal, saveProject,
%      configureModelForDataSimulation, configureModelForDataReal
%    
%   See also CONFIGUREMODELFORDATAREAL, CONFIGUREMODELFORDATASIMULATION

%   AUTHORS:
%      Ianis Gaudot,  Luong Ha Nguyen, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       April 20, 2018
%
%   DATE LAST UPDATE:
%       May 28, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'estimation', @isstruct );
addRequired(p,'misc', @isstruct );
parse(p,data, model, estimation, misc);

data=p.Results.data;
model=p.Results.model;
estimation=p.Results.estimation;
misc=p.Results.misc;

if ~misc.isDataSimulation
    
    %% Model configuration for real data   
    
    % Validation of structure data
    isValid = verificationDataStructure(data);
    if ~isValid
        disp(' ')
        disp('     ERROR: Unable to read the data from the structure.')
        disp(' ')
        return
    end
    [data, model, estimation, misc] =  ...
        configureModelForDataReal(data, model, estimation, misc);
    
else
    %% Model configuration for simulated data     
    [data, model, estimation, misc] = ...
        configureModelForDataSimulation (data, model, estimation, misc);
    
end
%--------------------END CODE ------------------------
end
