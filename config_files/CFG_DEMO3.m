%%%%%%%%%%%%%%%%%% Project file_data reference
[data, model, estimation, misc]=initializeProject;
[misc]=printProjectDateCreation(misc);
misc.ProjectName='DEMO3';
dat=load('processed_data/DATA_DEMO3.mat'); 
data.values=dat.values;
data.timestamps=dat.timestamps;
misc.trainingPeriod=[1,913];
misc.dataFilename='processed_data/DATA_DEMO3.mat';
misc.isDataSimulation=1;
misc.method='kalman';

%% Data
data.labels={'TS01'};

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
model.components.block{1}={[23 31 41 ] };
model.components.block{2}={[13 31 41 ] };

%% Model component constrains | Take the same  parameter as model class #1
 
model.components.const{2}={[1 1 1 ] };

 
%% Model inter-components dependence | {[components form dataset_i depends on components form  dataset_j]_i,[...]}
model.components.ic={[ ] };

 
 
%% Model parameters information :
 
 model.param_properties={
	 '\sigma_w',	'TcA' ,	'1',	'TS01',	[ 0    , Inf  ],	 'normal',	 0     ,	 1     %#1 
	        'p',	'PD1' ,	'1',	'TS01',	[ NaN  , NaN  ],	 'normal',	 0     ,	 1     %#2 
	 '\sigma_w',	'PD1' ,	'1',	'TS01',	[ NaN  , NaN  ],	 'normal',	 0     ,	 1     %#3 
	     '\phi',	'AR' ,	'1',	'TS01',	[ 0    , 1    ],	 'normal',	 0     ,	 1     %#4 
	 '\sigma_w',	'AR' ,	'1',	'TS01',	[ 0    , Inf  ],	 'normal',	 0     ,	 1     %#5 
	 '\sigma_v',	'' ,	'1',	'TS01',	[ 0    , Inf  ],	 'normal',	 0     ,	 1     %#6 
	 '\sigma_v',	'' ,	'2',	'TS01',	[ 0    , Inf  ],	 'normal',	 0     ,	 1     %#7 
	 '\sigma_w(11)',	'TcA' ,	'12',	'TS01',	[ 0    , Inf  ],	 'normal',	 0     ,	 1     %#8 
	 '\sigma_w(22)',	'TcA' ,	'12',	'TS01',	[ 0    , Inf  ],	 'normal',	 0     ,	 1     %#9 
	 '\sigma_w(33)',	'TcA' ,	'12',	'TS01',	[ 0    , Inf  ],	 'normal',	 0     ,	 1     %#10 
	    'Z(11)',	'' ,	'11',	'',	[ 0    , 1    ],	 'normal',	 0     ,	 1     %#11 
	    'Z(22)',	'' ,	'22',	'',	[ 0    , 1    ],	 'normal',	 0     ,	 1     %#12 
};
 
model.parameter=[
1E-08    	 %#1 
365.24   	 %#2 
0        	 %#3 
0.75     	 %#4 
0.01     	 %#5 
0.01     	 %#6 
0.01     	 %#7 
1E-05    	 %#8 
1E-05    	 %#9 
1E-05    	 %#10 
0.99973  	 %#11 
0.99973  	 %#12 
];
  
model.p_ref=[1   2   3   4   5   6   7   8   9  10  11  12];
 
%% Initial states values :
 
 model.initX{ 1 }=[
	10     
	-0.1   
	0      
	10     
	10     
	0      
];
 
model.initV{ 1 }=[
	0.01    	0       	0       	0       	0       	0       
	0       	0.01    	0       	0       	0       	0       
	0       	0       	0.01    	0       	0       	0       
	0       	0       	0       	0.04    	0       	0       
	0       	0       	0       	0       	0.04    	0       
	0       	0       	0       	0       	0       	0.01    
];
 
model.initS{1}=[0.5   ];

model.initX{ 2 }=[
	10     
	0      
	0      
	10     
	10     
	0      
];
 
model.initV{ 2 }=[
	0.01    	0       	0       	0       	0       	0       
	0       	0.01    	0       	0       	0       	0       
	0       	0       	0.01    	0       	0       	0       
	0       	0       	0       	0.04    	0       	0       
	0       	0       	0       	0       	0.04    	0       
	0       	0       	0       	0       	0       	0.01    
];
 
model.initS{2}=[0.5   ];


%% Custom anomalies :
 
misc.custom_anomalies.start_custom_anomalies=[1000];
misc.custom_anomalies.duration_custom_anomalies=[100];
misc.custom_anomalies.amplitude_custom_anomalies=[-0.025];

