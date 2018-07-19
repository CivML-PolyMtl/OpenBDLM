%%%%%%%%%%%%%%%%%% Project file_data reference
[data, model, estimation, misc]=initializeProject;
[misc]=printProjectDateCreation(misc);
misc.ProjectName='DEMO4';
dat=load('processed_data/DATA_DEMO4.mat'); 
data.values=dat.values;
data.timestamps=dat.timestamps;
misc.trainingPeriod=[1,364];
misc.dataFilename='processed_data/DATA_DEMO4.mat';
misc.isDataSimulation=1;
misc.method='kalman';

%% Data
data.labels={'DISP01','TEMP01'};

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
model.components.block{1}={[11 31 41 ] [12 ] };

%% Model component constrains | Take the same  parameter as model class #1
 
 
%% Model inter-components dependence | {[components form dataset_i depends on components form  dataset_j]_i,[...]}
model.components.ic={[ ] [1 ] };

 
 
%% Model parameters information :
 
 model.param_properties={
	 '\sigma_w',	'LL' ,	'1',	'DISP01',	[ NaN  , NaN  ],	 'normal',	 0     ,	 1     %#1 
	        'p',	'PD1' ,	'1',	'DISP01',	[ NaN  , NaN  ],	 'normal',	 0     ,	 1     %#2 
	 '\sigma_w',	'PD1' ,	'1',	'DISP01',	[ NaN  , NaN  ],	 'normal',	 0     ,	 1     %#3 
	     '\phi',	'AR' ,	'1',	'DISP01',	[ 0    , 1    ],	 'normal',	 0     ,	 1     %#4 
	 '\sigma_w',	'AR' ,	'1',	'DISP01',	[ 0    , Inf  ],	 'normal',	 0     ,	 1     %#5 
	 '\sigma_v',	'' ,	'1',	'DISP01',	[ 0    , Inf  ],	 'normal',	 0     ,	 1     %#6 
	     '\phi',	'T|D(PD)' ,	'1',	'DISP01',	[ -Inf , Inf  ],	 'normal',	 0     ,	 1     %#7 
	     '\phi',	'T|D(AR)' ,	'1',	'DISP01',	[ -Inf , Inf  ],	 'normal',	 0     ,	 1     %#8 
	 '\sigma_w',	'LT' ,	'1',	'TEMP01',	[ 0    , Inf  ],	 'normal',	 0     ,	 1     %#9 
	 '\sigma_v',	'' ,	'1',	'TEMP01',	[ 0    , Inf  ],	 'normal',	 0     ,	 1     %#10 
};
 
model.parameter=[
0        	 %#1 
365.24   	 %#2 
0        	 %#3 
0.75     	 %#4 
0.01     	 %#5 
0.01     	 %#6 
0.5      	 %#7 
0.5      	 %#8 
1E-07    	 %#9 
0.01     	 %#10 
];
  
model.p_ref=[1   2   3   4   5   6   7   8   9  10];
 
%% Initial states values :
 
 model.initX{ 1 }=[
	10     
	10     
	10     
	0      
	10     
	-0.1   
];
 
model.initV{ 1 }=[
	0.01    	0       	0       	0       	0       	0       
	0       	0.04    	0       	0       	0       	0       
	0       	0       	0.04    	0       	0       	0       
	0       	0       	0       	0.01    	0       	0       
	0       	0       	0       	0       	0.01    	0       
	0       	0       	0       	0       	0       	0.01    
];
 
model.initS{1}=[1     ];


