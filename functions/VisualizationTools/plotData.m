function plotData(data, model, estimation, misc, varargin)
%PLOTDATA Plot amplitude and time step of time series data
%
%   SYNOPSIS:
%     PLOTDATA(data, model, estimation, misc varargin)
%
%   INPUT:
%      data             - structure (required)
%                          data must contain three fields :
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
%                                   N: number of time series
%                                   M_i: number of samples of time series i
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
%      FilePath - character (optional)
%                   directory where to save the plot
%                   defaut: '.'  (current folder)
%
%      isSaveFigure - logical (optionnal)
%                     if isSaveFigures = true, save figures in FilePath in
%                     .fig format
%                     default = true
%
%      isPdf    - logical (optional)
%                 if true, build and open a PDF file with all figures
%                 default: false
%
%   OUTPUT:
%      One figure for each time series.
%      Figures saved in specified "FilePath" directory.
%      Format of the figure is Matlab fig
%
%   DESCRIPTION:
%      PLOTDATA reads time series data from structure
%      PLOTDATA plots amplitude and time step of each time series.
%      Format of output figures: fig
%
%   EXAMPLES:
%      PLOTDATA(data, model, estimation, misc)
%      PLOTDATA(data, model, estimation, misc, 'Filepath', './figures/')
%      PLOTDATA(data, model, estimation, misc,'Filepath', './figures/', 'isSaveFigures', false)
%      PLOTDATA(data, model, estimation, misc, 'Filepath', './figures/', 'isPdf', true)
%      PLOTDATA(data, model, estimation, misc, 'isPdf', true)
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
%       June 12, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultFilePath = '.';
defaultisPdf = false;
defaultisSaveFigures = true;

validationFct_FilePath = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'estimation', @isstruct );
addRequired(p,'misc', @isstruct );
addParameter(p,'FilePath', defaultFilePath, validationFct_FilePath);
addParameter(p,'isPdf', defaultisPdf, @islogical );
addParameter(p,'isSaveFigures', defaultisSaveFigures, @islogical );
parse(p,data, model, estimation, misc, varargin{:});

data=p.Results.data;
model=p.Results.model;
estimation=p.Results.estimation;
misc=p.Results.misc;
FilePath=p.Results.FilePath;
isPdf = p.Results.isPdf;
isSaveFigures = p.Results.isSaveFigures;

if isPdf && ~isSaveFigures
    isSaveFigures = true;
end


% Validation of structure data
isValid = verificationDataStructure(data);

if ~isValid
    disp(' ')
    disp('ERROR: Unable to read the data from the structure.')
    disp(' ')
    return
end

if isSaveFigures
    
    %% Remove space in filename
    FilePath = FilePath(~isspace(FilePath));
    
    %% Create specified path if not existing
    [isFileExist] = testFileExistence(FilePath, 'dir');
    if ~isFileExist
        % create directory
        mkdir(FilePath)
        % set directory on path
        addpath(FilePath)
    end
    
    
    fullname=fullfile(FilePath, misc.ProjectName);
    
    [isFileExist] = testFileExistence(fullname, 'dir');
    if isFileExist
        disp(' ')
        fprintf('Directory %s already exists. Overwrite ?\n', fullname)
        
        isYesNoCorrect = false;
        while ~isYesNoCorrect
            choice = input('     (y/n) >> ','s');
            if isempty(choice)
                disp(' ')
                disp('     wrong input --> please make a choice')
                disp(' ')
            elseif strcmp(choice,'y') || strcmp(choice,'yes') ||  ...
                    strcmp(choice,'Y') || strcmp(choice,'Yes')  || ...
                    strcmp(choice,'YES')
                
                isYesNoCorrect =  true;

            elseif strcmp(choice,'n') || strcmp(choice,'no') ||  ...
                    strcmp(choice,'N') || strcmp(choice,'No')  || ...
                    strcmp(choice,'NO')
                
                
                [name] = incrementFilename([misc.ProjectName, '_new'], FilePath);
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

%% Create a figure for each time series

% Get number of time series
numberOfTimeSeries = length(data.values);
% Set color of each plot
color = [0, 0.4, 0.8];

inc=0;
for i=1:numberOfTimeSeries
    inc=inc+1;
    % get timestamps
    timestamps=data.timestamps{i};
    % get values
    values=data.values{i};
    % compute reference (most frequent) time step
    [ReferenceTimestep]=defineReferenceTimeStep(timestamps);
    %Store the number of time steps
    nb_steps=length(timestamps);
    % Position of the missing data (NaN)
    pos_isnan=find(isnan(values) );
    % Percent of missing data (NaN)
    percent_missing=(length(pos_isnan)/nb_steps)*100;
    
    % Get reference name of the time series
    sname=data.labels{i};
    
    figure('Visible', 'on')
    set(gcf,'color','w');
    % Plot time series metadata and statistics
    subplot(3,1,1)
    rectangle('Position',[0 0 150 200], 'EdgeColor', 'none')
    str_1=['Time series #', num2str(inc), ' (' sname ')'];
    str_2=['Reference time step : ', num2str(ReferenceTimestep*24) , ...
        ' hours'];
    str_3=['Missing data : ', num2str(percent_missing), ' %' ];
    
    size_1=12;
    size_2=8;
    x_title=75;
    x_shift=0;
    text(x_title,150,str_1, 'Color','black','FontSize', size_1,  ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
        'Interpreter', 'none')
    text(x_shift, 70,str_2, 'Color','black','FontSize',size_2)
    text(x_shift,27.5,str_3, 'Color','black','FontSize',size_2)
    set(findobj(gcf, 'type','axes'), 'Visible','off')
    
    % Plot amplitude values
    subplot(3,1,2)
    full_val=values;
    not_nan_val=full_val(~isnan(full_val));
    full_ts=timestamps;
    not_nan_ts=full_ts(~isnan(full_val));
    plot(not_nan_ts, not_nan_val, 'Color', color, 'LineWidth', 1.5)
    hold on
    %    ylim([ min(values)-5 max(values)+5])
    set(gca,'XTick',linspace(timestamps(1),timestamps(end),5));
    set(gca,'FontSize',8)
    xlabel('Time [YY-MM]')
    ylabel('Amplitude');
    title('Amplitude', 'FontSize', 8)
    datetick('x','yy-mm','keepticks')
    
    % Plot time steps
    subplot(3,1,3)
    timestep=timestamps([ 2:end 1 ],1) - timestamps(:,1);
    semilogy(timestamps(1:end-1,1),timestep(1:end-1)*24 , ...
        'Color', color, ...
        'Marker', 'o', 'LineStyle', 'none', 'Markersize', 2, ...
        'MarkerFaceColor', color )
    set(gca,'XTick',linspace(timestamps(1),timestamps(end),5));
    set(gca,'FontSize',8)
    YTicks=([ 1 10 100 1000]);
    set(gca, 'YTick', YTicks)
    set(gca,'YTickLabel', cellstr(num2str(round(log10(YTicks(:))), '10^%d')))
    set(gca,'YMinorTick','off')
    title('Time step', 'FontSize', 8)
    datetick('x','yy-mm','keepticks')
    ylabel('Time step (hr)');
    xlabel('Time [YY-MM]')
    ylim([0.01 1000])
    
    
    if isSaveFigures
        % Export figure in fig amd pdf in specified directory
        filename=fullfile(fullname, ['num_', sprintf('%03d',inc)]);
        set(gcf,'PaperType', 'usletter', 'PaperOrientation', 'landscape')
        if isPdf
            export_fig([filename '.pdf'], '-nocrop')
            saveas(gcf, [filename '.fig'])
            close(gcf)
        else
            saveas(gcf, [filename '.fig'])
            close(gcf)
        end
    end
    
    
end
%
% %% Plot data availability
if isSaveFigures
    plotDataAvailability(data, 'FilePath', fullname, ...
        'isSaveFigures', isSaveFigures)
else
    plotDataAvailability(data,'isSaveFigures', isSaveFigures)
end
%
%% Build single pdf
if isPdf
    
    % name of the single pdf file
    pdfFileName = ['RAWDATA_', misc.ProjectName,'.pdf'];
    fullPdfFileName = fullfile(fullname, pdfFileName);
    
    [isFileExist] = testFileExistence(fullPdfFileName, 'file');
    
    if isFileExist
        delete(fullPdfFileName)
    end
    
    % List all newly created pdfs
    pdf_files=dir([fullname, '/', '*.pdf']);
    
    match = cellfun(@(S) (strcmp( S(1:4), 'num_' ) || ...
        strcmp( S(1:7), 'availab' )) , {pdf_files.name} );

    if ~isempty(match)
        pdf_files(~match) = [];
    end
    
    input_pdfs_list=cell(1,size(pdf_files,1));
    
    for i=1:size(pdf_files,1)
        input_pdfs_list{i}=which(pdf_files(i).name);
    end
    
    % append pdfs
    append_pdfs(fullPdfFileName, input_pdfs_list{:})
    
    % Clean directory
    delete([fullname, '/', '*num_*.pdf'])
    delete([fullname, '/', '*availability*.pdf'])
    
    open(fullPdfFileName)
    
else
    
    if isSaveFigures
        delete([fullname, '/', '*availability*.pdf'])
    end
end

if isSaveFigures
    fprintf('Figures saved in %s \n', fullname);
    disp('->done.')
    disp(' ')
end
%--------------------END CODE ------------------------
end
