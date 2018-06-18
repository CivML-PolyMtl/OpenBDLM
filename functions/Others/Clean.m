function Clean(FoldersList)
%CLEAN Permanently removes all elements in specified directories
%
%   SYNOPSIS:
%     CLEAN(FoldersList)
%
%   INPUT:
%      FolderList - cell array of strings (required)
%                   FolderList contains list of folder to delete
%
%   OUTPUT:
%      N/A
%      All files and subdirectories in specified directories are permanently
%      removed
%
%   DESCRIPTION:
%      CLEAN permanently removes all elements in specified directories
%      Elements include files and subdirectories
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
%       April 17, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications

p = inputParser;

addRequired(p,'FoldersList', @iscell);

parse(p, FoldersList);

FoldersList=p.Results.FoldersList;

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

fprintf('Do you want to remove the content of ');
fprintf('%s, ', FoldersList{1:end});
fprintf('?\n')

isYesNoCorrect= false;
while ~isYesNoCorrect
    choice = input('     (y/n) >> ','s');
    if isempty(choice)
        disp(' ')
        disp('     wrong input --> please make a choice')
        disp(' ')
    elseif strcmp(choice,'y') || strcmp(choice,'yes') ||  ...
            strcmp(choice,'Y') || strcmp(choice,'Yes')  || ...
            strcmp(choice,'YES')
        
        for i=1:length(FoldersList)
            
            if exist(FoldersList{i}, 'dir') == 0 && ...
                    exist(FoldersList{i}, 'file') == 0
                
                disp(' ')
                fprintf('WARNING: %s does not exist.\n',  ...
                    char(FoldersList{i}))
                disp(' ')
                continue
            else
                
                command = ['rm -rf ', FoldersList{i}];
                [status,~] = system(command);
                
                if status ~= 0
                    disp(' ')
                    fprintf('WARNING: Impossible to remove %s .\n',  ...
                        char(FoldersList{i}))
                    disp(' ')
                end
                
            end
            
        end
        
        isYesNoCorrect =  true;
        
    elseif strcmp(choice,'n') || strcmp(choice,'no') ||  ...
            strcmp(choice,'N') || strcmp(choice,'No')  || ...
            strcmp(choice,'NO')
        
        fprintf('No files has been removed.\n')
        isYesNoCorrect =  true;
        
    else
        disp(' ')
        disp('     wrong input')
        disp(' ')
    end
    
end

fprintf('-> Done.')
disp(' ')
%--------------------END CODE ------------------------
end
