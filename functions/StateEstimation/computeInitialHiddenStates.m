function [model] = computeInitialHiddenStates(data, model, estimation, misc, varargin)
%COMPUTEINITIALHIDDENSTATES Computes initial hidden states from smoother
%
%   SYNOPSIS:
%      [model] = COMPUTEINITIALHIDDENSTATES(data, model, estimation, misc, varargin)
%
%   INPUT:
%      data             - structure (required)
%                         see documentation for details about the fields of
%                         data
%
%      model            - structure (required)
%                          see documentation for details about the fields of
%                          model
%
%      estimation       - structure (required)
%                         see documentation for details about the fields of
%                         estimation
%
%      misc             - structure (required)
%                         see documentation for details about the fields of
%                         misc
%
%      FilePath         - character (optional)
%                         directory where to save the modifications
%                         Modifications are saved directly in project file
%                         located in FilePath/PROJ_'misc.ProjectName'.mat file
%                         default: '.'  (current folder)
%
%      Percent          - real (optional)
%                         percent of the total duration to define training
%                         period
%                         default: 25 %                        

%   OUTPUT:
%      model            - structure (required)
%                         see documentation for details about the fields of
%                         model
%
%      Updated project file with new initial hidden states values
%
%   DESCRIPTION:
%      COMPUTEINITIALHIDDENSTATES computes initial hidden states using
%      smoothing analysis on a subset of data that includes the first
%      datapoint
%      COMPUTEINITIALHIDDENSTATES stores new values (initial mean and
%      variance) in the project file
%
%   EXAMPLES:
%      [model] = COMPUTEINITIALHIDDENSTATES(data, model, estimation, misc)
%      [model] = COMPUTEINITIALHIDDENSTATES(data, model, estimation, misc, 'FilePath', 'saved_projects')
%      [model] = COMPUTEINITIALHIDDENSTATES(data, model, estimation, misc, 'Percent', 10)
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also BDLM

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
%       June 12, 2018
%
%   DATE LAST UPDATE:
%       June 12, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultFilePath = '.';
defaultPercent = 25;

validationFonction = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'estimation', @isstruct );
addRequired(p,'misc', @isstruct );
addParameter(p, 'FilePath', defaultFilePath, validationFonction)
addParameter(p, 'Percent', defaultPercent, @isreal)
parse(p,data, model, estimation, misc, varargin{:});

data=p.Results.data;
model=p.Results.model;
estimation=p.Results.estimation;
misc=p.Results.misc;
FilePath=p.Results.FilePath;
Percent=p.Results.Percent;

% %% Verification merged data
% [isMerged]=verificationMergedDataset(data);
% 
% if ~isMerged
%     disp(['     ERROR: Option not available because '...
%         'the timestamp vector is different for each time series.'])
%     disp(' ')
%     return
% end

% Convert cell2mat
% [data] = convertCell2Mat(data);

%% Extract subset of data
% Define timestamps
timestamps = data.timestamps;

% Define training period (starting from first data point)
[trainingPeriod]=defineTrainingPeriod(timestamps, 'Percent', Percent);

% Convert days to sample indexes
[training_start_idx]=day2sampleIndex(trainingPeriod(1), ...
    timestamps);
[training_end_idx]=day2sampleIndex(trainingPeriod(2), ...
    timestamps);

% Extract the subset of data, starting from first datapoint
data_train=data;

data_train.timestamps= data.timestamps(training_start_idx:training_end_idx);
data_train.values= data.values(training_start_idx:training_end_idx,:);


%% Run smoother on data subset to compute initial hidden states values
[estimation]=state_estimation(data_train,model,estimation, misc, ...
    'smooth',1);

%% Store the new initial hidden states values
for i=1:model.nb_class
    model.initX{i}=estimation.x_M{i}(:,1);
    model.initV{i}=estimation.V_M{i}(:,:,1);
    model.initS{i}=estimation.S(1,i);
end

% Convert mat2cell
% [data] = convertMat2Cell(data);

%% Save the project
% saveProject(data, model, estimation, misc, ...
%     'FilePath',FilePath)

%--------------------END CODE ------------------------
end
