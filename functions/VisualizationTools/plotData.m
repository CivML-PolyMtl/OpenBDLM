function [FigureNames] = plotData(data, misc, varargin)
%PLOTDATA Plot data amplitude values and data timestep
%
%   SYNOPSIS:
%     PLOTDATA(data, misc, varargin)
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
%      isPlotTimestep   - logical (optional)
%                         if isPlotTimestep = true, plot timestep
%                         default = false
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
%      isVisible        - logical (optional)
%                         if isVisible = true, show figure on screen
%                         default: true
%
%      isForceOverwrite - logical (optional)
%                         if isForceOverwrite = true, save figure and
%                         overwrite previous files of same name without notice
%                         default = false
%
%   OUTPUT:
%
%     FigureNames       - cell array of character
%                        record name of the saved figures
%
%     Show up figures on screen and eventually save them
%
%   DESCRIPTION:
%      PLOTDATA plots OpenBDLM data
%
%   EXAMPLES:
%      PLOTDATA(data, misc)
%      PLOTDATA(data, misc, 'isPlotTimestep', true)
%
%   EXTERNAL FUNCTIONS CALLED:
%      M/A
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also PLOTDATASUMMARY, PLOTDATAAVAILABILITY, PLOTESTIMATIONS

%   AUTHORS:
%       Ianis Gaudot, Luong Ha Nguyen,  James-A Goulet,
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.4.0.813654 (R2018a)
%
%   DATE CREATED:
%       August 23, 2018
%
%   DATE LAST UPDATE:
%       January 4, 2019

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultisPlotTimestep =  false;
defaultisExportPDF = false;
defaultisExportPNG = true;
defaultisExportTEX = false;
defaultisVisible = true;
defaultisForceOverwrite = false;

addRequired(p,'data', @isstruct );
addRequired(p,'misc', @isstruct );
addParameter(p,'isPlotTimestep', defaultisPlotTimestep, @islogical );
addParameter(p,'isExportPDF', defaultisExportPDF,  @islogical);
addParameter(p,'isExportPNG', defaultisExportPNG,  @islogical);
addParameter(p,'isExportTEX', defaultisExportTEX,  @islogical);
addParameter(p,'isVisible', defaultisVisible,  @islogical);
addParameter(p,'isForceOverwrite', defaultisForceOverwrite, @islogical);
parse(p,data, misc, varargin{:});

data=p.Results.data;
misc=p.Results.misc;
isExportPDF = p.Results.isExportPDF;
isExportPNG = p.Results.isExportPNG;
isExportTEX = p.Results.isExportTEX;
isVisible = p.Results.isVisible;
isForceOverwrite = p.Results.isForceOverwrite;
isPlotTimestep = p.Results.isPlotTimestep;

FigurePath=misc.internalVars.FigurePath;

% Set fileID for logfile
if misc.internalVars.isQuiet
    % output message in logfile
    fileID=fopen(misc.internalVars.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end

if isVisible
    VisibleOption = 'on';
else
    VisibleOption = 'off';
end

%% Get options from misc
FigurePosition=misc.options.FigurePosition;
isSecondaryPlot=misc.options.isSecondaryPlot;
Linewidth=misc.options.Linewidth;
ndivx = misc.options.ndivx;
ndivy = misc.options.ndivy;
Subsample = misc.options.Subsample;
Xaxis_lag=misc.options.Xaxis_lag;

% Figure setting
color_black = [0 0 0];
color_red = [1 0 0];

%% Create subdirectory where to save the figures
if isExportPNG || isExportPDF || isExportTEX
    
    disp('     Creating figures for data ...')
    
    % Create specified path if not existing
    [isFileExist] = testFileExistence(FigurePath, 'dir');
    if ~isFileExist
        % create directory
        mkdir(FigurePath)
        % set directory on path
        addpath(FigurePath)
    end
    
    fullPath = fullfile(FigurePath, misc.ProjectName);
    [isFileExist] = testFileExistence(fullPath, 'dir');
    
    if isFileExist
        
        if ~isForceOverwrite
            disp(['     Directory ', fullPath,' already ', ...
                'exists. Merge and overwrite existing files ?'] );
            
            isYesNoCorrect = false;
            while ~isYesNoCorrect
                choice = input('     (y/n) >> ','s');
                if isempty(choice)
                    fprintf(fileID,'\n');
                    fprintf(fileID,['     wrong input --> please ', ...
                        ' make a choice\n']);
                    fprintf(fileID,'\n');
                elseif strcmpi(choice,'y') || strcmpi(choice,'yes')
                    
                    isYesNoCorrect =  true;
                    
                elseif strcmpi(choice,'n') || strcmpi(choice,'no')
                    
                    [name] = incrementFilename([misc.ProjectName, '_new'], ...
                        FigurePath);
                    fullPath=fullfile(FigurePath, name);
                    
                    % Create new directory
                    mkdir(fullPath)
                    addpath(fullPath)
                    
                    isYesNoCorrect =  true;
                    
                else
                    fprintf(fileID,'\n');
                    fprintf(fileID,'     wrong input\n');
                    fprintf(fileID,'\n');
                end
                
            end
            
        end
    else
        
        % Create new directory
        mkdir(fullPath)
        addpath(fullPath)
        
    end
    
end


%% Get amplitude values to plot

% Get number of time series
numberOfTimeSeries = size(data.values,2);

% Get observation amplitude values
DataValues = data.values;

% Get timestamps vector
timestamps=data.timestamps;

% Compute timestep vector
[timesteps]=computeTimeSteps(timestamps);

% Get reference timestep
[referenceTimestep]=defineReferenceTimeStep(timestamps);

% Define timestamp vector for main plot
plot_time_1=1:Subsample:length(timestamps);

if  isSecondaryPlot
    
    ZoomDuration = 14; % zoom duration in days
    
    if ZoomDuration/referenceTimestep >= 1
        % Define timestamp vector for secondary plot plot
        time_fraction=0.641;
        plot_time_2=round(time_fraction*length(timestamps)): ...
            round(time_fraction*length(timestamps))+ ...
            (ZoomDuration/referenceTimestep);
    else
        isSecondaryPlot = false;
    end
end

%% Define paramater for plot appeareance

if ~isSecondaryPlot
    idx_supp_plot=1;
else
    idx_supp_plot=0;
end

if isPlotTimestep
    FigureNames=cell(numberOfTimeSeries*2,1);
else
    FigureNames=cell(numberOfTimeSeries,1);
end

%% Plot data amplitude
for i=1:numberOfTimeSeries
    FigHandle = figure('DefaultAxesPosition', [0.1, 0.17, 0.8, 0.8]);
    set(FigHandle, 'Position', FigurePosition)
    set(FigHandle, 'Visible', VisibleOption)
    subplot(1,3,1:2+idx_supp_plot,'align')
    
    %% Main plot
    
    % Plot observation mean values
    %plot(timestamps(plot_time_1),DataValues(plot_time_1,i), ...
    %    'Linewidth',Linewidth, 'Color', [1 0 0])
    
    
    plot(timestamps(plot_time_1), DataValues(plot_time_1,i), ...
        'Color', color_red, ...
        'LineWidth', Linewidth, ...
        'Marker', '.', 'MarkerSize',0.5, ...
        'MarkerEdgeColor', color_red, ...
        'MarkerFacecolor', color_red)
    
    
    miny=min(DataValues(plot_time_1,i));
    maxy=max(DataValues(plot_time_1,i));
    ylim([miny, maxy ])
    set(gca,'XTick',linspace(timestamps(plot_time_1(1)), ...
        timestamps(plot_time_1(size(timestamps(plot_time_1),1))),ndivx),...
        'YTick', linspace(miny, maxy, ndivy), ...
        'box','off', 'FontSize', 16);
    if miny~=maxy
        set(gca,'Ylim',[miny,maxy])
    end
    ax=gca;
    ax.YAxis.TickLabelFormat='%.1f';
    datetick('x','yy-mm','keepticks')
    xlabel('Time [YY-MM]')
    ylabel(data.labels{i})
    xlim([timestamps(1)-Xaxis_lag,timestamps(end)])
    hold off
    
    %% Secondary plot
    if isSecondaryPlot
        subplot(1,3,3,'align')
        
        % Plot observation mean values
        % plot(timestamps(plot_time_2),DataValues(plot_time_2,i), ...
        %     'Linewidth',Linewidth, 'Color', [1 0 0] )
               
        plot(timestamps(plot_time_2), DataValues(plot_time_2,i), ...
            'Color', color_red, ...
            'LineWidth', Linewidth, ...
            'Marker', '.', 'MarkerSize',0.5, ...
            'MarkerEdgeColor', color_red, ...
            'MarkerFacecolor', color_red)
        
        
        set(gca,'XTick',linspace(timestamps(plot_time_2(1)), ...
            timestamps(plot_time_2(size(timestamps(plot_time_2),1))), ...
            3), 'YTick', [], 'box','off', 'FontSize', 16);
        ax=gca;
        ax.YAxis.TickLabelFormat='%.1f';
        datetick('x','mm-dd','keepticks')
        year=datevec(timestamps(plot_time_2(1)));
        xlabel(['Time [' num2str(year(1)) '--MM-DD]'])
        hold off
        
    end
    
    %% Export plots
    if isExportPDF || isExportPNG || isExportTEX
        % Define the name of the figure
        NameFigure = [data.labels{i}, '_Amplitude' ];
        
        % Record Figure Name
        FigureNames{i} = NameFigure;
        
        % Export figure to TeX file in location given by fullPath
        exportPlot(NameFigure, 'FilePath', fullPath,  ...
            'isExportPDF', isExportPDF, ...
            'isExportPNG', isExportPNG, ...
            'isExportTEX', isExportTEX);
    else
        FigureNames{1} = [];
    end
    
    if ~isVisible
        close(FigHandle)
    end
    
    
end



if isPlotTimestep
    %% Plot data timestep
    
    for i=1:numberOfTimeSeries
        FigHandle = figure('DefaultAxesPosition', [0.1, 0.17, 0.8, 0.8]);
        set(FigHandle, 'Position', FigurePosition)
        set(FigHandle, 'Visible', VisibleOption)
        subplot(1,3,1:2+idx_supp_plot,'align')
        
        %% Main plot
        semilogy(timestamps,timesteps*24 , ...
            'Marker', 'o', 'LineStyle', 'none', 'Markersize', 6, ...
            'Color', [0 0 0], 'MarkerFaceColor',[0 0 0])
        
        set(gca,'XTick',linspace(timestamps(plot_time_1(1)), ...
            timestamps(plot_time_1(size(timestamps(plot_time_1),1))),ndivx),...
            'box','off', 'FontSize', 16);
        set(gca,'FontSize',16)
        YTicks=([ 1 10 100 1000]);
        set(gca, 'YTick', YTicks)
        set(gca,'YTickLabel', ...
            cellstr(num2str(round(log10(YTicks(:))), '10^%d')))
        set(gca,'YMinorTick','off')
        datetick('x','yy-mm','keepticks')
        xlabel('Time [YY-MM]')
        ylabel(data.labels{i})
        ylim([0.01 1000])
        
        %% Secondary plot
        if isSecondaryPlot
            subplot(1,3,3,'align')
            
            semilogy(timestamps(plot_time_2),timesteps(plot_time_2)*24 , ...
                'Marker', 'o', 'LineStyle', 'none', 'Markersize', 6, ...
                'Color', [0 0 0], 'MarkerFaceColor',[0 0 0])
            
            set(gca,'XTick',linspace(timestamps(plot_time_2(1)), ...
                timestamps(plot_time_2(size(timestamps(plot_time_2),1))), ...
                3), 'YTick', [], 'box','off', 'FontSize', 16);
            datetick('x','mm-dd','keepticks')
            year=datevec(timestamps(plot_time_2(1)));
            xlabel(['Time [' num2str(year(1)) '--MM-DD]'])
            ylim([0.01 1000])
            hold off
            
        end
        
        %% Export plots
        if isExportPDF || isExportPNG || isExportTEX
            % Define the name of the figure
            NameFigure = [data.labels{i}, '_Timesteps' ];
            
            % Record Figure Name
            FigureNames{i+numberOfTimeSeries} = NameFigure;
            
            % Export figure to TeX file in location given by fullPath
            exportPlot(NameFigure, 'FilePath', fullPath,  ...
                'isExportPDF', isExportPDF, ...
                'isExportPNG', isExportPNG, ...
                'isExportTEX', isExportTEX);
        else
            FigureNames{1} = [];
        end
        
        
        if ~isVisible
            close(FigHandle)
        end
        
    end
    
end

if isExportPNG || isExportPDF || isExportTEX
    fprintf(fileID,'\n');
    fprintf(fileID,'     Figures saved in %s.\n', fullPath);
    fprintf(fileID,'\n');
end

%--------------------END CODE ------------------------
end
