function modifyInitialHiddenStates(data, model, estimation, misc, varargin)
%MODIFYINITIALHIDDENSTATES Request user to modify initial hidden states
%
%   SYNOPSIS:
%     MODIFYINITIALHIDDENSTATES(data, model, estimation, misc, varargin)
%
%   INPUT:
%      data             - structure (required)
%                         see documentation for details about the fields of
%                         data
%
%      model            - structure (required)
%                          see documentation for details about the fields of
%                          model
%
%      estimation       - structure (required)
%                         see documentation for details about the fields of
%                         estimation
%
%      misc             - structure (required)
%                         see documentation for details about the fields of
%                         misc
%
%      FilePath         - character (optional)
%                         directory where to save the modifications
%                         Modifications are saved directly in project file
%                         located in FilePath/PROJ_'misc.ProjectName'.mat file
%                         default: '.'  (current folder)
%
%   OUTPUT:
%      N/A
%      Updated project file with new initial hidden states values
%
%   DESCRIPTION:
%      MODIFYINITIALHIDDENSTATES modifies initial hidden states values
%      MODIFYINITIALHIDDENSTATES modifies the mean and variance of
%      initial hidden state values
%
%   EXAMPLES:
%      MODIFYINITIALHIDDENSTATES(data, model, estimation, misc)
%      MODIFYINITIALHIDDENSTATES(data, model, estimation, misc, 'FilePath', 'saved_projects')
%
%   EXTERNAL FUNCTIONS CALLED:
%      saveProject
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also BDLM, SAVEPROJECT

%   AUTHORS:
%       Ianis Gaudot, Luong Ha Nguyen, James-A Goulet,
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       June 11, 2018
%
%   DATE LAST UPDATE:
%       June 11, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

defaultFilePath = '.';

validationFonction = @(x) ischar(x) && ...
    ~isempty(x(~isspace(x)));

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'estimation', @isstruct );
addRequired(p,'misc', @isstruct );
addParameter(p, 'FilePath', defaultFilePath, validationFonction)
parse(p,data, model, estimation, misc, varargin{:});

data=p.Results.data;
model=p.Results.model;
estimation=p.Results.estimation;
misc=p.Results.misc;
FilePath=p.Results.FilePath;


%% Display current values
disp(['#  |state variable    |observation    '...
    '         |E[x_0]         |var[x_0] '])
for i=1:length(model.initX{1})
    disp([repmat('0',1,2-length(num2str(i))) num2str(i) '  '  ...
        model.hidden_states_names{1}{i,1} ...
        repmat(' ',1,19-length(model.hidden_states_names{1}{i,1})) ...
        model.hidden_states_names{1}{i,3} ...
        repmat(' ',1,25-length(model.hidden_states_names{1}{i,3})) ...
        sprintf('%-10.5G',model.initX{1}(i)) ...
        repmat(' ',1,6) sprintf('%-10.5G',model.initV{1}(i,i))])
end
disp(' ')
disp('     1   ->  Modify a initial value')
disp('     2   ->  Export initial values in config file format')
disp('     3   ->  Quit')
disp(' ')
user_inputs.inp_2 =  input('     Selection : ');
if user_inputs.inp_2==1
    user_inputs.inp_3 =     input('     Modify variable # ');
    user_inputs.inp_4 = input('     New E[x_0] : ');
    user_inputs.inp_5 = input('     New var[x_0] : ');
    for i=1:model.nb_class
        model.initX{i}(user_inputs.inp_3)=user_inputs.inp_4;
        D=diag(model.initV{1});
        D(user_inputs.inp_3)=user_inputs.inp_5;
        model.initV{i}=diag(D);
    end
    % Save project
    saveProject(data, model, estimation, misc, 'FilePath', FilePath)
elseif user_inputs.inp_2==2
    for m=1:model.nb_class
        disp(' ')
        disp(['model.initX{' num2str(m) '}=['])
        for i=1:size(model.initX{m},1)
            disp(sprintf(['\t%-6.3G'], model.initX{m}(i,:)));
        end
        disp('];')
        disp(' ')
        disp(['model.initV{' num2str(m) '}=['])
        for i=1:size(model.initV{m},1)
            disp(sprintf(['\t%-8.3G'], model.initV{m}(i,:)));
        end
        disp('];')
        disp(' ')
        for i=1:size(model.initS{m},1)
            disp(sprintf('model.initS{%d}=[%-6.3G];',  ...
                m, model.initS{m}));
        end
    end
    
    
elseif user_inputs.inp_2==3
    disp(' ')
    disp('     See you soon.')
    return
else
    disp('     -> invalid input.')
end
disp(' ')



%--------------------END CODE ------------------------
end
