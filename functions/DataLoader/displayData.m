function displayData(data)
%DISPLAYDATA Display on screen the content of the data in memory
%
%   SYNOPSIS:
%     DISPLAYDATA(data)
% 
%   INPUT:
%       data       - structure (required)
%                      data must contain three fields :
%
%                           'timestamps' is a 1×N cell array
%                           each cell is a M_ix1 real array
%
%                           'values' is a 1×N cell array
%                           each cell is a M_ix1 real array
%
%                           'labels' is a 1×N cell array
%                           each cell is a character array
%
%                 N: number of time series
%                 M_i: number of samples of time series i
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
%       April 13, 2018
 
%--------------------BEGIN CODE ---------------------- 
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;
addRequired(p,'data', @isstruct );    
parse(p,data);

% Validation of structure data
% isValid = verificationDataStructure(data);
% if ~isValid
%     disp(' ')
%     disp('ERROR: Unable to read the data from the structure.')
%     disp(' ')
%     return
% end

%% Display data on screen
 
% Get number of time series in dataset
numberOfTimeSeries = length(data.labels);

% Show on screen which data are available
fprintf(' \n')
fprintf('- Data available: \n')

fprintf(' \n')
fprintf('     %-25s %-25s %-25s\t\n', ...
    'Time series number #', 'Reference name', 'Size');
fprintf('     %-30s\n', ...
    ['--------------------------------' ...
    '-----------------------------------']);
fprintf(' \n')
for i=1:numberOfTimeSeries
    sz=size(data.timestamps{i});
    fprintf('     %-25s %-25s %-25s\t\n', num2str(i), data.labels{i}, ...
        ['[', num2str(sz(1)),'x', num2str(sz(2)), ']' ] )
end
fprintf(' \n')
fprintf('     %-30s\n', ...
    ['-------------------------------------' ...
    '------------------------------']);
fprintf(' \n')
%--------------------END CODE ------------------------ 
end
