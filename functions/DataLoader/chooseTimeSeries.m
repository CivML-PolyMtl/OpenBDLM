function [data, misc]=chooseTimeSeries(data, misc)
%CHOOSETIMESERIES Request the user to select some time series
%
%   SYNOPSIS:
%     [data, misc]=CHOOSETIMESERIES(data, misc)
%
%   INPUT:
%       data         - structure (required)
%                         Two formats are accepted:
%
%                           (1) data must contain three fields :
%
%                               'timestamps' is a 1×N cell array
%                               each cell is a M_ix1 real array
%
%                               'values' is a 1×N cell array
%                               each cell is a M_ix1 real array
%
%                               'labels' is a 1×N cell array
%                               each cell is a character array
%
%                               N: number of time series
%                               M_i: number of samples of time series i
%
%
%                           (2) data must contain three fields:
%
%                               'timestamps' is a M×1 array
%
%                               'values' is a MxN  array
%
%                               'labels' is a 1×N cell array
%                               each cell is a character array
%
%                               N: number of time series
%                               M: number of samples
%
%      misc          - structure
%                      see the documentation for details about the
%                      field in misc
%
%   OUTPUT:
%       data        - structure 
%
%                           data must contain three fields :
%
%                               'timestamps' is a 1×N cell array
%                               each cell is a M_ix1 real array
%
%                               'values' is a 1×N cell array
%                               each cell is a M_ix1 real array
%
%                               'labels' is a 1×N cell array
%                               each cell is a character array
%
%                               N: number of time series
%                               M_i: number of samples of time series i
%
%
%      misc         - structure
%                      see the documentation for details about the
%                      field in misc
%
%   DESCRIPTION:
%      CHOOSETIMESERIES requests user to select  a subset of time series
%      from full data structure
%      CHOOSETIMESERIES replace/overwrite input data structure
%
%   EXAMPLES:
%      [data, misc] = CHOOSETIMESERIES(data, misc)
%      [data, misc] = CHOOSETIMESERIES(data, misc, 'isPlot', true)
%      [data, misc] = CHOOSETIMESERIES(data, misc, 'isPlot', true, 'isOutputfile', true)
%
%
%   EXTERNAL FUNCTIONS CALLED:
%      verificationDataStructure, displayData
%
%   See also VERIFICATIONDATASTRUCTURE, DETECTOVERLAP,
%   MERGETIMESTEPVECTORS, DISPLAYDATA


%   AUTHORS:
%      Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       April 12, 2018
%
%   DATE LAST UPDATE:
%       October 16, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications

p = inputParser;

addRequired(p,'data', @isstruct );
addRequired(p,'misc', @isstruct );

parse(p,data, misc);

data=p.Results.data;
misc=p.Results.misc;

MaxFailAttempts=4;

% Set fileID for logfile
if misc.internalVars.isQuiet
    % output message in logfile
    fileID=fopen(misc.internalVars.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end

% if data given in format (2), translate it to format (1)
if ~iscell(data.timestamps) && ~iscell(data.values)
    [data]=convertMat2Cell(data);  
end

%% Display data on screen
displayData(data, misc)

% Get number of time series in dataset
numberOfTimeSeries = length(data.labels);

%% Request the user to choose some time series
incTest=0;
while(1)
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    fprintf(fileID, ['- Choose the time series ', ...
        'to process (e.g [1 3 4]) : \n']);
    if misc.internalVars.BatchMode.isBatchMode
        chosen_ts= ...
            eval(char(misc.internalVars.BatchMode.Answers{...
            misc.internalVars.BatchMode.AnswerIndex}));
        x=chosen_ts;
        fprintf(fileID, ['     [%s]', ...
            '\n'], strjoin(cellstr(num2str(x(:))),', '));
        
    else
        chosen_ts = input('     choice >> ');
    end
    if isempty(chosen_ts)
        continue
    elseif ischar(chosen_ts) || any(mod(chosen_ts,1)) || ...
            ~isempty(chosen_ts(chosen_ts<1))
        fprintf(fileID,['     wrong input -> ', ...
            'should be positive integers\n']);
        continue
    elseif length(chosen_ts) > numberOfTimeSeries
        fprintf(fileID, ['     wrong input -> ', ...
            ' number of chosen time series ' ...
            '> number of time series available (%d) \n'], ...
            numberOfTimeSeries  );
        continue
    elseif length(chosen_ts) ~= length(unique(chosen_ts))
        fprintf(fileID, ['     wrong input -> a same time series' ...
            'cannot be chosen twice.\n']);
        continue
    elseif ~isempty(chosen_ts(chosen_ts> numberOfTimeSeries))
        fprintf(fileID,['     wrong input -> ', ...
            'at least one time series index' ...
            'is out of range.\n']);
        continue
    else
        
        break
    end
end

% Increment global variable to read next answer when required
misc.internalVars.BatchMode.AnswerIndex = ...
    misc.internalVars.BatchMode.AnswerIndex+1;

%% Remove unselected time series from data structure
full_ts = 1:numberOfTimeSeries;
ts_to_remove = full_ts(~ismember(full_ts, chosen_ts));

data.values(ts_to_remove) = [];
data.timestamps(ts_to_remove) = [];
data.labels(ts_to_remove) = [];

%% Display data on screen
%displayData(data, misc)

%--------------------END CODE ------------------------
end
