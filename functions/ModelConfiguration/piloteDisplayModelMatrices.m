function piloteDisplayModelMatrices(data, model, estimation, misc)
%PILOTEDISPLAYMODELMATRICES Pilote function to display model matrices
%
%   SYNOPSIS:
%     PILOTEDISPLAYMODELMATRICES(data, model, estimation, misc)
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
%
%   OUTPUT:
%      N/A
%      Display model matrices on screen
%
%   DESCRIPTION:
%      PILOTEDISPLAYMODELMATRICES Pilote function to display model matrices
%
%   EXAMPLES:
%      PILOTEDISPLAYMODELMATRICES(data, model, estimation, misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%      displayModelMatrices
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also DISPLAYMODELMATRICES

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
disp('/ Display model matrices')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])
disp(' ')
isCorrectAnswer_2 =  false;
disp('Timestamp index ? ')
while ~isCorrectAnswer_2
    user_inputs.inp_2 = input('     choice >> ');
    if isempty(user_inputs.inp_2)
        disp(' ')
        disp(['%%%%%%%%%%%%%%%%%%%%%%%%% ' ...
            ' > HELP < %%%%%%%%%%%%%%%%%%%%%%%'])
        disp(' ')
        disp('Choose timestamp index. ')
        disp('Timestamp index should be an integer value.')
        disp(' ')
        continue
    elseif ~any(rem(user_inputs.inp_2,1)) && ...
            (user_inputs.inp_2 < length(data.timestamps)) && ...
            (user_inputs.inp_2 ~= 0)
        TimestampIndex = user_inputs.inp_2;
        
        % Display model matrices
        displayModelMatrices(data, model, estimation, misc, TimestampIndex)
        
        isCorrectAnswer_2 =  true;
    else
        disp(' ')
        disp('Wrong input.')
        disp(' ')
        continue
    end
    disp(' ')
end


%--------------------END CODE ------------------------
end
