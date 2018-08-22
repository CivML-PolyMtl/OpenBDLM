function [data, model, estimation, misc]=configureModelForDataReal(data, model, estimation , misc)
%CONFIGUREMODELFORDATAREAL Configure model for BDLM analysis based on real data
%
%   SYNOPSIS:
%      [data, model, estimation, misc]=CONFIGUREMODELFORDATAREAL(data, model, estimation, misc)
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
%      CONFIGUREMODELFORDATAREAL configures model for BDLM analysis 
%      based on real data. Model configuration means: 
%      1) get information from data timestamp vector
%      2) define training dataset
%      3) define dependencies between time series
%      4) choose number of model class for each time series
%      5) choose  model components for each time series
% 
%   EXAMPLES:
%      [data, model, estimation, misc]=CONFIGUREMODELFORDATAREAL(data, model, estimation, misc)
% 
%   EXTERNAL FUNCTIONS CALLED:
%     verificationDataStructure, verificationMergedDataset, 
%     defineReferenceTimeStep, defineTrainingPeriod, defineModel,
%     buildModel
% 
%   See also DEFINEMODEL, BUILDMODEL, DEFINEREFERENCETIMESTEP,
%   DEFINETRAININGPERIOD, VERIFICATIONMERGEDDATASET,
%   VERIFICATIONDATASTRUCTURE
 
%   AUTHORS: 
%      Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
%      Catherine Paquin, Shervin Khazaeli 
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
%       July 25, 2018
 
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

% Set fileID for logfile
if misc.isQuiet
    % output message in logfile
    fileID=fopen(misc.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end


% Validation of structure data
isValid = verificationDataStructure(data);
if ~isValid
    fprintf(fileID,'\n');
    fprintf(fileID,['     ERROR: Unable to ', ...
        'read the data from the structure.\n']);
    fprintf(fileID,'\n');
    return
end   

%% Compute reference time step from timestamp vector
timestamps = data.timestamps;
[dt_ref] = defineReferenceTimeStep(timestamps);
misc.dt_ref = dt_ref;

%% Get training dataset from timestamp vector
[trainingPeriod] = defineTrainingPeriod (timestamps);

misc.options.trainingPeriod = trainingPeriod;

%% Define model
[model, misc] = defineModel(data, misc);

%% Build model
[model] = buildModel(data, model, misc);

%% Set default variable
%[misc]=setDefaultConfig(misc, data);

%--------------------END CODE ------------------------ 
end
