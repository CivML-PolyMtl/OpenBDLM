function [FigureNames] = plotKernelRegression(data, model, estimation, misc, varargin)
%PLOTKERNELREGRESSION Plot Kernel regression time series pattern
%
%   SYNOPSIS:
%     PLOTKERNELREGRESSION(data, model, estimation, misc, varargin)
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
%      Figure(s) on screen
%      If applicable, figure(s) saved in the location given by FilePath
%
%   DESCRIPTION:
%      PLOTKERNELREGRESSION plots dynamic regression hidden covariate
%      PLOTKERNELREGRESSION plots pattern x dynamic regression coefficient
%      The pattern
%
%   EXAMPLES:
%      PLOTKERNELREGRESSION(data, model, estimation, misc)
%      PLOTKERNELREGRESSION(data, model, estimation, misc, 'FilePath', 'figures')
%
%   EXTERNAL FUNCTIONS CALLED:
%      exportPlot
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also EXPORTPLOT, PLOTESTIMATIONS, PLOTPREDICTEDDATA,
%   PLOTHIDDENSTATES, PLOTMODELPROBABILITY

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
%       June 8, 2018

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

%% Read model parameter properties
% Current model parameters
idx_pvalues=size(model.param_properties,2)-1;
idx_pref= size(model.param_properties,2);

[arrayOut]=...
    readParameterProperties(model.param_properties, ...
    [idx_pvalues, idx_pref]);

parameter= arrayOut(:,1);
p_ref=arrayOut(:,2);

if isfield(model, 'ref')
    % Reference model parameters
    idx_pvalues=size(model.param_properties,2)-1;
    idx_pref= size(model.param_properties,2);
    
    [arrayOut]=...
        readParameterProperties(model.ref.param_properties, ...
        [idx_pvalues, idx_pref]);
    
    parameter_ref= arrayOut(:,1);
end



%% Create specified path if not existing
[isFileExist] = testFileExistence(FilePath, 'dir');
if ~isFileExist
    % create directory
    mkdir(FilePath)
    % set directory on path
    addpath(FilePath)
end

%% Get amplitude values to plot

% Get number of hidden states
numberOfHiddenStates = size(model.hidden_states_names{1},1);

% Get estimated hidden state valuesd (if applicable)
if isfield(estimation,'x')
    dataset_x=estimation.x; % mean estimated hidden states
    dataset_V=estimation.V; % posterior variance estimated hidden states
end

% Get true hidden state values
if isfield(estimation,'ref')
    dataset_x_ref = estimation.ref;
end

%% Define timestamp
% Get timestamps vector
timestamps=data.timestamps;

% Get reference timestep
[referenceTimestep]=defineReferenceTimeStep(timestamps);

% Compute timestep vector
[timesteps]=computeTimeSteps(timestamps);

% Define timestamp vector for main plot
plot_time_1=1:misc.subsample:length(timestamps);

% Define timestamp vector for secondary plot plot
if  misc.isSecondaryPlots
    
    time_fraction=0.641;
    plot_time_2=round(time_fraction*length(timestamps)): ...
        round(time_fraction*length(timestamps))+(14/referenceTimestep);
end


%% Define paramater for plot appeareance
% Get subplot parameter
if ~misc.isSecondaryPlots
    idx_supp_plot=1;
else
    idx_supp_plot=0;
end

% Define X-axis lag
Xaxis_lag=50;

% Define blue color for plots
BlueColor = [0, 0.4, 0.8];
pos=0;
for idx=1:numberOfHiddenStates
    if strncmpi(model.hidden_states_names{1}(idx,1),'x^{DH}',5)
        pos=pos+1;
                
        FigHandle = figure('DefaultAxesPosition', [0.1, 0.17, 0.8, 0.8]);
        set(FigHandle, 'Position', [100, 100, 1300, 270])
        subplot(1,3,1:2+idx_supp_plot,'align')
        
        %% Main plot
        if isfield(estimation, 'x')
            
            % Extract estimated pattern from control points
            y_DRHC = zeros(1,length(timestamps));
            for i=1:length(timestamps)
                M=model.C{1}(parameter(p_ref), ...
                    timestamps(i),timesteps(i));
                y_DRHC(i)=M(pos, contains ...
                    (model.hidden_states_names{1,1}(:,1),'x^{DH}'));
            end
            
            
            % Dynamic hidden state (dynamic regression coefficient*pattern)
            xpl=dataset_x(idx,plot_time_1).*y_DRHC(plot_time_1);
            spl=dataset_V(idx,plot_time_1).*(y_DRHC(plot_time_1).^2);
            
            mean_xpl=nanmean(xpl(round(0.05*length(xpl)):end));
            std_xpl=nanstd(xpl(round(0.05*length(xpl)):end));
            mean_spl=nanmean(sqrt(spl(round(0.05*length(xpl)):end)));
            mult_factor=6;
            
            miny=mean_xpl-mult_factor*(std_xpl+mean_spl);
            maxy=mean_xpl+mult_factor*(std_xpl+mean_spl);
            px=[timestamps(plot_time_1);
                flipud(timestamps(plot_time_1))]';
            py=[xpl-sqrt(spl) fliplr(xpl+sqrt(spl))];
            
            % Plot estimated posterior state variance values
            patch(px,py,'green','EdgeColor','none', ...
                'FaceColor','green','FaceAlpha',0.2);
            hold on
            % Plot estimated posterior state mean values
            plot(timestamps(plot_time_1),xpl, ...
                'k','Linewidth',misc.linewidth)
            
            set(gca,'XTick',linspace(timestamps(plot_time_1(1)), ...
                timestamps(plot_time_1(end)),misc.ndivx), ...
                'YTick',linspace(min(xpl),max(xpl),misc.ndivy), ...
                'box'  ,'off', 'Fontsize', 16);
            
            if isfield(estimation, 'ref')
                hold on
                y_DRHC_ref = zeros(1,length(timestamps));
                for i=1:length(timestamps)
                    M_ref=model.C{1}(parameter_ref(p_ref), ...
                        timestamps(i),timesteps(i));
                    y_DRHC_ref(i)=M_ref(pos, contains ...
                        (model.ref.hidden_states_names{1,1}(:,1),'x^{DH}'));
                end
                plot(timestamps(plot_time_1), ...
                    dataset_x_ref(plot_time_1,idx).*y_DRHC_ref(plot_time_1)','r--')                
                
            end
            
        else
            
            if isfield(estimation, 'ref')
                
                y_DRHC_ref = zeros(1,length(timestamps));
                for i=1:length(timestamps)
                    M_ref=model.C{1}(parameter_ref(p_ref),...
                        timestamps(i),timesteps(i));
                    y_DRHC_ref(i)=M_ref(pos, contains ...
                        (model.ref.hidden_states_names{1,1}(:,1),'x^{DH}'));
                end
                plot(timestamps(plot_time_1), ...
                    dataset_x_ref(plot_time_1,idx).*y_DRHC_ref(plot_time_1)', ...
                    'Color', BlueColor, 'LineWidth', misc.linewidth )
                
            end
            
        end
        
        ylabel(['$DRHC$ [' '$' ...
            model.hidden_states_names{1}{idx,3} ']$' ],'Interpreter','Latex')
        datetick('x','yy-mm','keepticks')
        xlabel('Time [YY-MM]')
        xlim([timestamps(1)-Xaxis_lag,timestamps(end)])
        hold off
        
        
        %% Secondary plots
        if misc.isSecondaryPlots
            subplot(1,3,3,'align')
            
            if isfield(estimation,'x')
                
                % Dynamic hidden state (dynamic regression coefficient)
                xpl=dataset_x(idx,plot_time_2).*y_DRHC(plot_time_2);
                spl=dataset_V(idx,plot_time_2).*(y_DRHC(plot_time_2).^2);
                
                mean_xpl=nanmean(xpl(round(0.05*length(xpl)):end));
                std_xpl=nanstd(xpl(round(0.05*length(xpl)):end));
                mean_spl=nanmean(sqrt(spl(round(0.05*length(xpl)):end)));
                mult_factor=6;
                
                miny=mean_xpl-mult_factor*(std_xpl+mean_spl);
                maxy=mean_xpl+mult_factor*(std_xpl+mean_spl);
                px=[timestamps(plot_time_2);
                    flipud(timestamps(plot_time_2))]';
                py=[xpl-sqrt(spl) fliplr(xpl+sqrt(spl))];
                
                
                % Plot estimated posterior state variance values
                patch(px,py,'green','EdgeColor','none', ...
                    'FaceColor','green','FaceAlpha',0.2);
                hold on
                % Plot estimated posterior state mean values
                plot(timestamps(plot_time_2),xpl,'k','Linewidth',misc.linewidth)                
                
                if isfield(estimation,'ref')
                    % Plot true values
                    hold on
                    plot(timestamps(plot_time_2), ...
                        dataset_x_ref(plot_time_2,idx).*y_DRHC_ref(plot_time_2)','r--')
                end
                
            else
                % Plot true values
                plot(timestamps(plot_time_2), ...
                    dataset_x_ref(plot_time_2,idx).*y_DRHC_ref(plot_time_2)', ...
                    'Color', BlueColor, 'LineWidth', misc.linewidth)
            end
                      
            set(gca,'XTick',linspace(timestamps(plot_time_2(1)), ...
                timestamps(plot_time_2(end)),misc.ndivx),...
                'box'  ,'off', ...
                'YTick', [], ...
                'FontSize', 16);            
            datetick('x','mm-dd','keepticks')
            year=datevec(timestamps(plot_time_2(1)));
            xlabel(['Time [' num2str(year(1)) '--MM-DD]'])
            hold off
            
        end
        
        %% Export plots
        if isExportPDF || isExportPNG || isExportTEX
            
            % Define the name of the figure
            match = [string('^'),string('{'),string('}'), string('x')];
            NameFigure = [ model.hidden_states_names{1}{idx,3}, '_', ...
                erase(model.hidden_states_names{1}{idx,1}, match)];
            
            % Record figure name
            FigureNames{idx} = NameFigure;
            
            
            % Export figure to location given by FilePath
            exportPlot(NameFigure, 'FilePath', FilePath,  ...
                'isExportPDF', isExportPDF, ...
                'isExportPNG', isExportPNG, ...
                'isExportTEX', isExportTEX);
        else
           FigureNames{1} = [];  
        end
    
    else
      FigureNames{1} = [];          
    end
end


%--------------------END CODE ------------------------
end
