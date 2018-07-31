function plotEstimations(data, model, estimation, misc, varargin)
%PLOTESTIMATIONS Plot hidden states results
%
%   SYNOPSIS:
%     PLOTESTIMATIONS(data, model, estimation, misc, varargin)
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
%                         if isExportPDF = true, export the figure in PDF
%                         format and build a single PDF file with all plots
%                         default: false
%
%      isExportPNG      - logical (optional)
%                         if isExportPNG = true , export the figure in PNG
%                         format
%                         default: false
%
%      isExportTEX      - logical (optional)
%                         if isExportTEX = true , export the figure in TEX
%                         format
%                         default: false
%
%      FilePath         - character (optional)
%                         directory where to save the file
%                         default: '.'  (current folder)
%
%   OUTPUT:
%      Plot figures on screen and export figures in the location given by
%      FilePath
%
%   DESCRIPTION:
%      PLOTESTIMATIONS plots hidden states results.
%      PLOTESTIMATIONS plots true hidden states values when they are known,
%      that is, in case of data simulation.
%      PLOTESTIMATIONS also plots predicted data and observations.
%
%   EXAMPLES:
%      PLOTESTIMATIONS(data, model, estimation, misc, 'FilePath', 'figures')
%      PLOTESTIMATIONS(data, model, estimation, misc, 'FilePath', 'figures', 'isExportPDF', true)
%      PLOTESTIMATIONS(data, model, estimation, misc, 'isExportPDF', true, 'isExportPNG', false, 'isExportTEX', true)
%
%   EXTERNAL FUNCTIONS CALLED:
%      plotPredictedData, plotHiddenStates, plotModelProbability,
%      plotStaticKernelRegression, plotWaterfallSKDKRegression
%
%   See also EXPORTPLOT, PLOTESTIMATIONS, PLOTPREDICTEDDATA,
%   PLOTHIDDENSTATES, PLOTMODELPROBABILITY, PLOTDYNAMICREGRESSION,
%   PLOTSTATICKERNELREGRESSION, PLOTWATERFALLSKDKREGRESSION

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
%       May 24, 2018
%
%   DATE LAST UPDATE:
%       June 11, 2018

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


%% Verification if there are data to plot, or not
if ~isfield(estimation,'ref') && ~isfield(estimation,'x')
    disp(' ')
    disp('     No plot to create...')
    return
end

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


%% Create subdirectory where to save the figures

if isExportPNG || isExportPDF || isExportTEX
    
    fullname = fullfile(FilePath, misc.ProjectName);
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
            elseif strcmpi(choice,'y') || strcmpi(choice,'yes')
                
                isYesNoCorrect =  true;
                
            elseif strcmpi(choice,'n') || strcmpi(choice,'no')
                
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
    
else
    
    fullname = FilePath;
    
end

%% Verification if there are data to plot, or not
if ~isfield(estimation,'ref') && ~isfield(estimation,'x')
    disp('No plot to create...')
    return
end

%% Define parameters for plot appareance
% Plot secondary close-up figure
if ~isfield(misc,'isSecondaryPlots')
    misc.isSecondaryPlots=true;
end

% Select linewidth
if ~isfield(misc,'linewidth')
    misc.linewidth=1;
end

% Select subsamples in order to reduce the number of points
if ~isfield(misc,'subsample')
    misc.subsample=1;
end

% number of x-axis division
if ~isfield(misc,'ndivx')
    misc.ndivx=5;
end

% number of y-axis division
if ~isfield(misc,'ndivy')
    misc.ndivy=3;
end

% Initialize a cell array that records the names of all the figures
FigureNames_full = {};

%% Plot predicted data

[FigureNames] = ...
    plotPredictedData(data, model, estimation, misc, ...
    'FilePath', fullname, ...
    'isExportPDF', isExportPDF, ...
    'isExportPNG', isExportPNG, ...
    'isExportTEX', isExportTEX);

FigureNames_full = [FigureNames_full  FigureNames]; % record figure names

%% Plot hidden state estimations
[FigureNames] = plotHiddenStates(data, model, estimation, misc, ...
    'FilePath', fullname, ...
    'isExportPDF', isExportPDF, ...
    'isExportPNG', isExportPNG, ...
    'isExportTEX', isExportTEX);

FigureNames_full = [FigureNames_full  FigureNames]; % record figure names

%% Plot model probability
[FigureNames] = plotModelProbability(data, model, estimation, misc, ...
    'FilePath', fullname, ...
    'isExportPDF', isExportPDF, ...
    'isExportPNG', isExportPNG, ...
    'isExportTEX', isExportTEX);

FigureNames_full = [FigureNames_full  FigureNames]; % record figure names

%% Plot dynamic regression
[FigureNames] = plotDynamicRegression(data, model, estimation, misc, ...
    'FilePath', fullname, ...
    'isExportPDF', isExportPDF, ...
    'isExportPNG', isExportPNG, ...
    'isExportTEX', isExportTEX);

FigureNames_full = [FigureNames_full  FigureNames]; % record figure names

%% Plot kernel regression results
[FigureNames] = plotStaticKernelRegression(data, model, estimation, misc, ...
    'FilePath', fullname, ...
    'isExportPDF', isExportPDF, ...
    'isExportPNG', isExportPNG, ...
    'isExportTEX', isExportTEX);

FigureNames_full = [FigureNames_full  FigureNames]; % record figure names

%% Waterfall plot for kernel regression
[FigureNames] = plotWaterfallSKDKRegression(data, model, estimation, misc, ...
    'FilePath', fullname, ...
    'isExportPDF', isExportPDF, ...
    'isExportPNG', isExportPNG, ...
    'isExportTEX', isExportTEX);

FigureNames_full = [FigureNames_full  FigureNames]; % record figure names

%% Concatenate all pdfs in a single pdf file
if isExportPDF
    
    % Remove empty cells
    FigureNames_full(cellfun('isempty',FigureNames_full)) = [];
    
    % Get number of time series
    numberOfTimeSeries = length(data.labels);
    
    for i=1:numberOfTimeSeries
        
        if i == 1
            FigureNames_sort = {};
        end
        
        pattern = data.labels{i};
        
        Test = strfind(FigureNames_full(:), pattern);
        Index = find(not(cellfun('isempty', Test )));
        
        FigureNames_sub =  ...
            FigureNames_full(Index);
        
        FigureNames_sort = [ FigureNames_sort FigureNames_sub];
        
    end
    
    if model.nb_class>1
        Test = strfind(FigureNames_full(:), 'ModelProbability');
        Index = find(not(cellfun('isempty', Test )));
        FigureNames_sub =  ...
            FigureNames_full(Index);
        
        FigureNames_sort = [FigureNames_sort FigureNames_sub];
    end
      
    pdfFileName = ['ESTIMATIONS_', misc.ProjectName,'.pdf'];
    fullPdfFileName = fullfile (fullname, pdfFileName);
    
    [isFileExist] = testFileExistence(fullPdfFileName, 'file');
    
    if isFileExist
        delete(fullPdfFileName)
    end
    
    FigureNames_sort = strcat(fullfile(fullname, FigureNames_sort),'.pdf');
        
    % Merge all pdfs for creating one single one in specified location
    append_pdfs(fullPdfFileName, FigureNames_sort{:})
    
    
    open(fullPdfFileName)
    
end
if isExportPNG || isExportPDF || isExportTEX
    fprintf('Figures saved in %s.', fullname)
    disp(' ')
end
end