% clear;clc;
% %% Data
% dat=load('DATA_ICOLD_CB3_WL_TBMA.mat');
% data.values=dat.values;
% data.timestamps=dat.timestamps;
% data.labels={'CB3','WL','WL','TBMA7','TBMA1','TBMA14'};
% %% saving val
% load('/Users/bhargobdeka/MLCIV Dropbox/Bhargob Deka/MATLAB/BDLM versions/OpenBDLM-master-v1_2/saved_projects/PROJ_ICOLD_CB3_WL_TBMA.mat')
% % load('estimation.mat')
% start01=[2000           1          1          0           0           0];
% end_01= [2017           12         31         0           0           0];
% idx_start_01  = find(data.timestamps==datenum(start01),1,'first');
% idx_end_01    = find(data.timestamps==datenum(end_01),1,'first');
% sigmaY_Pred   = sqrt(squeeze(estimation.Vy(1,idx_start_01:idx_end_01)))';
% muY_Pred      = estimation.y(1,idx_start_01:idx_end_01)';
% 
% %% 
% % CB2_Pred.data        = Y_val;
% CB3_Pred.values(:,1) = muY_Pred;
% CB3_Pred.values(:,2) = sigmaY_Pred;
% CB3_Pred.labels      = {'mean','std'};
% CB3_Pred.timestamps  = data.timestamps(idx_start_01:idx_end_01);
% save('BDLM_CB3_2000_2018.mat','-struct','CB3_Pred')
%% Load Data and Plot
load('BDLM_CB3_2000_2018.mat')
start_val = [2010           1          1          0           0           0];
end_val   = [2012           12         31         0           0           0];

ind1 = find(timestamps==datenum(start_val));
ind2 = find(timestamps==datenum(end_val));
plot(timestamps(ind1:ind2,1),values(ind1:ind2,1),'k','LineWidth',1);hold on;
t = timestamps(ind1:ind2)';
patch([t,fliplr(t)],[values(ind1:ind2,1)'+values(ind1:ind2,2)',fliplr(values(ind1:ind2,1)'-values(ind1:ind2,2)')],'g','FaceAlpha',0.2,'EdgeColor','green') % all should be row vectors
xlabel('$t$','Interpreter','latex','FontSize', 30)
ylabel('$CB2$','Interpreter','latex','FontSize', 30)
legend('$\mu$','$\mu \pm \sigma$','Interpreter','latex')