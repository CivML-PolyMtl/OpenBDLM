function exportPlot(FigureName, varargin)
%EXPORTPLOT Export the current figure in TeX file using matlab2tikz
%
%   SYNOPSIS:
%     EXPORTPLOT(FigureName, varargin)
%
%   INPUT:
%      FigureName  - character (required)
%                   name of the figure to export
%
%      isExportPDF - logical (optional)
%                    if isExportPDF, export the figure in PDF format
%                    default: false
%
%      isExportPNG - logical (optional)
%                    if isExportPNG, export the figure in PNG format
%                    default: true
%
%      isExportTEX - logical (optional)
%                    if isExportTEX, export the figure in TEX format
%                    default: false
%
%      FilePath    - character (optional)
%                     directory where to save the file
%                     default: '.'  (current folder)
%
%   OUTPUT:
%      N/A
%      Figures (possibly several format) in the location given by FilePath
%
%   DESCRIPTION:
%      EXPORTPLOT exports the current figure in TeX file using matlab2tikz
%      functions
%
%   EXAMPLES:
%      EXPORTPLOT('MyFigureName')
%      EXPORTPLOT('MyFigureName', 'FilePath', 'figures')
%
%   EXTERNAL FUNCTIONS CALLED:
%      matlab2tikz package
%
%   See also MATLAB2TIKZ

%   AUTHORS:
%       Luong Ha Nguyen, Ianis Gaudot, James-A Goulet
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
%       December 6, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultFilePath = '.';
defaultisExportPDF = false;
defaultisExportPNG = true;
defaultisExportTEX = false;

validationFonction = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p,'FigureName', validationFonction );
addParameter(p,'FilePath', defaultFilePath,  validationFonction);
addParameter(p,'isExportPDF', defaultisExportPDF,  @islogical);
addParameter(p,'isExportPNG', defaultisExportPNG,  @islogical);
addParameter(p,'isExportTEX', defaultisExportTEX,  @islogical);
parse(p, FigureName, varargin{:} );

FigureName=p.Results.FigureName;
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

%% Export figure

% Put white background
set(gcf,'Color',[1 1 1])

% Export figure in TEX using matlab2tikz
if isExportTEX
    % Adjust target resolution
    cleanfigure('targetResolution',300);
    
    % Add option for plot appearance
    opts=['scaled y ticks = false,',...
        'scaled x ticks = false,',...
        'y tick label style={/pgf/number format/.cd, '...
        ' fixed, fixed zerofill,precision=2},',...
        'x tick label style={/pgf/number format/.cd, '...
        'fixed, fixed zerofill,precision=2},',...
        'x label style={font=\LARGE},',...
        'y label style={font=\LARGE},',...
        'legend style={font=\LARGE},',...
        'legend columns=4',...
        %     ['restrict y to domain=' num2str(miny-0.5*abs(miny)) ':' ...
        %     num2str(maxy+0.5*abs(maxy))]
        ];
    
    % Run matlab2tikz
    warning off;
    matlab2tikz('figurehandle',gcf, ...
        'filename', [ fullfile(FilePath, FigureName),  '.tex'] , ...
        'standalone', true,'showInfo', false,...
        'floatFormat','%.8g','extraTikzpictureOptions','font=\LARGE','extraaxisoptions',opts, ...
        'width','1.8\textwidth');
    warning on;
end

% Export figure in pdf using export_fig
if isExportPDF
    warning off;
    export_fig([ fullfile(FilePath, FigureName),  '.pdf'], '-nocrop')
    warning on;
end

% Export figure in png using export_fig
if isExportPNG
    warning off;
    export_fig([ fullfile(FilePath, FigureName),  '.png'],  ...
        '-nocrop', '-r300')
    warning on;
end
%--------------------END CODE ------------------------
end
