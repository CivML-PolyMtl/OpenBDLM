%% A - Project name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
misc.ProjectName='ICOLD_CB3_WL_TBMA_SKF';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% B - Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dat=load('DATA_ICOLD_CB3_WL_TBMA_SKF.mat');
data.values=dat.values;
data.timestamps=dat.timestamps;
data.labels={'CB3','WL','WL','TBMA54','TBMA28','TBMA14'};

%% State-Regression
model.nb_temp = 3;
dependency_TS = 2;
if dependency_TS ==2
    model.dep     = 'LT and AR'; % 'LT and AR'
else
    model.dep     = 'LT and AR and AR';
end
%% Synthetic anomaly
anomaly.magnitude=0.25;       % mm
anomaly.start=2006;        % year
anomaly.duration=4;        % #years
nb_ts=size(data.values,1);
data_ref=data.values(:,1);
data.values(:,1)=data.values(:,1)+anomaly.magnitude*normcdf(1:nb_ts,(anomaly.start-2000)*365+anomaly.duration/2*365,anomaly.duration/4*365)';

plt=true;
%% Plot anomaly
if and(plt==true,abs(anomaly.magnitude)>0)
    nanidx=find(~isnan(data.values(1:nb_ts,1)));
    plot(data.timestamps(nanidx),data_ref(nanidx,1),'-k','Linewidth',1)
    hold on
    plot(data.timestamps(nanidx),data.values(nanidx,1),'-r','Linewidth',2)
    datetick('x','mm-yy','keepticks')
    year=datevec(data.timestamps(1));
    xlabel(['Time [' num2str(year(1)) '--MM-YY]'])
    ylabel([data.labels{1} ' [mm]'])
    xlim([min(data.timestamps), max(data.timestamps)])
    legend('Raw data', 'Raw data + synthetic anomaly')
    hold off
    %exportPlot('ICOLD_CB3_SKF_0','isExportTEX', true, 'FilePath', 'figures')
    %plot(data.timestamps,anomaly.magnitude*normcdf(1:nb_ts,(anomaly.start-2000)*365+anomaly.duration/2*365,anomaly.duration/4*365)')

    drawnow
    %pause
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% C - Model structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Components reference numbers
% 11: Local level
% 12: Local trend
% 13: Local acceleration
% 21: Local level compatible with local trend
% 22: Local level compatible with local acceleration
% 23: Local trend compatible with local acceleration
% 31: Periodic
% 41: Autoregressive
% 51: Kernel regression
% 61: Level Intervention

% Model components
% Model 1
model.components.block{1}={[21 51 41] [12 54] [54 41] [41] [41] [41] };
model.components.block{2}={[12 51 41] [12 54] [54 41] [41] [41] [41] };


% Model component constrains | Take the same  parameter as model class #1
model.components.const{2}={[0 1 1] [1 1] [1 1] [1] [1] [1]};

% Model inter-components dependence | {[components form dataset_i depends on components from  dataset_j]_i,[...]}
model.components.ic={[4,5,6] [ ] [ ] [ ] [ ] [ ] };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% D - Model parameters 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
model.param_properties={
     % #1           #2             #3      #4    #5               #6           #7       #8              #9              #10
     % Param name   Block name     Model   Obs   Bound            Prior        Mean     Std             Values          Ref
     '\sigma_w',   'LL',           '1',   '1',   [NaN  NaN  ],    'N/A',       NaN,     NaN,            0,              1      %#1   
     '\ell',       'KR',           '1',   '1',   [0    Inf  ],    'N/A',       NaN,     NaN,            0.542,          2      %#2   
     'p',          'KR',           '1',   '1',   [NaN  NaN  ],    'N/A',       NaN,     NaN,            365.2422,       3      %#3   
     '\sigma_w',   'KR',           '1',   '1',   [NaN  NaN  ],    'N/A',       NaN,     NaN,            0,              4      %#4   
     '\sigma_hw',  'KR',           '1',   '1',   [NaN  NaN  ],    'N/A',       NaN,     NaN,            0,              5      %#5   
     '\phi',       'AR',           '1',   '1',   [0    1    ],    'N/A',       NaN,     NaN,            0.975,          6      %#6   
     '\sigma_w',   'AR',           '1',   '1',   [0    Inf  ],    'N/A',       NaN,     NaN,            5.8e-02,        7      %#7   
     '\sigma_v',   '',             '1',   '1',   [NaN  NaN  ],    'N/A',       NaN,     NaN,            0.001,          8      %#8   
     '\sigma_w',   'LT',           '1',   '2',   [NaN  NaN  ],    'N/A',       NaN,     NaN,            2e-04,          9      %#9   
     '\sigma_v',   '',             '1',   '2',   [NaN  NaN  ],    'N/A',       NaN,     NaN,            0.001,          10     %#10  
     '\phi',       'AR',           '1',   '3',   [NaN  NaN  ],    'N/A',       NaN,     NaN,            1,              11     %#11  
     '\sigma_w',   'AR',           '1',   '3',   [NaN  NaN  ],    'N/A',       NaN,     NaN,            0.267,          12     %#12  
     '\sigma_v',   '',             '1',   '3',   [NaN  NaN  ],    'N/A',       NaN,     NaN,            0.001,          13     %#13  
     '\phi',       'AR',           '1',   '4',   [NaN  NaN  ],    'N/A',       NaN,     NaN,            0.8,            14     %#14  
     '\sigma_w',   'AR',           '1',   '4',   [NaN  NaN  ],    'N/A',       NaN,     NaN,            2.01,           15     %#15  
     '\sigma_v',   '',             '1',   '4',   [NaN  NaN  ],    'N/A',       NaN,     NaN,            0.1,            16     %#16  
     '\phi',       '1|4(AR)',      '1',   '4',   [-Inf  Inf ],    'N/A',       NaN,     NaN,            2.33e-02,       17     %#17  
     '\phi',       'AR',           '1',   '5',   [NaN  NaN  ],    'N/A',       NaN,     NaN,            0.8,            18     %#18  
     '\sigma_w',   'AR',           '1',   '5',   [NaN  NaN  ],    'N/A',       NaN,     NaN,            2.01,           19     %#19  
     '\sigma_v',   '',             '1',   '5',   [NaN  NaN  ],    'N/A',       NaN,     NaN,            0.1,            20     %#20  
     '\phi',       '1|5(AR)',      '1',   '5',   [-Inf  Inf ],    'N/A',       NaN,     NaN,            -1.51e-02,      21     %#21  
     '\phi',       'AR',           '1',   '6',   [NaN  NaN  ],    'N/A',       NaN,     NaN,            0.986,          22     %#22  
     '\sigma_w',   'AR',           '1',   '6',   [NaN  NaN  ],    'N/A',       NaN,     NaN,            0.353,          23     %#23  
     '\sigma_v',   '',             '1',   '6',   [NaN  NaN  ],    'N/A',       NaN,     NaN,            0.1,            24     %#24  
     '\phi',       '1|6(AR)',      '1',   '6',   [-Inf  Inf ],    'N/A',       NaN,     NaN,            -1.60e-02,      25     %#25   
     '\sigma_w',   'LT',           '2',   '1',   [0  Inf    ],    'N/A',       NaN,     NaN,            0,              26     %#26  
     '\sigma_v',   '',             '2',   '1',   [0  Inf    ],    'N/A',       NaN,     NaN,            0.001,          27     %#27  
     '\sigma_v',   '',             '2',   '2',   [0  Inf    ],    'N/A',       NaN,     NaN,            0.001,          28     %#28  
     '\sigma_v',   '',             '2',   '3',   [0  Inf    ],    'N/A',       NaN,     NaN,            0.001,          29     %#29  
     '\sigma_v',   '',             '2',   '4',   [0  Inf    ],    'N/A',       NaN,     NaN,            0.1,            30     %#30  
     '\sigma_v',   '',             '2',   '5',   [0  Inf    ],    'N/A',       NaN,     NaN,            0.1,            31     %#31  
     '\sigma_v',   '',             '2',   '6',   [0  Inf    ],    'N/A',       NaN,     NaN,            0.1,            32     %#32  
     '\sigma_w',   'LcT',          '12',  '1',   [0  Inf    ],    'N/A',       NaN,     NaN,            0.00,           33     %#33  
     '\sigma_w',   'LT',           '21',  '1',   [0  Inf    ],    'N/A',       NaN,     NaN,            5E-5,           34     %#34  
     'Z(11)',      '',             '11',  '',    [0  1      ],    'N/A',       NaN,     NaN,            0.99999,        35     %#35  
     'Z(22)',      '',             '22',  '',    [0  1      ],    'N/A',       NaN,     NaN,            0.99999,        36     %#36  
     '\l1',        '',             '1',   '1',   [0  Inf    ],    'N/A',       NaN,     NaN,            11.2,           37     %#37  
     '\l1',        '',             '1',   '1',   [0  Inf    ],    'N/A',       NaN,     NaN,            4.99,           38     %#38  
};
model.components.nb_KR_p = 20;
model.components.nb_SR_p = 20;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% E - Initial states values 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial hidden states mean for model 1:
model.initX{ 1 }=[	-3.04 0	0.958 	0.597 	3.13  	0.336 	0.378 	1.1   	0.666 	0.742 	-1.87 	-0.681	0.748 	-1.62 	-0.59 	-0.0819	-1.33 	0.327 	-1.14 	-1.05 	1.96  	-0.0692	0.501 	-8.09 	0.0194	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	-0.0188	-0.0142	-0.00873	-0.00202	0.00577	0.0146	0.0244	0.0349	0.046 	0.0577	0.0694	0.0813	0.0926	0.104 	0.114 	0.122 	0.13  	0.136 	0.141 	0.144 	0.0447	-0.362	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0.0637	0.11  	0.119 	0.0707	0.0383	0.104 	0.204 	0.192 	0.101 	0.109 	0.212 	0.22  	0.123 	0.12  	0.248 	0.288 	0.189 	0.182 	0.293 	0.228 	0.16  	-0.428	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	0     	-2.68 	-1.68 	-0.733	-0.0311]';
% Initial hidden states variance for model 1: 
model.initV{ 1 }=diag([0.001^2 1E-10 0.001^2 0.001^2*ones(1,19) 0.001^2  	1E-07	1E-07	zeros(1,20)    0.001^2*ones(1,20) 0.001^2 0.001^2 zeros(1,2*20) 0.001^2*ones(1,21)  zeros(1,21)	  1E-06 	1E-06  1E-06  1E-06 ]);

% Initial probability for model 1
model.initS{1}=[0.95];
% Initial hidden states mean for model 2:
model.initX{2}=model.initX{1};
% Initial hidden states variance for model 2: 
model.initV{2}=model.initV{1};
% Initial probability for model 2
model.initS{2}=1-model.initS{1};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% F - Options 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
misc.options.NaNThreshold=100;
misc.options.Tolerance=1e-06;
misc.options.trainingPeriod=[1  180];
misc.options.isParallel=true;
misc.options.isMute=false;
misc.options.isMAP=false;
misc.options.maxTime=60;
misc.options.maxIterations=100;
misc.options.isLaplaceApprox=false;
misc.options.isPredCap=false;
misc.options.NRLevelsLambdaRef=4;
misc.options.NRTerminationTolerance=1e-07;
misc.options.maxEpochs=50;
misc.options.SplitPercent=30;
misc.options.MiniBatchSizePercent=20;
misc.options.SGTerminationTolerance=95;
misc.options.Optimizer='MMT';
misc.options.MethodStateEstimation='kalman';
misc.options.MaxSizeEstimation=100;
misc.options.DataPercent=100;
misc.options.KRNumberControlPoints=100;
misc.options.Seed=12345;
misc.options.isPlotEstimations=true;
misc.options.FigurePosition=[100   100  1300   270];
misc.options.isSecondaryPlot=false;
misc.options.Subsample=1;
misc.options.Linewidth=1;
misc.options.ndivx=4;
misc.options.ndivy=3;
misc.options.Xaxis_lag=0;
misc.options.isExportTEX=false;
misc.options.isExportPNG=false;
misc.options.isExportPDF=false;