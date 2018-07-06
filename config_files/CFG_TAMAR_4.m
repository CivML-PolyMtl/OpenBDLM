%%%%%%%%%%%%%%%%%% Project file_data reference
[data, model, estimation, misc]=initializeProject;
[misc]=printProjectDateCreation(misc);
misc.ProjectName='TAMAR_4';
dat=load('processed_data/DATA_TAMAR_2.mat'); 
data.values=dat.values;
data.timestamps=dat.timestamps;
misc.trainingPeriod=[1,516];
misc.dataFilename='processed_data/DATA_TAMAR_2.mat';
misc.isDataSimulation=0;
misc.method='kalman';

%% Data
data.labels={'CLASS01','FREQ_VS1','TS062NC1','TS062ND1'};

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
model.components.block{1}={[11 ] [11 ] [11 ] [11 ] };

%% Model component constrains | Take the same  parameter as model class #1
 
 
%% Model inter-components dependence | {[components form dataset_i depends on components form  dataset_j]_i,[...]}
model.components.ic={[ ] [ ] [ ] [ ] };

 
 
%% Model parameters information :
 
 model.param_properties={
	 '\sigma_w',	'LL' ,	'1',	'CLASS01',	[ NaN  , NaN  ]	 %#1 
	 '\sigma_v',	'' ,	'1',	'CLASS01',	[ 0    , Inf  ]	 %#2 
	 '\sigma_w',	'LL' ,	'1',	'FREQ_VS1',	[ NaN  , NaN  ]	 %#3 
	 '\sigma_v',	'' ,	'1',	'FREQ_VS1',	[ 0    , Inf  ]	 %#4 
	 '\sigma_w',	'LL' ,	'1',	'TS062NC1',	[ NaN  , NaN  ]	 %#5 
	 '\sigma_v',	'' ,	'1',	'TS062NC1',	[ 0    , Inf  ]	 %#6 
	 '\sigma_w',	'LL' ,	'1',	'TS062ND1',	[ NaN  , NaN  ]	 %#7 
	 '\sigma_v',	'' ,	'1',	'TS062ND1',	[ 0    , Inf  ]	 %#8 
};
 
model.parameter=[
0        	 %#1 
0.3158   	 %#2 
0        	 %#3 
0.00010846 	 %#4 
0        	 %#5 
0.27634  	 %#6 
0        	 %#7 
0.23981  	 %#8 
];
  
model.p_ref=[1  2  3  4  5  6  7  8];
 
%% Initial states values :
 
 model.initX{ 1 }=[
	7.54   
	0.391  
	11.3   
	10     
];
 
model.initV{ 1 }=[
	160     	0       	0       	0       
	0       	1.88E-05	0       	0       
	0       	0       	122     	0       
	0       	0       	0       	92      
];
 
model.initS{1}=[1     ];


