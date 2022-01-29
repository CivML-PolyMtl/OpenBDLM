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
% numberOfTimeSeries = size(data.values,2);
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
LL.Prod=@(p,t,dt) 0;
LL.pProd=[];
LL.pProd0=[];
LL.C=@(p,t,dt) 1;
LL.pC=[];
LL.pC0=[];
LL.I=@(p,t,dt) 0;
LL.pI=[];
LL.pI0=[];
LL.Q=@(p,t,dt) p^2*dt';
LL.pQ={'\sigma_w','LL',[],[],[nan,nan], PriorType, PriorMean, PriorSdev};
LL.ProdQ=@(m,idx,p,t,dt) 0;
LL.pProdQ=[];
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
LT.Prod=@(p,t,dt) [0 0;0 0];
LT.pProd=[];
LT.pProd0=[];
LT.C=@(p,t,dt) [1 0];
LT.pC=[];
LT.pC0=[];
% LT.I=@(p,t,dt) [0 0];      % BD changed to have linear reg. coeff for LT                                              
% LT.pI=[];
% LT.pI0=[];
LT.I=@(p,t,dt) [p 0];
LT.pI={'\phi','LT,I',[],[],[-inf,inf], PriorType, PriorMean, PriorSdev};
LT.pI0={'0.01'};
LT.Q=@(p,t,dt) p^2*dt/dt_ref*[dt^3/3 dt^2/2;dt^2/2 dt];
LT.pQ={'\sigma_w','LT',[],[],[0,inf], PriorType, PriorMean, PriorSdev };
LT.ProdQ=@(m,idx,p,t,dt) [0 0;0 0];
LT.pProdQ = [];
LT.x={'x^{LL}',[],[];'x^{LT}',[],[]};
if misc.internalVars.isDataSimulation
    LT.pQ0={'1E-7'};
    LT.init={'[10 -0.1]','[0.1^2 0.1^2]'};
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
LA.Prod=@(p,t,dt) [0 0 0;0 0 0;0 0 0];
LA.pProd=[];
LA.pProd0=[];
%LA.Q=@(p,t,dt) p^2*dt/dt_ref*[dt^5/20 dt^4/8 dt^3/6;dt^4/8 dt^3/3 dt^2/2;dt^3/6 dt^2/2 dt]; Continuous-time process error
LA.Q=@(p,t,dt) p^2*dt/dt_ref*[dt^4/4 dt^3/2 dt^2/2;dt^3/2 dt^2 dt;dt^2/2 dt 1]; %Discrete-time process error
LA.pQ={'\sigma_w','LA',[],[],[0,inf], PriorType, PriorMean, PriorSdev};
LA.ProdQ=@(m,idx,p,t,dt) [0 0 0;0 0 0; 0 0 0];
LA.pProdQ = [];
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
LcT.Prod=@(p,t,dt) [0 0;0 0];
LcT.pProd=[];                                                                   % components needs to be added for Prod 
LcT.pProd0=[];
LcT.ProdQ=@(m,idx,p,t,dt) [0 0;0 0];
LcT.pProdQ=[];
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
LcA.Prod=@(p,t,dt) zeros(3,3);
LcA.pProd=[];                                                                   % components needs to be added for Prod 
LcA.pProd0=[];
LcA.pA0=[];
%LcA.Q=@(p,t,dt) p^2*dt/dt_ref*[1 0 0;0 0 0; 0 0 1E-15/(p^2*dt/dt_ref)];
LcA.Q=@(p,t,dt) p^2*dt/dt_ref*[1 0 0;0 0 0; 0 0 1E-30];
LcA.pQ={'\sigma_w','LcA',[],[],[0,inf], PriorType, PriorMean, PriorSdev};
LcA.ProdQ=@(m,idx,p,t,dt) zeros(3,3);
LcA.pProdQ=[];
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
TcA.Prod=@(p,t,dt) zeros(3,3);
TcA.pProd=[];                                                                   % components needs to be added for Prod 
TcA.pProd0=[];
TcA.pC0=[];
%TcA.Q=@(p,t,dt) p^2*dt/dt_ref*[dt^3/3 dt^2/2 0;dt^2/2 dt 0; 0 0 1E-15/(p^2*dt/dt_ref)];
TcA.Q=@(p,t,dt) p^2*dt/dt_ref*[dt^4/4 dt^3/2 0;dt^3/2 dt^2 0; 0 0 1E-30];
TcA.pQ={'\sigma_w','TcA',[],[],[0,inf], PriorType, PriorMean, PriorSdev};
TcA.ProdQ=@(m,idx,p,t,dt) zeros(3,3);
TcA.pProdQ=[];
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
PD.Prod=@(p,t,dt) [0 0;0 0];
PD.pProd=[];
PD.pProd0=[];
PD.C=@(p,t,dt) [1 0];
PD.pC=[];
PD.pC0=[];
PD.I=@(p,t,dt) [p 0];
PD.pI={'\phi','PD,I',[],[],[-inf,inf], PriorType, PriorMean, PriorSdev};
PD.pI0={'0.5'};
PD.Q=@(p,t,dt) p^2*dt/dt_ref*[1 0;0 1];
PD.pQ={'\sigma_w','PD',[],[],[nan,nan], PriorType, PriorMean, PriorSdev};
PD.ProdQ=@(m,idx,p,t,dt) [0 0;0 0];
PD.pProdQ = [];
PD.x={'x^{S1}',[],[];'x^{S2}',[],[]};
if misc.internalVars.isDataSimulation
    PD.pQ0={'0'};
    PD.init={'[10,0]','[(2*0.1)^2,(2*0.1)^2]'};
else
    PD.pQ0={'0*nanstd(data.values(:,obs))'};
    PD.init={'[5,0]','[(2*nanstd(data.values(:,obs)))^2,(2*nanstd(data.values(:,obs)))^2]'};
end
PD.B=@(p,t,dt) [0 0];
PD.pB=[];
PD.pB0=[];
PD.W=@(p,t,dt) diag([0,0]);
PD.pW=[];
PD.pW0=[];

%#41 Autoregressive component
model.components.idx{41}='AR';
AR.A=@(p,t,dt) p(1)^(dt/dt_ref);
AR.pA={'\phi','AR',[],[],[0,1], PriorType, PriorMean, PriorSdev};
AR.pA0={'0.75'};
AR.Prod=@(p,t,dt) 0;
AR.pProd=[];
AR.pProd0=[];
AR.C=@(p,t,dt) 1;
AR.pC=[];
AR.pC0=[];
AR.I=@(p,t,dt) p;
AR.pI={'\phi','AR,I',[],[],[-inf,inf], PriorType, PriorMean, PriorSdev};
AR.pI0={'0.5'};
AR.Q=@(p,t,dt) p^2*dt/dt_ref;
AR.pQ={'\sigma_w','AR',[],[],[0,inf], PriorType, PriorMean, PriorSdev};
AR.ProdQ=@(m,idx,p,t,dt) 0;
AR.pProdQ = [];
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

%#42 Autoregressive component
model.components.idx{42}='ARN';
ARN.A=@(p,t,dt) [0 0 1;0 1 0;0 0 0];
ARN.pA=[];
ARN.pA0=[];
ARN.Prod=@(p,t,dt) [0 0 0;0 0 0;1 1 0];
ARN.pProd=[];
ARN.pProd0=[];
ARN.C=@(p,t,dt) [1 0 0];
ARN.pC=[];
ARN.pC0=[];
ARN.I=@(p,t,dt) [p 0 0];
ARN.pI={'\phi','AR,I',[],[],[-inf,inf], PriorType, PriorMean, PriorSdev};
ARN.pI0={'0.5'};
ARN.Q=@(p,t,dt) p^2*dt/dt_ref*[1 0 0;0 0 0;0 0 0];
ARN.pQ={'\sigma_w','AR',[],[],[0,inf], PriorType, PriorMean, PriorSdev};
ARN.ProdQ=@(m,idx,p,t,dt) [0 m(idx(1)) 0; 0 1 0;0 0 0]*[0 0 0;0 p^2 0;0 0 0]*[0 m(idx(1)) 0; 0 1 0;0 0 0]'*dt;
%ARN.ProdQ=@(m,idx,p,t,dt) [0 0 0; 0 1 0;0 0 0]*[0 0 0;0 p^2 0;0 0 0]*[0 0 0; 0 1 0;0 0 0]'*dt;
ARN.pProdQ={'\sigma_w','phi',[],[],[0,inf], PriorType, PriorMean, PriorSdev};
ARN.x={'x^{AR}',[],[];'x^{phi}',[],[];'x^{Prod}',[],[]};

if misc.internalVars.isDataSimulation
    ARN.pQ0={'1E-2'};
    ARN.pProdQ0={'1E-3'};
    ARN.init={'[0,0.75,0]','[0.01,0.0001,0]'};
else
    ARN.pQ0={'1E-1*nanstd(data.values(:,obs))'};
    ARN.pProdQ0={'1E-1*nanstd(data.values(:,obs))'};
    ARN.init={'[0,0.75,0]','[(nanstd(data.values(:,obs)))^2,(nanstd(data.values(:,obs)))^2,1e-6]'};
end
ARN.B=@(p,t,dt) 0;
ARN.pB=[];
ARN.pB0=[];
ARN.W=@(p,t,dt) 0;
ARN.pW=[];
ARN.pW0=[];


%#51 Kernel Regression
% if ~isfield(model.components,'nb_KR_p')
%     model.components.nb_KR_p=20+1;
% end
if ~isfield(model.components,'nb_KR_p')
    model.components.nb_KR_p=misc.options.KRNumberControlPoints+1;
end
model.components.idx{51}='KR';
KR.A=@(p,t,dt) [[0 Kernel_component(p,t,timestamps(1),model.components.nb_KR_p-1)];zeros(model.components.nb_KR_p-1,1) eye(model.components.nb_KR_p-1)];
KR.pA=[{'\ell','KR',[],[],[0,inf], PriorType, PriorMean, PriorSdev}; ...
    {'p','KR',[],[],[nan,nan], PriorType, PriorMean, PriorSdev}];
KR.pA0=[{'0.5'};{'365.2422'}];
KR.Prod=@(p,t,dt) [0 zeros(1,model.components.nb_KR_p-1);zeros(model.components.nb_KR_p-1,1) zeros(model.components.nb_KR_p-1)];
KR.pProd=[];
KR.pProd0=[];
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
KR.ProdQ=@(m,idx,p,t,dt) zeros(model.components.nb_KR_p);
KR.pProdQ = [];
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

%#52 Double Kernel Regression

if ~isfield(model.components,'nb_DKR_p1') && ~isfield(model.components,'nb_DKR_p2')
    model.components.nb_DKR_p1=30;
    model.components.nb_DKR_p2=50;
end
model.components.idx{52}='DKR';
DKR.A=@(p,t,dt) [[ [[0 Kernel_component(p,t,timestamps(1),model.components.nb_DKR_p1-1)]; zeros(model.components.nb_DKR_p1-1,1) eye(model.components.nb_DKR_p1-1)] zeros(model.components.nb_DKR_p1,model.components.nb_DKR_p2) zeros(model.components.nb_DKR_p1,1)];
    [zeros(model.components.nb_DKR_p2,model.components.nb_DKR_p1) [[0  Kernel_component_DKR(p,t,timestamps(1),model.components.nb_DKR_p2-1)];zeros(model.components.nb_DKR_p2-1,1)  eye(model.components.nb_DKR_p2-1)] zeros(model.components.nb_DKR_p2,1)];
    [zeros(1,model.components.nb_DKR_p1+model.components.nb_DKR_p2) 0]];

DKR.pA=[{'\ell1','DKR',[],[],[0,inf], PriorType, PriorMean, PriorSdev}; ...
    {'p1','DKR',[],[],[nan,nan], PriorType, PriorMean, PriorSdev}; ...
    {'\ell2','DKR',[],[],[0,inf], PriorType, PriorMean, PriorSdev}; ...
    {'p2','DKR',[],[],[nan,nan], PriorType, PriorMean, PriorSdev}];

DKR.pA0=[{'0.5'};{'7'};{'0.5'};{'365'}];
DKR.Prod=@(p,t,dt) [zeros(model.components.nb_DKR_p1+model.components.nb_DKR_p2,model.components.nb_DKR_p1+model.components.nb_DKR_p2+1); ...
    1 zeros(1,model.components.nb_DKR_p1-1) 1 zeros(1,model.components.nb_DKR_p2) ];
DKR.pProd=[];
DKR.pProd0=[];
DKR.C=@(p,t,dt) [0 zeros(1,model.components.nb_DKR_p1-1) 0 zeros(1,model.components.nb_DKR_p2-1) 1];
DKR.pC=[];
DKR.pC0=[];
DKR.I=@(p,t,dt) [p(1)*1 zeros(1,model.components.nb_DKR_p1-1) p(2)*1 zeros(1,model.components.nb_DKR_p2-1) 0];
DKR.pI=[{'\phi1','DKR,I',[],[],[-inf,inf], PriorType, PriorMean, PriorSdev}; ...
    {'\phi2','DKR,I',[],[],[-inf,inf], PriorType, PriorMean, PriorSdev}];

DKR.pI0=[{'0.01'};{'0.01'}];
%KR.Q=@(p,t,dt) blkdiag(0,eye(model.components.nb_KR_p-1)*p^2*dt/dt_ref);
DKR.Q=@(p,t,dt) [[blkdiag(p(1)^2*dt/dt_ref,eye(model.components.nb_DKR_p1-1)*p(2)^2*dt/dt_ref,p(3)^2*dt/dt_ref,eye(model.components.nb_DKR_p2-1)*p(4)^2*dt/dt_ref) zeros(model.components.nb_DKR_p1+model.components.nb_DKR_p2,1)]; ...
    [zeros(1,model.components.nb_DKR_p1+model.components.nb_DKR_p2) 0]];
DKR.pQ=[{'\sigma_w1','DKR',[],[],[0,inf], PriorType, PriorMean, PriorSdev};...
    {'\sigma_hw1','DKR',[],[],[NaN,NaN], PriorType, PriorMean, PriorSdev} ;...
    {'\sigma_w2','DKR',[],[],[0,inf], PriorType, PriorMean, PriorSdev};...
    {'\sigma_hw2','DKR',[],[],[NaN,NaN], PriorType, PriorMean, PriorSdev}];


DKR.ProdQ=@(m,idx,p,t,dt) zeros(model.components.nb_DKR_p1+model.components.nb_DKR_p2+1);
DKR.pProdQ = [];
DKR.x=[];

for i=0:(model.components.nb_DKR_p1-1)
    DKR.x=[DKR.x;{['x^{DKR1_' num2str(i) '}'],[],[]}];
end
for i=0:(model.components.nb_DKR_p2-1)
    DKR.x=[DKR.x;{['x^{DKR2_' num2str(i) '}'],[],[]}];
end
DKR.x =[DKR.x;{'DKR^{Prod}',[],[]}];
clear i
if misc.internalVars.isDataSimulation
    t = linspace(1,2*pi, model.components.nb_DKR_p);
    a=sin(t);
    b=sin(4*t+30);
    c = sin(8*t-45);
    summ=a+b+c;
    summ_trun = summ(1:model.components.nb_DKR_p);
    
    DKR.pQ0=[{'0'};{'0'}];
    DKR.init={['[' sprintf('%f ', summ_trun) ']'],['[' repmat('0.01 ',[1,model.components.nb_DKR_p]) ']']};
else
    
    DKR.pQ0=[{'1E-1*nanstd(data.values(:,obs))'};{'0'};{'1E-1*nanstd(data.values(:,obs))'};{'0'};{'1E-1*nanstd(data.values(:,obs))'}]; %SA
    %DKR.init={['[' repmat('0 ',[1,model.components.nb_DKR_p]) ']'],['[' '1E-4*nanstd(data.values(:,obs))^2 ' repmat('nanstd(data.values(:,obs))^2 ',[1,model.components.nb_DKR_p-1]) ']']};
    DKR.init={['[' repmat('0 ',[1,model.components.nb_DKR_p1+model.components.nb_DKR_p2+1]) ']'],['[' 'nanstd(data.values(:,obs))^2 ' repmat('nanstd(data.values(:,obs))^2 ',[1,model.components.nb_DKR_p1+model.components.nb_DKR_p2]) ']']};
end
DKR.B=@(p,t,dt) zeros(1,model.components.nb_DKR_p);
DKR.pB=[];
DKR.pB0=[];
DKR.W=@(p,t,dt) zeros(model.components.nb_DKR_p);
DKR.pW=[];
DKR.pW0=[];


%#53 Nonlinear Periodic Regression
if ~isfield(model.components,'nb_PR_p1')
    model.components.nb_PR_p1 = 20;
    model.components.nb_PR_p2 = 0;
    model.components.nb_SR_p  = 20;
end
% for i = 1:size(model.components.block,2)
%     
%     if  any(ismember(model.components.block{1}{i},51))
%         model.components.nb_PR_p1 = model.components.nb_KR_p-1;
%         model.components.nb_PR_p2 = 0;
%         if ~isfield(model.components,'nb_SR_p')
%             model.components.nb_SR_p  = 20;
%         end
%         
%     elseif any(ismember(model.components.block{1}{i},52))
%         model.components.nb_PR_p1 = model.components.nb_DKR_p1-1;
%         model.components.nb_PR_p2 = model.components.nb_DKR_p2-1;
%         model.components.nb_SR_p  = 20;
%     else
%         model.components.nb_PR_p1 = 20;
%         model.components.nb_PR_p2 = 0;
%         model.components.nb_SR_p  = 20;
%     end
% end
nb_XD = double(any(model.components.nb_PR_p1))+double(any(model.components.nb_PR_p2));
model.components.nb_XD = nb_XD;
A1 = blkdiag(1,zeros(model.components.nb_PR_p1+model.components.nb_PR_p2),zeros(nb_XD),zeros(model.components.nb_PR_p1+model.components.nb_PR_p2));

% Indices for Product terms
ind1 = [2+model.components.nb_PR_p1+model.components.nb_PR_p2]; ind1 = [ind1;ind1+nb_XD-1];
ind2 = ind1(2) + 1; ind2 = [ind2;ind2+model.components.nb_PR_p1-1];
if model.components.nb_PR_p2 ~=0
    ind3 = ind2(2)+1; ind3 = [ind3;ind3+model.components.nb_PR_p2-1];
    A1(ind1(1),ind2(1):ind2(end)) = ones(1,model.components.nb_PR_p1);
    A1(ind1(2),ind3(1):ind3(end)) = ones(1,model.components.nb_PR_p2);
else
    A1(ind1(1),ind2(1):ind2(end)) = ones(1,model.components.nb_PR_p1);
end

A2 = [blkdiag(zeros(model.components.nb_SR_p),eye(model.components.nb_SR_p),0) [zeros(2*model.components.nb_SR_p,model.components.nb_SR_p+1);[0 ones(1,model.components.nb_SR_p)]];...
    zeros(1,3*model.components.nb_SR_p+2);zeros(model.components.nb_SR_p,2*model.components.nb_SR_p+2) zeros(model.components.nb_SR_p)];

model.components.idx{53}='NPR';
NPR.A=@(p,t,dt) blkdiag(A1,A2);
NPR.pA=[];
NPR.pA0=[];
NPR.Prod=@(p,t,dt) blkdiag(zeros(size(A1,1)),zeros(3*model.components.nb_SR_p+2));
NPR.pProd=[];
NPR.pProd0=[];
NPR.C=@(p,t,dt) [zeros(1,size(A1,1)) zeros(1,2*model.components.nb_SR_p) 0 1 zeros(1,model.components.nb_SR_p)];
NPR.pC=[];
NPR.pC0=[];
NPR.I=@(p,t,dt) [zeros(1,size(A1,1)) zeros(1,2*model.components.nb_SR_p) 0 0 zeros(1,model.components.nb_SR_p)];
NPR.pI=[];
NPR.pI0=[];
NPR.Q=@(p,t,dt) blkdiag(zeros(size(A1,1)),zeros(3*model.components.nb_SR_p+2));
NPR.pQ=[];
NPR.ProdQ=@(m,idx,p,t,dt) blkdiag(zeros(size(A1,1)),zeros(3*model.components.nb_SR_p+2));
NPR.pProdQ=[];

% Naming of the components
NPR.x = {'x^{delta}',[],[]};
for i = 1:model.components.nb_PR_p1
    NPR.x =[NPR.x;{['x^{K1_delta' num2str(i) '}'],[],[]}];
end
if model.components.nb_PR_p2 ~= 0
    for i = 1:model.components.nb_PR_p2
        NPR.x =[NPR.x;{['x^{K2_delta' num2str(i) '}'],[],[]}];
    end
end
for i = 1:nb_XD
    NPR.x =[NPR.x;{['x^{D' num2str(i) '}'],[],[]}];
end
for i = 1:model.components.nb_PR_p1+model.components.nb_PR_p2
    NPR.x =[NPR.x;{['x^{P_Prod' num2str(i) '}'],[],[]}];
end
for i = 1:model.components.nb_SR_p
    NPR.x =[NPR.x;{['x^{SR' num2str(i) '}'],[],[]}];
end
for i = 1:model.components.nb_SR_p
    NPR.x =[NPR.x;{['x^{S_phi' num2str(i) '}'],[],[]}];
end
NPR.x = [NPR.x;{'x^{phi0}',[],[]}];
NPR.x = [NPR.x;{'x^{S1}',[],[]}];
for i = 1:model.components.nb_SR_p
    NPR.x =[NPR.x;{['x^{S_Prod' num2str(i) '}'],[],[]}];
end



if misc.internalVars.isDataSimulation
    NPR.pQ0=[];
    NPR.pProdQ0=[];
    NPR.init={'zeros(1,2*(model.components.nb_PR_p1+model.components.nb_PR_p2)+1+nb_XD+3*model.components.nb_SR_p+2)','zeros(1,2*(model.components.nb_PR_p1+model.components.nb_PR_p2)+1+nb_XD+3*model.components.nb_SR_p+2)'};
else
    NPR.pQ0=[];
    NPR.pProdQ0=[];
    NPR.init={'zeros(1,2*(model.components.nb_PR_p1+model.components.nb_PR_p2)+1+nb_XD+3*model.components.nb_SR_p+2)','zeros(1,2*(model.components.nb_PR_p1+model.components.nb_PR_p2)+1+nb_XD+3*model.components.nb_SR_p+2)'};
end
NPR.B=@(p,t,dt) 0;
NPR.pB=[];
NPR.pB0=[];
NPR.W=@(p,t,dt) 0;
NPR.pW=[];
NPR.pW0=[];

%#54 State Regression
if ~isfield(model.components,'nb_SR_p')
    model.components.nb_SR_p=20;
end
model.components.idx{54}='SR';
SR.A=@(p,t,dt) [blkdiag(zeros(model.components.nb_SR_p),eye(model.components.nb_SR_p),0) [zeros(2*model.components.nb_SR_p,model.components.nb_SR_p+1);[0 ones(1,model.components.nb_SR_p)]];...
                 zeros(1,3*model.components.nb_SR_p+2);zeros(model.components.nb_SR_p,2*model.components.nb_SR_p+2) zeros(model.components.nb_SR_p)];
SR.pA=[];
SR.pA0=[];
SR.Prod=@(p,t,dt) [zeros(2*model.components.nb_SR_p+2,3*model.components.nb_SR_p+2);eye(model.components.nb_SR_p) eye(model.components.nb_SR_p) zeros(model.components.nb_SR_p,model.components.nb_SR_p+2)];
SR.pProd=[];
SR.pProd0=[];
SR.C=@(p,t,dt) [zeros(1,2*model.components.nb_SR_p) 0 0 zeros(1,model.components.nb_SR_p)];
SR.pC=[];
SR.pC0=[];
SR.I=@(p,t,dt) zeros(1,3*model.components.nb_SR_p+2);
SR.pI=[];
SR.pI0=[];
SR.Q=@(p,t,dt) zeros(3*model.components.nb_SR_p+2);
SR.pQ=[];
SR.ProdQ=@(m,idx,p,t,dt) zeros(3*model.components.nb_SR_p+2);
SR.pProdQ=[];
SR.x=[];

for i=1:(model.components.nb_SR_p)
    SR.x=[SR.x;{['x^{SR_' num2str(i) '}'],[],[]}];
end
for i=1:(model.components.nb_SR_p)
    SR.x=[SR.x;{['x^{phi' num2str(i) '}'],[],[]}];
end
SR.x =[SR.x;{'x^{phi0}',[],[]}];
SR.x =[SR.x;{'x^{D}',[],[]}];
for i=1:(model.components.nb_SR_p)
    SR.x=[SR.x;{['x^{Prod' num2str(i) '}'],[],[]}];
end
clear i

if misc.internalVars.isDataSimulation
    SR.pQ0=[];
    SR.pProdQ0=[];
    SR.init={'zeros(1,3*model.components.nb_SR_p+2)','zeros(1,3*model.components.nb_SR_p+2)'};
else
    SR.pQ0=[];
    SR.pProdQ0=[];
    SR.init={'zeros(1,3*model.components.nb_SR_p+2)','zeros(1,3*model.components.nb_SR_p+2)'};
end
SR.B=@(p,t,dt) 0;
SR.pB=[];
SR.pB0=[];
SR.W=@(p,t,dt) 0;
SR.pW=[];
SR.pW0=[];

%#61 Level intervention
model.components.idx{61}='LI';
LI.A=@(p,t,dt) 1;
LI.pA=[];
LI.pA0=[];
LI.C=@(p,t,dt) 1;
LI.pC=[];
LI.pC0=[];
LI.Prod=@(p,t,dt) 0;
LI.pProd=[];
LI.pProd0=[];
LI.I=@(p,t,dt) 0;
LI.pI=[];
LI.pI0=[];
LI.Q=@(p,t,dt) 0;
LI.pQ=[];
LI.x={'x^{LI}',[],[]};
LI.pQ0={'0'};
LI.ProdQ=@(m,idx,p,t,dt) 0;
LI.pProdQ=[];
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
    Prod{class_from}=[];
    R{class_from}=[];
    B{class_from}=[];
    W{class_from}=[];
    initX{class_from}=[];        %Initial state variable expected value
    initV{class_from}=[];        %Initial state variable variance
    hidden_states_names{class_from}={};     %Reference vector for hidden state variables names
    for class_to=1:numberOfModelClass%Loop over each model class
        Q{class_from}{class_to}=[];
        ProdQ{class_from}{class_to}=[];
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
                        elseif strcmp(block_name,'KR') || strcmp(block_name,'DKR')
                            name=eval([block_name '.pA']);
                            k_count=0;
                            for i=1:size(name,1)
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
                        if ~isempty(name)&&~strcmp(block_name,'KR')&&~strcmp(block_name,'DKR')
                            for i = 1:size(name,1)
                                name{i,3}=[num2str(class_from)];
                                name{i,4}=num2str(obs);
                            end
                        end
                        param_properties=[param_properties;name];
                        A_param_ref{class_from}{obs}{block}=p_idx;
                        param_idx=param_idx+nb_param;
                    end
                    
                    % Prod - index matrix
                    if class_from>1&&model.components.const{class_from}{obs}(block)==1
                        Prod{class_from}=[Prod{class_from},',',[block_name '.Prod(p([' num2str(Prod_param_ref{1}{obs}{block}) ']),t,dt)']];
                    else
                        nb_param=eval(['size(' block_name '.pProd,1)']);
                        if nb_param>0
                            p_idx=param_idx:param_idx-1+nb_param;
                        else
                            p_idx=[];
                        end
                        Prod{class_from}=[Prod{class_from},',',[block_name '.Prod(p([' num2str(p_idx) ']),t,dt)']];
                        if any(strcmp(eval([block_name '.pProd']),'p'))
                            p_count=p_count+1;
                            name={'p' ,['PD' num2str(p_count)],[],[],eval([block_name '.pProd{4}']), PriorType, PriorMean, PriorSdev};
                            p_value=eval([block_name '.pProd0{' num2str(p_count) '}']);
                            if ~isempty(p_value)
                                parameter=[parameter;eval(p_value)];
                            end
                            %                         elseif strcmp(block_name,'KR')
                            %                             name=eval([block_name '.pProd']);
                            %                             k_count=0;
                            %                             for i=1:2
                            %                                 k_count=k_count+1;
                            %                                 p_value=eval([block_name '.pProd0{' num2str(k_count) '}']);
                            %                                 parameter=[parameter;eval(p_value)];
                            %                                 name{i,3}=[num2str(class_from)];
                            %                                 name{i,4}=num2str(obs);
                            %                             end
                        else
                            name=eval([block_name '.pProd']);
                            p_value=eval([block_name '.pProd0']);
                            if ~isempty(p_value)
                                parameter=[parameter;eval(p_value{:})];
                            end
                        end
                        if ~isempty(name)&&~strcmp(block_name,'KR')
                            name{3}=[num2str(class_from)];
                            name{4}=num2str(obs);
                        end
                        param_properties=[param_properties;name];
                        Prod_param_ref{class_from}{obs}{block}=p_idx;
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
                    
                    % Q_Prod - Product error covariance
                    if class_from>1&&model.components.const{class_from}{obs}(block)==1
                        ProdQ{class_from}{class_to}=[ProdQ{class_from}{class_to},',',[block_name '.ProdQ(m,idx,p([' num2str(ProdQ_param_ref{1}{obs}{block}) ']),t,dt)']];
                        ProdQ_param_ref{class_from}{obs}{block}=ProdQ_param_ref{1}{obs}{block};
                    else
                        nb_param=eval(['size(' block_name '.pProdQ,1)']);
                        if nb_param>0
                            p_idx=param_idx:param_idx-1+nb_param;
                        else
                            p_idx=[];
                        end
                        ProdQ{class_from}{class_to}=[ProdQ{class_from}{class_to},',',[block_name '.ProdQ(m,idx,p([' num2str(p_idx) ']),t,dt)']];
                        %                         if any(strcmp(eval([block_name '.pA']),'p'))
                        %                             name={'\sigma_w',['PD' num2str(p_count)],[],[],eval([block_name '.pProdQ(5)']), PriorType, PriorMean, PriorSdev};
                        %                         else
                        name=eval([block_name '.pProdQ']);
                        %                         end
                        if ~isempty(name)
                            for i=1:nb_param
                                p_value=eval(eval([block_name '.pProdQ0{' num2str(i) '}']));
                                parameter=[parameter;p_value];
                                name{i,3}=[num2str(class_from)];
                                name{i,4}=num2str(obs);
                            end
                        end
                        param_properties=[param_properties;name];
                        ProdQ_param_ref{class_from}{obs}{block}=p_idx;
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
            model.Prod{class_from}=eval(['@(p,t,dt) blkdiag(' Prod{class_from}(2:end) ')']);
            model.C{class_from}=eval(['@(p,t,dt) reshape([' ([Cc{class_from}{:}]) '],[' num2str(sum([nb_hidden_states{class_from}{:}])) ','  num2str(numberOfTimeSeries) '])''']);
            model.R{class_from}=eval(['@(p,t,dt) blkdiag(' R{class_from}(2:end) ')']);
            model.Q{class_from}{class_to}=eval(['@(p,t,dt) blkdiag(' Q{class_from}{class_to}(2:end) ')']);
            model.ProdQ{class_from}{class_to}=eval(['@(m,idx,p,t,dt) blkdiag(' ProdQ{class_from}{class_to}(2:end) ')']);
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
                    if block_idx>10&&block_idx<30 &&obs==1 %&& ~strcmp(block_name,'LcT')                       %BD
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
%% Indexes of each of the hidden components used
j = 1;
k = 1;
if size(model.components.block{1,1},2)>1
    len = [];
    b   = 1;
    while b <= size(model.components.block{1,1},2)
        len = [len length(model.components.block{1,1}{1,b})];
        b   = b+1;
    end
    for i = 1:sum(len)
        component_id = model.components.block{1,1}{1,j}(k);
        k = k+1;
        block_name = model.components.idx{component_id};
        if exist(block_name,'var')
            model.components.index{1,i} = block_name;
            model.components.index{2,i} = size(eval([model.components.idx{component_id} '.x']),1);
            if i ==1
                model.components.index{3,i} = 1;
            else
                model.components.index{3,i} = model.components.index{3,i-1} + model.components.index{2,i-1};
            end
        end
        if component_id == model.components.block{1, 1}{1, j}(end)
            if j == size(model.components.block{1,1},2)
                break;
            else
                j = j+1;
                k = 1;
            end
        end
    end
end


%%  Adding additional parameters
Index_53 = ismember(model.param_properties(:,1), '\l1');
if ~any(Index_53)
    for i = 1:size(model.components.block{1,1},2)
        if any(ismember(model.components.block{1}{i},53))     %DKR 
            r = size(model.param_properties,1);
            model.param_properties{r+1,1} = ['\l1'];model.param_properties{r+1,2} = [];model.param_properties{r+1,3} = ['1'];model.param_properties{r+1,4} = ['1'];model.param_properties{r+1,5} = [0,Inf];model.param_properties{r+1,6} = 'N/A';model.param_properties{r+1,7} = NaN;model.param_properties{r+1,8} = NaN;model.param_properties{r+1,9} = 0.482; model.param_properties{r+1,10} = r+1;
        elseif any(ismember(model.components.block{1}{i},54)) %SR
            r = size(model.param_properties,1);
            model.param_properties{r+1,1} = ['\l1'];model.param_properties{r+1,2} = [];model.param_properties{r+1,3} = ['1'];model.param_properties{r+1,4} = ['1'];model.param_properties{r+1,5} = [0,Inf];model.param_properties{r+1,6} = 'N/A';model.param_properties{r+1,7} = NaN;model.param_properties{r+1,8} = NaN;model.param_properties{r+1,9} = 0.482; model.param_properties{r+1,10} = r+1;
            ind_SR = find(ismember(model.components.block{1}{i},54));  % position within the block containing SR
            len_SR = length(ind_SR);
            if len_SR > 1
                k = 1;
                r = size(model.param_properties,1);
                while k <=len_SR-1
                    model.param_properties{r+k,1} = ['\l1'];model.param_properties{r+k,2} = [];model.param_properties{r+k,3} = ['1'];model.param_properties{r+k,4} = ['1'];model.param_properties{r+k,5} = [0,Inf];model.param_properties{r+k,6} = 'N/A';model.param_properties{r+k,7} = NaN;model.param_properties{r+k,8} = NaN;model.param_properties{r+k,9} = 0.482; model.param_properties{r+k,10} = r+k;
                    k = k+1;
                end
                clear k
            end
            
        end
    end
end
%% Getting indices of the Product terms
Product = model.Prod{1}([],[],[]);
S = [];
if size(model.components.block{1,1},2)>1
    for i = 1:size(model.components.index,2)
        S{i} = model.components.index{1,i};
    end
end
model.S = S;
if any(strcmp(S,'DKR'))
    
    if  any(strcmp(S,'DKR'))&&any(strcmp(S,'NPR'))
        index_DKR           = any(cellfun(@(c) ischar(c) && strcmp(c,'DKR'),model.components.index));   % Index DKR
        index_DKR0_1        = model.components.index{3, index_DKR};
        index_DKR1          = index_DKR0_1+1:1:index_DKR0_1+1+(model.components.nb_DKR_p1-1)-1;
        index_DKR0_2        = index_DKR1(end)+1;
        index_DKR2          = index_DKR0_2+1:1:index_DKR0_2+1+(model.components.nb_DKR_p2-1)-1;
        index_Prod_DKR      = index_DKR2(end)+1;
        index_NPR           = any(cellfun(@(c) ischar(c) && strcmp(c,'NPR'),model.components.index));    % Index NPR
        index_delta         = model.components.index{3, index_NPR};
        index_K1_delta      = index_delta+1:1:index_delta+1+model.components.nb_PR_p1-1;
        index_K2_delta      = index_K1_delta(end)+1:1:index_K1_delta(end)+1+model.components.nb_PR_p2-1;
        index_XD            = index_K2_delta(end)+1:1:index_K2_delta(end)+1+model.components.nb_XD-1;
        index_P_Prod        = index_XD(end)+1:1:index_XD(end)+1+(model.components.nb_PR_p1+model.components.nb_PR_p2)-1;
        index_SK            = index_P_Prod(end)+1:1:index_P_Prod(end)+1+model.components.nb_SR_p-1;
        index_Sphi          = index_SK(end)+1:1:index_SK(end)+1+model.components.nb_SR_p-1;
        index_xphi          = index_Sphi(end)+1;
        index_XS1           =  index_xphi(end)+1;
        index_S_Prod        = index_XS1(end)+1:1:index_XS1(end)+1+model.components.nb_SR_p-1;
        model.idx_xprod     = [index_DKR1 index_DKR2 index_SK;index_K1_delta index_K2_delta index_Sphi];
        model.idx_prod      = [index_Prod_DKR index_P_Prod index_S_Prod]';
    elseif  any(strcmp(S,'DKR'))&&any(strcmp(S,'ARN'))
        index_DKR           = any(cellfun(@(c) ischar(c) && strcmp(c,'DKR'),model.components.index));  %Index_DKR
        index_DKR0_1        = model.components.index{3, index_DKR};
        index_DKR1          = index_DKR0_1+1:1:index_DKR0_1+1+model.components.nb_DKR_p1-1;
        index_DKR0_2        = index_DKR1(end)+1;
        index_DKR2          = index_DKR0_2+1:1:index_DKR0_2+1+model.components.nb_DKR_p2-1;
        index_Prod_DKR      = index_DKR2(end)+1;
        
        N = 1;
       [idx_xprod_ARN,idx_prod_ARN]=ind2sub(size(Product),find(Product'));                           % Index_ARN
       idx_prod_ARN=idx_prod_ARN(1:2:2*N-1);
       idx_xprod_ARN=reshape(idx_xprod_ARN,2,N);
       model.idx_xprod = [index_DKR0_1;index_DKR0_2];
       model.idx_xprod = [model.idx_xprod idx_xprod_ARN];
       model.idx_prod  = [index_Prod_DKR;idx_prod_ARN];
    elseif  any(strcmp(S,'DKR'))&&any(strcmp(S,'NPR'))&&any(strcmp(S,'ARN'))
        index_DKR           = any(cellfun(@(c) ischar(c) && strcmp(c,'DKR'),model.components.index));  %Index_DKR
        index_DKR0_1        = model.components.index{3, index_DKR};
        index_DKR1          = index_DKR0_1+1:1:index_DKR0_1+1+model.components.nb_DKR_p1-1;
        index_DKR0_2        = index_DKR1(end)+1;
        index_DKR2          = index_DKR0_2+1:1:index_DKR0_2+1+model.components.nb_DKR_p2-1;
        %index_Prod_DKR       = index_DKR2(end)+1;
        
        index_NPR           = any(cellfun(@(c) ischar(c) && strcmp(c,'NPR'),model.components.index));    % Index NPR
        index_delta         = model.components.index{3, index_NPR};
        index_K1_delta      = index_delta+1:1:index_delta+1+model.components.nb_PR_p1-1;
        index_K2_delta      = index_K1_delta(end)+1:1:index_K1_delta(end)+1+model.components.nb_PR_p2-1;
        index_XD            = index_K2_delta(end)+1:1:index_K2_delta(end)+1+model.components.nb_XD-1;
        index_P_Prod        = index_XD(end)+1:1:index_XD(end)+1+(model.components.nb_PR_p1+model.components.nb_PR_p2)-1;
        index_SK            = index_P_Prod(end)+1:1:index_P_Prod(end)+1+model.components.nb_SR_p-1;
        index_Sphi          = index_SK(end)+1:1:index_SK(end)+1+model.components.nb_SR_p-1;
        index_xphi          = index_Sphi(end)+1;
        index_XS1           =  index_xphi(end)+1;
        index_S_Prod        = index_XS1(end)+1:1:index_XS1(end)+1+model.components.nb_SR_p-1;
        
        
        N = 1;
       [idx_xprod_ARN,idx_prod_ARN]=ind2sub(size(Product),find(Product'));                           % Index_ARN
       idx_prod_ARN=idx_prod_ARN(1:2:2*N-1);
       idx_xprod_ARN=reshape(idx_xprod_ARN,2,N);
       
       model.idx_xprod     = [index_DKR1 index_DKR2 index_SK;index_K1_delta index_K2_delta index_Sphi];
       model.idx_xprod     = [model.idx_xprod idx_xprod_ARN];
       model.idx_prod      = [index_P_Prod;index_S_Prod;idx_prod_ARN];
        
    else
        index_DKR           = any(cellfun(@(c) ischar(c) && strcmp(c,'DKR'),model.components.index));
        index_DKR0_1        = model.components.index{3, index_DKR};
        index_DKR1          = index_DKR0_1+1:1:index_DKR0_1+1+model.components.nb_DKR_p1-1;
        index_DKR0_2        = index_DKR1(end)+1;
        index_DKR2          = index_DKR0_2+1:1:index_DKR0_2+1+model.components.nb_DKR_p2-1;
        index_Prod_DKR      = index_DKR2(end)+1;
        model.idx_xprod     = [index_DKR0_1;index_DKR0_2];
        model.idx_prod      = index_Prod_DKR;
    end
elseif any(strcmp(S,'SR'))                                    %BD
    N=model.components.nb_SR_p;
    index_SR        = any(cellfun(@(c) ischar(c) && strcmp(c,'SR'),model.components.index));
    if length(find(index_SR))==1
        index_x_SR      = model.components.index{3, index_SR}:model.components.index{3, index_SR}+N-1;  % X^{SR}
        index_x_phi     = index_x_SR(end)+1:index_x_SR(end)+N;
        index_S_Prod    = index_x_phi(end)+3:index_x_phi(end)+3+N-1;
        model.idx_xprod = [index_x_SR;index_x_phi];
        model.idx_prod  = index_S_Prod;
    else
        indices         = find(index_SR);
        len             = length(indices);
        k = 1;
        index_x_SR   = cell(1,len);
        index_x_phi  = cell(1,len);
        index_S_Prod = cell(1,len);
        model.idx_xprod = []; model.idx_prod = [];
        while k <= len
            index_x_SR{k}     = model.components.index{3, indices(k)}:model.components.index{3, indices(k)}+N-1;
            index_x_phi{k}    = index_x_SR{k}(end)+1:index_x_SR{k}(end)+N;
            index_S_Prod{k}   = index_x_phi{k}(end)+3:index_x_phi{k}(end)+3+N-1;
            model.idx_xprod   = [model.idx_xprod [index_x_SR{k};index_x_phi{k}]];
            model.idx_prod    = [model.idx_prod index_S_Prod{k}];
            k = k+1;
        end
        
    end
elseif  any(strcmp(S,'KR'))
    if  any(strcmp(S,'KR'))&&any(strcmp(S,'NPR'))
        index_KR    = any(cellfun(@(c) ischar(c) && strcmp(c,'KR'),model.components.index));     %index of KR
        index_KR0_1 = model.components.index{3, index_KR};
        index_KR1   = model.components.index{3, index_KR}+1:1:model.components.index{3, index_KR}+model.components.nb_KR_p-1;
        index_NPR   = any(cellfun(@(c) ischar(c) && strcmp(c,'NPR'),model.components.index));   %index of NPR
        index_delta = model.components.index{3, index_NPR};
        index_K_delta = index_delta+1:1:index_delta+model.components.nb_KR_p-1;
        index_XD = index_K_delta(end)+1:1:index_K_delta(end)+1+model.components.nb_XD-1;
        index_P_Prod = index_XD(end)+1:1:index_XD(end)+1+(model.components.nb_PR_p1+model.components.nb_PR_p2)-1;
        index_SK = index_P_Prod(end)+1:1:index_P_Prod(end)+1+model.components.nb_SR_p-1;
        index_Sphi = index_SK(end)+1:1:index_SK(end)+1+model.components.nb_SR_p-1;
        index_xphi = index_Sphi(end)+1;
        index_XS1 =  index_xphi(end)+1;
        index_S_Prod = index_XS1(end)+1:1:index_XS1(end)+1+model.components.nb_SR_p-1;
        model.idx_xprod = [index_KR1 index_SK;index_K_delta index_Sphi];
        model.idx_prod  = [index_P_Prod index_S_Prod]';
    elseif  any(strcmp(S,'KR'))&&any(strcmp(S,'ARN'))
        N = 1;
        [idx_xprod,idx_prod]=ind2sub(size(Product),find(Product'));
        idx_prod=idx_prod(1:2:2*N-1);
        idx_xprod=reshape(idx_xprod,2,N);
        model.idx_prod=idx_prod;
        model.idx_xprod=idx_xprod;
    else
        model.idx_xprod = [];
        model.idx_prod  = [];
        
    end
elseif   ~any(Product)
    model.idx_xprod = [];
    model.idx_prod  = [];

else
    N = 1;
    [idx_xprod,idx_prod]=ind2sub(size(Product),find(Product'));
    idx_prod=idx_prod(1:2:2*N-1);
    idx_xprod=reshape(idx_xprod,2,N);
    model.idx_prod=idx_prod;
    model.idx_xprod=idx_xprod;
end

% 
%--------------------END CODE ------------------------
end
