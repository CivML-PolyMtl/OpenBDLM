function [misc]=piloteExport(data, model, estimation, misc)
%PILOTEEXPORT Pilote function to export data, estimations and project
%
%   SYNOPSIS:
%     [misc]=PILOTEEXPORT(data, model, estimation, misc)
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
%      Files and figures saved in specified directories
%
%   DESCRIPTION:
%      PILOTEEXPORT export data, estimations and project in configuration
%      file
%
%   EXAMPLES:
%      [misc]=PILOTEEXPORT(data, model, estimation, misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%      printConfigurationFile, saveDataCSV, plotEstimations
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also PRINTCONFIGURATIONFILE, SAVEDATACSV, PLOTESTIMATIONS

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
%       December 6, 2018
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

FigurePath=misc.internalVars.FigurePath ;
ConfigPath=misc.internalVars.ConfigPath;
DataPath=misc.internalVars.DataPath;
ResultsPath=misc.internalVars.ResultsPath;

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
fprintf(fileID,'/    Export\n');
fprintf(fileID,['-----------------------------------------', ...
    '-----------------------------------------------------\n']);

isCorrectAnswer =  false;
incTest = 0;
while ~isCorrectAnswer
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    fprintf(fileID,'\n');
    fprintf(fileID,['     1 ->  Export the project ', ...
        'in a configuration file\n']);
    fprintf(fileID,'     2 ->  Export data in CSV format\n');
    fprintf(fileID,['     3 ->  Export results', ...
        ' in CSV format\n']);
    fprintf(fileID,'     4 ->  Create and export figures \n');
    fprintf(fileID,'\n');
    fprintf(fileID,'     Type R to return to the previous menu\n');
    fprintf(fileID,'\n');
    
    if misc.internalVars.BatchMode.isBatchMode
        user_inputs.inp_1=eval(char(misc.internalVars.BatchMode.Answers ...
            {misc.internalVars.BatchMode.AnswerIndex}));
        user_inputs.inp_1 = num2str(user_inputs.inp_1);
        if ischar(user_inputs.inp_1)
            fprintf(fileID, '     %s  \n', user_inputs.inp_1);
        else
            fprintf(fileID, '     %s  \n', num2str(user_inputs.inp_1));
        end
        
    else
        user_inputs.inp_1 = input('     choice >> ', 's');
    end
    
    % Remove space and simple/double quotes
    user_inputs.inp_1=strrep(user_inputs.inp_1,'''','');
    user_inputs.inp_1=strrep(user_inputs.inp_1,'"','' );
    user_inputs.inp_1=strrep(user_inputs.inp_1, ' ','' );
    
    if ischar(user_inputs.inp_1) && length(user_inputs.inp_1) == 1 && ...
            strcmpi(user_inputs.inp_1, 'R')
        break
        
    elseif round(str2double(user_inputs.inp_1)) == 1
        % Export project in configuration file format
        [~] = printConfigurationFile(data, model, ...
            estimation, misc, 'FilePath', ConfigPath);
        isCorrectAnswer =  true;
    elseif round(str2double(user_inputs.inp_1)) == 2
        % Export data in CSV format
        [misc] = saveDataCSV(data, misc, 'FilePath', DataPath);
        isCorrectAnswer =  true;
    elseif round(str2double(user_inputs.inp_1)) == 3
        % Export hidden states in CSV format
        [misc]=saveResultsCSV(data, model, estimation, misc, ...
            'FilePath', ResultsPath);
        
        isCorrectAnswer =  true;
    elseif round(str2double(user_inputs.inp_1)) == 4
        
        
        misc.internalVars.BatchMode.AnswerIndex = ...
            misc.internalVars.BatchMode.AnswerIndex+1;
        
        % Export figures in PNG, PDF or TEX format
        incTest_2=0;
        isAnswerCorrect = false;
        while ~isAnswerCorrect
            
            incTest_2=incTest_2+1;
            if incTest_2 > MaxFailAttempts ; error(['Too many failed ', ...
                    'attempts (', num2str(MaxFailAttempts)  ').']) ; end
            
            fprintf(fileID,'\n');
            fprintf(fileID,'     1 ->  Export figures in PNG\n');
            fprintf(fileID,'     2 ->  Export figures in PDF\n');
            fprintf(fileID,'     3 ->  Export figures in TEX\n');
            fprintf(fileID,'\n');
            
            if misc.internalVars.BatchMode.isBatchMode
                user_inputs.inp_2= ...
                    eval(char(misc.internalVars.BatchMode.Answers{...
                    misc.internalVars.BatchMode.AnswerIndex}));
                user_inputs.inp_2 = num2str(user_inputs.inp_2);
                fprintf(fileID,'     %s', num2str(user_inputs.inp_2));
            else
                fprintf(fileID,'\n');
                user_inputs.inp_2 = input('     choice >> ', 's');
            end
            
            % Remove space and simple/double quotes
            user_inputs.inp_2=strrep(user_inputs.inp_2,'''','');
            user_inputs.inp_2=strrep(user_inputs.inp_2,'"','' );
            user_inputs.inp_2=strrep(user_inputs.inp_2, ' ','' );
            
            if round(str2double(user_inputs.inp_2)) == 1
                
                isExportTEX = false;
                isExportPNG = true;
                isExportPDF = false;
                
                isAnswerCorrect = true;
                
            elseif round(str2double(user_inputs.inp_2)) == 2
                
                isExportTEX = false;
                isExportPNG = false;
                isExportPDF = true;
                
                isAnswerCorrect = true;
            elseif round(str2double(user_inputs.inp_2)) == 3
                
                isExportTEX = true;
                isExportPNG = false;
                isExportPDF = false;
                
                isAnswerCorrect = true;
            else
                fprintf(fileID,'\n');
                fprintf(fileID,'     wrong input\n');
                fprintf(fileID,'\n');
                continue
            end
                     
        end
            plotData(data, misc, ...
                'isPlotTimestep', true, ...
                'isExportTEX', isExportTEX, ...
                'isExportPNG', isExportPNG, ...
                'isExportPDF', isExportPDF, ...
                'isVisible'   , false  );
            
            
            plotEstimations(data, model, estimation, misc, ...
                'FilePath', FigurePath, ...
                'isExportTEX',  isExportTEX, ...
                'isExportPNG',  isExportPNG, ...
                'isExportPDF',  isExportPDF, ...
                'isVisible'  ,  false);
        
        incTest = 0;
        isCorrectAnswer =  true;
        
%         misc.internalVars.BatchMode.AnswerIndex = ...
%             misc.internalVars.BatchMode.AnswerIndex+1;
        
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
