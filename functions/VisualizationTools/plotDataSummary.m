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
%      isSaveFigures    - logical (optionnal)
%                         if isSaveFigures = true, save figures in FilePath in
%                         .fig format
%                         default = false
%
%      isPdf            - logical (optional)
%                         if true, build and open a PDF file with all figures
%                         default: false
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
%      PLOTDATASUMMARY(data, misc,'Filepath', './figures/', 'isSaveFigures', false)
%      PLOTDATASUMMARY(data, misc, 'Filepath', './figures/', 'isPdf', true)
%      PLOTDATASUMMARY(data, misc, 'isPdf', true)
%
%   EXTERNAL FUNCTIONS CALLED:
%      plotDataAvailability, verificationDataStructure, export_fig,
%      incrementFilename
%
%   See also VERIFICATIONDATASTRUCTURE,PLOTDATAAVAILABILITY, EXPORT_FIG,
%             INCREMENTFILENAME

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
%       October 16, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultFilePath = '.';
defaultisPdf = false;
defaultisSaveFigures = false;

validationFct_FilePath = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p,'data', @isstruct );
addRequired(p,'misc', @isstruct );
addParameter(p,'FilePath', defaultFilePath, validationFct_FilePath);
addParameter(p,'isPdf', defaultisPdf, @islogical );
addParameter(p,'isSaveFigures', defaultisSaveFigures, @islogical );
parse(p,data, misc, varargin{:});

data=p.Results.data;
misc=p.Results.misc;
FilePath=p.Results.FilePath;
isPdf = p.Results.isPdf;
isSaveFigures = p.Results.isSaveFigures;

ProjectName=misc.ProjectName;

%% Get options from misc
FigurePosition=misc.options.FigurePosition;
Linewidth=misc.options.Linewidth;
ndivx=misc.options.ndivx;
ndivy=misc.options.ndivy;

% Set fileID for logfile
% if misc.internalVars.isQuiet
%     % output message in logfile
%     fileID=fopen(misc.internalVars.logFileName, 'a');
% else
%     % output message on screen and logfile using diary command
%     fileID=1;
% end

% If data given in format (2), translate it to format (1)
if ~iscell(data.timestamps) && ~iscell(data.values)
    [data]=convertMat2Cell(data);  
end

if isSaveFigures
    
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
    %not_nan_val=full_val(~isnan(full_val));
    %full_ts=timestamps;
    %not_nan_ts=full_ts(~isnan(full_val));
    % Percent of missing data (NaN)
    pos_isnan=find(isnan(values));
    nb_steps=length(timestamps);
    percent_missing=(length(pos_isnan)/nb_steps)*100;
    %plot(not_nan_ts, not_nan_val, 'Color', color, 'LineWidth', Linewidth)
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
    
    %set(gca,'XTick',linspace(timestamps(1),timestamps(end),ndivx));
    
    set(gca,'XTick',linspace(begg_min,endd_max,ndivx))
    
    set(gca,'FontSize',16)
    datetick('x','yy-mm','keepticks')
    if i == numberOfTimeSeries
        set(gca,'YTick',linspace(min(full_val),max(full_val),ndivy));
        xlabel('Time [YY-MM]')
    else
        set(gca,'xticklabel',{[]})
    end
       
    if isSaveFigures
        % Export figure in fig and pdf in specified directory
        filename=fullfile(fullname, 'num_AMP');
        set(gcf,'PaperType', 'usletter', 'PaperOrientation', 'landscape')
        if isPdf
            export_fig([filename '.pdf'], '-nocrop')
        end
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
     
    if isSaveFigures
        % Export figure in fig and pdf in specified directory
        filename=fullfile(fullname, 'num_DT');
        set(gcf,'PaperType', 'usletter', 'PaperOrientation', 'landscape')
        if isPdf
            export_fig([filename '.pdf'], '-nocrop')
        end
    end
 
end

%% Plot data availability
fullname = fullfile(FilePath, ProjectName);
plotDataAvailability(data, misc, 'FilePath', fullname)

%% Previous version

% % if isPdf && ~isSaveFigures
% %     isSaveFigures = true;
% % end
% 
% % Validation of structure data
% % isValid = verificationDataStructure(data);
% % 
% % if ~isValid
% %     disp(' ')
% %     disp('     ERROR: Unable to read the data from the structure.');
% %     disp(' ')
% %     return
% % end
% 
% if isSaveFigures
%     
%     %% Create specified path if not existing
%     [isFileExist] = testFileExistence(FilePath, 'dir');
%     if ~isFileExist
%         % create directory
%         mkdir(FilePath)
%         % set directory on path
%         addpath(FilePath)
%     end
%     
%     fullname=fullfile(FilePath, ProjectName);
%     
%     [isFileExist] = testFileExistence(fullname, 'dir');
%     if isFileExist
%         disp( ['     Directory ', fullname ,' already exists. ', ...
%             'Overwrite ? (y/n)']);
%         isYesNoCorrect = false;
%         while ~isYesNoCorrect
%             choice = input('     choice >> ','s');
%             if isempty(choice)
%                 disp(' ')
%                 disp('     wrong input')
%                 disp(' ')
%             elseif strcmpi(choice,'y') || strcmpi(choice,'yes')
%                 
%                 isYesNoCorrect =  true;
%                 
%             elseif strcmpi(choice,'n') || strcmpi(choice,'no')
%                 
%                 [name] = incrementFilename([ProjectName, '_new'], ...
%                     FilePath);
%                 fullname=fullfile(FilePath, name);
%                 
%                 % Create new directory
%                 mkdir(fullname)
%                 addpath(fullname)
%                 
%                 isYesNoCorrect =  true;
%                 
%             else
%                 disp(' ')
%                 disp('     wrong input')
%                 disp(' ')
%             end
%             
%         end
%     else
%         
%         % Create new directory
%         mkdir(fullname)
%         addpath(fullname)
%         
%     end
% end
% 
% 
% disp('     Plotting data...')
% 
% % Get number of time series
% numberOfTimeSeries = size(data.values, 2);
% % Set color of each plot
% color = [0, 0.4, 0.8];
% 
% %% Create a single figure for the data amplitude
% FigHandle = figure('Name','Data amplitude','NumberTitle','off', ...
%     'DefaultAxesPosition', [0.1, 0.17, 0.8, 0.8]);
% set(FigHandle, 'Position', FigurePosition)
% set(gcf,'color','w');
% inc=0;
% for i=1:numberOfTimeSeries
%     subplot(numberOfTimeSeries,1, i )
%     inc=inc+1;
%     % get label
%     label=data.labels{i};
%     % get timestamps
%     timestamps=data.timestamps;
%     % get values
%     values=data.values(:,i);
%     full_val=values;
%     not_nan_val=full_val(~isnan(full_val));
%     full_ts=timestamps;
%     not_nan_ts=full_ts(~isnan(full_val));
%     % Percent of missing data (NaN)
%     pos_isnan=find(isnan(values) );
%     nb_steps=length(timestamps);
%     percent_missing=(length(pos_isnan)/nb_steps)*100;
%     %plot(not_nan_ts, not_nan_val, 'Color', color, 'LineWidth', Linewidth)
%     plot(timestamps, values, 'Color', color, 'LineWidth', Linewidth)
%     hold on
%     text(0.075, 0.15, label, 'FontSize', 12, ...
%         'HorizontalAlignment','center', 'Units', 'normalized', ...
%         'BackgroundColor',[1. 1. 1.])
%     
%     text(0.925, 0.15, ...
%         ['Missing data: ', num2str(percent_missing), '%'], ...
%         'FontSize', 12, 'HorizontalAlignment','center', ...
%         'Units', 'normalized', 'BackgroundColor',[1. 1. 1.])
%     
%     set(gca,'XTick',linspace(timestamps(1),timestamps(end),ndivx));
%     set(gca,'FontSize',12)
%     datetick('x','yy-mm','keepticks')
%     if i == numberOfTimeSeries
%         set(gca,'YTick',linspace(min(full_val),max(full_val),ndivy));
%         xlabel('Time [YY-MM]')
%     else
%         set(gca,'xticklabel',{[]})
%     end
%     
%     
%     
%     if isSaveFigures
%         % Export figure in fig and pdf in specified directory
%         filename=fullfile(fullname, 'num_AMP');
%         set(gcf,'PaperType', 'usletter', 'PaperOrientation', 'landscape')
%         if isPdf
%             export_fig([filename '.pdf'], '-nocrop')
%             %saveas(gcf, [filename '.fig'])
%             %close(gcf)
%         else
%             %saveas(gcf, [filename '.fig'])
%             %close(gcf)
%         end
%     end
%     
%     
%     
% end
% 
% %% Create a single figure for the data time step
% FigHandle = figure('Name','Data time step','NumberTitle','off', ...
%     'DefaultAxesPosition', [0.1, 0.17, 0.8, 0.8]);
% set(FigHandle, 'Position', FigurePosition);
% set(gcf,'color','w');
% inc=0;
% for i=1:numberOfTimeSeries
%     subplot(numberOfTimeSeries,1, i )
%     inc=inc+1;
%     
%     % get label
%     label=data.labels{i};
%     
%     % compute timestep
%     %timestep=timestamps([ 2:end 1 ],1) - timestamps(:,1);
%     
%     timesteps = computeTimeSteps(timestamps);
%     
%     % compute reference (most frequent) time step
%     [ReferenceTimestep]=defineReferenceTimeStep(timestamps);
%     
%     % plot
%     %semilogy(timestamps(1:end-1,1),timestep(1:end-1)*24 , ...
%     semilogy(timestamps,timesteps*24 , ...
%         'Color', color, ...
%         'Marker', 'o', 'LineStyle', 'none', 'Markersize', 2, ...
%         'MarkerFaceColor', color )
%     hold on
%     text(0.075, 0.15, label, 'FontSize', 12, ...
%         'HorizontalAlignment','center', 'Units', 'normalized', ...
%         'BackgroundColor',[1. 1. 1.])
%     
%     text(0.92, 0.15, ...
%         ['Reference timestep: ', num2str(ReferenceTimestep*24), ' hours'], ...
%         'FontSize', 12, 'HorizontalAlignment','center', ...
%         'Units', 'normalized', 'BackgroundColor',[1. 1. 1.])
%     
%     set(gca,'XTick',linspace(timestamps(1),timestamps(end),5));
%     set(gca,'FontSize',12)
%     YTicks=([ 1 10 100 1000]);
%     set(gca, 'YTick', YTicks)
%     set(gca,'YTickLabel', ...
%         cellstr(num2str(round(log10(YTicks(:))), '10^%d')))
%     set(gca,'YMinorTick','off')
%     datetick('x','yy-mm','keepticks')
%     ylim([0.01 1000])
%     if i == numberOfTimeSeries
%         xlabel('Time [YY-MM]')
%     else
%         
%         set(gca,'xticklabel',{[]})
%     end
%     
%     
%     if isSaveFigures
%         % Export figure in fig and pdf in specified directory
%         filename=fullfile(fullname, 'num_DT');
%         set(gcf,'PaperType', 'usletter', 'PaperOrientation', 'landscape')
%         if isPdf
%             export_fig([filename '.pdf'], '-nocrop')
%             %saveas(gcf, [filename '.fig'])
%             %close(gcf)
%         else
%             %saveas(gcf, [filename '.fig'])
%             %close(gcf)
%         end
%     end
%     
%     
% end
% 
% 
% % Plot data availability
% if isSaveFigures
%     plotDataAvailability(data, misc, 'FilePath', fullname, ...
%         'isSaveFigures', isSaveFigures)
% else
%     plotDataAvailability(data, misc,'isSaveFigures', isSaveFigures)
% end
% %
% %% Build single pdf
% if isPdf
%     
%     % name of the single pdf file
%     pdfFileName = ['DATASUMMARY_', ProjectName,'.pdf'];
%     fullPdfFileName = fullfile(fullname, pdfFileName);
%     
%     [isFileExist] = testFileExistence(fullPdfFileName, 'file');
%     
%     if isFileExist
%         delete(fullPdfFileName)
%     end
%     
%     % List all newly created pdfs
%     pdf_files=dir([fullname, '/', '*.pdf']);
%     
%     match = cellfun(@(S) (strcmp( S(1:4), 'num_' ) || ...
%         strcmp( S(1:7), 'availab' )) , {pdf_files.name} );
%     
%     if ~isempty(match)
%         pdf_files(~match) = [];
%     end
%     
%     input_pdfs_list=cell(1,size(pdf_files,1));
%     
%     for i=1:size(pdf_files,1)
%         input_pdfs_list{i}=which(pdf_files(i).name);
%     end
%     
%     % append pdfs
%     append_pdfs(fullPdfFileName, input_pdfs_list{:})
%     
%     % Clean directory
%     delete([fullname, '/', '*num_*.pdf'])
%     delete([fullname, '/', '*availability*.pdf'])
%     
%     %open(fullPdfFileName)
%     
% else
%     
%     if isSaveFigures
%         delete([fullname, '/', '*availability*.pdf'])
%     end
% end
% 
% if isSaveFigures
%     fprintf(fileID, '     Figures saved in %s \n', fullname);
%     fprintf(fileID,'\n');
% end
%--------------------END CODE ------------------------
end
