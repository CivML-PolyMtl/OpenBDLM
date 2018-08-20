function [FigureNames] = plotWaterfallKRegression(data, model, estimation, misc, varargin)
%PLOTWATERFALLKREGRESSION Waterfall plot for kernel regression component
%
%   SYNOPSIS:
%     PLOTWATERFALLKREGRESSION(data, model, estimation, misc, varargin)
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
%      Figure(s) on screen
%      If applicable, figure(s) saved in the location given by FilePath
%
%   DESCRIPTION:
%      PLOTWATERFALLKREGRESSION plot "waterfall" like plot for static
%      and dynamic kernel regression components
%
%   EXAMPLES:
%       PLOTWATERFALLKREGRESSION(data, model, estimation, misc)
%       PLOTWATERFALLKREGRESSION(data, model, estimation, misc, 'FilePath', 'figures')
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
%       Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
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

%% Read model parameter properties
% Current model parameters
idx_pvalues=size(model.param_properties,2)-1;
idx_pref= size(model.param_properties,2);

[arrayOut]=...
    readParameterProperties(model.param_properties, ...
    [idx_pvalues, idx_pref]);

parameter= arrayOut(:,1);


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

%% Get number of time series
numberOfTimeSeries = length(data.labels);

%% Create static/dynamic kernel regression waterfall plot for each time series
% Loop over time series
for obs=1:numberOfTimeSeries
    
    % Get data labels
    labels=data.labels{obs};
    
    % Get hidden states associated to this observation
    TestNameHiddenStates = ...
        strfind(model.hidden_states_names{1}(:,3), num2str(obs));
    IndexNameHiddenStates = ...
        find(not(cellfun('isempty', TestNameHiddenStates )));
    
    hidden_states_names_sub =  ...
        model.hidden_states_names{1}(IndexNameHiddenStates,:);
    
    % Get parameters associated to this observation
    
    strs=model.param_properties(:,4);
    strs(cellfun('isempty',strs)) = [];
    
    TestNameParameters = ...
        strfind(strs, num2str(obs));
    IndexNameParameters = ...
        find(not(cellfun('isempty',  TestNameParameters)));
    
    % Get parameter properties
    param_properties_sub =  model.param_properties(IndexNameParameters,:);
    
    % Get estimated current parameter values
    parameter_sub = parameter(IndexNameParameters,:);
    
    %% Get amplitude values to plot
    % Estimated hidden states values
    if isfield(estimation, 'x')
        % mean values
        estimation_x_sub = estimation.x_M{1,1}(IndexNameHiddenStates,:);
        
        numberOfHiddenStates_sub = size(hidden_states_names_sub,1);
        
        for idx=1:numberOfHiddenStates_sub
            if and(strncmpi(hidden_states_names_sub(idx,1),'x^{KR',5), ...
                    ~strcmp(hidden_states_names_sub(idx,1),'x^{KR1}'))
                Kernel_regression='KR';
                break
            else
                FigureNames{obs}=[];
                Kernel_regression=[];
            end
        end
        
        if isempty(Kernel_regression)
            continue
        end
        
        % Get model parameters index corresponding to kernel regression
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
        
        % Get hidden states index corresponding to kernel regression
        K_x_idx=[];
        for i=1:size(hidden_states_names_sub,1)
            if strncmpi(hidden_states_names_sub(i,1),['x^{' Kernel_regression],5)
                K_x_idx=[K_x_idx i];
            end
        end
        if strcmp(Kernel_regression,'KR')
            K_x_idx=K_x_idx(2:end);
        end
        
        
        period=parameter_sub(K_p_idx);
        tsi=timestamps(1);
        tsf=tsi+period;
        X=[];
        Y=[];
        Z=[];
        ts_plot=floor((timestamps(end)-timestamps(1))/(period));
        CP=zeros(ts_plot,length(K_x_idx));
        for i=1:ts_plot
            x=linspace(tsi,tsf,200);
            xpl=zeros(1,length(x));
            ts_hs=find(abs(timestamps-tsf)==min(abs(timestamps-tsf)));
            if isfield(estimation, 'x')
                CP(i,:)=estimation_x_sub(K_x_idx,ts_hs)';
            end
            
            for j=1:length(x)
                    p_KRHC=parameter_sub(1:length(parameter_sub));
                    p_KRHC=p_KRHC(K_idx(1:2));
                    k=Kernel_component(p_KRHC,x(j), ...
                        timestamps(1),model.components.nb_KR_p-1);
                xpl(j)=CP(i,:)*k';
            end
            tsi_last=tsi;
            tsi=tsf;
            tsf=tsi+period;
            
            X=[X;x*0+x(1)];
            Y=[Y;x-x(1)];
            Z=[Z;xpl];
            
        end
        
        
        FigHandle = figure('DefaultAxesPosition', [0.1, 0.17, 0.8, 0.8]);
        set(FigHandle, 'Position', [100, 100, 1300, 270])
        set(gca, 'Fontsize', 16)
        
        if isfield(estimation, 'x')
            
            
            subplot(1,2,1)
            waterfall(X,Y,Z)
            xlim([timestamps(1) timestamps(end)])
            ylim([0 period])
            datetick('x','yy','keepticks')
            datetick('y','mm-dd','keepticks')
            ylim([0 period])
            xlim([timestamps(1) timestamps(end)])
            
            xlabel('Time [YY]')
            ylabel('Time [MM-DD]')
                zlabel(['Kernel Regression', ' [', labels, ']'], ...
                    'Interpreter','Latex' )
            set(gca, 'Fontsize', 16)
            grid on
            
            subplot(1,2,2)
            [X2,Y2]=ndgrid(linspace(timestamps(1),tsi_last,ts_plot), ...
                linspace(0,period,length(K_x_idx)));
            plot3(X2,Y2,CP,'+r')
            xlim([timestamps(1) timestamps(end)])
            ylim([0 period])
            datetick('x','yy','keepticks')
            datetick('y','mm-dd','keepticks')
            ylim([0 period])
            xlim([timestamps(1) timestamps(end)])
            
            xlabel('Time [YY]')
            ylabel('Time [MM-DD]')
            zlabel(['Control points',' [', labels, ']'], ...
                'Interpreter','Latex' )
            set(gca, 'Fontsize', 16)
            grid on
            hold off
        end
        
        %% Export plots
        if isExportPDF || isExportPNG || isExportTEX
            
            NameFigure = [ labels, '_', Kernel_regression, '_Waterfall'];
            
            FigureNames{obs} = NameFigure;
            
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
