function [misc] = pilotePlot(data, model, estimation, misc)
%PILOTEPLOT Pilote function to plot data and estimations
%
%   SYNOPSIS:
%     [misc] = PILOTEPLOT(data, model, estimation, misc)
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
%      misc               - structure
%                            see documentation for details about the fields
%                            in structure "misc"
%
%      Figures on screen and/or figures saved
%
%   DESCRIPTION:
%     PILOTEPLOT Pilote function to plot data and estimations
%
%   EXAMPLES:
%      [misc] = PILOTEPLOT(data, model, estimation, misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%     plotEstimations, verificationMergedDataset
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also PLOTESTIMATIONS, VERIFICATIONMERGEDDATASET

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
%       December 6, 2018

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

%% Get options from misc
isExportPNG=misc.options.isExportPNG;
isExportPDF=misc.options.isExportPDF;
isExportTEX=misc.options.isExportTEX;

FigurePath=misc.internalVars.FigurePath ;

MaxFailAttempts = 4;

% Set fileID for logfile
if misc.internalVars.isQuiet
    % output message in logfile
    fileID=fopen(misc.internalVars.logFileName, 'a');
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
incTest = 0;
isCorrectAnswer =  false;
while ~isCorrectAnswer
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    
    fprintf(fileID,'\n');
    fprintf(fileID,'     1 ->  Plot data \n');
    fprintf(fileID,'     2 ->  Plot data summary \n');
    fprintf(fileID,'     3 ->  Plot hidden states \n');
    fprintf(fileID,'\n');
    fprintf(fileID,'     Type R to return to the previous menu\n');
    fprintf(fileID,'\n');
    
    if misc.internalVars.BatchMode.isBatchMode
        user_inputs.inp_2=eval(char(misc.internalVars.BatchMode.Answers ...
            {misc.internalVars.BatchMode.AnswerIndex}));
        user_inputs.inp_2 = num2str(user_inputs.inp_2);
        if ischar(user_inputs.inp_2)
            fprintf(fileID, '     %s  \n', user_inputs.inp_2);
        else
            fprintf(fileID, '     %s  \n', num2str(user_inputs.inp_2));
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
        
        [isMerged]=verificationMergedDataset(data);
        
        if isMerged
            plotData(data, misc, ...
                'isPlotTimestep', true, ...
                'isExportTEX', isExportTEX, ...
                'isExportPNG', isExportPNG, ...
                'isExportPDF', isExportPDF);
            
            isCorrectAnswer =  true;
        else
            disp(' ')
            error('Unable to read the data from the structure.');
        end
        
    elseif round(str2double(user_inputs.inp_2)) == 2
        
        plotDataSummary(data, misc, 'FilePath', FigurePath, ...
            'isExportTEX', isExportTEX, ...
            'isExportPNG', isExportPNG, ...
            'isExportPDF', isExportPDF);
        
        isCorrectAnswer =  true;       
    elseif round(str2double(user_inputs.inp_2)) == 3
        
        plotEstimations(data, model, estimation, misc, ...
            'FilePath', FigurePath, ...
            'isExportTEX', isExportTEX, ...
            'isExportPNG', isExportPNG, ...
            'isExportPDF', isExportPDF);
        
        isCorrectAnswer =  true;
    else
        fprintf(fileID,'\n');
        fprintf(fileID,'      wrong input\n');
        continue
    end
    
end

misc.internalVars.BatchMode.AnswerIndex = ...
    misc.internalVars.BatchMode.AnswerIndex+1;

%--------------------END CODE ------------------------
end
