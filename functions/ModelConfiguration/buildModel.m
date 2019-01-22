function [model, misc]=buildModel(data, model, misc)
%BUILDMODEL Build model (build A,C, Q, R matrices)
%
%   SYNOPSIS:
%     [model]=BUILDMODEL(data, model, misc, model)
%
%   INPUT:
%       data       - structure (required)
%                    data must contain three fields:
%
%                       'timestamps' is a M×1 array
%
%                       'values' is a MxN  array
%
%                       'labels' is a 1×N cell array
%                               each cell is a character array
%
%                           N: number of time series
%                           M: number of samples
%
%      model       - structure (required)
%
%      misc        - structure (required)
%
%   OUTPUT:
%      model       - structure
%
%      misc        - structure
%
%   DESCRIPTION:
%      BUILDMODEL builds model (build A,C,Q,R matrices)
%
%   EXAMPLES:
%      [model] = BUILDMODEL(data, model, misc)
%
%   See also DEFINEMODEL

%   AUTHORS:
%      James-A Goulet, Luong Ha Nguyen, Ianis Gaudot
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       April 23, 2018
%
%   DATE LAST UPDATE:
%       August 22, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'misc', @isstruct );
parse(p,data, model, misc);

data=p.Results.data;
model=p.Results.model;
misc=p.Results.misc;

%% Get reference time step
%% Compute reference time step from timestamp vector
timestamps = data.timestamps;
[dt_ref] = defineReferenceTimeStep(timestamps);
%misc.dt_ref = dt_ref;

%% Get number of time series
numberOfTimeSeries = length(data.labels);

%% Get the number of time steps
numberOfTimeSteps = length(data.timestamps);

%% Get number of model class
numberOfModelClass = size(model.components.block,2);
model.nb_class = size(model.components.block,2);

%% Data simulation ?
if ~isfield(misc.internalVars, 'isDataSimulation')
    misc.internalVars.isDataSimulation = false;
end


%% Default prior information

PriorType = 'N/A'; 
PriorMean = NaN;
PriorSdev = NaN;

disp('     Building model...')

%% Block Component definition

%#11 Local level
model.components.idx{11}='LL';
LL.A=@(p,t,dt) 1;
LL.pA=[];
LL.pA0=[];
LL.C=@(p,t,dt) 1;
LL.pC=[];
LL.pC0=[];
LL.I=@(p,t,dt) 0;
LL.pI=[];
LL.pI0=[];
LL.Q=@(p,t,dt) p^2*dt';
LL.pQ={'\sigma_w','LL',[],[],[nan,nan], PriorType, PriorMean, PriorSdev};
LL.x={'x^{LL}',[],[]};
if misc.internalVars.isDataSimulation
    LL.pQ0={'0'};
    LL.init={'10','0.1^2'};
else
    LL.pQ0={'0'};
    LL.init={'nanmean(data.values(1:round(length(timestamps)*0.1), obs))','(2*nanstd(data.values(:,obs)))^2'};
end
LL.B=@(p,t,dt) 0;
LL.pB=[];
LL.pB0=[];
LL.W=@(p,t,dt) 0;
LL.pW=[];
LL.pW0=[];

%#12 Local trend
model.components.idx{12}='LT';
LT.A=@(p,t,dt) [1 dt;0 1];
LT.pA=[];
LT.pA0=[];
LT.C=@(p,t,dt) [1 0];
LT.pC=[];
LT.pC0=[];
LT.I=@(p,t,dt) [0 0];
LT.pI=[];
LT.pI0=[];
LT.Q=@(p,t,dt) p^2*dt/dt_ref*[dt^3/3 dt^2/2;dt^2/2 dt];
LT.pQ={'\sigma_w','LT',[],[],[0,inf], PriorType, PriorMean, PriorSdev };
LT.x={'x^{LL}',[],[];'x^{LT}',[],[]};
if misc.internalVars.isDataSimulation
    LT.pQ0={'1E-7'};
    LT.init={'[10 -0.001]','[0.1^2 0.1^2]'};
else
    LT.pQ0={'1E-7*nanstd(data.values(:,obs))'};
    %LT.init={'[nanmean(data.values(1:max(min(365*dt_ref,numberOfTimeSteps),round(0.1*numberOfTimeSteps)), obs)) 0]','[(1E-1*nanstd(data.values(:,obs)))^2 (1E-3*nanstd(data.values(:,obs)))^2]'};
    LT.init={'[nanmean(data.values(1:round(length(timestamps)*0.1), obs)) 0]','[(2*nanstd(data.values(:,obs)))^2 (nanstd(data.values(:,obs)))^2]'};
end
LT.B=@(p,t,dt) zeros(1,2);
LT.pB=[];
LT.pB0=[];
LT.W=@(p,t,dt) zeros(2);
LT.pW=[];
LT.pW0=[];
% LT.B=@(p,t,dt) p'*dt/dt_ref;
% LT.pB=[{'B_L','LT',[],[],[-inf,inf]};{'B_T','LT',[],[],[-inf,inf]}];
% LT.pB0=[{'1E-2'};{'1E-3'}];
% LT.W=@(p,t,dt) diag((p*dt/dt_ref).^2);
% LT.pW=[{'\sigma_WL','LT',[],[],[0,inf]};{'\sigma_WT','LT',[],[],[0,inf]}];
% LT.pW0=[{'nanstd(data.values(:,obs))'};{'0.1*nanstd(data.values(:,obs))'}];

%#13 Local acceleration
model.components.idx{13}='LA';
LA.A=@(p,t,dt)[1 dt 0.5*dt^2;0 1 dt;0 0 1];
LA.pA=[];
LA.pA0=[];
LA.C=@(p,t,dt)[1 0 0];
LA.pC=[];
LA.pC0=[];
LA.I=@(p,t,dt) [0 0 0];
LA.pI=[];
LA.pI0=[];
LA.Q=@(p,t,dt) p^2*dt/dt_ref*[dt^5/20 dt^4/8 dt^3/6;dt^4/8 dt^3/3 dt^2/2;dt^3/6 dt^2/2 dt];
LA.pQ={'\sigma_w','LA',[],[],[0,inf], PriorType, PriorMean, PriorSdev};
LA.x={'x^{LL}',[],[];'x^{LT}',[],[];'x^{LA}',[],[]};
if misc.internalVars.isDataSimulation
    LA.pQ0={'1E-8'};
    LA.init={'[10 -0.001 -0.00001]','[0.1^2 0.1^2 0.1^2]'};
else
    LA.pQ0={'1E-8*nanstd(data.values(:,obs))'};
    %LA.init={'[nanmean(data.values(1:max(min(365*dt_ref,numberOfTimeSteps),round(0.1*numberOfTimeSteps)), obs)) 0 0]','[(1E-1*nanstd(data.values(:,obs)))^2 (1E-4*nanstd(data.values(:,obs)))^2 (1E-8*nanstd(data.values(:,obs)))^2]'};
    LA.init={'[nanmean(data.values(1:round(length(timestamps)*0.1), obs)) 0 0]','[(2*nanstd(data.values(:,obs)))^2 (nanstd(data.values(:,obs)))^2 (nanstd(data.values(:,obs)))^2]'};
end
LA.B=@(p,t,dt) zeros(1,3);
LA.pB=[];
LA.pB0=[];
LA.W=@(p,t,dt) zeros(3);
LA.pW=[];
LA.pW0=[];
% LA.B=@(p,t,dt) p'*dt/dt_ref;
% LA.pB=[{'B_L','LA',[],[],[-inf,inf]};{'B_T','LA',[],[],[-inf,inf]};{'B_LA','LA',[],[],[-inf,inf]}];
% LA.pB0=[{'1E-2'};{'1E-3'};{'1E-4'}];
% LA.W=@(p,t,dt) diag((p*dt/dt_ref).^2);
% LA.pW=[{'\sigma_WL','LA',[],[],[0,inf]};{'\sigma_WT','LA',[],[],[0,inf]};{'\sigma_WA','LA',[],[],[0,inf]}];
% LA.pW0=[{'nanstd(data.values(:,obs))'};{'0.1*nanstd(data.values(:,obs))'};{'0.01*nanstd(data.values(:,obs))'}];

%#21 Local level compatible with LT
model.components.idx{21}='LcT';
LcT.A=@(p,t,dt) [1 0;0 0];
LcT.pA=[];
LcT.pA0=[];
LcT.C=@(p,t,dt) [1 0];
LcT.pC=[];
LcT.pC0=[];
LcT.I=@(p,t,dt) [0 0];
LcT.pI=[];
LcT.pI0=[];
%LcT.Q=@(p,t,dt) p^2*dt/dt_ref*[1 0;0 1E-15/(p^2*dt/dt_ref)];
LcT.Q=@(p,t,dt) p^2*dt/dt_ref*[1 0;0 1E-30];
LcT.pQ={'\sigma_w','LcT',[],[],[0,inf], PriorType, PriorMean, PriorSdev};
LcT.x={'x^{LL}',[],[];'x^{LTc}',[],[]};
if misc.internalVars.isDataSimulation
    LcT.pQ0={'1E-7'};
    LcT.init={'[10 0]','[0.1^2 (1E-6)^2]'};
else
    LcT.pQ0={'1E-7*nanstd(data.values(:,obs))'};
    %LcT.init={'[nanmean(data.values(1:max(min(365*dt_ref,numberOfTimeSteps),round(0.1*numberOfTimeSteps)), obs)) 0]','[(1E-1*nanstd(data.values(:,obs)))^2 (1E-6*nanstd(data.values(:,obs)))^2]'};
    LcT.init={'[nanmean(data.values(1:round(length(timestamps)*0.1), obs)) 0]','[(2*nanstd(data.values(:,obs)))^2 (nanstd(data.values(:,obs)))^2]'};
end
LcT.B=@(p,t,dt) zeros(1,2);
LcT.pB=[];
LcT.pB0=[];
LcT.W=@(p,t,dt) zeros(2);
LcT.pW=[];
LcT.pW0=[];

%#22 Local level compatible with LA
model.components.idx{22}='LcA';
LcA.A=@(p,t,dt) [1 0 0;0 0 0; 0 0 0]';
LcA.pA=[];
LcA.pA0=[];
LcA.C=@(p,t,dt) [1 0 0];
LcA.pC0=[];
LcA.pC=[];
LcA.I=@(p,t,dt) [0 0 0];
LcA.pI=[];
LcA.pA0=[];
%LcA.Q=@(p,t,dt) p^2*dt/dt_ref*[1 0 0;0 0 0; 0 0 1E-15/(p^2*dt/dt_ref)];
LcA.Q=@(p,t,dt) p^2*dt/dt_ref*[1 0 0;0 0 0; 0 0 1E-30];
LcA.pQ={'\sigma_w','LcA',[],[],[0,inf], PriorType, PriorMean, PriorSdev};
LcA.x={'x^{LL}',[],[];'x^{LTc}',[],[];'x^{LAc}',[],[]};
if misc.internalVars.isDataSimulation
    LcA.pQ0={'1E-7'};
    LcA.init={'[10 -0.1 0]','[0.1^2 0.1^2 0.1^2]'};
else
    LcA.pQ0={'1E-7*nanstd(data.values(:,obs))'};
    %LcA.init={'[nanmean(data.values(1:round(max(min(365*dt_ref,numberOfTimeSteps),round(0.1*numberOfTimeSteps)), obs)) 0 0]','[(1E-1*nanstd(data.values(:,obs)))^2 (1E-3*nanstd(data.values(:,obs)))^2 (1E-6*nanstd(data.values(:,obs)))^2]'};
    LcA.init={'[nanmean(data.values(1:round(length(timestamps)*0.1), obs)) 0 0]','[(2*nanstd(data.values(:,obs)))^2 (nanstd(data.values(:,obs)))^2 (nanstd(data.values(:,obs)))^2]'};
end
LcA.B=@(p,t,dt) zeros(1,3);
LcA.pB=[];
LcA.pB0=[];
LcA.W=@(p,t,dt) zeros(3);
LcA.pW=[];
LcA.pW0=[];


%#23 Local trend compatible with LA
model.components.idx{23}='TcA';
TcA.A=@(p,t,dt) [1 dt 0;0 1 0; 0 0 0];
TcA.pA=[];
TcA.pA0=[];
TcA.C=@(p,t,dt) [1 0 0];
TcA.pC=[];
TcA.pC0=[];
TcA.I=@(p,t,dt) [0 0 0];
TcA.pI=[];
TcA.pC0=[];
%TcA.Q=@(p,t,dt) p^2*dt/dt_ref*[dt^3/3 dt^2/2 0;dt^2/2 dt 0; 0 0 1E-15/(p^2*dt/dt_ref)];
TcA.Q=@(p,t,dt) p^2*dt/dt_ref*[dt^3/3 dt^2/2 0;dt^2/2 dt 0; 0 0 1E-30];
TcA.pQ={'\sigma_w','TcA',[],[],[0,inf], PriorType, PriorMean, PriorSdev};
TcA.x={'x^{LL}',[],[];'x^{LT}',[],[];'x^{LAc}',[],[]};
if misc.internalVars.isDataSimulation
    TcA.pQ0={'1E-8'};
    TcA.init={'[10 -0.1 0]','[0.1^2 0.1^2 0.1^2]'};
else
    TcA.pQ0={'1E-8*nanstd(data.values(:,obs))'};
    %TcA.init={'[nanmean(data.values(1:max(min(365*dt_ref,numberOfTimeSteps),round(0.1*numberOfTimeSteps)), obs)) 0 0]','[(1E-1*nanstd(data.values(:,obs)))^2 (1E-4*nanstd(data.values(:,obs)))^2 (1E-20*nanstd(data.values(:,obs)))^2]'};
    TcA.init={'[nanmean(data.values(1:round(length(timestamps)*0.1), obs)) 0 0]','[(2*nanstd(data.values(:,obs)))^2 (nanstd(data.values(:,obs)))^2 (nanstd(data.values(:,obs)))^2]'};
end
TcA.B=@(p,t,dt) zeros(1,3);
TcA.pB=[];
TcA.pB0=[];
TcA.W=@(p,t,dt) zeros(3);
TcA.pW=[];
TcA.pW0=[];

%#31 Periodic component
model.components.idx{31}='PD';
PD.A=@(p,t,dt) [cos(2*pi*dt/p(1)) sin(2*pi*dt/p(1));-sin(2*pi*dt/p(1)) cos(2*pi*dt/p(1))];
PD.pA={'p','PD',[],[nan,nan]};
PD.pA0={'365.2422','1','365.2422/2','7', '1', '1', '1', '1', '1' , '1'};
PD.C=@(p,t,dt) [1 0];
PD.pC=[];
PD.pC0=[];
PD.I=@(p,t,dt) [p 0];
PD.pI={'\phi','PD,I',[],[],[-inf,inf], PriorType, PriorMean, PriorSdev};
PD.pI0={'0.5'};
PD.Q=@(p,t,dt) p^2*dt/dt_ref*[1 0;0 1];
PD.pQ={'\sigma_w','PD',[],[],[nan,nan], PriorType, PriorMean, PriorSdev};
PD.x={'x^{S1}',[],[];'x^{S2}',[],[]};
if misc.internalVars.isDataSimulation
    PD.pQ0={'0'};
    PD.init={'[10,10]','[(2*0.1)^2,(2*0.1)^2]'};
else
    PD.pQ0={'0*nanstd(data.values(:,obs))'};
    PD.init={'[5,0]','[(2*nanstd(data.values(:,obs)))^2,(2*nanstd(data.values(:,obs)))^2]'};
end
PD.B=@(p,t,dt) 0;
PD.pB=[];
PD.pB0=[];
PD.W=@(p,t,dt) diag([0,0]);
PD.pW=[];
PD.pW0=[];

%#41 Autoregressive component
model.components.idx{41}='AR';
AR.A=@(p,t,dt)  p(1)^(dt/dt_ref);
AR.pA={'\phi','AR',[],[],[0,1], PriorType, PriorMean, PriorSdev};
AR.pA0={'0.75'};
AR.C=@(p,t,dt) 1;
AR.pC=[];
AR.pC0=[];
AR.I=@(p,t,dt) p;
AR.pI={'\phi','AR,I',[],[],[-inf,inf], PriorType, PriorMean, PriorSdev};
AR.pI0={'0.5'};
AR.Q=@(p,t,dt) p^2*dt/dt_ref;
AR.pQ={'\sigma_w','AR',[],[],[0,inf], PriorType, PriorMean, PriorSdev};
AR.x={'x^{AR}',[],[]};
if misc.internalVars.isDataSimulation
    AR.pQ0={'1E-1*0.1'};
    AR.init={'0','0.1^2'};
else
    AR.pQ0={'1E-1*nanstd(data.values(:,obs))'};
    AR.init={'0','(nanstd(data.values(:,obs)))^2'};
end
AR.B=@(p,t,dt) 0;
AR.pB=[];
AR.pB0=[];
AR.W=@(p,t,dt) 0;
AR.pW=[];
AR.pW0=[];

%#51 Kernel Regression
if ~isfield(model.components,'nb_KR_p')
    model.components.nb_KR_p=10+1;
end
model.components.idx{51}='KR';
KR.A=@(p,t,dt) [[0 Kernel_component(p,t,timestamps(1),model.components.nb_KR_p-1)];zeros(model.components.nb_KR_p-1,1) eye(model.components.nb_KR_p-1)];
KR.pA=[{'\ell','KR',[],[],[0,inf], PriorType, PriorMean, PriorSdev}; ...
    {'p','KR',[],[],[nan,nan], PriorType, PriorMean, PriorSdev}];
KR.pA0=[{'0.5'};{'365.2422'}];
KR.C=@(p,t,dt) [1 zeros(1,model.components.nb_KR_p-1)];
KR.pC=[];
KR.pC0=[];
KR.I=@(p,t,dt) p*[1 zeros(1,model.components.nb_KR_p-1)];
KR.pI={'\phi','KR,I',[],[],[-inf,inf], PriorType, PriorMean, PriorSdev};
KR.pI0={'0.01'};
%KR.Q=@(p,t,dt) blkdiag(0,eye(model.components.nb_KR_p-1)*p^2*dt/dt_ref);
KR.Q=@(p,t,dt) blkdiag(p(1)^2*dt/dt_ref,eye(model.components.nb_KR_p-1)*p(2)^2*dt/dt_ref);
KR.pQ=[{'\sigma_w','KR',[],[],[0,inf], PriorType, PriorMean, PriorSdev};...
    {'\sigma_hw','KR',[],[],[NaN,NaN], PriorType, PriorMean, PriorSdev}];
KR.x=[];
for i=0:model.components.nb_KR_p-1
    KR.x=[KR.x;{['x^{KR' num2str(i) '}'],[],[]}];
end
clear i
if misc.internalVars.isDataSimulation
    t = linspace(1,2*pi, model.components.nb_KR_p);
    a=sin(t);
    b=sin(4*t+30);
    c = sin(8*t-45);
    summ=a+b+c;
    summ_trun = summ(1:model.components.nb_KR_p);
    
    KR.pQ0=[{'0'};{'0'}];
    KR.init={['[' sprintf('%f ', summ_trun) ']'],['[' repmat('0.01 ',[1,model.components.nb_KR_p]) ']']};
else
    
    KR.pQ0=[{'1E-1*nanstd(data.values(:,obs))'};{'0'}];
    %KR.init={['[' repmat('0 ',[1,model.components.nb_KR_p]) ']'],['[' '1E-4*nanstd(data.values(:,obs))^2 ' repmat('nanstd(data.values(:,obs))^2 ',[1,model.components.nb_KR_p-1]) ']']};
    KR.init={['[' repmat('0 ',[1,model.components.nb_KR_p]) ']'],['[' 'nanstd(data.values(:,obs))^2 ' repmat('nanstd(data.values(:,obs))^2 ',[1,model.components.nb_KR_p-1]) ']']};
end
KR.B=@(p,t,dt) zeros(1,model.components.nb_KR_p);
KR.pB=[];
KR.pB0=[];
KR.W=@(p,t,dt) zeros(model.components.nb_KR_p);
KR.pW=[];
KR.pW0=[];
% KR.B=@(p,t,dt) zeros(1,model.components.nb_KR_p);
% KR.pB=[];
% KR.pB0=[];
% KR.W=@(p,t,dt) eye(model.components.nb_KR_p)*p^2*dt/dt_ref;
% KR.pW={'\sigma_W','KR',[],[],[0,inf]};
% KR.pW0={'1E-2*nanstd(data.values(:,obs))'};

%#61 Level intervention
model.components.idx{61}='LI';
LI.A=@(p,t,dt) 1;
LI.pA=[];
LI.pA0=[];
LI.C=@(p,t,dt) 1;
LI.pC=[];
LI.pC0=[];
LI.I=@(p,t,dt) 0;
LI.pI=[];
LI.pI0=[];
LI.Q=@(p,t,dt) 0;
LI.pQ=[];
LI.x={'x^{LI}',[],[]};
LI.pQ0={'0'};
LI.init={'0','1E-20'};
LI.B=@(p,t,dt) p'*dt/dt_ref;
LI.pB=[{'b','LI',[],[],[-inf,inf]}];
LI.pB0=[{'1E-1*nanstd(data.values(:,obs))'}];
LI.W=@(p,t,dt) (p*dt/dt_ref).^2;
LI.pW=[{'\sigma_W','LI',[],[],[0,inf]}];
LI.pW0=[{'nanstd(data.values(:, obs))'}];

%% Block initialization
param_properties={};        %Reference vector for parameter names in A,C,Q,R matrices
param_idx=1;                %Index for parameter count in A,C,Q,R matrices
x_count=zeros(numberOfTimeSeries,100);
parameter=[];               %Default values for parameters
nb_param_class=1;           %number of parameter per model class
for class_from=1:numberOfModelClass  %Loop over each model class
    h_count=0;                   %Count of the number of periodic component
    A{class_from}=[];            %Matrices initialization
    R{class_from}=[];
    B{class_from}=[];
    W{class_from}=[];
    initX{class_from}=[];        %Initial state variable expected value
    initV{class_from}=[];        %Initial state variable variance
    hidden_states_names{class_from}={};     %Reference vector for hidden state variables names
    for class_to=1:numberOfModelClass%Loop over each model class
        Q{class_from}{class_to}=[];
        CI_block=cell(numberOfTimeSeries);
        for obs=1:numberOfTimeSeries   %Loop over each observation
            p_count=0;                   %Count of the number of periodic component
            nb_hidden_states{class_from}{obs}=0;
            C{class_from}{obs,obs}=[];
            C_block=[];
            for block=1:length(model.components.block{class_from}{obs}) %loop over each model block
                block_idx=model.components.block{class_from}{obs}(block);
                block_name=model.components.idx{block_idx};
                if class_from==class_to
                    x_count(obs,block_idx)=x_count(obs,block_idx)+1;    %count the number of components
                    if x_count(obs,block_idx)>1
                        count_label=num2str(x_count(obs,block_idx));
                    else
                        count_label=num2str([]);
                    end
                    name=eval([block_name '.x']);
                    for i=1:size(name,1)
                        name{i,2}=num2str(class_from);
                        name{i,3}=num2str(obs);
                        hidden_states_names{class_from}=[hidden_states_names{class_from};name(i,:)];
                    end
                    % initial hidden state values
                    initX{class_from}=[initX{class_from},eval(eval([block_name '.init{1}']))];
                    initV{class_from}=[initV{class_from},eval(eval([block_name '.init{2}']))];
                    
                    % A - Transition matrix
                    if class_from>1&&model.components.const{class_from}{obs}(block)==1
                        A{class_from}=[A{class_from},',',[block_name '.A(p([' num2str(A_param_ref{1}{obs}{block}) ']),t,dt)']];
                    else
                        nb_param=eval(['size(' block_name '.pA,1)']);
                        if nb_param>0
                            p_idx=param_idx:param_idx-1+nb_param;
                        else
                            p_idx=[];
                        end
                        A{class_from}=[A{class_from},',',[block_name '.A(p([' num2str(p_idx) ']),t,dt)']];
                        if any(strcmp(eval([block_name '.pA']),'p'))
                            p_count=p_count+1;
                            name={'p' ,['PD' num2str(p_count)],[],[],eval([block_name '.pA{4}']), PriorType, PriorMean, PriorSdev};
                            p_value=eval([block_name '.pA0{' num2str(p_count) '}']);
                            if ~isempty(p_value)
                                parameter=[parameter;eval(p_value)];
                            end
                        elseif strcmp(block_name,'KR')
                            name=eval([block_name '.pA']);
                            k_count=0;
                            for i=1:2
                                k_count=k_count+1;
                                p_value=eval([block_name '.pA0{' num2str(k_count) '}']);
                                parameter=[parameter;eval(p_value)];
                                name{i,3}=[num2str(class_from)];
                                name{i,4}=num2str(obs);
                            end
                        else
                            name=eval([block_name '.pA']);
                            p_value=eval([block_name '.pA0']);
                            if ~isempty(p_value)
                                parameter=[parameter;eval(p_value{:})];
                            end
                        end
                        if ~isempty(name)&&~strcmp(block_name,'KR')
                            name{3}=[num2str(class_from)];
                            name{4}=num2str(obs);
                        end
                        param_properties=[param_properties;name];
                        A_param_ref{class_from}{obs}{block}=p_idx;
                        param_idx=param_idx+nb_param;
                    end
                    
                    % Q - Model transition error covariance
                    if class_from>1&&model.components.const{class_from}{obs}(block)==1
                        Q{class_from}{class_to}=[Q{class_from}{class_to},',',[block_name '.Q(p([' num2str(Q_param_ref{1}{obs}{block}) ']),t,dt)']];
                        Q_param_ref{class_from}{obs}{block}=Q_param_ref{1}{obs}{block};
                    else
                        nb_param=eval(['size(' block_name '.pQ,1)']);
                        if nb_param>0
                            p_idx=param_idx:param_idx-1+nb_param;
                        else
                            p_idx=[];
                        end
                        Q{class_from}{class_to}=[Q{class_from}{class_to},',',[block_name '.Q(p([' num2str(p_idx) ']),t,dt)']];
                        if any(strcmp(eval([block_name '.pA']),'p'))
                            name={'\sigma_w',['PD' num2str(p_count)],[],[],eval([block_name '.pQ{5}']), PriorType, PriorMean, PriorSdev};
                        else
                            name=eval([block_name '.pQ']);
                        end
                        if ~isempty(name)
                            for i=1:nb_param
                                p_value=eval(eval([block_name '.pQ0{' num2str(i) '}']));
                                parameter=[parameter;p_value];
                                name{i,3}=[num2str(class_from)];
                                name{i,4}=num2str(obs);
                            end
                        end
                        param_properties=[param_properties;name];
                        Q_param_ref{class_from}{obs}{block}=p_idx;
                        param_idx=param_idx+nb_param;
                    end
                    
                    % C - Observation matrix
                    if class_from>1&&model.components.const{class_from}{obs}(block)==1
                        C_block=[C_block,',',[block_name '.C(p([' num2str(C_param_ref{1}{obs}{block}) ']),t,dt)']];
                    else
                        nb_param=eval(['size(' block_name '.pC,1)']);
                        if nb_param>0
                            p_idx=param_idx:param_idx-1+nb_param;
                        else
                            p_idx=[];
                        end
                        C_block=[C_block,',',[block_name '.C(p([' num2str(p_idx) ']),t,dt)']];
                        name=eval([block_name '.pC']);
                        if ~isempty(name)
                            if any(strcmp(eval([block_name '.pC{1,1}']),'ycp1'))
                                for i=1:size(eval([block_name '.pC']),1)
                                    h_count=h_count+1;
                                    p_value=eval([block_name '.pC0{' num2str(h_count) '}']);
                                    parameter=[parameter;eval(p_value)];
                                    name{i,3}=[num2str(class_from)];
                                    name{i,4}=num2str(obs);
                                end
                            elseif any(strcmp(eval([block_name '.pC{1,1}']),'\ell'))
                                C_block_K=[block_name '.C(p([' num2str(p_idx) ']),t,dt)'];
                                k_count=0;
                                for i=1:2
                                    k_count=k_count+1;
                                    p_value=eval([block_name '.pC0{' num2str(k_count) '}']);
                                    parameter=[parameter;eval(p_value)];
                                    name{i,3}=[num2str(class_from)];
                                    name{i,4}=num2str(obs);
                                end
                            else
                                p_value=eval([block_name '.pC0{' num2str(p_count) '}']);
                                parameter=[parameter;eval(h_value)];
                                name{3}=[num2str(class_from)];
                                name{4}=num2str(obs);
                            end
                        end
                        param_properties=[param_properties;name];
                        C_param_ref{class_from}{obs}{block}=p_idx;
                        param_idx=param_idx+nb_param;
                    end
                    nb_hidden_states{class_from}{obs}=nb_hidden_states{class_from}{obs}+length(eval([block_name '.A(ones(1,10000),1,1)']));
                    
                    if isfield(data,'interventions')
                        % B - Interventions mean shift
                        nb_param=eval(['size(' block_name '.pB,1)']);
                        if nb_param>0
                            p_idx=param_idx:param_idx-1+nb_param;
                        else
                            p_idx=[];
                        end
                        B{class_from}=[B{class_from},',',[block_name '.B(p([' num2str(p_idx) ']),t,dt)']];
                        name=eval([block_name '.pB']);
                        if ~isempty(name)
                            for i=1:size(name,1)
                                p_value=eval(eval([block_name '.pB0{i}']));
                                parameter=[parameter;p_value];
                                name{i,3}=[num2str(class_from)];
                                name{i,4}=num2str(obs);
                                name{i,6}=PriorType;
                                name{i,7}=PriorMean;
                                name{i,8}=PriorSdev;
                            end
                        end
                        param_properties=[param_properties;name];
                        B_param_ref{class_from}{obs}{block}=p_idx;
                        param_idx=param_idx+nb_param;
                        
                        % W - Interventions covariance
                        nb_param=eval(['size(' block_name '.pW,1)']);
                        if nb_param>0
                            p_idx=param_idx:param_idx-1+nb_param;
                        else
                            p_idx=[];
                        end
                        W{class_from}=[W{class_from},',',[block_name '.W(p([' num2str(p_idx) ']),t,dt)']];
                        name=eval([block_name '.pW']);
                        if ~isempty(name)
                            for i=1:size(name,1)
                                p_value=eval(eval([block_name '.pW0{i}']));
                                parameter=[parameter;p_value];
                                name{i,3}=[num2str(class_from)];
                                name{i,4}=num2str(obs);
                                name{i,6}=PriorType;
                                name{i,7}=PriorMean;
                                name{i,8}=PriorSdev;
                            end
                        end
                        param_properties=[param_properties;name];
                        W_param_ref{class_from}{obs}{block}=p_idx;
                        param_idx=param_idx+nb_param;
                    end
                end
            end
            if class_from==class_to
                
                R{class_from}=[R{class_from},',p([' num2str(param_idx) '])^2'];
                C{class_from}{obs,obs}=[C{class_from}{obs,obs},',[' C_block(2:end) ']'];
                param_properties=[param_properties;{['\sigma_v'],[],[num2str(class_from)],[num2str(obs)],[0,inf], PriorType, PriorMean, PriorSdev}];
                
                if misc.internalVars.isDataSimulation
                    parameter=[parameter;0.01];
                else
                    parameter=[parameter;0.05*nanstd(data.values(:,obs))];
                end
                param_idx=param_idx+1;
                
                % PCA inter-component regression
                if isfield(model.components,'PCA')
                    %PCA_coeff=model.components.PCA{obs};
                    for pca_idx=1:length(model.components.ic{obs})
                        PCA_reg_param{obs}(pca_idx)=param_idx;
                        param_properties=[param_properties;{['\phi'],[ num2str(obs) '|' 'PC' num2str(pca_idx) ],[num2str(class_from)],[num2str(obs)],[-inf,inf], PriorType, PriorMean, PriorSdev}];
                        parameter=[parameter;1];
                        param_idx=param_idx+1;
                    end
                    
                end
                
                % I - Inter-component regression
                for obs_idx=1:numberOfTimeSeries
                    
                    if obs_idx ~= obs
                        C{class_from}{obs_idx,obs} = [];
                    end
                    
                    ic_idx=find([model.components.ic{obs_idx}]==obs);
                    if ~isempty(ic_idx)
                        %param_reg=0;
                        for block=1:length(model.components.block{class_from}{obs}) %loop over each model block
                            block_idx=model.components.block{class_from}{obs}(block);
                            block_name=model.components.idx{block_idx};
                            
                            if class_from>1&&model.components.const{class_from}{obs}(block)==1
                                C{class_from}{obs_idx,obs}=[C{class_from}{obs_idx,obs},',',[block_name '.I(p([' num2str(IC_param_ref{1}{obs}{block}) ']),t,dt)']];
                            else
                                nb_param=eval(['size(' block_name '.pI,1)']);
                                if nb_param>0
                                    p_idx=param_idx:param_idx-1+nb_param;
                                    param_reg=p_idx;
                                    param_properties=[param_properties;{'\phi', [num2str(obs_idx) '|' num2str(obs) '(' block_name ')' ],[num2str(class_from)],[num2str(obs)],[-inf,inf], PriorType, PriorMean, PriorSdev}];
                                    parameter=[parameter;eval(eval([block_name '.pI0{:}']))];
                                    param_idx=param_idx+1;
                                    
                                else
                                    p_idx=[];
                                end
                                    C{class_from}{obs_idx,obs}=[C{class_from}{obs_idx,obs},',',[block_name '.I(p([' num2str(p_idx) ']),t,dt)']];
                            end
                            if isfield(model.components,'PCA')
                                C{class_from}{obs_idx,obs}=[C{class_from}{obs_idx,obs},'*','sum(p([' num2str(PCA_reg_param{obs_idx}) ']).*model.components.PCA{' num2str(obs_idx) '}(' num2str(ic_idx) ',:)'')' ];
                            end
                            IC_param_ref{class_from}{obs}{block}=p_idx;
                        end
                    elseif obs_idx~=obs
                        C{class_from}{obs_idx,obs}=[',' num2str(zeros(1,nb_hidden_states{class_from}{obs}))];
                    end
                end
            end
        end
        if class_from==class_to
            for obs=1:numberOfTimeSeries  %Loop over each observation
                Cc{class_from}{obs,1}=[',[' cell2mat(C{class_from}(obs,:)) ']'];
            end
            model.A{class_from}=eval(['@(p,t,dt) blkdiag(' A{class_from}(2:end) ')']);
            model.C{class_from}=eval(['@(p,t,dt) reshape([' ([Cc{class_from}{:}]) '],[' num2str(sum([nb_hidden_states{class_from}{:}])) ','  num2str(numberOfTimeSeries) '])''']);
            model.R{class_from}=eval(['@(p,t,dt) blkdiag(' R{class_from}(2:end) ')']);
            model.Q{class_from}{class_to}=eval(['@(p,t,dt) blkdiag(' Q{class_from}{class_to}(2:end) ')']);
            model.B{class_from}=eval(['@(p,t,dt) [' B{class_from}(2:end) ']']);
            model.W{class_from}=eval(['@(p,t,dt) blkdiag(' W{class_from}(2:end) ')']);
        end
    end
end

%% Q_ij model process noise transition errors
for class_from=1:numberOfModelClass  %Loop over each model class
    for class_to=setdiff([1:numberOfModelClass],class_from)%Loop over each model class
        Q{class_from}{class_to}=[];
        if class_from~=class_to
            for obs=1:numberOfTimeSeries   %Loop over each observation
                for block=1:length(model.components.block{class_from}{obs}) %loop over each model block
                    block_idx=model.components.block{class_from}{obs}(block);
                    block_name=model.components.idx{block_idx};
                    % Q - Model transition error covariance
                    if block_idx>10&&block_idx<30
                        nb_param=1;
                        %nb_param=size(eval([block_name '.Q(1,1,1)']),1);
                        if nb_param>0
                            p_idx=param_idx:param_idx-1+nb_param;
                        else
                            p_idx=[];
                        end
                        if class_from>1&&model.components.const{class_from}{obs}(block)==1
                            Q{class_from}{class_to}=[Q{class_from}{class_to},',',[block_name '.Q(p([' num2str(Q_param_ref{1}{obs}{block}) ']),t,dt)']];
                        else
                            %Q{class_from}{class_to}=[Q{class_from}{class_to},',',['diag(p([' num2str(p_idx) ']))']];
                            Q{class_from}{class_to}=[Q{class_from}{class_to},',',[block_name '.Q(p([' num2str(p_idx) ']),t,dt)']];
                            for i=1:nb_param
                                name=[eval([block_name '.pQ'])];
                                if ~isempty(name)
                                    if nb_param>1
                                        name{1}=name{1};
                                        %name{1}=[name{1},'(' num2str(i),num2str(i) ')'];
                                    end
                                    parameter=[parameter;1E3*eval(eval([block_name '.pQ0{:}']))];
                                    name{3}=[num2str(class_from) num2str(class_to)];
                                    name{4}=num2str(obs);
                                end
                                param_properties=[param_properties;name];
                            end
                            param_idx=param_idx+nb_param;
                        end
                    else
                        Q{class_from}{class_to}=[Q{class_from}{class_to},',',[block_name '.Q(p([' num2str(Q_param_ref{class_from}{obs}{block}) ']),t,dt)']];
                    end
                end
            end
        end
        if class_from~=class_to
            model.Q{class_from}{class_to}=eval(['@(p,t,dt) blkdiag(' Q{class_from}{class_to}(2:end) ')']);
        end
    end
end

%% Initial nanmean vector and covariance matrix

if ~isfield(model,'initX')
    for class_from=1:numberOfModelClass
        model.initX{class_from}=initX{class_from}';
    end
end
if ~isfield(model,'initV')
    for class_from=1:numberOfModelClass
        model.initV{class_from}=diag(initV{class_from});
    end
end
if ~isfield(model,'initS')
    for class_from=1:numberOfModelClass
        model.initS{class_from}=1/numberOfModelClass;
    end
end

%% Transition matrix
model.Z=[];
if numberOfModelClass==1
    model.Z=@(p,t,dt) 1;
elseif numberOfModelClass==2
    model.Z=@(p,t,dt) eval(['[p(' num2str(param_idx) ') 1-p(' num2str(param_idx) ') ;1-p(' num2str(param_idx) '+1) p(' num2str(param_idx) '+1) ]^(dt/' num2str(dt_ref) ')']);
    param_properties=[param_properties;{'Z(11)',[],'11',[],[0,1], PriorType, PriorMean, PriorSdev};{'Z(22)',[],'22',[],[0,1], PriorType, PriorMean, PriorSdev}];
    parameter=[parameter;1-1/(365/dt_ref*10);1-1/(365/dt_ref*10)];
    param_idx=param_idx+2;
    
else
    for i=1:numberOfModelClass
        for j=i:numberOfModelClass
            param_idx=param_idx+1;
            model.Z=[model.Z;{ 'p(param_idx)'}];
            param_properties=[param_properties;{'\pi_z',[],[num2str(i),num2str(j)], [] ,[nan,nan], PriorType, PriorMean, PriorSdev}];
            parameter=[parameter;0.5];
        end
    end
    model.Z=@(p,t,dt) [reshape(model.Z),[numberOfModelClass,numberOfModelClass]]^(dt/dt_ref);
end

if ~isfield(model.components,'PCA')
    model.components.PCA=cell(1,numberOfTimeSeries);
end

% Model hidden states name
model.hidden_states_names=hidden_states_names;

% Create model.param_properties using default values only if
% model.param_properties does not exist

if ~isfield(model,'param_properties')
    
    % No parameter constrain by default
    p_ref = 1:length(parameter);
    p_ref=p_ref';
    
    % Add parameter and p_ref to param_properties
    [model.param_properties]=writeParameterProperties(param_properties, ...
        [parameter, p_ref], size(param_properties,2)+1);
    
else
    
    %% Read model parameter properties
    idx_pvalues=size(model.param_properties,2)-1;
    idx_pref= size(model.param_properties,2);
    
    [arrayOut]=...
        readParameterProperties(model.param_properties, [idx_pvalues, idx_pref]);
    
    parameter= arrayOut(:,1);
    p_ref = arrayOut(:,2);
    
    %% Write model parameter properties
    % Add parameter and p_ref to param_properties
    [model.param_properties]=writeParameterProperties(model.param_properties, ...
        [parameter, p_ref], 9);
    
end

%--------------------END CODE ------------------------
end
