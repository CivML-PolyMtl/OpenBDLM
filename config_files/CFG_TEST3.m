%%%%%%%%%%%%%%%%%% Project file_data reference
[data, model, estimation, misc]=initializeProject;
[misc]=printProjectDateCreation(misc);
misc.ProjectName='TEST3';
dat=load('processed_data/DATA_TOTO.mat'); 
data.values=dat.values;
data.timestamps=dat.timestamps;
misc.trainingPeriod=[1,2472];
misc.dataFilename='processed_data/DATA_TOTO.mat';
misc.isDataSimulation=0;
misc.method='kalman';

%% Data
data.labels={'LTU014PIAEVA920'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BDLM Component reference numbers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 11: Local level
% 12: Local trend
% 13: Local acceleration
% 21: Local level compatible with local trend
% 22: Local level compatible with local acceleration
% 23: Local trend compatible with local acceleration
% 31: Periodic
% 41: Autoregressive
% 51: Dynamic regression with hidden component
% 52: Static kernel regression
% 53: Dynamic kernel regression
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Model components | Choose which component to employ to build the model
model.components.block{1}={[11 ] };

%% Model component constrains | Take the same  parameter as model class #1
 
 
%% Model inter-components dependence | {[components form dataset_i depends on components form  dataset_j]_i,[...]}
model.components.ic={[ ] };

 
 
%% Model parameters information :
 
 model.param_properties={
	 '\sigma_w',	'LL' ,	'1',	'LTU014PIAEVA920',	[ NaN  , NaN  ]	 %#1 
	 '\sigma_v',	'' ,	'1',	'LTU014PIAEVA920',	[ 0    , Inf  ]	 %#2 
};
 
model.parameter=[
0        	 %#1 
0.11491  	 %#2 
];
  
model.p_ref=[1  2];
 
%% Initial states values :
 
 model.initX{ 1 }=[
	-8.18  
];
 
model.initV{ 1 }=[
	21.1    
];
 
model.initS{1}=[1     ];


