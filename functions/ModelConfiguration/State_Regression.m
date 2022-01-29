function [xpred,Vpred,C] = State_Regression(A,x,V,idx_xprod,idx_prod,l1,Q,ProdQ,x_ref,C,nb_temp)
%% State-Regression
n_temp = nb_temp;    % considering 3 TS (CB, water1, water2)
if size(C,1)>2
    if size(x_ref,2)==1
        x_dependent = x(end-1);
        V_dependent = V(end-1,:);
        VV_dep      = V_dependent(end-1);
    elseif size(x_ref,2)==2
        N_SR = size(x_ref,1);
        depV = 'LT';    % needs to go in config file
        if strcmp(depV,'LT')
            x_dependent(1)   = x(idx_xprod(1,1)-2);     % 2 for LT
            V_dependent(1,:) = V(idx_xprod(1,1)-2,:);
            VV_dep(1)        = V_dependent(1,idx_xprod(1,1)-2);
        elseif strcmp(depV,'AR')
            x_dependent(1)   = x(idx_prod(1,N_SR)+1);     % 2 for LT
            V_dependent(1,:) = V(idx_prod(1,N_SR)+1,:);
            VV_dep(1)        = V_dependent(1,idx_prod(1,N_SR)+1);
        end
        method = 1;   %BD
        if method==2
            x_dependent(2)   = x(end-1)   + x(idx_xprod(1,1)-2);                % LL + AR of water-level
            V_dependent(2,:) = V(end-1,:) + V(idx_xprod(1,1)-2,:);
            VV_dep(2)        = V(end-1,end-1) + V(idx_xprod(1,1)-2,idx_xprod(1,1)-2) + 2*V(end-1,idx_xprod(1,1)-2);
        elseif method == 3
            N_SR             = size(x_ref,1);
            x_dependent(2)   = x(end-1)   + x(idx_xprod(1,N_SR+1)-2);                % LL + AR of water-level
            V_dependent(2,:) = V(end-1,:) + V(idx_xprod(1,N_SR+1)-2,:);
            VV_dep(2)        = V(end-1,end-1) + V(idx_xprod(1,N_SR+1)-2,idx_xprod(1,N_SR+1)-2) + 2*V(end-1,idx_xprod(1,N_SR+1)-2);
        else
            x_dependent(2)   = x(end-n_temp);                                        % AR of water-level
            V_dependent(2,:) = V(end-n_temp,:);
            VV_dep(2)        = V(end-n_temp,end-n_temp);
        end
        % new lines of code
      elseif size(x_ref,2)==3
          N_SR = size(x_ref,1);
         x_dependent   = [x(idx_prod(1,N_SR)+1) x(idx_prod(1,2*N_SR)+1) x(idx_prod(1,3*N_SR)+1)];     % 2 for LT
         V_dependent   = [V(idx_prod(1,N_SR)+1,:);V(idx_prod(1,2*N_SR)+1,:);V(idx_prod(1,3*N_SR)+1,:)];
         VV_dep        = [V_dependent(1,idx_prod(1,N_SR)+1) V_dependent(2,idx_prod(1,2*N_SR)+1) V_dependent(3,idx_prod(1,3*N_SR)+1)] ;
         
        
    end
    
else
    x_dependent = x(end-n_temp);
    V_dependent = V(end-n_temp,:);
    VV_dep      = V_dependent(end-n_temp);
    
end
if size(x_ref,2) == 2
    N_SR = length(x_ref);
    [K_E,K_Cov,K_Var]=Kernel_component2(l1,x_dependent,V_dependent,x_ref, VV_dep, idx_xprod,idx_prod,n_temp);
    x(idx_xprod(1,1:N_SR))                    = K_E(:,1);
    x(idx_xprod(1,N_SR+1:end))                = K_E(:,2);
    V(idx_xprod(1,1):idx_xprod(1,N_SR),:)     =  K_Cov{1};
    V(:,idx_xprod(1,1):idx_xprod(1,N_SR))     =  K_Cov{1}';
    V(idx_xprod(1,N_SR+1):idx_xprod(1,end),:) =  K_Cov{2};
    V(:,idx_xprod(1,N_SR+1):idx_xprod(1,end)) =  K_Cov{2}';
    
    V(idx_xprod(1,1):idx_xprod(1,N_SR),idx_xprod(1,1):idx_xprod(1,N_SR))         = K_Var{1};
    V(idx_xprod(1,N_SR+1):idx_xprod(1,end),idx_xprod(1,N_SR+1):idx_xprod(1,end)) = K_Var{2};
    % indices for product terms
    idx_SR1_phi1       = idx_xprod(:,1:N_SR);
    idx_SR2_phi2       = idx_xprod(:,N_SR+1:end);
    idx_Prod1          = idx_prod(1:N_SR);
    idx_Prod2          = idx_prod(N_SR+1:end);
    idx_SR_phi(1:2,:)  = idx_SR1_phi1;
    idx_SR_phi(3:4,:)  = idx_SR2_phi2;
    idx_Prod(1,:)      = idx_Prod1;
    idx_Prod(2,:)      = idx_Prod2;
    [mP,sP,ProdQ]      = ProductmeanVar(A,x,V,idx_SR_phi,idx_Prod,ProdQ);
    
elseif size(x_ref,2) == 3
    N_SR = length(x_ref);
    [K_E,K_Cov,K_Var]=Kernel_component2(l1,x_dependent,V_dependent,x_ref, VV_dep, idx_xprod,idx_prod,n_temp);
    x(idx_xprod(1,1:N_SR))                    = K_E(:,1);
    x(idx_xprod(1,N_SR+1:2*N_SR))             = K_E(:,2);
    x(idx_xprod(1,2*N_SR+1:3*N_SR))           = K_E(:,3);
    
    V(idx_xprod(1,1):idx_xprod(1,N_SR),:)          =  K_Cov{1};
    V(:,idx_xprod(1,1):idx_xprod(1,N_SR))          =  K_Cov{1}';
    V(idx_xprod(1,N_SR+1):idx_xprod(1,2*N_SR),:)   =  K_Cov{2};
    V(:,idx_xprod(1,N_SR+1):idx_xprod(1,2*N_SR))   =  K_Cov{2}';
    V(idx_xprod(1,2*N_SR+1):idx_xprod(1,3*N_SR),:) =  K_Cov{3};
    V(:,idx_xprod(1,2*N_SR+1):idx_xprod(1,3*N_SR)) =  K_Cov{3}';
    
    V(idx_xprod(1,1):idx_xprod(1,N_SR),idx_xprod(1,1):idx_xprod(1,N_SR))                    = K_Var{1};
    V(idx_xprod(1,N_SR+1):idx_xprod(1,2*N_SR),idx_xprod(1,N_SR+1):idx_xprod(1,2*N_SR))      = K_Var{2};
    V(idx_xprod(1,2*N_SR+1):idx_xprod(1,3*N_SR),idx_xprod(1,2*N_SR+1):idx_xprod(1,3*N_SR))  = K_Var{3};
    
    % indices for product terms
    idx_SR1_phi1       = idx_xprod(:,1:N_SR);
    idx_SR2_phi2       = idx_xprod(:,N_SR+1:2*N_SR);
    idx_SR3_phi3       = idx_xprod(:,2*N_SR+1:3*N_SR);
    idx_Prod1          = idx_prod(1:N_SR);
    idx_Prod2          = idx_prod(N_SR+1:2*N_SR);
    idx_Prod3          = idx_prod(2*N_SR+1:3*N_SR);
    idx_SR_phi(1:2,:)  = idx_SR1_phi1;
    idx_SR_phi(3:4,:)  = idx_SR2_phi2;
    idx_SR_phi(5:6,:)  = idx_SR3_phi3;
    idx_Prod(1,:)      = idx_Prod1;
    idx_Prod(2,:)      = idx_Prod2;
    idx_Prod(3,:)      = idx_Prod3;
    [mP,sP,ProdQ]      = ProductmeanVar(A,x,V,idx_SR_phi,idx_Prod,ProdQ);
    
else
    [x(idx_xprod(1,1:end)),K_Cov,K_Var]=Kernel_component2(l1,x_dependent,V_dependent,x_ref, VV_dep, idx_xprod,idx_prod,n_temp);
    V(idx_xprod(1,1):idx_xprod(1,end),:)=K_Cov;
    V(:,idx_xprod(1,1):idx_xprod(1,end))=K_Cov';
    % I = zeros(size(V,1));
    % I(idx_xprod(1,1):idx_xprod(1,end),idx_xprod(1,1):idx_xprod(1,end))=eye(length(idx_prod));
    % V(I==1)=K_V1;
    V(idx_xprod(1,1):idx_xprod(1,end),idx_xprod(1,1):idx_xprod(1,end)) = K_Var;
    [mP,sP,ProdQ] = ProductmeanVar(A,x,V,idx_xprod,idx_prod,ProdQ);                                  %BD
end
%% Prediction step
% Predicted hidden state mean

xpred = A*(x+mP);

% Predicted hidden state covariance
 
Vpred = A*(V+sP)*A'+Q;                    %+ProdQ
Vpred=(Vpred+Vpred')/2;
if size(C,1)>2
    if size(x_ref,2) == 2                 % double SR components
        method = 2;
        if method == 2
            if strcmp(depV,'LT')
                idx_prod1 = [idx_xprod(1,1)-2        length(Vpred)-n_temp];
            elseif strcmp(depV,'AR')
                idx_prod1 = [idx_prod(1,N_SR)+1      length(Vpred)-n_temp];
            end
            idx_prod2 = [idx_xprod(2,N_SR)+1   idx_xprod(2,end)+1];
            x_prod    = [idx_prod1;idx_prod2];
            prod      = [idx_prod2(1)+1  idx_prod2(2)+1];
            [mP1,sP1,~] = ProductmeanVar1(A,xpred,Vpred,x_prod,prod,ProdQ);
        elseif method == 3
            idx_prod1 = [idx_xprod(1,1)-2     length(Vpred)-1     idx_xprod(1,N_SR+1)-2];
            idx_prod2 = [idx_xprod(2,N_SR)+1   idx_xprod(2,end)+1   0];
            x_prod    = [idx_prod1;idx_prod2];
            prod      = [idx_prod2(1)+1  idx_prod2(2)+1];
            [mP1,sP1,~] = ProductmeanVar1(A,xpred,Vpred,x_prod,prod,ProdQ);
        end
        xpred = xpred + mP1;
        Vpred = Vpred + sP1;
        len = length(prod);
        C(:,prod) = [ones(1,len);zeros(size(C,1)-1,len)];
    elseif size(x_ref,2) == 3                 % 3 SR components
        idx_prod1 = [idx_prod(1,N_SR)+1   idx_prod(1,2*N_SR)+1       idx_prod(1,3*N_SR)+1];
        idx_prod2 = [idx_xprod(2,N_SR)+1  idx_xprod(2,2*N_SR)+1      idx_xprod(2,3*N_SR)+1];
        x_prod    = [idx_prod1;idx_prod2];
        prod      = [idx_prod2(1)+1  idx_prod2(2)+1  idx_prod2(3)+1];
        [mP1,sP1,~] = ProductmeanVar1(A,xpred,Vpred,x_prod,prod,ProdQ);
        xpred = xpred + mP1;
        Vpred = Vpred + sP1;
        len = length(prod);
        C(:,prod) = [ones(1,len);zeros(size(C,1)-1,len)];
    else                                 % single SR component
        idx_prod1   = length(Vpred)-1;
        prod = idx_prod(1)-1; x_prod = [idx_prod1;idx_prod(1)-2];
        [mP1,sP1,~] = ProductmeanVar1(A,xpred,Vpred,x_prod,prod,ProdQ);
        xpred = xpred + mP1;
        Vpred = Vpred + sP1;                     
        len = size(C,1)-1;
        C(:,idx_xprod(2,end)+2)=[1 zeros(1,len)]';
    end
else
    idx_prod1   =  length(V_dependent);
    prod = idx_prod(1)-1; x_prod = [idx_prod1;idx_prod(1)-2];
    [mP1,sP1,~] = ProductmeanVar1(A,xpred,Vpred,x_prod,prod,ProdQ);
    xpred = xpred + mP1;
    Vpred = Vpred + sP1;                      
    len = size(C,1)-1;
    C(:,idx_xprod(2,end)+2)=[1 zeros(1,len)]';
end






end