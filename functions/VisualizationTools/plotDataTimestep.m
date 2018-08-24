function plotDataTimestep(data, misc, varargin)
%PLOTDATATIMESTEP Plot data timestep vector
%
%   SYNOPSIS:
%     PLOTDATATIMESTEP(data, misc, varargin)
%
%   INPUT:
%       data            - structure (required)
%                         data must contain three fields:
%
%                               'timestamps' is a M×1 array
%
%                               'values' is a MxN  array
%
%                               'labels' is a 1×N cell array
%                                each cell is a character array
%
%                                   N: number of time series
%                                   M: number of samples
%
%      misc             - structure (required)
%                           see the documentation for details about the
%                           field in misc
%
%      isExportPDF      - logical (optional)
%                         if isExportPDF, export the figure in PDF format
%                         default: false
%
%      isExportPNG      - logical (optional)
%                         if isExportPNG, export the figure in PNG format
%                         default: true
%
%      isExportTEX      - logical (optional)
%                         if isExportTEX, export the figure in TEX format
%                         default: false
%
%   OUTPUT:
%      N/A
%      Show up a figure on screen and eventually save it
%
%   DESCRIPTION:
%      PLOTDATATIMESTEP plots data timestep
%
%   EXAMPLES:
%      PLOTDATATIMESTEP(data, misc, 'isExportPDF', true)
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also PILOTEPLOT, PLOTDATA, PLOTDATASUMMARY

%   AUTHORS:
%      Ianis Gaudot, Luong Ha Nguyen,  James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.4.0.813654 (R2018a)
%
%   DATE CREATED:
%       August 24, 2018
%
%   DATE LAST UPDATE:
%       August 24, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultisExportPDF = false;
defaultisExportPNG = false;
defaultisExportTEX = false;

addRequired(p,'data', @isstruct );
addRequired(p,'misc', @isstruct );
addParameter(p,'isExportPDF', defaultisExportPDF,  @islogical);
addParameter(p,'isExportPNG', defaultisExportPNG,  @islogical);
addParameter(p,'isExportTEX', defaultisExportTEX,  @islogical);
parse(p,data, misc, varargin{:});

data=p.Results.data;
misc=p.Results.misc;
isExportPDF = p.Results.isExportPDF;
isExportPNG = p.Results.isExportPNG;
isExportTEX = p.Results.isExportTEX;

FigurePath=misc.FigurePath;

ProjectName=misc.ProjectName;

%% Get options from misc
FigurePosition=misc.options.FigurePosition;
isSecondaryPlot=misc.options.isSecondaryPlot;
Linewidth=misc.options.Linewidth;
ndivx = misc.options.ndivx;
ndivy = misc.options.ndivy;
Subsample = misc.options.Subsample;

%% Create specified path if not existing
[isFileExist] = testFileExistence(FigurePath, 'dir');
if ~isFileExist
    % create directory
    mkdir(FilePath)
    % set directory on path
    addpath(FilePath)
end

%% Create subdirectory where to save the figures

if isExportPNG || isExportPDF || isExportTEX
    
    fullPath = fullfile(FigurePath, ProjectName);
    [isFileExist] = testFileExistence(fullPath, 'dir');
    
    if ~isFileExist
        mkdir(fullPath)
        addpath(fullPath)
    end
    
end

%% Get amplitude values to plot

% Get timestamps vector
timestamps=data.timestamps;

% Compute timestep vector
[timesteps]=computeTimeSteps(timestamps);

% Get reference timestep
[referenceTimestep]=defineReferenceTimeStep(timestamps);

if  isSecondaryPlot
    % Define timestamp vector for secondary plot plot
    time_fraction=0.641;
    plot_time_2=round(time_fraction*length(timestamps)): ...
        round(time_fraction*length(timestamps))+(14/referenceTimestep);
end


%% Define paramater for plot appeareance

if ~isSecondaryPlot
    idx_supp_plot=1;
else
    idx_supp_plot=0;
end

%% Plot timestep
FigHandle = figure('DefaultAxesPosition', [0.1, 0.17, 0.8, 0.8]);
set(FigHandle, 'Position', FigurePosition)
subplot(1,3,1:2+idx_supp_plot,'align')

%% Main plot
semilogy(timestamps,timesteps*24 , ...
    'Marker', 'o', 'LineStyle', 'none', 'Markersize', 2, ...
    'Color', [0 0 0])

set(gca,'XTick',linspace(timestamps(1),timestamps(end),5));
set(gca,'FontSize',16)
YTicks=([ 1 10 100 1000]);
set(gca, 'YTick', YTicks)
set(gca,'YTickLabel', ...
    cellstr(num2str(round(log10(YTicks(:))), '10^%d')))
set(gca,'YMinorTick','off')
datetick('x','yy-mm','keepticks')
xlabel('Time [YY-MM]')
ylabel('Time step [hours]')
ylim([0.01 1000])

%% Secondary plot
if isSecondaryPlot
    subplot(1,3,3,'align')
    
    semilogy(timestamps(plot_time_2),timesteps(plot_time_2)*24 , ...
        'Marker', 'o', 'LineStyle', 'none', 'Markersize', 2, ...
        'Color', [0 0 0])
    
    set(gca,'XTick',linspace(timestamps(plot_time_2(1)), ...
        timestamps(plot_time_2(size(timestamps(plot_time_2),1))), ...
        ndivy), 'YTick', [], 'box','off', 'FontSize', 16);
    datetick('x','mm-dd','keepticks')
    year=datevec(timestamps(plot_time_2(1)));
    xlabel(['Time [' num2str(year(1)) '--MM-DD]'])
    ylim([0.01 1000])
    hold off
    
end

%% Export plots
if isExportPDF || isExportPNG || isExportTEX
    % Define the name of the figure
    NameFigure = ['TIMESTEP_', ProjectName ];
    
    % Export figure to TeX file in location given by fullPath
    exportPlot(NameFigure, 'FilePath', fullPath,  ...
        'isExportPDF', isExportPDF, ...
        'isExportPNG', isExportPNG, ...
        'isExportTEX', isExportTEX);
end

%--------------------END CODE ------------------------
end
