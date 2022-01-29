function [xpred,Vpred,C,prod] = Nonlinear_Regression(A,x,V,idx_xprod,idx_prod,l1,parameters,nb_PR,Q,ProdQ,x_ref,t,t_ref,C)
% Indexes for phase regression and State Regression
if length(nb_PR) == 2
    index_DKR_prod = idx_prod(1);      % DKR prod term
    idx_prod(1) = [];
else
    index_DKR_prod = [];
end
idx_xprod1 = idx_xprod(:,1:sum(nb_PR));
idx_xprod2 = idx_xprod(:,sum(nb_PR)+1:end);
idx_prod1 = idx_prod(1:sum(nb_PR));
idx_prod2 = idx_prod(sum(nb_PR)+1:end);
if isempty(index_DKR_prod)
    idx_delta = idx_xprod1(1,end)+1;
else
    idx_delta = index_DKR_prod + 1;
end

%%Phase Regression


%% Computing the Kernel Regression variables for Phase-Regression applicable to DKR or KR
i = 1;
j = i+1;
if ~isempty(index_DKR_prod)
while i ~= length(nb_PR)
    [x(idx_xprod1(2,1:nb_PR(i))),K_V,K_V1]=Kernel_component3(parameters(i),parameters(j),t,t_ref,x(idx_delta),V(idx_delta,:),nb_PR(i),idx_delta);
    V(idx_xprod1(2,1):idx_xprod1(2,nb_PR(i)),:)=K_V;
    V(idx_xprod1(2,1):idx_xprod1(2,nb_PR(i)),idx_xprod1(2,1):idx_xprod1(2,nb_PR(i))) = K_V1;
    clear K_V; clear K_V1;
    if i ==length(nb_PR)
        break;
    
   else
        [x(idx_xprod1(2,nb_PR(i)+1:end)),K_V,K_V1]=Kernel_component3(parameters(j+1),parameters(j+2),t,t_ref,x(idx_delta),V(idx_delta,:),nb_PR(j),idx_delta);
        V(idx_xprod1(2,nb_PR(i)+1):idx_xprod1(2,end),:)=K_V;
        V(idx_xprod1(2,nb_PR(i)+1):idx_xprod1(2,end),idx_xprod1(2,nb_PR(i)+1):idx_xprod1(2,end)) = K_V1;
        i = i+1;
        clear K_V; clear K_V1;
    end
end

else
    [x(idx_xprod1(2,1:nb_PR(i))),K_V,K_V1]=Kernel_component3(parameters(i),parameters(j),t,t_ref,x(idx_delta),V(idx_delta,:),nb_PR(i),idx_delta);
    V(idx_xprod1(2,1):idx_xprod1(2,nb_PR(i)),:)=K_V;
    V(idx_xprod1(2,1):idx_xprod1(2,nb_PR(i)),idx_xprod1(2,1):idx_xprod1(2,nb_PR(i))) = K_V1;
end
%% Getting indices for XD's and computing the Product terms for Phase Regression (the Phase_Prods)
index_XD = [idx_xprod1(2,end)+1:idx_prod1(1)-1]';
[mP1,sP1,ProdQ] = ProductxV(A,x,V,idx_xprod1,idx_prod1,ProdQ,idx_prod2,index_XD(end));

%% 1st layer of Prediction step for Phase Regression
A1 = A;
A1(idx_prod1(end)+1:idx_prod2(end),idx_prod1(end)+1:idx_prod2(end)) = zeros(idx_prod2(end)-idx_prod1(end));
xpred1 = A1*(x+mP1);
Vpred1 = A1*(V+sP1)*A1'+Q+ProdQ; 
Vpred1=(Vpred1+Vpred1')/2;

if ~isempty(index_DKR_prod)
    prod = index_DKR_prod; x_prod = index_XD;
    
    [mP,sP,ProdQ] = ProductxV_1(A1,xpred1,Vpred1,x_prod,prod,ProdQ);
    xpred1 = xpred1 + mP;
    Vpred1 = Vpred1 + sP + ProdQ;
    index_PR_S1 = index_DKR_prod;
else
    index_PR_S1 = index_XD;
end

%% State Regression

%% Computing Kernel Regression variables for State Regression using Hidden states from Phase Regression
[xpred1(idx_xprod2(1,1:end)),K_V,K_V1]=Kernel_component2(l1,xpred1(index_PR_S1),Vpred1(index_PR_S1,:),x_ref,index_PR_S1);
Vpred1(idx_xprod2(1,1):idx_xprod2(1,end),:)=K_V;
Vpred1(idx_xprod2(1,1):idx_xprod2(1,end),idx_xprod2(1,1):idx_xprod2(1,end)) = K_V1;
clear K_V;clear K_V1;

%% Computing Products for State Regression 
Vpred1(idx_xprod2(2,:),:) = V(idx_xprod2(2,:),:);
xpred1(idx_xprod2(2,:)) = x(idx_xprod2(2,:));
index_S_phi = idx_xprod2(2,end);       % Index for the last S_phi value in order to compute covariance sP
[mP2,sP2,ProdQ] = ProductxV(A,xpred1,Vpred1,idx_xprod2,idx_prod2,ProdQ,idx_prod2,index_S_phi);
%% Prediction Step 2
A2 = A;% make the diagonal terms 1 for non-dummy hidden states
D = diag(A);
%% Indices for transition matrix to be used for State Regression that should not change

index_T1 = 1:idx_xprod1(1,1);              % index from 1st hidden state until the 1st control point
index_T2 = idx_prod2(end)+1:size(A,1);     % index of the hidden components of the 2nd time series

D(index_T1)= ones(1,length(index_T1)); D(index_T2) = ones(1,length(index_T2)); D(index_PR_S1) = 1;

if ~isempty(index_DKR_prod)
    index_T3 = idx_xprod1(1,nb_PR(1))+1;       % index of  2nd X0 component in DKR
    D(index_T3) = 1;
    D(index_XD) = zeros(2,1);                   % To be verified
end

%%
A2 = diag(D);
A2(idx_xprod2(2,1):idx_prod2(end),:) = A(idx_xprod2(2,1):idx_prod2(end),:);
xpred2 = A2*(xpred1+mP2);
Vpred2 = A2*(Vpred1+sP2)*A2'+ProdQ;   %% No Q required
Vpred2=(Vpred2+Vpred2')/2;

%% Prediction Step 3
prod = idx_prod2(1,1)-1; x_prod = [index_PR_S1;idx_xprod2(2,end)+1];
%x_prod = [3;66];
[mP3,sP3,ProdQ] = ProductxV_1(A,xpred2,Vpred2,x_prod,prod,ProdQ);
xpred = xpred2 + mP3;
Vpred = Vpred2 + sP3 + ProdQ;
C(:,prod)=[0 1]';







end