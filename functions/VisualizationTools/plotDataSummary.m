function plotDataSummary(data, misc, varargin)
%PLOTDATASUMMARY Plot amplitude and time step of time series data
%
%   SYNOPSIS:
%     PLOTDATASUMMARY(data, misc, varargin)
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
%      FilePath         - character (optional)
%                         directory where to save the plot
%                         defaut: '.'  (current folder)
%
%   OUTPUT:
%      One figure for each time series.
%
%   DESCRIPTION:
%      PLOTDATASUMMARY reads time series data from structure
%      PLOTDATASUMMARY plots amplitude and time step of each time series.
%      Figures saved in specified "FilePath" directory.
%
%   EXAMPLES:
%      PLOTDATASUMMARY(data, misc)
%      PLOTDATASUMMARY(data, misc, 'Filepath', './figures/')
%
%   EXTERNAL FUNCTIONS CALLED:
%      plotDataAvailability, exportPlot, incrementFilename
%
%   See also PLOTDATAAVAILABILITY, EXPORTPLOT, INCREMENTFILENAME

%   AUTHORS:
%      Ianis Gaudot,Luong Ha Nguyen, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       April 10, 2018
%
%   DATE LAST UPDATE:
%       October 26, 2018
%
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

ProjectName=misc.ProjectName;

%% Get options from misc
FigurePosition=misc.options.FigurePosition;
Linewidth=misc.options.Linewidth;
ndivx=misc.options.ndivx;
ndivy=misc.options.ndivy;
isExportPDF = misc.options.isExportPDF;
isExportPNG = misc.options.isExportPNG;
isExportTEX = misc.options.isExportTEX;

% If data given in format (2), translate it to format (1)
if ~iscell(data.timestamps) && ~iscell(data.values)
    [data]=convertMat2Cell(data);
end

if isExportPNG || isExportPDF || isExportTEX
    
    %% Create specified path if not existing
    [isFileExist] = testFileExistence(FilePath, 'dir');
    if ~isFileExist
        % create directory
        mkdir(FilePath)
        % set directory on path
        addpath(FilePath)
    end
    
    fullname=fullfile(FilePath, ProjectName);
    
    [isFileExist] = testFileExistence(fullname, 'dir');
    if isFileExist
        disp( ['     Directory ', fullname ,' already exists. ', ...
            'Overwrite ? (y/n)']);
        isYesNoCorrect = false;
        while ~isYesNoCorrect
            choice = input('     choice >> ','s');
            if isempty(choice)
                disp(' ')
                disp('     wrong input')
                disp(' ')
            elseif strcmpi(choice,'y') || strcmpi(choice,'yes')
                
                isYesNoCorrect =  true;
                
            elseif strcmpi(choice,'n') || strcmpi(choice,'no')
                
                [name] = incrementFilename([ProjectName, '_new'], ...
                    FilePath);
                fullname=fullfile(FilePath, name);
                
                % Create new directory
                mkdir(fullname)
                addpath(fullname)
                
                isYesNoCorrect =  true;
                
            else
                disp(' ')
                disp('     wrong input')
                disp(' ')
            end
            
        end
    else
        
        % Create new directory
        mkdir(fullname)
        addpath(fullname)
        
    end
end

disp('     Plotting data...')
% Get begg min and end max over all time series
% Get number of time series
numberOfTimeSeries = length(data.values);

% Loop over time series
for i=1:numberOfTimeSeries
    
    % Get timestamps
    timestamps=data.timestamps{i};
    
    begg=timestamps(1); % Start of time series
    endd=timestamps(end); % End of time series
    
    % Detect earliest start and latest end in the dataset
    if i == 1
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
    
end

% Figure setting
color = [0, 0.4, 0.8];
color_black = [0 0 0];


%% Create one single figure for data amplitude

FigHandle = figure('Name','Data amplitude','NumberTitle','off', ...
    'DefaultAxesPosition', [0.1, 0.17, 0.8, 0.8]);
set(FigHandle, 'Position', FigurePosition)
set(gcf,'color','w');
inc=0;

for i=1:numberOfTimeSeries
    subplot(numberOfTimeSeries,1, i )
    inc=inc+1;
    
    % get label
    label=data.labels{i};
    % get timestamps
    timestamps=data.timestamps{i};
    % get values
    values=data.values{i};
    full_val=values;
    % Percent of missing data (NaN)
    pos_isnan=find(isnan(values));
    nb_steps=length(timestamps);
    percent_missing=(length(pos_isnan)/nb_steps)*100;
    plot(timestamps, values, 'Color', color_black, 'LineWidth', Linewidth, ...
        'Marker', '.', 'MarkerSize',0.5, 'MarkerEdgeColor', color_black, ...
        'MarkerFacecolor', color_black)
    
    hold on
    text(0.075, 0.15, label, 'FontSize', 12, ...
        'HorizontalAlignment','center', 'Units', 'normalized', ...
        'BackgroundColor',[1. 1. 1.])
    
    text(0.925, 0.15, ...
        ['Missing data: ', num2str(percent_missing), '%'], ...
        'FontSize', 12, 'HorizontalAlignment','center', ...
        'Units', 'normalized', 'BackgroundColor',[1. 1. 1.])
    
    xlim([begg_min, endd_max])
    
    miny=min(full_val);
    maxy=max(full_val);
    
    ylim([miny, maxy ])
    
    set(gca,'XTick',linspace(begg_min,endd_max,ndivx), ...
        'YTick', linspace(miny, maxy, ndivy))
        
    set(gca,'FontSize',16)
    datetick('x','yy-mm','keepticks')
    
    if i == numberOfTimeSeries
        xlabel('Time [YY-MM]')
    else
        set(gca,'xticklabel',{[]})
    end
    
    %% Export figure in specified formats
    if isExportPDF || isExportPNG || isExportTEX
        filename='ALL_AMPLITUDES';
        exportPlot(filename, 'FilePath', fullname,  ...
            'isExportPDF', isExportPDF, ...
            'isExportPNG', isExportPNG, ...
            'isExportTEX', isExportTEX);
    end
end

%% Create one single figure for data timestep
FigHandle = figure('Name','Data timestep','NumberTitle','off', ...
    'DefaultAxesPosition', [0.1, 0.17, 0.8, 0.8]);

set(FigHandle, 'Position', FigurePosition)
set(gcf,'color','w');
inc=0;

for i=1:numberOfTimeSeries
    subplot(numberOfTimeSeries,1, i )
    inc=inc+1;
    
    % get label
    label=data.labels{i};
    
    % get timestamps
    timestamps=data.timestamps{i};
    
    timesteps = computeTimeSteps(timestamps);
    
    % compute reference (most frequent) time step
    [ReferenceTimestep]=defineReferenceTimeStep(timestamps);
    
    semilogy(timestamps,timesteps*24 , ...
        'Color', color, ...
        'Marker', 'o', 'LineStyle', 'none', 'Markersize', 2, ...
        'MarkerFaceColor', color )
    
    hold on
    text(0.075, 0.15, label, 'FontSize', 12, ...
        'HorizontalAlignment','center', 'Units', 'normalized', ...
        'BackgroundColor',[1. 1. 1.])
    
    text(0.92, 0.15, ...
        ['Reference timestep: ', num2str(ReferenceTimestep*24), ' hours'], ...
        'FontSize', 12, 'HorizontalAlignment','center', ...
        'Units', 'normalized', 'BackgroundColor',[1. 1. 1.])
    
    xlim([begg_min, endd_max])
    
    set(gca,'XTick',linspace(begg_min,endd_max,ndivx))
    
    set(gca,'FontSize',16)
    YTicks=([ 1 10 100 1000]);
    set(gca, 'YTick', YTicks)
    set(gca,'YTickLabel', ...
        cellstr(num2str(round(log10(YTicks(:))), '10^%d')))
    set(gca,'YMinorTick','off')
    datetick('x','yy-mm','keepticks')
    ylim([0.01 1000])
    if i == numberOfTimeSeries
        xlabel('Time [YY-MM]')
    else
        set(gca,'xticklabel',{[]})
    end
    
    %% Export figure in specified formats
    if isExportPDF || isExportPNG || isExportTEX
        filename='ALL_TIMESTEPS';
        exportPlot(filename, 'FilePath', fullname,  ...
            'isExportPDF', isExportPDF, ...
            'isExportPNG', isExportPNG, ...
            'isExportTEX', isExportTEX);
    end
    
end

%% Create one single figure for data availability

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
    exportPlot(filename, 'FilePath', fullname,  ...
        'isExportPDF', isExportPDF, ...
        'isExportPNG', isExportPNG, ...
        'isExportTEX', isExportTEX);
end
%--------------------END CODE ------------------------
end
