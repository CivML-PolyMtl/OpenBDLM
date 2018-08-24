function [misc]=printOptions(misc)
%PRINTOPTIONS Print misc.options fields in configuration file format
%
%   SYNOPSIS:
%     [misc]=PRINTOPTIONS(misc)
%
%   INPUT:
%      misc             - structure (required)
%                         see documentation for details about the fields of
%                         misc
%
%   OUTPUT:
%      misc             - structure (required)
%                         see documentation for details about the fields of
%                         misc
%
%   DESCRIPTION:
%      PRINTOPTIONS prints misc.options fields in configuration file format
%
%   EXAMPLES:
%      [misc]=PRINTOPTIONS(misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also

%   AUTHORS:
%       Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.4.0.813654 (R2018a)
%
%   DATE CREATED:
%       August 14, 2018
%
%   DATE LAST UPDATE:
%       August 21, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'misc', @isstruct );
parse(p, misc);
misc=p.Results.misc;

% Set fileID for logfile
if misc.isQuiet
    % output message in logfile
    fileID=fopen(misc.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end


%% Display misc.options in configuration file format
fprintf(fileID,'\n');
fprintf(fileID, repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID, '\n');
fprintf(fileID, '%%%% F - Options \n');
fprintf(fileID, repmat('%s',1,75),repmat('%',1,75));
fprintf(fileID, '\n');
names = fieldnames(misc.options);

for i=1:length(names)
    
    if strcmp(names{i}, 'trainingPeriod') || ...
            strcmp(names{i}, 'FigurePosition')
        fprintf(fileID, 'misc.options.%s=[%s];\n', names{i},  ...
            strjoin(cellstr(num2str(misc.options.(names{i}))),', '));
        
    elseif strcmp(names{i}, 'MethodStateEstimation')
        
        fprintf(fileID, 'misc.options.%s=%s;\n', ...
            names{i}, ['''', num2str(misc.options.(names{i})), '''']);
        
    elseif strcmp(names{i}(1:2), 'is')
        
        if misc.options.(names{i})
        
        fprintf(fileID, 'misc.options.%s=%s;\n', ...
            names{i},  'true');
        
        else
                 fprintf(fileID, 'misc.options.%s=%s;\n', ...
            names{i},  'false');   
        end
    else
        fprintf(fileID, 'misc.options.%s=%s;\n', ...
            names{i}, num2str(misc.options.(names{i})));
    end
end



%--------------------END CODE ------------------------
end
