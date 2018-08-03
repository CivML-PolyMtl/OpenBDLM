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
%       July 27, 2018

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

disp(' ')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])
disp('/    Plot')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])

isCorrectAnswer =  false;
while ~isCorrectAnswer
    disp(' ')
    disp('     1 ->  Plot data')
    disp('     2 ->  Plot hidden states')
    disp(' ')
    disp('     Type ''R'' to return to the previous menu')
    disp(' ')
    
    if misc.BatchMode.isBatchMode
        user_inputs.inp_2=eval(char(misc.BatchMode.Answers ...
            {misc.BatchMode.AnswerIndex}));
        disp(user_inputs.inp_2)
    else
        user_inputs.inp_2 = input('     choice >> ');
    end
    
    
    if ischar(user_inputs.inp_2) && length(user_inputs.inp_2) == 1 && ...
            strcmpi(user_inputs.inp_2, 'R')
        break
    elseif user_inputs.inp_2 == 1
        
        [isValid] = verificationDataStructure(data);
        
        if isValid
            disp(' ')
            disp('     ...in progress')
            plotData(data, misc, ...
                'FilePath', 'figures', ...
                'isPdf', false, ...
                'isSaveFigure', false)
            isCorrectAnswer =  true;
        else
            continue
        end
        
    elseif user_inputs.inp_2 == 2
        disp(' ')
        disp('     ...in progress')
        plotEstimations(data, model, estimation, misc, ...
            'FilePath', 'figures', ...
            'isExportTEX', false, ...
            'isExportPNG', false, ...
            'isExportPDF', false);
        isCorrectAnswer =  true;
    else
        disp(' ')
        disp('      wrong input')
        continue
    end
    
end

misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;

%--------------------END CODE ------------------------
end
