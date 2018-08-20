function pilotePlot(data, model, estimation, misc)
%PILOTEPLOT Pilote function to plot data and estimations
%
%   SYNOPSIS:
%     PILOTEPLOT(data, model, estimation, misc)
%
%   INPUT:
%      data                - structure
%                            see documentation for details about the fields
%                            in structure "data"
%
%      model               - structure
%                            see documentation for details about the fields
%                            in structure "model"
%
%      estimation         - structure
%                            see documentation for details about the fields
%                            in structure "estimation"
%
%      misc               - structure
%                            see documentation for details about the fields
%                            in structure "misc"
%   OUTPUT:
%      N/A
%      Figures on screen and/or figures saved
%
%   DESCRIPTION:
%      PILOTEPLOT Pilote function to plot data and estimations
%
%   EXAMPLES:
%      PILOTEPLOT(data, model, estimation, misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%     plotEstimations, verificationDataStructure
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also PLOTESTIMATIONS, VERIFICATIONDATASTRUCTURE

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
%       July 27, 2018
%
%   DATE LAST UPDATE:
%       August 9, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'estimation', @isstruct );
addRequired(p,'misc', @isstruct );
parse(p,data, model, estimation, misc );

data=p.Results.data;
model=p.Results.model;
estimation=p.Results.estimation;
misc=p.Results.misc;


% Set fileID for logfile
if misc.isQuiet
    % output message in logfile
    fileID=fopen(misc.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end

fprintf(fileID,'\n');
fprintf(fileID,['-----------------------------------------', ...
    '-----------------------------------------------------\n']);
fprintf(fileID,'/    Plot\n');
fprintf(fileID,['-----------------------------------------', ...
    '-----------------------------------------------------\n']);

isCorrectAnswer =  false;
while ~isCorrectAnswer
    fprintf(fileID,'\n');
    fprintf(fileID,'     1 ->  Plot data \n');
    fprintf(fileID,'     2 ->  Plot hidden states \n');
    fprintf(fileID,'\n');
    fprintf(fileID,'     Type R to return to the previous menu\n');
    fprintf(fileID,'\n');
    
    if misc.BatchMode.isBatchMode
        user_inputs.inp_2=eval(char(misc.BatchMode.Answers ...
            {misc.BatchMode.AnswerIndex}));
        user_inputs.inp_2 = num2str(user_inputs.inp_2);
        if ischar(user_inputs)
            fprintf(fileID, '     %s  \n', user_inputs);
        else
            fprintf(fileID, '     %s  \n', num2str(user_inputs));
        end
        
    else
        user_inputs.inp_2 = input('     choice >> ', 's');
    end
    
    % Remove space and simple/double quotes
    user_inputs.inp_2=strrep(user_inputs.inp_2,'''','');
    user_inputs.inp_2=strrep(user_inputs.inp_2,'"','' );
    user_inputs.inp_2=strrep(user_inputs.inp_2, ' ','' );
    
    
    if ischar(user_inputs.inp_2) && length(user_inputs.inp_2) == 1 && ...
            strcmpi(user_inputs.inp_2, 'R')
        break
        
    elseif round(str2double(user_inputs.inp_2)) == 1
        
        [isValid] = verificationDataStructure(data);
        
        if isValid
            plotData(data, misc, ...
                'FilePath', 'figures', ...
                'isPdf', false, ...
                'isSaveFigure', false)
            isCorrectAnswer =  true;
        else
            disp(' ')
            disp(['     ERROR: Unable to ', ...
                'read the data from the structure.']);
            disp(' ')
            continue
        end
        
    elseif round(str2double(user_inputs.inp_2)) == 2
        plotEstimations(data, model, estimation, misc, ...
            'FilePath', 'figures', ...
            'isExportTEX', false, ...
            'isExportPNG', false, ...
            'isExportPDF', false);
        isCorrectAnswer =  true;
    else
        fprintf(fileID,'\n');
        fprintf(fileID,'      wrong input\n');
        continue
    end
    
end

misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;

%--------------------END CODE ------------------------
end
