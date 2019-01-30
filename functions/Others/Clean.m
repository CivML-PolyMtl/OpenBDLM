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
%      Pattern              - character (optionnal)
%                             files and folder containing pattern are not
%                             deleted
%                             default: 'Example'
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
%      CLEAN('FolderList', {'raw_data', 'processed_data'}, 'Pattern', '')
%      CLEAN({'FolderList','figures'})

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
%       January 29, 2019

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications

p = inputParser;

defaultFoldersList = {'saved_projects', 'config_files', 'data', ...
    'figures', 'log_files', 'results'};

defaultisForceDelete = false;

defaultPattern = 'Example';

addParameter(p,'FoldersList', defaultFoldersList, @iscell);
addParameter(p, 'isForceDelete', defaultisForceDelete, @islogical)
addParameter(p, 'Pattern', defaultPattern, @ischar)

parse(p, varargin{:});

FoldersList=p.Results.FoldersList;
isForceDelete = p.Results.isForceDelete;
pattern = p.Results.Pattern;

%% Clean the list of CSV files

% Remove empty fields
FoldersList=FoldersList(~cellfun(@isempty, FoldersList));

if isempty(FoldersList)
    disp(' ')
    error('Folder list is empty.')
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
%disp('     Cleaning and building folder tree...')
for i=1:length(FoldersList)
    
    isDir = testFileExistence(FoldersList{i}, 'dir');
    
    if ~isDir
        
        % Create the folder
        mkdir(FoldersList{i});
        addpath(FoldersList{i});
        
        % Add file .keep to allow the directory to be push in Git
        % repos
        phantomFilename='.keep';
        
        fileID=fopen(fullfile(FoldersList{i}, ...
            phantomFilename), 'w');
        fclose(fileID);
                
        % re-build tree directory for data folder
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
        
        % re-build tree directory for results folder
        if strcmp(FoldersList{i}, 'results')
            mkdir(fullfile('results', 'mat'));
            mkdir(fullfile('results', 'csv'));
            addpath(fullfile('results', 'mat'));
            addpath(fullfile('results', 'csv'));
            
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
%        fprintf(fileID, 'DATA_*\n');
        fprintf(fileID, 'PROJ_*\n');
%        fprintf(fileID, 'CFG_*\n');
        fprintf(fileID, 'RES_*\n');
        fprintf(fileID, 'ProjectsInfo.mat\n');
%        fprintf(fileID, '*/*/*.csv\n');
        fprintf(fileID, '*/*.fig\n');
        fprintf(fileID, '*/*.pdf\n');
        fprintf(fileID, '*/*.png\n');
        
        continue
    else
        
        if strcmp(FoldersList{i}, 'config_files')
            
            MyFolderInfoCFG=dir(FoldersList{i});
            
            % remove '.' and '..' files from the list of files
            MyFolderInfoCFG=MyFolderInfoCFG(~ismember(...
                {MyFolderInfoCFG.name},{'.','..'}));
            
            if ~isempty(MyFolderInfoCFG)
                
                for j=1:length(MyFolderInfoCFG)
                    
                    if isempty(strfind(MyFolderInfoCFG(j).name, pattern))
                        
                        warning off
                        
                        % Delete folders
                        try rmdir(fullfile(FoldersList{i}, ...
                                MyFolderInfoCFG(j).name), 's')
                        catch
                        end
                        
                        % Delete files
                        try  delete(fullfile(FoldersList{i}, ...
                                MyFolderInfoCFG(j).name))
                        catch
                        end
                        warning on
                        
                    end
                    
                end
                
            end
            
        elseif strcmp(FoldersList{i}, 'data')
            
            % Handle data/csv files and folders
            
            MyFolderInfoCSV=dir(fullfile(FoldersList{i}, 'csv'));
            
            % remove '.' and '..' files from the list of files
            MyFolderInfoCSV= MyFolderInfoCSV(~ismember( ...
                {MyFolderInfoCSV.name},{'.','..'}));
            
            if ~isempty(MyFolderInfoCSV)
                
                for j=1:length(MyFolderInfoCSV)
                    
                    if isempty(strfind(MyFolderInfoCSV(j).name, pattern))
                        
                        warning off
                        % Delete folders
                        try rmdir(fullfile(FoldersList{i}, ...
                                'csv', MyFolderInfoCSV(j).name), 's')
                        catch
                        end
                        
                        % Delete files
                        try    delete(fullfile(FoldersList{i}, ...
                                'csv', MyFolderInfoCSV(j).name))
                        catch
                        end
                        warning on
                    end
                    
                end
                
            end
            
            % Handle data/mat files and folders
            
            MyFolderInfoMAT=dir(fullfile(FoldersList{i}, 'mat'));
            
            % remove '.' and '..' files from the list of files
            MyFolderInfoMAT=MyFolderInfoMAT(~ismember( ...
                {MyFolderInfoMAT.name},{'.','..'}));
            
            if ~isempty(MyFolderInfoMAT)
                
                for j=1:length(MyFolderInfoMAT)
                    
                    if isempty(strfind(MyFolderInfoMAT(j).name, pattern))
                                                
                        warning off
                        % Delete folders
                        try rmdir(fullfile(FoldersList{i}, ...
                                'mat', MyFolderInfoMAT(j).name), 's')
                        catch
                        end
                        
                        % Delete files
                        try    delete(fullfile(FoldersList{i},...
                                'mat', MyFolderInfoMAT(j).name))
                        catch
                        end
                        warning on
                        
                    end
                    
                end
                
            end
            
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
            
        end
        
        % Add file .keep to allow the directory to be push in Git
        % repos
        phantomFilename='.keep';
        
        fileID=fopen(fullfile(FoldersList{i}, ...
            phantomFilename), 'w');
        fclose(fileID);
                
        % re-build tree directory for data folder
        if strcmp(FoldersList{i}, 'data')
            warning off
            mkdir(fullfile('data', 'mat'));
            mkdir(fullfile('data', 'csv'));
            addpath(fullfile('data', 'mat'));
            addpath(fullfile('data', 'csv'));
            warning on
            fileID=fopen(fullfile(FoldersList{i}, ...
                'mat', phantomFilename), 'w');
            fclose(fileID);
            
            fileID=fopen(fullfile(FoldersList{i}, ...
                'csv', phantomFilename), 'w');
            fclose(fileID);
            
        end
        
        % re-build tree directory for results folder
        if strcmp(FoldersList{i}, 'results')
            warning off
            mkdir(fullfile('results', 'mat'));
            mkdir(fullfile('results', 'csv'));
            addpath(fullfile('results', 'mat'));
            addpath(fullfile('results', 'csv'));
            warning on
            
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
%        fprintf(fileID, 'DATA_*\n');
        fprintf(fileID, 'PROJ_*\n');
%        fprintf(fileID, 'CFG_*\n');
        fprintf(fileID, 'RES_*\n');
        fprintf(fileID, 'ProjectsInfo.mat\n');
%        fprintf(fileID, '*/*/*.csv\n');
        fprintf(fileID, '*/*.fig\n');
        fprintf(fileID, '*/*.pdf\n');
        fprintf(fileID, '*/*.png\n');
        
    end
    
end
disp(' ')
%--------------------END CODE ------------------------
end
