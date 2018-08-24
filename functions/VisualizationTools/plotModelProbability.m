function [FigureNames] = plotModelProbability(data, model, estimation, misc, varargin)
%PLOTMODELPROBABILITY Plot true and estimated model probability
%
%   SYNOPSIS:
%     PLOTMODELPROBABILITY(data, model, estimation, misc, varargin)
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
%                         record name of the saved figures
%
%      Figure(s) on screen
%      If applicable, figure(s) saved in the location given by FilePath
%
%   DESCRIPTION:
%      PLOTMODELPROBABILITY plots true and estimated model probability.
%
%   EXAMPLES:
%      PLOTMODELPROBABILITY((data, model, estimation, misc)
%      PLOTMODELPROBABILITY((data, model, estimation, misc, 'FilePath', 'figures')
%
%   EXTERNAL FUNCTIONS CALLED:
%      exportPlots
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also EXPORTPLOTS, PLOTESTIMATIONS, PLOTHIDDENSTATES,
%   PLOTPREDICTEDDATA

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
%       June 6, 2018
%
%   DATE LAST UPDATE:
%       August 22, 2018

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
addParameter(p,'isExportPDF', defaultisExportPDF,  @islogical);
addParameter(p,'isExportPNG', defaultisExportPNG,  @islogical);
addParameter(p,'isExportTEX', defaultisExportTEX,  @islogical);
addParameter(p, 'FilePath', defaultFilePath, validationFonction)
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
Subsample=misc.options.Subsample;

%% Remove space in filename
%FilePath = FilePath(~isspace(FilePath));

%% Create specified path if not existing
[isFileExist] = testFileExistence(FilePath, 'dir');
if ~isFileExist
    % create directory
    mkdir(FilePath)
    % set directory on path
    addpath(FilePath)
end

% Do not plot model probability in case of one model
if model.nb_class == 1
    FigureNames{1} = [];
    return
end


%% Get amplitude values to plot

% Get estimated hidden state valuesd (if applicable)
if isfield(estimation,'x')
    % Get estimated hidden state if applicable
    if isfield(estimation,'x')
        Pr_M=estimation.S;      % posterior probability of models
    end
end

% Get true hidden state values
if isfield(estimation,'ref')
    dataset_x_ref = estimation.ref(:,end);
end

% Define blue color for plots
BlueColor = [0, 0.4, 0.8];

%% Define timestamp

% Get timestamps vector
timestamps=data.timestamps;
% Get reference timestep
[referenceTimestep]=defineReferenceTimeStep(timestamps);

% Define timestamp vector for main plot
plot_time_1=1:Subsample:length(timestamps);

% Define timestamp vector for secondary plot plot
if  isSecondaryPlot
    
    time_fraction=0.641;
    plot_time_2=round(time_fraction*length(timestamps)): ...
        round(time_fraction*length(timestamps))+(14/referenceTimestep);
end

%% Define paramater for plot appeareance
% Get subplot parameter
if ~isSecondaryPlot
    idx_supp_plot=1;
else
    idx_supp_plot=0;
end

% Define X-axis lag
Xaxis_lag=50;


%% Plot model probability

%% Main plot

FigHandle = figure('DefaultAxesPosition', [0.1, 0.17, 0.8, 0.8]);
set(FigHandle, 'Position', FigurePosition)
subplot(1,3,1:2+idx_supp_plot,'align')

if isfield(estimation,'x')
    % Plot estimated values
    plot(timestamps(plot_time_1),Pr_M(plot_time_1,2), ...
        'color',[1 0.0 0],'Linewidth',Linewidth*2)
    hold on
    if isfield(estimation,'ref')
        % Plot true values
        plot(timestamps(plot_time_1), ...
            1-dataset_x_ref(plot_time_1, end),'--r')
    end
    
else
    % Plot true values
    plot(timestamps(plot_time_1),1-dataset_x_ref(plot_time_1, end), ...
        'Color', BlueColor, 'LineWidth', Linewidth)
end

set(gca,'XTick',linspace(timestamps(plot_time_1(1)), ...
    timestamps(plot_time_1(size(timestamps(plot_time_1),1))), ...
    ndivx),...
    'YTick',[0 0.5 1],...
    'box' ,'off', 'Fontsize', 16);
datetick('x','yy-mm','keepticks')
xlabel('Time [YY-MM]')
ylabel('$Pr(S=M_2)$ ','Interpreter','Latex')
xlim([timestamps(1)-Xaxis_lag,timestamps(end)])
ylim([0,1])
hold off


%% Secondary plots
if isSecondaryPlot
    subplot(1,3,3,'align')
    
    if isfield(estimation,'x')
        
        % Plot estimated values
        plot(timestamps(plot_time_2),Pr_M(plot_time_2,2), ...
            'color',[1 0.0 0],'Linewidth',Linewidth*2)
        hold on
        
        if isfield(estimation,'ref')
            % Plot true values
            plot(timestamps(plot_time_2), ...
                1-dataset_x_ref(plot_time_2,end), '--r')
        end
        
        
    else
        % Plot true values
        plot(timestamps(plot_time_2),1-dataset_x_ref(plot_time_2,end), ...
            'Color', BlueColor, 'LineWidth', Linewidth )
    end
    
    
    set(gca,'XTick',linspace(timestamps(plot_time_2(1)), ...
        timestamps(plot_time_2(size(timestamps(plot_time_2),1))), ...
        ndivy),...
        'YTick', [], ...
        'box', 'off', 'Fontsize', 16);
    datetick('x','mm-dd','keepticks')
    year=datevec(timestamps(plot_time_2(1)));
    xlabel(['Time [' num2str(year(1)) '--MM-DD]'])
    hold off
    ylim([0,1])

end


%% Export plots
if isExportPDF || isExportPNG || isExportTEX
    
    % Define the name of the figure
    NameFigure =  'ModelProbability';
    
    % Record Figure Name
    FigureNames{1} = NameFigure;
    
    % Export figure to location given by FilePath
    exportPlot(NameFigure, 'FilePath', FilePath,  ...
        'isExportPDF', isExportPDF, ...
        'isExportPNG', isExportPNG, ...
        'isExportTEX', isExportTEX);
else
   FigureNames{1} = []; 
end


end


%--------------------END CODE ------------------------
