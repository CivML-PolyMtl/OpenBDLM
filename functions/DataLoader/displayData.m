function displayData(data, misc)
%DISPLAYDATA Display on screen the content of the data in memory
%
%   SYNOPSIS:
%     DISPLAYDATA(data)
%
%   INPUT:
%       data        - structure (required)
%                         Two formats are accepted:
%
%                           (1) data must contain two or three fields :
%
%                               'timestamps' is a 1×N cell array
%                               each cell is a M_ix1 real array
%
%                               'labels' is a 1×N cell array
%                               each cell is a character array
%
%                               'values' is a 1×N cell array
%                               each cell is a M_ix1 real array
%                               This field is optional
%
%                               N: number of time series
%                               M_i: number of samples of time series i
%
%
%                           (2) data must contain two or three fields:
%
%                               'timestamps' is a M×1 array
%
%                               'labels' is a 1×N cell array
%                               each cell is a character array
%
%                               'values' is a MxN  array
%                               This field is optional
%
%                               N: number of time series
%                               M: number of samples
%
%      misc         - structure (required)
%
%   OUTPUT:
%      Print message on screen
%
%   DESCRIPTION:
%      DISPLAYDATA displays on screen the content of the data in memory
%
%   EXAMPLES:
%      DISPLAYDATA(data)
%
%   See also CHOOSETIMESERIES

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

% Set fileID for logfile
if misc.internalVars.isQuiet
    % output message in logfile
    fileID=fopen(misc.internalVars.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end

if isfield(data, 'values')
    
    % if data given in format (2), translate it to format (1)
    if ~iscell(data.timestamps) && ~iscell(data.values)
        [data]=convertMat2Cell(data);
    end
    
    %% Display data on screen
    % Get number of time series in dataset
    numberOfTimeSeries = length(data.labels);
    
    % Show on screen which data are available
    fprintf(fileID,' \n');
    fprintf(fileID,'- Data available: \n');
    
    fprintf(fileID, ' \n');
    fprintf(fileID, '     %-25s %-25s %-25s\t\n', ...
        'Time series number #', 'Reference name', 'Size');
    fprintf(fileID, '     %-30s\n', ...
        ['--------------------------------', ...
        '-----------------------------------']);
    for i=1:numberOfTimeSeries
        sz=size(data.timestamps{i});
        fprintf(fileID, '     %-25s %-25s %-25s\t\n', ...
            num2str(i), data.labels{i}, ...
            ['[', num2str(sz(1)),'x', num2str(sz(2)), ']' ] );
    end
    fprintf(fileID, '     %-30s\n', ...
        ['-------------------------------------' ...
        '------------------------------']);
    fprintf(fileID, ' \n');
else
    
    %% Display data on screen
    % Get number of time series in dataset
    numberOfTimeSeries = length(data.labels);
    
    % Show on screen which data are available
    fprintf(fileID,' \n');
    fprintf(fileID,'- Data available: \n');
    
    fprintf(fileID, ' \n');
    fprintf(fileID, '     %-25s %-25s %-25s\t\n', ...
        'Time series number #', 'Reference name', 'Size');
    fprintf(fileID, '     %-30s\n', ...
        ['--------------------------------', ...
        '-----------------------------------']);
    for i=1:numberOfTimeSeries
        sz=size(data.timestamps);
        fprintf(fileID, '     %-25s %-25s %-25s\t\n', ...
            num2str(i), data.labels{i}, ...
            ['[', num2str(sz(1)),'x', num2str(sz(2)), ']' ] );
    end
    fprintf(fileID, '     %-30s\n', ...
        ['-------------------------------------' ...
        '------------------------------']);
    fprintf(fileID, ' \n');
end

%--------------------END CODE ------------------------
end
