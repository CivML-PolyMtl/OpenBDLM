function modifyTrainingPeriod(data, model, estimation, misc, varargin)
%MODIFYTRAININGPERIOD Request user to modify training period
%
%   SYNOPSIS:
%     MODIFYTRAININGPERIOD(data, model, estimation, misc, varargin)
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
%                         save modification in
%                         FilePath/PROJ_'misc.ProjectName'.mat file
%                         default: '.'  (current folder)
%   OUTPUT:
%      N/A
%      Updated project file with new training period
%
%   DESCRIPTION:
%      MODIFYTRAININGPERIOD requests user to modify training period
%
%   EXAMPLES:
%      [misc]=MODIFYTRAININGPERIOD(data, model, estimation, misc)
%      [misc]=MODIFYTRAININGPERIOD(data, model, estimation, misc, 'FilePath', 'saved_projects')
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also BDLM

%   AUTHORS:
%       Ianis Gaudot, Luong Ha Nguyen, James-A Goulet,
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


validationFonction = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'estimation', @isstruct );
addRequired(p,'misc', @isstruct );
addParameter(p, 'FilePath', defaultFilePath, validationFonction)
parse(p,data, model, estimation, misc, varargin{:});

data=p.Results.data;
model=p.Results.model;
estimation=p.Results.estimation;
misc=p.Results.misc;
FilePath=p.Results.FilePath;


%% Verification merged data
[isMerged]=verificationMergedDataset(data);

if ~isMerged
    disp(['     ERROR: Impossible to modify training period because '...
        'the timestamp vector is different for each time series.'])
    disp(' ')
    return
end

%% Define timestamps
timestamps = data.timestamps{1};

%% Get current training period
if isfield(misc, 'trainingPeriod')
    disp(' ')
    disp(['     Current training period: from ' ...
        num2str(misc.trainingPeriod(1)) ' to ' ...
        num2str(misc.trainingPeriod(2)) ' days.'])
    disp(' ')
else
    [trainingPeriod]=defineTrainingPeriod(timestamps);
    misc.trainingPeriod = trainingPeriod;
    disp(' ')
    disp(['     Current training period: from ' ...
        num2str(misc.trainingPeriod(1)) ' to ' ...
        num2str(misc.trainingPeriod(2)) ' days.'])
    disp(' ')
end

%% Modify current training period

% Start of training period (in days)
disp(' ')
isCorrect = false;
while ~isCorrect
    disp('     Start training [days]: ');
    startTraining=input('     choice >> ');
    
    if isempty(startTraining)
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('                                                         ')
        disp(['Give start of the training period in '...
            'number of days since the first datapoint. '])
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp(' ')
        continue
    else
        if ischar(startTraining)
            disp(' ')
            disp('     wrong input -> not an digit ')
            disp(' ')
            continue
        elseif length(startTraining) > 1
            disp(' ')
            disp('     wrong input -> should be single value ')
            disp(' ')
            continue
        else
            isCorrect = true;
        end
    end
end

% End of training period (in days)
disp(' ')
isCorrect = false;
while ~isCorrect
    disp('     End training [days]: ');
    endTraining=input('     choice >> ');
    
    if isempty(endTraining)
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('                                                         ')
        disp(['End of the training period in '...
            'number of days since the first datapoint. '])
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp(' ')
        continue
    else
        if ischar(endTraining)
            disp(' ')
            disp('     wrong input -> not an digit ')
            disp(' ')
            continue
        elseif length(endTraining) > 1
            disp(' ')
            disp('     wrong input -> should be single value ')
            disp(' ')
            continue
        elseif endTraining <= startTraining
            disp(' ')
            disp(['     wrong input -> should be greater '...
                'than start of training period.'])
            disp(' ')
            continue
        else
            isCorrect = true;
        end
    end
end

% Record training period
trainingPeriod = [startTraining, endTraining];
misc.trainingPeriod = trainingPeriod;

%% Save project with updated values
saveProject(data, model, estimation, misc, 'FilePath', FilePath)

%% Display the new training period
disp(' ')
disp(['     New training period: from ' ...
    num2str(misc.trainingPeriod(1)) ' to ' ...
    num2str(misc.trainingPeriod(2)) ' days.'])
disp(' ')

%--------------------END CODE ------------------------
end
