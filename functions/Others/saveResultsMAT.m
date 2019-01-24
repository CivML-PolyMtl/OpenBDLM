function [misc]=saveResultsMAT(data, model, estimation, misc, varargin)
%SAVERESULTSMAT Save results in a .mat file
%
%   SYNOPSIS:
%     [misc]=SAVERESULTSMAT(data, model, estimation, misc, varargin)
%
%   INPUT:
%      data                 - structure (required)
%                             see the documentation for details about the
%                             field in misc
%
%      model                - structure (required)
%                             see the documentation for details about the
%                             field in misc
%
%      estimation           - structure (required)
%                             see the documentation for details about the
%                             field in misc
%
%      misc                 - structure (required)
%                             see the documentation for details about the
%                             field in misc
%
%      FilePath             - character (optional)
%                             directory where to save the MAT files
%                             default: '.'  (current folder)
%
%      isForceOverwrite     - logical (optional)
%                             if isOverwrite = true, overwrite previous file without
%                             notice
%                             default = false
%
%   OUTPUT:
%      misc                 - structure (required)
%                             see the documentation for details about the
%                             field in misc
%
%      MAT files saved in the location given by FilePath.
%
%   DESCRIPTION:
%      SAVERESULTSMAT saves estimated hidden states, predicted data, and
%      model probability in Matlab MAT binary files
%
%   EXAMPLES:
%      [misc]=SAVERESULTSMAT(data, model, estimation, misc)
%      [misc]=SAVERESULTSMAT(data, model, estimation, misc, 'FilePath', 'results/mat')
%
%   EXTERNAL FUNCTIONS CALLED:
%      testFileExistence, incrementFilename
%
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also TESTFILEEXISTENCE, INCREMENTFILENAME

%   AUTHORS:
%      Ianis Gaudot, Luong Ha Nguyen,  James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.4.0.813654 (R2018a)
%
%   DATE CREATED:
%       December 6, 2018
%
%   DATE LAST UPDATE:
%       December 7, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultFilePath = '.';
validationFct_FilePath = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));
defaultisForceOverwrite = false;

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'estimation', @isstruct );
addRequired(p,'misc', @isstruct );
addParameter(p,'FilePath', defaultFilePath, validationFct_FilePath );
addParameter(p,'isForceOverwrite', defaultisForceOverwrite, @islogical );
parse(p,data, model, estimation, misc, varargin{:});

data=p.Results.data;
model=p.Results.model;
estimation=p.Results.estimation;
misc=p.Results.misc;
FilePath=p.Results.FilePath;
isForceOverwrite=p.Results.isForceOverwrite;

FilePath_full=fullfile(FilePath, 'mat');

ProjectName = misc.ProjectName;

% Set fileID for logfile
if misc.internalVars.isQuiet
    % output message in logfile
    fileID=fopen(misc.internalVars.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end

%% Verification if there are data to plot, or not
if ~isfield(estimation,'x')
    %     fprintf(fileID,'     No files to create.\n');
    %     fprintf(fileID,'\n');
    return
end

%% Create specified path if not existing
[isFileExist] = testFileExistence(FilePath_full, 'dir');
if ~isFileExist
    % create directory
    mkdir(FilePath_full)
    % set directory on path
    addpath(FilePath_full)
end

ResultsFilename = ['RES_',ProjectName, '.mat'];


if ~isForceOverwrite
    
    [isFileExist] = testFileExistence(fullfile(FilePath_full, ...
        ResultsFilename), 'file');
    
    if isFileExist
        isAnswerCorrect = false;
        while ~isAnswerCorrect
            disp(['     Result file ', ...
                'name ', ResultsFilename ,' already exists. ' ...
                'Overwrite ? (y/n)']);
            choice = input('     choice >> ','s');
            % Remove space and quotes
            choice=strrep(choice,'''','' ); % remove quotes
            choice=strrep(choice,'"','' ); % remove double quotes
            choice=strrep(choice, ' ','' ); % remove spaces
            
            if isempty(choice)
                disp(' ')
                disp('     wrong input')
                disp(' ')
                continue
            elseif strcmpi(choice,'y') || strcmpi(choice,'yes')
                Filename = fullfile(FilePath_full, ResultsFilename);
                isAnswerCorrect =  true;
            elseif strcmpi(choice,'n') || strcmpi(choice,'no')
                [name]=incrementFilename('RES_new', ...
                    './results/mat', 'FileExtension', 'mat');
                Filename = fullfile(FilePath_full, name);
                isAnswerCorrect = true;
            else
                disp(' ')
                disp('     wrong input')
                disp(' ')
                continue
            end
            
        end
    else
        Filename = fullfile(FilePath_full, ResultsFilename);
    end
    
else
    Filename = fullfile(FilePath_full, ResultsFilename);
end


%% Get posterior mu and sigma values

% Get posterior mean and variance hidden states values
dataset_x=estimation.x;
dataset_V=estimation.V;

% Get posterior mean and variance predicted data values
dataset_y=estimation.y;
dataset_Vy=estimation.Vy;

% get posterior model probability
Pr_M=estimation.S;

if model.nb_class == 2
    Pr_M = Pr_M(:,2);
end
%% Save in MAT file

% Get number of hidden states
numberOfHiddenStates = size(model.hidden_states_names{1},1);

% Get number of time series
numberOfTimeSeries = size(data.values,2);

% Get timestamps
timestamps = data.timestamps;

% Select indexes of the hidden states of interest
HiddenStatesNames = model.hidden_states_names{1}(:,1);
IndexC = strfind(HiddenStatesNames,['KR', num2str(model.components.nb_KR_p-1)]);
Index = find(not(cellfun('isempty',IndexC)));

if ~isempty(Index)
    ind=[];
    for i=1:length(Index)
        
        indi=Index(i)-model.components.nb_KR_p+3;
        ind=[ind Index(i):-1:indi];
        
    end
    
    idx_to_keep = find(~ismember(1:numberOfHiddenStates, ind));
    
else
    
    idx_to_keep = 1:numberOfHiddenStates;
    
end

% Select hidden states of interest

full_Labels = cell(1,length(idx_to_keep)+ numberOfTimeSeries + 1);
inc=0;
loop=0;
for i=1:length(idx_to_keep)+ numberOfTimeSeries + 1
    
    if i <= length(idx_to_keep)
        
        sensor_name = ...
            data.labels{...
            str2double(model.hidden_states_names{1}{idx_to_keep(i),3})};
        
        
        if i > 1 && ~strcmp(model.hidden_states_names{1}{idx_to_keep(i)-1,3},  ...
                model.hidden_states_names{1}{idx_to_keep(i),3})
            loop=0;
        end
        
        loop=loop+1;
               
        match = [string('^'),string('{'),string('}'), string('x')];
        full_Labels{i} = [ sensor_name, '_', ...
            erase(model.hidden_states_names{1}{idx_to_keep(i),1}, match), ...
            '_', num2str(loop)];
        
 
    elseif i >  length(idx_to_keep) && ...
            i <= length(idx_to_keep)+ numberOfTimeSeries
        
        inc=inc+1;
        full_Labels{i} = ['Predicted_' data.labels{inc}];
        
    else
        
        full_Labels{i} = 'ModelProbability';
    end
    
end

mean = [ dataset_x(idx_to_keep,:)' dataset_y' Pr_M ];
std = [ sqrt(dataset_V(idx_to_keep,:))' sqrt(dataset_Vy)' ...
    zeros(length(timestamps),1)];

%% Create structure for saving

dat.timestamps = timestamps;
dat.Mean = mean;
dat.StandardDeviation =  std;
dat.labels = full_Labels;

save(Filename, '-struct', 'dat')
fprintf(fileID, '     Results saved in %s. \n', Filename);

%--------------------END CODE ------------------------
end
