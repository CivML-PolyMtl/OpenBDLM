function [FigureNames] = plotStaticKernelRegression(data, model, estimation, misc, varargin)
%PLOTSTATICKERNELREGRESSION Plot static kernel regression patterns
%
%   SYNOPSIS:
%     PLOTSTATICKERNELREGRESSION(data, model, estimation, misc, varargin)
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
%                        see documentation for details about the fields of
%                        estimation
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
%      PLOTSTATICKERNELREGRESSION plots static regression time series
%
%   EXAMPLES:
%      PLOTSTATICKERNELREGRESSION(data, model, estimation, misc)
%      PLOTSTATICKERNELREGRESSION(data, model, estimation, misc, 'FilePath', 'figures')
%
%   EXTERNAL FUNCTIONS CALLED:
%      exportPlot
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also EXPORTPLOT, PLOTESTIMATIONS, PLOTPREDICTEDDATA,
%   PLOTHIDDENSTATES, PLOTMODELPROBABILITY, PLOTDYNAMICREGRESSION

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

%% Create specified path if not existing
[isFileExist] = testFileExistence(FilePath, 'dir');
if ~isFileExist
    % create directory
    mkdir(FilePath)
    % set directory on path
    addpath(FilePath)
end

%% Define timestamp
% Get timestamps vector
timestamps=data.timestamps;

% Get reference timestep
[referenceTimestep]=defineReferenceTimeStep(timestamps);

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

% Get number of time series
numberOfTimeSeries = length(data.labels);

%% Plot static kernel regression hidden states for each time series
% Loop over time series
for obs=1:numberOfTimeSeries
    
    % Get data labels
    labels=data.labels{obs};
    
    % Get hidden states associated to this observation
    TestNameHiddenStates = ...
        strfind(model.hidden_states_names{1}(:,3), labels);
    IndexNameHiddenStates = ...
        find(not(cellfun('isempty', TestNameHiddenStates )));
    
    hidden_states_names_sub =  ...
        model.hidden_states_names{1}(IndexNameHiddenStates,:);
    
    % Get parameters associated to this observation
    
    strs=model.param_properties(:,4);
    strs(cellfun('isempty',strs)) = [];
    
    TestNameParameters = ...
        strfind(strs, labels);
    IndexNameParameters = ...
        find(not(cellfun('isempty',  TestNameParameters)));
    
    % Get parameter properties
    param_properties_sub =  model.param_properties(IndexNameParameters,:);
    
    % Get estimated current parameter values
    parameter_sub = model.parameter(IndexNameParameters,:);
    
    if isfield(estimation, 'ref')
    % Get true parameter values
        parameter_ref_sub = model.ref.parameter(IndexNameParameters,:);
    end
    
    %% Get amplitude values to plot
    % Estimated hidden states values
    if isfield(estimation, 'x')
        % mean values
        estimation_x_sub = estimation.x_M{1,1}(IndexNameHiddenStates,:);
        % variance value
        estimation_V_sub = ...
            estimation.V_M{1,1}(IndexNameHiddenStates,IndexNameHiddenStates,:);
    end
    
    if isfield(estimation, 'ref')
        estimation_ref_sub = estimation.ref(:,IndexNameHiddenStates);
    end
    
    numberOfHiddenStates_sub = size(hidden_states_names_sub,1);
    
    for idx=1:numberOfHiddenStates_sub
        if and(strncmpi(hidden_states_names_sub(idx,1),'x^{SK',5), ...
                ~strcmp(hidden_states_names_sub(idx,1),'x^{SK1}'))
            Kernel_regression='SK';
            break
            
        else
            FigureNames{obs} = [];
            Kernel_regression=[];
        end
    end
       
    
    if isempty(Kernel_regression)
        continue
    end
    
    
    % Get model parameters index corresponding to static kernel regression
    K_p_idx=[];
    K_idx=[];
    for i=1:size(param_properties_sub,1)
        if strcmp(param_properties_sub(i,2),Kernel_regression)
            K_idx=[K_idx i];
            if strcmp(param_properties_sub(i,1),'p')
                K_p_idx=[K_p_idx i];
            end
        end
    end
    
    % Get hidden states index corresponding to static kernel regression
    K_x_idx=[];
    for i=1:size(hidden_states_names_sub,1)
        if strncmpi(hidden_states_names_sub(i,1),['x^{' Kernel_regression],5)
            K_x_idx=[K_x_idx i];
        end
    end
    
    FigHandle = figure('DefaultAxesPosition', [0.1, 0.17, 0.8, 0.8]);
    set(FigHandle, 'Position', [100, 100, 1300, 270])
    subplot(1,3,1:2+idx_supp_plot,'align')
    
    xpl=zeros(1,length(plot_time_1));
    spl=zeros(1,length(plot_time_1));
    
    %% Main plot
    if isfield(estimation,'x')
        
        p_KRHC=parameter_sub(1:length(parameter_sub));
        p_KRHC=p_KRHC(K_idx(2:end));
        
        % Plot estimated values
        for i=plot_time_1
            CP=estimation_x_sub(K_x_idx,i)'; % mean
            CPS=estimation_V_sub(K_x_idx,K_x_idx,i)'; % variance
            
            if strcmp(Kernel_regression,'SK')
                k=Static_kernel_component(p_KRHC,timestamps(i), ...
                    timestamps(1),model.components.nb_SK_p);
            end
            xpl(i)=CP*k';
            spl(i)=k*CPS*k';
        end
        mean_xpl=mean(xpl(round(0.25*length(xpl)):end));
        std_xpl=std(xpl(round(0.25*length(xpl)):end));
        mult_factor=3;
        miny=mean_xpl-mult_factor*std_xpl;
        maxy=mean_xpl+mult_factor*std_xpl;
        
        px=[timestamps(plot_time_1); flipud(timestamps(plot_time_1))]';
        py=[xpl-sqrt(spl), fliplr(xpl+sqrt(spl))];
        patch(px,py,'green','EdgeColor','none', ...
            'FaceColor','green','FaceAlpha',0.2);
        hold on
        plot(timestamps(plot_time_1),xpl,'k','Linewidth',misc.linewidth)
        hold on
        
        % Plot true values
        if isfield(estimation,'ref')
            
            p_KRHC_ref=parameter_ref_sub(1:length(parameter_ref_sub));
            p_KRHC_ref=p_KRHC_ref(K_idx(2:end));
            
            for i=plot_time_1
                CP=estimation_ref_sub(i,K_x_idx);
                if strcmp(Kernel_regression,'SK')
                    k=Static_kernel_component(p_KRHC_ref,timestamps(i), ...
                        timestamps(1),model.ref.components.nb_SK_p);
                end
                xpl(i)=CP*k';
            end
            plot(timestamps(plot_time_1),xpl,'--r')
            
        end
        
    else
        
        % Plot true values
        p_KRHC_ref=parameter_ref_sub(1:length(parameter_ref_sub));
        p_KRHC_ref=p_KRHC_ref(K_idx(2:end));
        
        for i=plot_time_1
            CP=estimation_ref_sub(i,K_x_idx);
            k=Static_kernel_component(p_KRHC_ref,timestamps(i), ...
                timestamps(1),model.ref.components.nb_SK_p);
            xpl(i)=CP*k';
        end
        plot(timestamps(plot_time_1),xpl,'Color', BlueColor,  ...
            'LineWidth', misc.linewidth)
    end
    
    set(gca,'XTick' ,linspace(timestamps(plot_time_1(1)), ...
        timestamps(plot_time_1(size(timestamps(plot_time_1),1))), ...
        misc.ndivx),...
        'YTick'            ,linspace(min(xpl),max(xpl),misc.ndivy),...
        'Ylim'             ,[min(xpl),max(xpl)],...
        'box'              ,'off', 'Fontsize', 16);
    datetick('x','yy-mm','keepticks')
    xlabel('Time [YY-MM]')
    ylabel(['SK component', ' [', labels ,']'], 'Interpreter','Latex')
    xlim([timestamps(1)-Xaxis_lag,timestamps(end)])
    hold off
    
    %% Secondary plots
    if misc.isSecondaryPlots
        subplot(1,3,3,'align')
        
        xpl=zeros(1,length(plot_time_2));
        spl=zeros(1,length(plot_time_2));
        
        % Plot estimated values
        if isfield(estimation,'x')
            
            pos=0;
            for i=plot_time_2
                pos=pos+1;
                CP=estimation_x_sub(K_x_idx,i)'; % posterior mean
                CPS=estimation_V_sub(K_x_idx,K_x_idx,i)'; % posterior variance
                k=Static_kernel_component(p_KRHC,timestamps(i), ...
                    timestamps(1),model.components.nb_SK_p);
                xpl(pos)=CP*k';
                spl(pos)=k*CPS*k';
            end
            mean_xpl=mean(xpl(round(0.25*length(xpl)):end));
            std_xpl=std(xpl(round(0.25*length(xpl)):end));
            mult_factor=3;
            miny=mean_xpl-mult_factor*std_xpl;
            maxy=mean_xpl+mult_factor*std_xpl;
            
            px=[timestamps(plot_time_2); flipud(timestamps(plot_time_2))]';
            py=[xpl-sqrt(spl), fliplr(xpl+sqrt(spl))];
            patch(px,py,'green','EdgeColor','none', ...
                'FaceColor','green','FaceAlpha',0.2);
            hold on
            plot(timestamps(plot_time_2),xpl,'k','Linewidth',misc.linewidth)
            hold on
            
            % Plot true values
            if isfield(estimation,'ref')
                
                pos=0;
                for i=plot_time_2
                    pos=pos+1;
                    CP=estimation_ref_sub(i,K_x_idx);
                    k=Static_kernel_component(p_KRHC_ref,timestamps(i), ...
                        timestamps(1),model.ref.components.nb_SK_p);
                    xpl(pos)=CP*k';
                end
                plot(timestamps(plot_time_2),xpl,'--r')
            end
            
        else
            
            % Plot true values
            pos=0;
            for i=plot_time_2
                pos=pos+1;
                CP=estimation_ref_sub(i,K_x_idx);
                k=Static_kernel_component(p_KRHC_ref,timestamps(i), ...
                    timestamps(1),model.ref.components.nb_SK_p);
                xpl(pos)=CP*k';
            end
            plot(timestamps(plot_time_2),xpl,'Color', BlueColor,  ...
                'LineWidth', misc.linewidth)
            
        end
               
        set(gca,'XTick',linspace(timestamps(plot_time_2(1)), ...
            timestamps(plot_time_2(end)),misc.ndivx),...
            'box'  ,'off', ...
            'YTick', [], ...
            'Fontsize', 16);
        datetick('x','mm-dd','keepticks')
        year=datevec(timestamps(plot_time_2(1)));
        xlabel(['Time [' num2str(year(1)) '--MM-DD]'])
        hold off
    end
    
    %% Export plots
    if isExportPDF || isExportPNG || isExportTEX
        
        NameFigure = [ labels, '_', Kernel_regression];
        
        FigureNames{obs} = NameFigure;
        
        % Export figure to location given by FilePath
        exportPlot(NameFigure, 'FilePath', FilePath,  ...
            'isExportPDF', isExportPDF, ...
            'isExportPNG', isExportPNG, ...
            'isExportTEX', isExportTEX);
    else
        FigureNames{1}=[];
    end
    
end
%--------------------END CODE ------------------------
end
