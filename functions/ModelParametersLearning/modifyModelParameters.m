function modifyModelParameters(data, model, estimation, misc, varargin)
%MODIFYMODELPARAMETERS Request user to modify model parameters values
%
%   SYNOPSIS:
%     MODIFYMODELPARAMETERS(data, model, estimation, misc, varargin)
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
%                         save modification in
%                         FilePath/PROJ_'misc.ProjectName'.mat file
%                         default: '.'  (current folder)
%
%   OUTPUT:
%      N/A
%      Updated project file with new model parameters values
%
%   DESCRIPTION:
%      MODIFYMODELPARAMETERS modifies model parameters (values, domain)
%
%   EXAMPLES:
%      MODIFYMODELPARAMETERS(data, model, estimation, misc)
%      MODIFYMODELPARAMETERS(data, model, estimation, misc, 'FilePath', 'saved_projects')
%
%   EXTERNAL FUNCTIONS CALLED:
%      saveProject
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also BDLM, SAVEPROJECT

%   AUTHORS:
%        Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
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
%       June 18, 2018

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
disp(['#   |Parameter    |Component |Model # |Observation '...
    '        |Current value |Bounds min/max |Constraint'])
for i=1:length(model.parameter)
    i_ref=model.p_ref(i);
    if i~=i_ref
        contraint=['@' num2str(i_ref)];
    else
        contraint='';
    end
    disp([repmat('0',1,2-length(num2str(i))) num2str(i) '    ' ...
        model.param_properties{i,1}  ...
        repmat(' ',1,14-length(model.param_properties{i,1})) ...
        model.param_properties{i,2} ...
        repmat(' ',1,11-length(model.param_properties{i,2})) ...
        model.param_properties{i,3} ...
        repmat(' ',1,9-length(model.param_properties{i,3}))...
        model.param_properties{i,4} ...
        repmat(' ',1,21-length(model.param_properties{i,4})) ...
        num2str(model.parameter(i_ref)) ...
        repmat(' ', 1,14-length(num2str(model.parameter(i_ref))))...
        num2str(model.param_properties{i,5}(1)) ...
        repmat(' ',1,5-length(num2str(model.param_properties{i,5}(1)))) '/'  ...
        num2str(model.param_properties{i,5}(2)), ...
        repmat(' ',1,9-length(model.param_properties{i,5})) contraint ]);
end
disp(' ')
disp(['     1   ->  Modify a parameter value'])
disp(['     2   ->  Constrain a parameter to another'])
disp(['     3   ->  Export current  ' ...
    'parameter properties in config file format'])
disp(['     4   ->  Quit  '])
disp(' ')
user_inputs.inp_2 =  input('Selection : ');
if user_inputs.inp_2==1
    user_inputs.inp_2 = input('     Modify parameter # ');
    user_inputs.inp_3 = input('     New value : ');
    user_inputs.inp_4 = input('     New bounds : ');
    if ~isempty(user_inputs.inp_3)
        model.parameter(user_inputs.inp_2)=user_inputs.inp_3;
    end
    if ~isempty(user_inputs.inp_4)
        model.param_properties{user_inputs.inp_2,5}=user_inputs.inp_4;
    end
    disp(' ')
    % Save project
    saveProject(data, model, estimation, misc, 'FilePath', FilePath)
elseif user_inputs.inp_2==2
    user_inputs.inp_2 = input('     Constrain parameter # ');
    user_inputs.inp_3 = input('     to parameter # ');
    model.p_ref(user_inputs.inp_2)=user_inputs.inp_3;
    model.param_properties{user_inputs.inp_2,5}=[nan,nan];
    disp(' ')
    % Save project
    saveProject(data, model, estimation, misc, 'FilePath', FilePath)
elseif user_inputs.inp_2==3
    disp(' ')
    disp('model.param_properties={')
    for i=1:size(model.param_properties,1)
        space=repmat(' ',1,8-length(model.param_properties{i,1}));
        disp(sprintf(['\t''%-s''' space ',\t ''%-s'',\t  '...
            ' ''%-s'',\t ''%-s'',\t '...
            '[ %-5G, %-5G]\t %%#%d'], ...
            model.param_properties{i,:},i));
    end
    disp('};')
    disp(' ')
    disp('model.parameter=[')
    for i=1:size(model.parameter,1)
        disp(sprintf('%-8.5G \t %%#%d \t%%%-s',  ...
            model.parameter(i),i,model.param_properties{i,1}));
    end
    disp(']; ')
    disp(' ')
    disp(['model.p_ref=[' num2str(model.p_ref) '];'])
    disp(' ')
elseif user_inputs.inp_2==4
    disp(' ')
    disp('     See you soon.')
    return
else
    disp('     -> invalid input.')
end
disp(' ')
%--------------------END CODE ------------------------
end
