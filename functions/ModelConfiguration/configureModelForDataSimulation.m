function [data, model, estimation, misc]=configureModelForDataSimulation(data, model, estimation , misc)
%CONFIGUREMODELFORDATASIMULATION Configure model for BDLM analysis based on simulated data
%
%   SYNOPSIS:
%      [data, model, estimation, misc]=CONFIGUREMODELFORDATASIMULATION(data, model, estimation, misc)
%
%   INPUT:
%      data         - structure
%                     see documentation for details about the fields of data
%
%      model        - structure
%                     see documentation for details about the fields of
%                     model
%
%      estimation   - structure
%                     see documentation for details about the fields of
%                     estimation
%
%      misc         - structure
%                     see documentation for details about the fields of misc
%
%   OUTPUT:
%      data         - structure
%                     see documentation for details about the fields of data
%
%      model        - structure
%                     see documentation for details about the fields of
%                     model
%
%      estimation   - structure
%                     see documentation for details about the fields of
%                     estimation
%
%      misc         - structure
%                     see documentation for details about the fields of misc
%
%   DESCRIPTION:
%      CONFIGUREMODELFORDATASIMULATION configures model for BDLM analysis 
%      based on simulated data. Model configuration means: 
%      1) define data timestamp vector
%      2) define training dataset
%      3) define dependencies between time series
%      4) choose number of model class for each time series
%      5) choose  model components for each time series 
%
%   EXAMPLES:
%      [data, model, estimation, misc]=CONFIGUREMODELFORDATASIMULATION(data, model, estimation, misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%     defineLabels, defineTimestamps,
%    verificationDataStructure, verificationMergedDataset,
%     defineReferenceTimeStep, defineTrainingPeriod, defineModel,
%     buildModel,
%
%   See also DEFINELABELS, DEFINETIMESTAMPS, DEFINEMODEL, BUILDMODEL,
%       DEFINEREFERENCETIMESTEP, DEFINETRAININGPERIOD,
%      VERIFICATIONMERGEDDATASET, VERIFICATIONDATASTRUCTURE

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

%% Request user's input to define data labels
[data, misc]=defineDataLabels(data, misc);

%% Request user's input to define timestamps
[data, misc]=defineTimestamps(data, misc);

%% Compute reference time step from timestamp vector
timestamps = data.timestamps;
[dt_ref] = defineReferenceTimeStep(timestamps);
misc.dt_ref = dt_ref;

%% Get training dataset from timestamp vector
[trainingPeriod] = defineTrainingPeriod(timestamps);

misc.options.trainingPeriod = trainingPeriod;

%% Define model
[model, misc] = defineModel(data, misc);

%% Define custom anomalies
if model.nb_class > 1
    [misc] = defineCustomAnomalies(data, model, misc);
end

%% Build model
[model] = buildModel(data, model, misc);

%% Set default variable
%[misc]=setDefaultConfig(misc, data);

%--------------------END CODE ------------------------
end
