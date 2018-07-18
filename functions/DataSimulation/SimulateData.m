function [data, model, estimation, misc]=SimulateData(data, model, misc, varargin)
%SIMULATEDATA Simulate data from current model configuration
%
%   SYNOPSIS:
%     [data, model, estimation, misc]=SIMULATEDATA(data, model, misc, varargin)
%
%   INPUT:
%      data         - structure (required)
%                     see documentation for details about the fiels of data
%
%      model        - structure (required)
%                     see documentation for details about the fiels of
%                     model
%
%      misc         - structure (required)
%                     see documentation for details about the fiels of misc
%
%      isPlot       - logical (optional)
%                     if isPlot = true, plot the simulated data
%                     default: true
%
%   OUTPUT:
%      data         - structure (required)
%                     see documentation for details about the fiels of data
%
%      model        - structure (required)
%                     see documentation for details about the fiels of
%                     model
%
%      estimation   - structure (required)
%                     see documentation for details about the fiels of
%                     estimation
%
%      misc         - structure (required)
%                     see documentation for details about the fiels of misc
%
%   DESCRIPTION:
%      SIMULATEDATA simulates data from current model configuration
%
%   EXAMPLES:
%      [data, model, estimation, misc]=SimulateData(data, model, estimation, misc)
%      [data, model, estimation, misc]=SimulateData(data, model, estimation, misc, 'isPlot', true)
%
%   EXTERNAL FUNCTIONS CALLED:
%      simulateDataFromCustomAnomalies, simulateDataFromTransitionProbabilities
%      incrementProjectName, saveProject
%
%   See also SIMULATEDATADFROMCUSTOMANOMALIES,
%   SIMULATEDATAFROMTRANSITIONPROBABILITIES, SAVEPROJECTS,
%   INCREMENTPROJECTNAME

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

defaultisPlot = true;

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'misc', @isstruct );
addParameter(p, 'isPlot', defaultisPlot, @islogical)
parse(p,data, model,  misc, varargin{:});

data=p.Results.data;
model=p.Results.model;
misc=p.Results.misc;
isPlot=p.Results.isPlot;

if isfield(data, 'values')
    % prevent overwriting by incrementing ProjectName
    ProjectName = incrementProjectName('new', 'saved_projects' );
    misc.ProjectName = ProjectName;   
end

if isfield(misc, 'custom_anomalies') && ~isempty(misc.custom_anomalies)
    [data, model, estimation, misc]= ...
        simulateDataFromCustomAnomalies(data, model, misc);
else
     [data, model, estimation, misc]= ...
        simulateDataFromTransitionProbabilities(data, model, ...
        misc);
end

if isPlot
    plotData(data, model, estimation, misc, 'isPdf', false, 'FilePath', 'figures', ...
        'isSaveFigures', true );
end

%--------------------END CODE ------------------------
end
