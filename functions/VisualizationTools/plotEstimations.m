function plotEstimations(data, model, estimation, misc, varargin)
%PLOTESTIMATIONS Plot hidden states, predicted data, and model probability
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
%   PLOTHIDDENSTATES, PLOTMODELPROBABILITY,
%   PLOTKERNELREGRESSION, PLOTWATERFALLSKDKREGRESSION

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
%       October 26, 2018

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

% Set fileID for logfile
if misc.internalVars.isQuiet
    % output message in logfile
    fileID=fopen(misc.internalVars.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end

%% Verification if there are data to plot, or not
if ~isfield(estimation,'ref') && ~isfield(estimation,'x')
    fprintf(fileID,'\n');
    fprintf(fileID,'     No plot to create.\n');
    fprintf(fileID,'\n');
    return
end

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
        %fprintf(fileID,'\n');
        disp(['     Directory ', fullname,' already ', ...
            'exists. Overwrite ?'] );
        
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
                    FilePath);
                fullname=fullfile(FilePath, name);
                
                % Create new directory
                mkdir(fullname)
                addpath(fullname)
                
                isYesNoCorrect =  true;
                
            else
                fprintf(fileID,'\n');
                fprintf(fileID,'     wrong input\n');
                fprintf(fileID,'\n');
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

disp('     Plotting hidden states estimations ...')

%% Verification if there are data to plot, or not
if ~isfield(estimation,'ref') && ~isfield(estimation,'x')
    fprintf(fileID,'No plot to create.\n');
    return
end

% Initialize a cell array that records the names of all the figures
%% Plot predicted data

[~] = plotPredictedData(data, model, estimation, misc, ...
    'FilePath', fullname, ...
    'isExportPDF', isExportPDF, ...
    'isExportPNG', isExportPNG, ...
    'isExportTEX', isExportTEX);

%% Plot hidden state estimations
[~] = plotHiddenStates(data, model, estimation, misc, ...
    'FilePath', fullname, ...
    'isExportPDF', isExportPDF, ...
    'isExportPNG', isExportPNG, ...
    'isExportTEX', isExportTEX);

%% Plot model probability
[~] = plotModelProbability(data, model, estimation, misc, ...
    'FilePath', fullname, ...
    'isExportPDF', isExportPDF, ...
    'isExportPNG', isExportPNG, ...
    'isExportTEX', isExportTEX);

%% Waterfall plot for kernel regression
[~] = plotWaterfallKRegression(data, model, estimation, misc, ...
    'FilePath', fullname, ...
    'isExportPDF', isExportPDF, ...
    'isExportPNG', isExportPNG, ...
    'isExportTEX', isExportTEX);

if isExportPNG || isExportPDF || isExportTEX
    fprintf(fileID,'\n');
    fprintf(fileID,'     Figures saved in %s.\n', fullname);
    fprintf(fileID,'\n');
end

end