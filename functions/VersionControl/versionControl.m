function [controlOut]=versionControl(misc, varargin)
%VERSIONCONTROL Version control for OpenBDLM
%
%   SYNOPSIS:
%     [controlOut]=VERSIONCONTROL(misc, varargin)
%
%   INPUT:
%      misc                 - structure (required)
%                            see documentation for details about the fields
%                            in structure "misc"
%
%      FilePath             - character (optionnal)
%                             Path of the directory in which version
%                             control files are stored
%                             default = '.'(current directory)
%
%   OUTPUT:
%      controlOut          - cell array
%                            controlOut stores the results of the version
%                            control tests
%
%   DESCRIPTION:
%      VERSIONCONTROL controls version of OpenBDLM
%
%   EXAMPLES:
%      [controlOut]=VERSIONCONTROL(misc)
%      [controlOut]=VERSIONCONTROL(misc, 'FilePath','version_control')
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also

%   AUTHORS:
%       Ianis Gaudot, Luong Ha Nguyen,  James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.4.0.813654 (R2018a)
%
%   DATE CREATED:
%       August 6, 2018
%
%   DATE LAST UPDATE:
%       August 7, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;
defaultFilePath = '.';
validationFct_FilePath = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p,'misc',  @isstruct);
addParameter(p,'FilePath',defaultFilePath, validationFct_FilePath);

parse(p,misc, varargin{:});

misc=p.Results.misc;
FilePath=p.Results.FilePath;

ProjectPath=misc.ProjectPath;
ProjectInfofile = misc.ProjectInfoFilename;

sse_threshold=1E-3;

%% Search for all CFG files in FilePath

InfoFile_1=dir(fullfile(FilePath, '*CFG*'));

if isempty(InfoFile_1)  % the file does not exist
    disp(' ')
    fprintf('     No version control configuration file(s) found in %s\n',...
        FilePath)
    disp(' ')
    return
else
    controlOut={};
    for j=1:length(InfoFile_1)
        
        % Get name of the files
        ConfigFileName_src=InfoFile_1(j).name;
        
        % Get reference name
        subref_1=strsplit(ConfigFileName_src, 'CFG_');
        subref_2=strsplit(subref_1{2}, '.');
        refname = subref_2{1};
        
        disp(' ')
        disp(['- Version control test #', num2str(j)]);
        disp(' ')
        
        
        DataFileName_src=['DATA_', refname, '.mat'];
        ProjectFileName_src=['PROJ_', refname, '.mat'];
        
        % Search for DATA_refname and PROJ_refname in FilePath
        InfoFile_2=dir(fullfile(FilePath, DataFileName_src));
        InfoFile_3=dir(fullfile(FilePath, ProjectFileName_src));
        
        if isempty(InfoFile_2) || isempty(InfoFile_3)
            continue
        else
            
            %Get y_ref
            project = load(fullfile(FilePath, ProjectFileName_src ));
            if isfield(project.estimation, 'y')
                y_ref=project.estimation.y;
            else
                continue
            end
            
            % Try to run OpenBLDM to compute y_test
            try
                [~, ~, estimation, ~] = ...
                    OpenBDLM_main({['''',ConfigFileName_src,''''], ...
                    '3', '1', '''Q'''});
                isRun = true;
            catch
                isRun = false;
                isValidSSE=false;
                mean_sse = Inf;
            end
            
            if isRun
                
                % Get predicted data from current version
                y_test=estimation.y;
                
                % Verify size are compatible
                if size(y_ref, 1) ~= size(y_test, 1) || ...
                        size(y_ref, 2) ~= size(y_ref, 2)
                    continue
                end
                
                % Compute sum squared error between y_test and y_ref
                sse_sum=0;
                for i=1:size(y_ref,2)
                    
                    sse=mean((y_ref(:,i)-y_test(:,i)).^2);
                    sse_sum=sse+sse_sum;
                end
                
                mean_sse=sse_sum/size(y_ref,2);
                
                if mean_sse < sse_threshold
                    isValidSSE=true;
                else
                    isValidSSE=false;
                end
                
            end
            
        end
        
        controlOut=[controlOut ; {refname, isRun, isValidSSE, mean_sse}];
        
        
        disp(' ')
        if ~isRun || ~isValidSSE
            resStr = 'FAIL';
        else
            resStr = 'PASS';
        end
        
        disp( ['     ==> Version control ', ...
            'test ' , num2str(j), ': ' , resStr]);
        disp(' ')
        
        
    end
    
end

% Clean folder tree
Clean('isForceDelete', true);

%--------------------END CODE ------------------------
end
