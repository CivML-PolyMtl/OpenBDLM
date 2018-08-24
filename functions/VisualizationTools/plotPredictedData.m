function [FigureNames] = plotPredictedData(data, model, estimation, misc, varargin)
%PLOTPREDICTEDDATA Plot observed and predicted data
%   SYNOPSIS:
%     PLOTPREDICTEDDATA(data, model, estimation, misc, varargin)
%
%   INPUT:
%      data             - structure (required)
%                         see documentation for details about the fields of
%                         data
%
%      model            - structure (required)
%                         see documentation for details about the fields of
%                         model
%
%      estimation       - structure (required)
%                         see documentation for details about the fields of
%                         estimation
%
%      misc             - structure (required)
%                         see documentation for details about the fields of
%                         misc
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
%      FilePath         - character (optional)
%                         directory where to save the file
%                         default: '.'  (current folder)
%
%   OUTPUT:
%      FigureNames      - cell array of character
%                        record name of the saved figures
%
%      Figure(s) on screen
%      If applicable, figure(s) saved in the location given by FilePath.
%
%   DESCRIPTION:
%      PLOTPREDICTEDDATA plot observed and predicted data
%
%   EXAMPLES:
%      PLOTPREDICTEDDATA(data, model, estimation, misc)
%      PLOTPREDICTEDDATA(data, model, estimation, misc, 'FilePath', 'figures')
%
%   EXTERNAL FUNCTIONS CALLED:
%      exportPlot
%
%   See also EXPORTPLOT, PLOTESTIMATIONS

%   AUTHORS:
%       Luong Ha Nguyen, Ianis Gaudot, James-A Goulet,
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       June 5, 2018
%
%   DATE LAST UPDATE:
%       July 25, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultFilePath = '.';
defaultisExportPDF = false;
defaultisExportPNG = true;
defaultisExportTEX = false;

validationFonction = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'estimation', @isstruct );
addRequired(p,'misc', @isstruct );
addParameter(p, 'FilePath', defaultFilePath, validationFonction)
addParameter(p,'isExportPDF', defaultisExportPDF,  @islogical);
addParameter(p,'isExportPNG', defaultisExportPNG,  @islogical);
addParameter(p,'isExportTEX', defaultisExportTEX,  @islogical);
parse(p,data, model, estimation, misc, varargin{:});

data=p.Results.data;
model=p.Results.model;
estimation=p.Results.estimation;
misc=p.Results.misc;
isExportPDF = p.Results.isExportPDF;
isExportPNG = p.Results.isExportPNG;
isExportTEX = p.Results.isExportTEX;
FilePath=p.Results.FilePath;

%% Get options from misc
FigurePosition=misc.options.FigurePosition;
isSecondaryPlot=misc.options.isSecondaryPlot;
Linewidth=misc.options.Linewidth;
ndivx = misc.options.ndivx;
ndivy = misc.options.ndivy;
Subsample = misc.options.Subsample;

%% Read model parameter properties
idx_pvalues=size(model.param_properties,2)-1;
idx_pref= size(model.param_properties,2);

[arrayOut]=...
    readParameterProperties(model.param_properties, [idx_pvalues, idx_pref]);

parameter= arrayOut(:,1);

%% Create specified path if not existing
[isFileExist] = testFileExistence(FilePath, 'dir');
if ~isFileExist
    % create directory
    mkdir(FilePath)
    % set directory on path
    addpath(FilePath)
end

%% Get amplitude values to plot

% Get number of time series
numberOfTimeSeries = size(data.values,2);

% Get observation amplitude values
DataValues = data.values;

% Get predicted data amplitude value
if isfield(estimation, 'y')
    dataset_y=estimation.y;
    dataset_Vy=estimation.Vy;
end

%% Define timestamps

% Get timestamps vector
timestamps=data.timestamps;

% Get reference timestep
[referenceTimestep]=defineReferenceTimeStep(timestamps);

% Compute timestep vector
[timesteps]=computeTimeSteps(timestamps);

% Define timestamp vector for main plot
plot_time_1=1:Subsample:length(timestamps);

if  isSecondaryPlot
    % Define timestamp vector for secondary plot plot
    time_fraction=0.641;
    plot_time_2=round(time_fraction*length(timestamps)): ...
        round(time_fraction*length(timestamps))+(14/referenceTimestep);
end

%% Define paramater for plot appeareance
% Define X-axis lag
Xaxis_lag=50;

if ~isSecondaryPlot
    idx_supp_plot=1;
else
    idx_supp_plot=0;
end
% Define blue color for plots
BlueColor = [0, 0.4, 0.8];


%% Plot observation & predicted data
for i=1:numberOfTimeSeries
    FigHandle = figure('DefaultAxesPosition', [0.1, 0.17, 0.8, 0.8]);
    set(FigHandle, 'Position', FigurePosition)
    subplot(1,3,1:2+idx_supp_plot,'align')
    
    % Observations
    ypl=DataValues(plot_time_1,i)';
    sv = sqrt(model.R{1}(parameter,timestamps(1),timesteps(1)));
    psy=[ypl-sv(i,i), fliplr(ypl+sv(i,i))];
    
    %% Main plot
    
    if isfield(estimation, 'y')
        
        px=[timestamps(plot_time_1); flipud(timestamps(plot_time_1))]';
        
        % Plot observations
        % Plot observation noise variance values
        patch(px,psy,'red','EdgeColor','none','FaceColor','red', ...
            'FaceAlpha',0.2);
        hold on
        % Plot observation mean values
        plot(timestamps(plot_time_1),DataValues(plot_time_1,i), ...
            '-r','Linewidth',Linewidth)
        
        % Predictions
        xpl=dataset_y(i,plot_time_1);
        spl=dataset_Vy(i,plot_time_1);
        
        py=[xpl-sqrt(spl), fliplr(xpl+sqrt(spl))];
        
        mean_xpl=mean(xpl(round(0.25*length(xpl)):end));
        std_xpl=std(xpl(round(0.25*length(xpl)):end));
        mult_factor=5;
        miny=mean_xpl-mult_factor*std_xpl;
        maxy=mean_xpl+mult_factor*std_xpl;
        
        % Plot predicted data
        % Plot predicted data variance values
        patch(px,py,'green','EdgeColor','none','FaceColor','green', ...
            'FaceAlpha',0.2);
        % Plot predicted data mean values
        plot(timestamps(plot_time_1),xpl,'k','Linewidth',Linewidth)
        
        if ~misc.isSmoother
            h=legend('$y_{t}\pm \sigma_V$', ...
                '$y_{t}$','$E[Y_t|y_{1:t}]\pm\sigma_E[Y_t|y_{1:t}]$',  ...
                '$E[Y_t|y_{1:t}]$');
        else
            h=legend('$y_{t}\pm \sigma_V$', ...
                '$y_{t}$','$E[Y_t|y_{1:T}]\pm\sigma_E[Y_t|y_{1:T}]$', ...
                '$E[Y_t|y_{1:T}]$');
        end
        set(h,'Interpreter','Latex')
        PatchInLegend = findobj(h, 'type', 'patch');
        set(PatchInLegend, 'facea', 0.5)
        
    else
        
        % Plot observation mean values
        plot(timestamps(plot_time_1),DataValues(plot_time_1,i), ...
            'Color', BlueColor ,'Linewidth',Linewidth)
        
        miny=min(DataValues(plot_time_1,i));
        maxy=max(DataValues(plot_time_1,i));
        
    end
    
    
    set(gca,'XTick',linspace(timestamps(plot_time_1(1)), ...
        timestamps(plot_time_1(size(timestamps(plot_time_1),1))),ndivx),...
        'box','off',  ...
        'FontSize', 16);
    if miny~=maxy
        set(gca,'Ylim',[miny,maxy])
    end
    datetick('x','yy-mm','keepticks')
    xlabel('Time [YY-MM]')
    ylabel(data.labels{i})
    xlim([timestamps(1)-Xaxis_lag,timestamps(end)])
    hold off
    
    %% Secondary plot
    if isSecondaryPlot
        subplot(1,3,3,'align')
        
        if isfield(estimation, 'y')
            
            xpl=dataset_y(i,plot_time_2);
            spl=dataset_Vy(i,plot_time_2);
            
            px=[timestamps(plot_time_2); flipud(timestamps(plot_time_2))]';
            py=[xpl-sqrt(spl), fliplr(xpl+sqrt(spl))];
            
            psy=[DataValues(plot_time_2,i)'-sv(i,i), ...
                fliplr(DataValues(plot_time_2,i)'+sv(i,i))];
            
            % Plot observations
            % Plot observation noise variance values
            patch(px,psy,'red','EdgeColor','none','FaceColor','red', ...
                'FaceAlpha',0.2);
            hold on
            % Plot observation mean values
            plot(timestamps(plot_time_2),DataValues(plot_time_2,i),'-r')
            
            % Plot predicted data
            % Plot predicted data variance values
            patch(px,py,'green','EdgeColor','none','FaceColor','green', ...
                'FaceAlpha',0.2);
            % Plot predicted data mean values
            plot(timestamps(plot_time_2),xpl,'k','Linewidth',Linewidth)
        else
            
            % Plot observation mean values
            plot(timestamps(plot_time_2),DataValues(plot_time_2,i),...
                'Color', BlueColor )
            
        end
        
        set(gca,'XTick',linspace(timestamps(plot_time_2(1)), ...
            timestamps(plot_time_2(size(timestamps(plot_time_2),1))), ...
            ndivy),...
            'YTick', [], ...
            'box','off', ...
            'FontSize', 16);
        datetick('x','mm-dd','keepticks')
        year=datevec(timestamps(plot_time_2(1)));
        xlabel(['Time [' num2str(year(1)) '--MM-DD]'])
        hold off
        
    end
    
    %% Export plots
    if isExportPDF || isExportPNG || isExportTEX
        % Define the name of the figure
        NameFigure = [data.labels{i}, '_ObservedPredicted' ];
        
        % Record Figure Name
        FigureNames{i} = NameFigure;
        
        % Export figure to TeX file in location given by FilePath
        exportPlot(NameFigure, 'FilePath', FilePath,  ...
            'isExportPDF', isExportPDF, ...
            'isExportPNG', isExportPNG, ...
            'isExportTEX', isExportTEX);
    else
        FigureNames{1} = [];
    end
    
end
%--------------------END CODE ------------------------
end
