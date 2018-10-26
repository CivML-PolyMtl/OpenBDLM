function plotDataAvailability(data, misc, varargin)
%PLOTDATAAVAILABILITY Summarize data availability of a time series dataset
%
%   SYNOPSIS:
%      PLOTDATAAVAILABILITY(data, varargin)
%
%   INPUT:
%       data            - structure (required)
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
%      misc             - structure (required)
%                         see documentation for details about the fields of
%                         misc
%
%      FilePath     - character (optional)
%                     directory where to save the plot
%                     default: '.'  (current folder)
%
%   OUTPUT:
%      One figure saved in "FilePath" directory.
%
%   DESCRIPTION:
%      PLOTDATAAVAILABILITY summarizes the data availability
%      of a collection of time series in a single plot.
%      Availability refers to indicating the start/end of each record, and
%      missing data (NaN).
%
%   EXAMPLES:
%      PLOTDATAAVAILABILITY(data)
%      PLOTDATAAVAILABILITY(data, 'FilePath', './figures/')
%
%   EXTERNAL FUNCTIONS CALLED:
%      exportPlot
%
%   See also EXPORTPLOT

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
%       April 10, 2018
%
%   DATE LAST UPDATE:
%       October 26, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultFilePath = '.';

validationFct_FilePath = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p,'data', @isstruct );
addRequired(p,'misc', @isstruct );
addParameter(p,'FilePath', defaultFilePath, validationFct_FilePath);
parse(p,data, misc, varargin{:});

data=p.Results.data;
misc=p.Results.misc;
FilePath=p.Results.FilePath;

%% Get info from misc
% Options
FigurePosition=misc.options.FigurePosition;
ndivx=misc.options.ndivx;
isExportPDF = misc.options.isExportPDF;
isExportPNG = misc.options.isExportPNG;
isExportTEX = misc.options.isExportTEX;

% If data given in format (2), translate it to format (1)
if ~iscell(data.timestamps) && ~iscell(data.values)
    [data]=convertMat2Cell(data);
end

%% Create specified path if not existing
[isFileExist] = testFileExistence(FilePath, 'dir');
if ~isFileExist
    % create directory
    mkdir(FilePath)
    % set directory on path
    addpath(FilePath)
end

%% Plot data availability

% Get number of time series in dataset
numberOfTimeSeries = length(data.values);

% Data availability plot
FigHandle = figure('Name','Data availability','NumberTitle','off', ...
    'DefaultAxesPosition', [0.1, 0.17, 0.8, 0.8]);
set(FigHandle, 'Position', FigurePosition)
%figure('Visible', 'on')
set(gcf,'color','w');

nan_detect=[];
sensor=cell(1,numberOfTimeSeries);

% Loop over time series
inc=0;
for i=numberOfTimeSeries:-1:1
    inc=inc+1;
    % Get timestamps
    timestamps=data.timestamps{i};
    % Get amplitude values
    values=data.values{i};
    % Get time series name
    sname=data.labels{i};
    
    nan_pos=find(isnan(values) );  % Position of the missing data (NaN)
    begg=timestamps(1); % Start of time series
    endd=timestamps(end); % End of time series
    sensor{1,inc}=num2str(i);
    
    % Detect earliest start and latest end in the dataset
    if i == numberOfTimeSeries
        begg_min=begg;
        endd_max=endd;
    else
        if begg < begg_min
            begg_min=begg;
        end
        if endd > endd_max
            endd_max=endd;
        end
    end
    
    % Indicate missing data (NaN) in the plot
    if ~isempty(nan_pos)
        plot( timestamps(nan_pos), (inc-0.15)*ones(length(nan_pos),1),  ...
            'Color', [1 0 0], 'Marker', '*', 'LineStyle', 'none', ...
            'Markersize', 2.5, 'MarkerFaceColor',[1 0 0] )
        hold on
        nan_detect=1;
    end
    
    % Indicate working period
    plot([begg, endd] , [ inc inc ], 'Color', [0.17, 0.88, 0.3], ...
        'linewidth', 10)
    hold on
    % Indicate time series reference name
    text(begg, inc, sname ,'FontSize', 10, 'Interpreter', 'none')
end

% Add legend to plot
if ~isempty(nan_detect)
    text(endd_max-((endd_max-begg_min)/7.5), ...
        numberOfTimeSeries+1-0.4, 'missing data',...
        'FontSize', 12, 'HorizontalAlignment','center')
    hold on
    text(endd_max-((endd_max-begg_min)/5.75),  ...
        numberOfTimeSeries+1-0.4, '+', ...
        'FontSize', 12, 'HorizontalAlignment','center', ...
        'Color', [1 0 0] )
end

% Adjust xlim and ylim
xlim([begg_min-1, endd_max+1])
ylim([ 0, numberOfTimeSeries+1])

set(gca,'YTick',linspace(1, numberOfTimeSeries+1,numberOfTimeSeries+1));
set(gca, 'YTicklabel', { sensor{1,:}, ' '})
set(gca,'XTick',linspace(begg_min,endd_max,ndivx));
set(gca,'FontSize',16)
datetick('x','yy-mm','keepticks')
xlabel('Time [YY-MM]')
ylabel('time series #')

%% Export figure in specified formats
if isExportPDF || isExportPNG || isExportTEX
    filename='AVAILABILITY';
    exportPlot(filename, 'FilePath', FilePath,  ...
        'isExportPDF', isExportPDF, ...
        'isExportPNG', isExportPNG, ...
        'isExportTEX', isExportTEX);
end

%--------------------END CODE ------------------------
end
