function Clean(varargin)
%CLEAN Clean OpenBDLM folder tree
%
%   SYNOPSIS:
%     CLEAN(FoldersList)
%
%   INPUT:
%
%      FolderList           - cell array of strings (optionnal)
%                             FolderList contains list of folder to delete
%                             default: {'saved_projects', 'config_files', 'processed_data', 'figures', 'raw_data'}
%
%      isForceDelete        - logical (optionnal)
%                             if isForceDelete, delete without notice
%                             default = false
%
%   OUTPUT:
%      N/A
%      All files and subdirectories in specified directories are permanently
%      removed
%
%   DESCRIPTION:
%      CLEAN permanently removes all elements in specified directories
%      Elements include files and subdirectories
%      CLEAN also add specific hidden files for git file management
%
%   EXAMPLES:
%      CLEAN({'raw_data', 'processed_data'})
%      CLEAN({'figures'})

%   AUTHORS:
%      Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       April 17, 2018
%
%   DATE LAST UPDATE:
%       August 21, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications

p = inputParser;

defaultFilderList = {'saved_projects', 'config_files', 'data', ...
    'figures', 'log_files'};

defaultisForceDelete = false;

addParameter(p,'FoldersList', defaultFilderList, @iscell);
addParameter(p, 'isForceDelete', defaultisForceDelete, @islogical)

parse(p, varargin{:});

FoldersList=p.Results.FoldersList;
isForceDelete = p.Results.isForceDelete;

%% Clean the list of CSV files

% Remove empty fields
FoldersList=FoldersList(~cellfun(@isempty, FoldersList));

if isempty(FoldersList)
    disp(' ')
    disp('WARNING: Folder list is empty.')
    disp(' ')
    return
end

% Remove redundant fields
FoldersList=unique(FoldersList);

if ~isForceDelete
    
    %% Notice user that we are about to permanently remove folder content
    fprintf('Do you want to remove the content of ');
    fprintf('%s, ', FoldersList{1:end});
    fprintf('? (y/n)\n')
    
    isYesNoCorrect= false;
    while ~isYesNoCorrect
        choice = input('     choice >> ','s');
        if isempty(choice)
            disp(' ')
            disp('     wrong input')
            disp(' ')
        elseif strcmpi(choice,'y') || strcmpi(choice,'yes')
            
            isYesNoCorrect =  true;
            
        elseif strcmpi(choice,'n') || strcmpi(choice,'no')
            disp(' ')
            disp('     No files has been removed.')
            disp(' ')
            return
        else
            disp(' ')
            disp('     wrong input')
            disp(' ')
        end
        
    end
    
end

%% Deletion
%disp('     Cleaning folder tree...')
for i=1:length(FoldersList)
    
    isDir = testFileExistence(FoldersList{i}, 'dir');
    
    if ~isDir
        disp(' ')
        fprintf('WARNING: %s does not exist.\n',  ...
            char(FoldersList{i}))
        disp(' ')
        continue
    else
        
        warning off
        % Delete folders
        try rmdir(fullfile(FoldersList{i}, '*'), 's')
        catch
        end
        
        % Delete files
        try delete(fullfile(FoldersList{i}, '*'))
        catch
        end
        warning on
        
        % Add file .keep to allow the directory to be push in Git
        % repos
        phantomFilename='.keep';
        
        fileID=fopen(fullfile(FoldersList{i}, ...
            phantomFilename), 'w');
        fclose(fileID);
        
        
        % re-build tree directory for data
        if strcmp(FoldersList{i}, 'data')
            mkdir(fullfile('data', 'mat'));
            mkdir(fullfile('data', 'csv'));
            addpath(fullfile('data', 'mat'));
            addpath(fullfile('data', 'csv'));
            
            fileID=fopen(fullfile(FoldersList{i}, ...
                'mat', phantomFilename), 'w');
            fclose(fileID);
            
            fileID=fopen(fullfile(FoldersList{i}, ...
                'csv', phantomFilename), 'w');
            fclose(fileID);
            
        end
        
        
        % Add .gitignore file
        gitignorefilename='.gitignore';
        fileID=fopen(fullfile(FoldersList{i}, ...
            gitignorefilename), 'w');
        
        fprintf(fileID, 'LOG_*\n');
        fprintf(fileID, 'DATA_*\n');
        fprintf(fileID, 'PROJ_*\n');
        fprintf(fileID, 'CFG_*\n');
        fprintf(fileID, 'ProjectsInfo.mat\n');
        fprintf(fileID, '*/*/*.csv\n');
        fprintf(fileID, '*/*.fig\n');
        fprintf(fileID, '*/*.pdf\n');
        fprintf(fileID, '*/*.png\n');
        
        
        
    end
    
end
disp(' ')
%--------------------END CODE ------------------------
end
