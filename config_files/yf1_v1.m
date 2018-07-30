%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Project file_data reference
%[data, model, estimation, misc]=initializeProject;
%[misc]=printProjectDateCreation(misc);
misc.ProjectName='yf1_v1';
load('yf1_semaine_final.mat'); 
data.values=yf1_semaine; %Enter your dataset here; each column is a dataset; missing data -> NaN 
data.timestamps=t_yf1_semaine; %Enter the time stamps (Unix format); column vector; 
clear yf1_semaine t_yf1_semaine
data.labels={'ext'};

data.interventions=data.timestamps(750);
data.values(750:end)=data.values(750:end)+6;

misc.trainingPeriod=[1,10000];
misc.dataFilename='processed_data/DATA_DEMO1.mat';
misc.isDataSimulation=0;
misc.method='kalman';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BDLM Component reference numbers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 11: Local level
% 12: Local trend
% 13: Local acceleration
% 21: Local level compatible with local trend
% 22: Local level compatible with local acceleration
% 23: Local trend compatible with local acceleration
% 31: Perodic
% 41: Autoregressive
% 52: Dynamic regression with hidden component
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Model components | Choose which component to employ to build the model
model.components.block{1}={[13 52 41 61]};

%% Model component constrains | Take the same parameter as model class ##1
%% Model inter-components dependence | {[components form dataset_i depends on components form dataset_j]_i,[...]}
model.components.ic={[ ]};

model.param_properties={
	'\sigma_w',	 'LA',	   '1',	 'ext',	 [ 0    , Inf  ],	 'normal',	 0     ,	 1E+06   %#1
	'\sigma_w',	 'SK',	   '1',	 'ext',	 [ 0    , Inf  ],	 'normal',	 0     ,	 1E+06   %#2
	'\ell'    ,	 'SK',	   '1',	 'ext',	 [ 0    , Inf  ],	 'normal',	 0     ,	 1E+06   %#3
	'p'       ,	 'SK',	   '1',	 'ext',	 [ NaN  , NaN  ],	 'normal',	 0     ,	 1E+06   %#4
	'\phi'    ,	 'AR',	   '1',	 'ext',	 [ 0    , 1    ],	 'normal',	 0     ,	 1E+06   %#5
	'\sigma_w',	 'AR',	   '1',	 'ext',	 [ 0    , Inf  ],	 'normal',	 0     ,	 1E+06   %#6
	'B_LI'    ,	 'LI',	   '1',	 'ext',	 [ -Inf , Inf  ],	 'normal',	 0     ,	 1E+06   %#7
	'\sigma_W',	 'LI',	   '1',	 'ext',	 [ 0    , Inf  ],	 'normal',	 0     ,	 1E+06   %#8
	'\sigma_v',	 '',	   '1',	 'ext',	 [ NaN  , NaN  ],	 'normal',	 0     ,	 1E+06   %#9
};
 
model.parameter=[
1E-08 	     %#1 	%\sigma_w
0.1         %#2 	%\sigma_w
0.5      	 %#3 	%\ell
365.2422   	 %#4 	%p
0.95     	 %#5 	%\phi
0.37472  	 %#6 	%\sigma_w
4        	 %#7 	%B_LI
1   	 %#8 	%\sigma_W
0.001   	 %#9 	%\sigma_v
]; 
 
model.p_ref=[1  2  3  4  5  6  7  8  9];
