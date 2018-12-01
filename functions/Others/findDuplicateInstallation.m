function findDuplicateInstallation
%FINDDUPLICATEINSTALLATION Warning if conflictous OpenBDLM installation
%
%   SYNOPSIS:
%     FINDDUPLICATEINSTALLATION(misc)
%
%   INPUT:
%
%   OUTPUT:
%
%   DESCRIPTION:
%      FINDDUPLICATEINSTALLATION Warning if duplicate OpenBDLM installation
%
%   EXAMPLES:
%      FINDDUPLICATEINSTALLATION(misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also

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
%       September 17, 2018
%
%   DATE LAST UPDATE:
%       November 30, 2018

%--------------------BEGIN CODE ---------------------

functionPath = 'functions';

% List folder in function path
MyFolderInfo = dir(functionPath);

MyFolderInfo=MyFolderInfo(~ismember({MyFolderInfo.name}, ...
    {'.','..', '.DS_Store'}));

isDuplicate =  false;
if ~isempty(MyFolderInfo)  % the file does not exist
    
    for j=1:length(MyFolderInfo)
        
        FolderName=MyFolderInfo(j).name;
        
        P=path;
        P=strsplit(P, pathsep());
        
        IndexC = strfind(P, FolderName);
        Index = find(not(cellfun('isempty', IndexC)));
        
        if length(Index) > 1
            isDuplicate = true;
        end
        
    end
end

if isDuplicate   
    warning(['Possible multiple conflictous OpenBLDM installations ', ...
        'have been detected. ', ...
        'Verify that only one version of the software is on the Matlab '...
        'path to prevent errors.'])
    disp(' ')
end

%--------------------END CODE ------------------------
end
