function [misc]=saveResultsCSV(data, model, estimation, misc, varargin)
%SAVERESULTSCSV Save results in CSV files
%
%   SYNOPSIS:
%     [misc]=SAVERESULTSCSV(data, model, estimation, misc, varargin)
%
%   INPUT:
%      data       - structure (required)
%                   see the documentation for details about the
%                   field in misc
%
%      model      - structure (required)
%                   see the documentation for details about the
%                   field in misc
%
%      estimation - structure (required)
%                   see the documentation for details about the
%                   field in misc
%
%      misc       - structure (required)
%                   see the documentation for details about the
%                   field in misc
%
%      FilePath   - character (optional)
%                   directory where to save the CSV files
%                   default: '.'  (current folder)
%
%   OUTPUT:
%      misc       - structure (required)
%                   see the documentation for details about the
%                   field in misc
%
%      CSV files saved in the location given by FilePath.
%
%   DESCRIPTION:
%      SAVERESULTSCSV saves estimated hidden states, predicted data, and
%      model probability in CSV files
%
%   EXAMPLES:
%      [misc]=SAVERESULTSCSV(data, model, estimation, misc)
%      [misc]=SAVERESULTSCSV(data, model, estimation, misc, 'FilePath', '/results/csv')
%
%   EXTERNAL FUNCTIONS CALLED:
%      testFileExistence, incrementFilename
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also TESTFILEEXISTENCE, INCREMENTFILENAME

%   AUTHORS:
%        Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
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

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'estimation', @isstruct );
addRequired(p,'misc', @isstruct );
addParameter(p,'FilePath', defaultFilePath, validationFct_FilePath );
parse(p,data, model, estimation, misc, varargin{:});

data=p.Results.data;
model=p.Results.model;
estimation=p.Results.estimation;
misc=p.Results.misc;
FilePath=p.Results.FilePath;

FilePath_full=fullfile(FilePath, 'csv');

% Set fileID for logfile
if misc.internalVars.isQuiet
    % output message in logfile
    fileID=fopen(misc.internalVars.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end

disp('     Exporting results in CSV files ...')
disp(' ')
%% Verification if there are data to plot, or not
if ~isfield(estimation,'x')
    fprintf(fileID,'     No files to create.\n');
    fprintf(fileID,'\n');
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

%% Create subdirectory

fullname = fullfile(FilePath_full, misc.ProjectName);
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
                FilePath_full);
            fullname=fullfile(FilePath_full, name);
            
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

%% Write hidden states estimation in CSV

% Get number of hidden states
numberOfHiddenStates = size(model.hidden_states_names{1},1);

dataset_x=estimation.x; % mean estimated hidden states
dataset_V=estimation.V; % posterior variance estimated hidden states
loop=0;
% Loop over hidden states
for idx=1:numberOfHiddenStates
    if and(strncmpi(model.hidden_states_names{1}(idx,1),'x^{KR',5),...
            ~strcmp(model.hidden_states_names{1}(idx,1),'x^{KR1}')) && ...
            and(strncmpi(model.hidden_states_names{1}(idx,1),'x^{KR',5),...
            ~strcmp(model.hidden_states_names{1}(idx,1),'x^{KR0}'))
    else
        
        
        if idx > 1 && ~strcmp(model.hidden_states_names{1}{idx-1,3},  ...
                model.hidden_states_names{1}{idx,3})
            loop=0;
        end
        
        loop=loop+1;
        
    
        mu=dataset_x(idx,:)'; % posterior mean
        std=sqrt(dataset_V(idx,:)'); %posterior standard deviation
        
        % Define the name of the figure
        
        sensor_name = data.labels{ ...
            str2double(model.hidden_states_names{1}{idx,3})};
        
        match = [string('^'),string('{'),string('}'), string('x')];
        NameFile = [ sensor_name, '_', ...
            erase(model.hidden_states_names{1}{idx,1}, match), ...
            '_',num2str(loop),'.csv'];
        
        file_name=fullfile(fullname, NameFile);
        
        first_timestamps=data.timestamps(1);
        % Convert the serial date to string date
        date_str=datestr(first_timestamps, 'yyyy-mm-dd-HH:MM:SS');
        
        %create/open csv file
        fid = fopen(file_name, 'w');
        % write csv header
        fprintf(fid, '%s \n', [ sensor_name ', ''' date_str '''']) ;
        % write timestamps, posterior mean and standard deviation values in csv file
        dlmwrite( file_name, [data.timestamps(:) mu std] , ...
            '-append', 'precision','%f');
        % close file
        fclose(fid);
        
    end
    
end

%% Write predicted data in CSV file

% Get number of time series
numberOfTimeSeries = size(data.values,2);

% Get posterior mean and variance predicted data values

dataset_y=estimation.y;
dataset_Vy=estimation.Vy;

for idx=1:numberOfTimeSeries
    
    mu=dataset_y(idx,:)'; % posterior mean
    std=sqrt(dataset_Vy(idx,:)'); %posterior standard deviation
    
    NameFile = [data.labels{idx}, '_Predicted.csv' ];
    file_name=fullfile(fullname, NameFile);
    
    first_timestamps=data.timestamps(1);
    % Convert the serial date to string date
    date_str=datestr(first_timestamps, 'yyyy-mm-dd-HH:MM:SS');
    
    %create/open csv file
    fid = fopen(file_name, 'w');
    % write csv header
    fprintf(fid, '%s \n', [ sensor_name ', ''' date_str '''']) ;
    % write timestamps, posterior mean and standard deviation values in csv file
    dlmwrite( file_name, [data.timestamps(:) mu std] , ...
        '-append', 'precision','%f');
    % close file
    fclose(fid);
    
    
end


%% Write model probability in CSV file

Pr_M=estimation.S;      % posterior probability of models

if model.nb_class == 2
    Pr_M = Pr_M(:,2);
end

NameFile = 'ModelProbability.csv' ;
file_name=fullfile(fullname, NameFile);

first_timestamps=data.timestamps(1);
% Convert the serial date to string date
date_str=datestr(first_timestamps, 'yyyy-mm-dd-HH:MM:SS');

%create/open csv file
fid = fopen(file_name, 'w');
% write csv header
fprintf(fid, '%s \n', [ sensor_name ', ''' date_str '''']) ;
% write timestamps, posterior model probability in csv file
dlmwrite( file_name, [data.timestamps(:) Pr_M] , ...
    '-append', 'precision','%f');
% close file
fclose(fid);


fprintf(fileID,'\n');
fprintf(fileID,'     CSV files saved in %s \n', fullname);
fprintf(fileID,'\n');

%--------------------END CODE ------------------------
end
