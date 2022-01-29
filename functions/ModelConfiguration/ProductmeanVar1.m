function [mP,sP,ProdQ] = ProductmeanVar1(A,x,V,idx_xprod,idx_prod,ProdQ)
if ~isempty(idx_xprod)||~isempty(idx_prod)
    %% Non-Gaussian GC Z=X*Y (Saeid Amiri)
    m12=@(m,S,idx) (m(idx{1}).*m(idx{2}))+S(sub2ind(size(S),idx{1},idx{2}))';
    cov312=@(m,S,idx) S(sub2ind(size(S),idx{3},idx{1})).*m(idx{2})+S(sub2ind(size(S),idx{2},idx{1})).*m(idx{3});
    cov3412=@(m,S,idx) S(sub2ind(size(S),idx{1},idx{3})).*S(sub2ind(size(S),idx{2},idx{4}))+S(sub2ind(size(S),idx{2},idx{3})).*S(sub2ind(size(S),idx{1},idx{4}))+S(sub2ind(size(S),idx{1},idx{3})).*m(idx{2}).*m(idx{4})+S(sub2ind(size(S),idx{1},idx{4})).*m(idx{2}).*m(idx{3})+S(sub2ind(size(S),idx{2},idx{3})).*m(idx{1}).*m(idx{4})+S(sub2ind(size(S),idx{2},idx{4})).*m(idx{1}).*m(idx{3});
    if length(idx_prod) == 1   
        N = 1;
        M=size(A,1);
        idx12{1}  =idx_xprod(1,:);
        idx12{2}  =idx_xprod(2,:);

    %     idx312{1} =[1:1:idx_xprod(2,:)];
    %     idx312{2} =[repmat(idx_xprod(1,:)',[1,M])];
    %     idx312{3} =[repmat(idx_xprod(2,:)',[1,M])];

        idx312{1}=repmat(1:1:idx12{2}(end),[length(idx12{2}),1]);
        idx312{2}=repmat(idx12{1}',[1,idx12{2}(end)]);
        idx312{3}=repmat(idx12{2}',[1,idx12{2}(end)]);

        idx312N{1}=[M-1,M];
        idx312N{2}=repmat(idx_xprod(1,:),[1,2]); % Needs better coding to adapt for different no of components
        idx312N{3}=repmat(idx_xprod(2,:),[1,2]);

    %     idx3412{1}=[repmat(idx_xprod(1,:)',[1,N])];
    %     idx3412{2}=[repmat(idx_xprod(2,:)',[1,N])];
    %     idx3412{3}=[repmat(idx_xprod(1,:) ,[N,1])];
    %     idx3412{4}=[repmat(idx_xprod(2,:) ,[N,1])];

        idx3412{1}=repmat(idx12{1}',[1,length(idx12{2})]);
        idx3412{2}=repmat(idx12{2}',[1,length(idx12{2})]);
        idx3412{3}=idx3412{1}';
        idx3412{4}=idx3412{2}';

    %     f = cell(size(A,1),1);
    %     f{idx_prod(1):1:idx_prod(end),1}=@(m,s) m12(m,s,idx12);
          f=@(m,s) m12(m,s,idx12);
        mP = zeros(size(A,1),1);
        mP(idx_prod(1):1:idx_prod(end),1)=f(x,V);
        %mP(idx_prod(1):1:idx_prod(end),1)=f{idx_prod}(x,V);

        f3 = @(m,s) cov312(m',s,idx312N);
        f1 = @(m,s) cov312(m',s,idx312);
        f2 = @(m,s) cov3412(m,s,idx3412);
        sP = zeros(size(V));
        sP(1:idx12{2}(end),idx12{2}(end)+1)=(f1(x,V))'; % generalize (end-3)
        sP(idx12{2}(end)+1,1:idx12{2}(end))=f1(x,V);
        sP(idx_prod,M-1:M)=(cov312(x',V,idx312N))';
        sP(M-1:M,idx_prod)=cov312(x',V,idx312N);
        sP(idx_prod,idx_prod) = f2(x,V);
    elseif length(idx_prod) == 2
        idx_LL      = idx_xprod(1,1);
        idx_AR      = idx_xprod(1,2);     
        idx_phi0_LL = idx_xprod(2,1);
        idx_phi0_AR = idx_xprod(2,2);
        
        method = 1; % only AR
        if method == 1
            % expected value of xD
            E_D_LL = x(idx_phi0_LL).*x(idx_LL) + V(idx_phi0_LL,idx_LL);
            E_D_AR = x(idx_phi0_AR).*x(idx_AR) + V(idx_phi0_AR,idx_AR);
            % covariance of xD_LL and xD_AR with all X 
            cov_D_LL_X = V(idx_phi0_LL,:).*x(idx_LL) + V(idx_LL,:).*x(idx_phi0_LL);
            cov_D_AR_X = V(idx_phi0_AR,:).*x(idx_AR) + V(idx_AR,:).*x(idx_phi0_AR);
            % variance
            %V_D_LL     = V(idx_phi0_LL,idx_phi0_LL).*V(idx_LL,idx_LL) + V(idx_phi0_LL,idx_LL).^2 + 2*V(idx_phi0_LL,idx_LL).*x(idx_phi0_LL).*x(idx_LL)+V(idx_phi0_LL,idx_phi0_LL).*x(idx_LL).^2+V(idx_LL,idx_LL).*x(idx_phi0_LL).^2;

            % variance of D_LL
            idx3412_D_LL{1}=repmat(idx_phi0_LL',[1,length(idx_phi0_LL)]);
            idx3412_D_LL{2}=repmat(idx_LL',[1,length(idx_LL)]);
            idx3412_D_LL{3}=idx3412_D_LL{1}';
            idx3412_D_LL{4}=idx3412_D_LL{2}';
            f_D_LL   = @(m,s) cov3412(m,s,idx3412_D_LL);
            V_D_LL = f_D_LL(x,V);

            % variance of D_AR
            idx3412_D_AR{1}=repmat(idx_phi0_AR',[1,length(idx_phi0_AR)]);
            idx3412_D_AR{2}=repmat(idx_AR',[1,length(idx_AR)]);
            idx3412_D_AR{3}=idx3412_D_AR{1}';
            idx3412_D_AR{4}=idx3412_D_AR{2}';
            f_D_AR   = @(m,s) cov3412(m,s,idx3412_D_AR);
            V_D_AR = f_D_AR(x,V);

            % cross-covariance between D_LL and D_AR
            idx3412_D12{1}=repmat(idx_phi0_LL',[1,length(idx_phi0_LL)]);
            idx3412_D12{2}=repmat(idx_LL',[1,length(idx_LL)]);
            idx3412_D12{3}=repmat(idx_phi0_AR',[1,length(idx_phi0_AR)])';
            idx3412_D12{4}=repmat(idx_AR',[1,length(idx_AR)])';
            f_D12   = @(m,s) cov3412(m,s,idx3412_D12);
            V_D12   = f_D12(x,V);
        elseif method == 2   % LL + AR
            % expected value of xD
            E_D_LL = x(idx_phi0_LL).*x(idx_LL) + V(idx_phi0_LL,idx_LL);
            E_D_AR = x(idx_phi0_AR).*x(idx_AR) + V(idx_phi0_AR,idx_AR) + x(idx_phi0_AR).*x(idx_LL) + V(idx_phi0_AR,idx_LL);
            
            % covariance of xD_LL and (xD_AR + xD_LL) with all X 
            cov_D_LL_X = V(idx_phi0_LL,:).*x(idx_LL) + V(idx_LL,:).*x(idx_phi0_LL);
            cov_D_AR_X = V(idx_phi0_AR,:).*x(idx_AR) + V(idx_AR,:).*x(idx_phi0_AR) + V(idx_phi0_AR,:).*x(idx_LL) + V(idx_LL,:).*x(idx_phi0_AR);
            
            % variance
            V_LLplusAR = V(idx_AR,idx_AR) + V(idx_LL,idx_LL) + 2*V(idx_AR,idx_LL);
            E_LLplusAR = x(idx_AR,1) + x(idx_LL,1);
            V_D_AR     = V(idx_phi0_AR,idx_phi0_AR).*V_LLplusAR + (V(idx_phi0_AR,idx_LL) + V(idx_phi0_AR,idx_AR))^2 + 2*(V(idx_phi0_AR,idx_LL) + V(idx_phi0_AR,idx_AR)).*x(idx_phi0_AR).*E_LLplusAR + V(idx_phi0_AR,idx_phi0_AR).*E_LLplusAR.^2 + V_LLplusAR.*x(idx_phi0_AR).^2;
            %V_D_1     = V(idx_phi0_LL,idx_phi0_LL).*V(idx_LL,idx_LL) + V(idx_phi0_LL,idx_LL)^2 + 2*V(idx_phi0_LL,idx_LL)*x(idx_phi0_LL)*x(idx_LL) + V(idx_phi0_LL,idx_phi0_LL)*x(idx_LL)^2 + V(idx_LL,idx_LL)*x(idx_phi0_LL)^2
            % variance of D_LL
            idx3412_D_LL{1}=repmat(idx_phi0_LL',[1,length(idx_phi0_LL)]);
            idx3412_D_LL{2}=repmat(idx_LL',[1,length(idx_LL)]);
            idx3412_D_LL{3}=idx3412_D_LL{1}';
            idx3412_D_LL{4}=idx3412_D_LL{2}';
            f_D_LL   = @(m,s) cov3412(m,s,idx3412_D_LL);
            V_D_LL = f_D_LL(x,V);
            
            % cross-covariance between D_LL and D_AR
            idx3412_D_LL_AR{1}=repmat(idx_phi0_LL',[1,length(idx_phi0_LL)]);
            idx3412_D_LL_AR{2}=repmat(idx_LL',[1,length(idx_LL)]);
            idx3412_D_LL_AR{3}=repmat(idx_phi0_AR',[1,length(idx_phi0_AR)])';
            idx3412_D_LL_AR{4}=repmat(idx_AR',[1,length(idx_AR)])';
            f_D_LL_AR   = @(m,s) cov3412(m,s,idx3412_D_LL_AR);
            % cross-covariance addtional term
            idx3412_D12_add{1}=repmat(idx_phi0_LL',[1,length(idx_phi0_LL)]);
            idx3412_D12_add{2}=repmat(idx_LL',[1,length(idx_LL)]);
            idx3412_D12_add{3}=repmat(idx_phi0_AR',[1,length(idx_phi0_AR)])';
            idx3412_D12_add{4}=repmat(idx_LL',[1,length(idx_LL)])';
            f_D12_add         = @(m,s) cov3412(m,s,idx3412_D12_add);
            V_D12             = f_D_LL_AR(x,V) + f_D12_add(x,V);
        elseif method == 3
            % expected value of xD
            idx_LL2      = idx_xprod(1,end);
            E_D_LL = x(idx_phi0_LL).*x(idx_LL) + V(idx_phi0_LL,idx_LL);
            E_D_AR = x(idx_phi0_AR).*x(idx_AR) + V(idx_phi0_AR,idx_AR) + x(idx_phi0_AR).*x(idx_LL2) + V(idx_phi0_AR,idx_LL2);
            
            % covariance of xD_LL and (xD_AR + xD_LL) with all X 
            cov_D_LL_X = V(idx_phi0_LL,:).*x(idx_LL) + V(idx_LL,:).*x(idx_phi0_LL);
            cov_D_AR_X = V(idx_phi0_AR,:).*x(idx_AR) + V(idx_AR,:).*x(idx_phi0_AR) + V(idx_phi0_AR,:).*x(idx_LL2) + V(idx_LL2,:).*x(idx_phi0_AR);
            
            % variance
            V_LLplusAR = V(idx_AR,idx_AR) + V(idx_LL2,idx_LL2) + 2*V(idx_AR,idx_LL2);
            E_LLplusAR = x(idx_AR,1) + x(idx_LL2,1);
            V_D_AR     = V(idx_phi0_AR,idx_phi0_AR).*V_LLplusAR + (V(idx_phi0_AR,idx_LL2) + V(idx_phi0_AR,idx_AR))^2 + 2*(V(idx_phi0_AR,idx_LL2) + V(idx_phi0_AR,idx_AR)).*x(idx_phi0_AR).*E_LLplusAR + V(idx_phi0_AR,idx_phi0_AR).*E_LLplusAR.^2 + V_LLplusAR.*x(idx_phi0_AR).^2;
            %V_D_1     = V(idx_phi0_LL,idx_phi0_LL).*V(idx_LL,idx_LL) + V(idx_phi0_LL,idx_LL)^2 + 2*V(idx_phi0_LL,idx_LL)*x(idx_phi0_LL)*x(idx_LL) + V(idx_phi0_LL,idx_phi0_LL)*x(idx_LL)^2 + V(idx_LL,idx_LL)*x(idx_phi0_LL)^2
            % variance of D_LL
            idx3412_D_LL{1}=repmat(idx_phi0_LL',[1,length(idx_phi0_LL)]);
            idx3412_D_LL{2}=repmat(idx_LL',[1,length(idx_LL)]);
            idx3412_D_LL{3}=idx3412_D_LL{1}';
            idx3412_D_LL{4}=idx3412_D_LL{2}';
            f_D_LL   = @(m,s) cov3412(m,s,idx3412_D_LL);
            V_D_LL = f_D_LL(x,V);
            
            % cross-covariance between D_LL and D_AR
            idx3412_D_LL_AR{1}=repmat(idx_phi0_LL',[1,length(idx_phi0_LL)]);
            idx3412_D_LL_AR{2}=repmat(idx_LL',[1,length(idx_LL)]);
            idx3412_D_LL_AR{3}=repmat(idx_phi0_AR',[1,length(idx_phi0_AR)])';
            idx3412_D_LL_AR{4}=repmat(idx_AR',[1,length(idx_AR)])';
            f_D_LL_AR   = @(m,s) cov3412(m,s,idx3412_D_LL_AR);
            % cross-covariance addtional term
            idx3412_D12_add{1}=repmat(idx_phi0_LL',[1,length(idx_phi0_LL)]);
            idx3412_D12_add{2}=repmat(idx_LL',[1,length(idx_LL)]);
            idx3412_D12_add{3}=repmat(idx_phi0_AR',[1,length(idx_phi0_AR)])';
            idx3412_D12_add{4}=repmat(idx_LL2',[1,length(idx_LL2)])';
            f_D12_add         = @(m,s) cov3412(m,s,idx3412_D12_add);
            V_D12             = f_D_LL_AR(x,V) + f_D12_add(x,V);
        end
        % Placing into mP and sP
        mP = zeros(size(A,1),1);
        sP = zeros(size(V));
        
        mP(idx_prod(1),1) = E_D_LL;
        mP(idx_prod(2),1) = E_D_AR;
        
        sP(idx_prod(1),:) = cov_D_LL_X;
        sP(:,idx_prod(1)) = cov_D_LL_X';
        sP(idx_prod(2),:) = cov_D_AR_X;
        sP(:,idx_prod(2)) = cov_D_AR_X';
        
        sP(idx_prod(1),idx_prod(1)) = V_D_LL;
        sP(idx_prod(2),idx_prod(2)) = V_D_AR;
        
        sP(idx_prod(1),idx_prod(2))  = V_D12;
        sP(idx_prod(2),idx_prod(1))  = V_D12;
        
        sP = (sP + sP')*0.5;
        %% check
%         issymmetric((sP+sP')/2)
    elseif length(idx_prod) == 3
        idx_LL       = idx_xprod(1,1);
        idx_AR       = idx_xprod(1,2); 
        idx_AR1      = idx_xprod(1,3); 
        idx_phi0_LL  = idx_xprod(2,1);
        idx_phi0_AR  = idx_xprod(2,2);
        idx_phi0_AR1 = idx_xprod(2,3);
        
        % expected value of xD
        E_D_LL  = x(idx_phi0_LL).*x(idx_LL) + V(idx_phi0_LL,idx_LL);
        E_D_AR  = x(idx_phi0_AR).*x(idx_AR) + V(idx_phi0_AR,idx_AR);
        E_D_AR1 = x(idx_phi0_AR1).*x(idx_AR1) + V(idx_phi0_AR1,idx_AR1);
        % covariance of xD_LL, xD_AR, xD_AR1 with all X 
        cov_D_LL_X  = V(idx_phi0_LL,:).*x(idx_LL) + V(idx_LL,:).*x(idx_phi0_LL);
        cov_D_AR_X  = V(idx_phi0_AR,:).*x(idx_AR) + V(idx_AR,:).*x(idx_phi0_AR);
        cov_D_AR1_X = V(idx_phi0_AR1,:).*x(idx_AR1) + V(idx_AR1,:).*x(idx_phi0_AR1);
        % variance
        %V_D_LL     = V(idx_phi0_LL,idx_phi0_LL).*V(idx_LL,idx_LL) + V(idx_phi0_LL,idx_LL).^2 + 2*V(idx_phi0_LL,idx_LL).*x(idx_phi0_LL).*x(idx_LL)+V(idx_phi0_LL,idx_phi0_LL).*x(idx_LL).^2+V(idx_LL,idx_LL).*x(idx_phi0_LL).^2;

        % variance of D_LL
        idx3412_D_LL{1}=repmat(idx_phi0_LL',[1,length(idx_phi0_LL)]);
        idx3412_D_LL{2}=repmat(idx_LL',[1,length(idx_LL)]);
        idx3412_D_LL{3}=idx3412_D_LL{1}';
        idx3412_D_LL{4}=idx3412_D_LL{2}';
        f_D_LL   = @(m,s) cov3412(m,s,idx3412_D_LL);
        V_D_LL = f_D_LL(x,V);

        % variance of D_AR
        idx3412_D_AR{1}=repmat(idx_phi0_AR',[1,length(idx_phi0_AR)]);
        idx3412_D_AR{2}=repmat(idx_AR',[1,length(idx_AR)]);
        idx3412_D_AR{3}=idx3412_D_AR{1}';
        idx3412_D_AR{4}=idx3412_D_AR{2}';
        f_D_AR   = @(m,s) cov3412(m,s,idx3412_D_AR);
        V_D_AR = f_D_AR(x,V);

        % variance of D_AR1
        idx3412_D_AR1{1}=repmat(idx_phi0_AR1',[1,length(idx_phi0_AR1)]);
        idx3412_D_AR1{2}=repmat(idx_AR1',[1,length(idx_AR1)]);
        idx3412_D_AR1{3}=idx3412_D_AR1{1}';
        idx3412_D_AR1{4}=idx3412_D_AR1{2}';
        f_D_AR1         = @(m,s) cov3412(m,s,idx3412_D_AR1);
        V_D_AR1         = f_D_AR1(x,V);

        % cross-covariance between D_LL and D_AR
        idx3412_D12{1}=repmat(idx_phi0_LL',[1,length(idx_phi0_LL)]);
        idx3412_D12{2}=repmat(idx_LL',[1,length(idx_LL)]);
        idx3412_D12{3}=repmat(idx_phi0_AR',[1,length(idx_phi0_AR)])';
        idx3412_D12{4}=repmat(idx_AR',[1,length(idx_AR)])';
        f_D12   = @(m,s) cov3412(m,s,idx3412_D12);
        V_D12   = f_D12(x,V);
        
        % cross-covariance between D_LL and D_AR1
        idx3412_D13{1}=repmat(idx_phi0_LL',[1,length(idx_phi0_LL)]);
        idx3412_D13{2}=repmat(idx_LL',[1,length(idx_LL)]);
        idx3412_D13{3}=repmat(idx_phi0_AR1',[1,length(idx_phi0_AR1)])';
        idx3412_D13{4}=repmat(idx_AR1',[1,length(idx_AR1)])';
        f_D13   = @(m,s) cov3412(m,s,idx3412_D13);
        V_D13   = f_D13(x,V);
        
        % cross-covariance between D_LL and D_AR1
        idx3412_D23{1}=repmat(idx_phi0_AR',[1,length(idx_phi0_AR)]);
        idx3412_D23{2}=repmat(idx_AR',[1,length(idx_AR)]);
        idx3412_D23{3}=repmat(idx_phi0_AR1',[1,length(idx_phi0_AR1)])';
        idx3412_D23{4}=repmat(idx_AR1',[1,length(idx_AR1)])';
        f_D23   = @(m,s) cov3412(m,s,idx3412_D23);
        V_D23   = f_D23(x,V);
        
        % Placing into mP and sP
        mP = zeros(size(A,1),1);
        sP = zeros(size(V));
        
        mP(idx_prod(1),1) = E_D_LL;
        mP(idx_prod(2),1) = E_D_AR;
        mP(idx_prod(3),1) = E_D_AR1;
        
        sP(idx_prod(1),:) = cov_D_LL_X;
        sP(:,idx_prod(1)) = cov_D_LL_X';
        sP(idx_prod(2),:) = cov_D_AR_X;
        sP(:,idx_prod(2)) = cov_D_AR_X';
        sP(idx_prod(3),:) = cov_D_AR1_X;
        sP(:,idx_prod(3)) = cov_D_AR1_X';
        
        sP(idx_prod(1),idx_prod(1)) = V_D_LL;
        sP(idx_prod(2),idx_prod(2)) = V_D_AR;
        sP(idx_prod(3),idx_prod(3)) = V_D_AR1;
        
        sP(idx_prod(1),idx_prod(2))  = V_D12;
        sP(idx_prod(2),idx_prod(1))  = V_D12;
        
        sP(idx_prod(1),idx_prod(3))  = V_D13;
        sP(idx_prod(3),idx_prod(1))  = V_D13;
        
        sP(idx_prod(2),idx_prod(3))  = V_D23;
        sP(idx_prod(3),idx_prod(2))  = V_D23;
        
        sP = (sP + sP')*0.5;
    end
else
    mP = 0;
    sP = 0;
    ProdQ = 0;
end







end
