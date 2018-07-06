%%%%%%%%%%%%%%%%%% Project file_data reference
[data, model, estimation, misc]=initializeProject;
[misc]=printProjectDateCreation(misc);
misc.ProjectName='TEST_12';
dat=load('processed_data/DATA_TEST_12.mat'); 
data.values=dat.values;
data.timestamps=dat.timestamps;
misc.trainingPeriod=[1,1204];
misc.dataFilename='processed_data/DATA_TEST_12.mat';
misc.isDataSimulation=0;
misc.method='kalman';

%% Data
data.labels={'LTU014PIAEVA920','LTU016PIAPE910','LTU017PIAPRG300'};

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
model.components.block{1}={[11 ] [11 ] [11 ] };

%% Model component constrains | Take the same  parameter as model class #1
 
 
%% Model inter-components dependence | {[components form dataset_i depends on components form  dataset_j]_i,[...]}
model.components.ic={[ ] [ ] [ ] };

 
 
%% Model parameters information :
 
 model.param_properties={
	 '\sigma_w',	'LL' ,	'1',	'LTU014PIAEVA920',	[ NaN  , NaN  ]	 %#1 
	 '\sigma_v',	'' ,	'1',	'LTU014PIAEVA920',	[ 0    , Inf  ]	 %#2 
	 '\sigma_w',	'LL' ,	'1',	'LTU016PIAPE910',	[ NaN  , NaN  ]	 %#3 
	 '\sigma_v',	'' ,	'1',	'LTU016PIAPE910',	[ 0    , Inf  ]	 %#4 
	 '\sigma_w',	'LL' ,	'1',	'LTU017PIAPRG300',	[ NaN  , NaN  ]	 %#5 
	 '\sigma_v',	'' ,	'1',	'LTU017PIAPRG300',	[ 0    , Inf  ]	 %#6 
};
 
model.parameter=[
0        	 %#1 
0.25026  	 %#2 
0        	 %#3 
0.079735 	 %#4 
0        	 %#5 
0.18828  	 %#6 
];
  
model.p_ref=[1  2  3  4  5  6];
 
%% Initial states values :
 
 model.initX{ 1 }=[
	-12.7  
	3.61   
	-24.4  
];
 
model.initV{ 1 }=[
	100     	0       	0       
	0       	10.2    	0       
	0       	0       	56.7    
];
 
model.initS{1}=[1     ];


