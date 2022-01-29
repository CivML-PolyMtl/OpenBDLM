function [mP,sP,ProdQ] = ProductmeanVar(A,x,V,idx_xprod,idx_prod,ProdQ)
if ~isempty(idx_xprod)||~isempty(idx_prod)
    %% Non-Gaussian GC Z=X*Y (Saeid Amiri)
    m12=@(m,S,idx) (m(idx{1}).*m(idx{2}))+S(sub2ind(size(S),idx{1},idx{2}))';
    cov312=@(m,S,idx) S(sub2ind(size(S),idx{3},idx{1})).*m(idx{2})+S(sub2ind(size(S),idx{2},idx{1})).*m(idx{3});
    cov3412=@(m,S,idx) S(sub2ind(size(S),idx{1},idx{3})).*S(sub2ind(size(S),idx{2},idx{4}))+S(sub2ind(size(S),idx{2},idx{3})).*S(sub2ind(size(S),idx{1},idx{4}))+S(sub2ind(size(S),idx{1},idx{3})).*m(idx{2}).*m(idx{4})+S(sub2ind(size(S),idx{1},idx{4})).*m(idx{2}).*m(idx{3})+S(sub2ind(size(S),idx{2},idx{3})).*m(idx{1}).*m(idx{4})+S(sub2ind(size(S),idx{2},idx{4})).*m(idx{1}).*m(idx{3});
    if size(idx_xprod,1)==2   
        N = 1;
        M=size(A,1);
        idx12{1}  =idx_xprod(1,:);
        idx12{2}  =idx_xprod(2,:);

    %     idx312{1} =[1:1:idx_xprod(2,:)];
    %     idx312{2} =[repmat(idx_xprod(1,:)',[1,M])];
    %     idx312{3} =[repmat(idx_xprod(2,:)',[1,M])];

        idx312{1}=repmat(1:1:idx12{2}(end)+2,[length(idx12{2}),1]);
        idx312{2}=repmat(idx12{1}',[1,idx12{2}(end)+2]);
        idx312{3}=repmat(idx12{2}',[1,idx12{2}(end)+2]);

        idx312N{1}=repmat((idx_prod(end)+1:1:M)',[1,size(idx_xprod,2)]);
        idx312N{2}=repmat(idx12{1},[M-idx_prod(end),1]);
        idx312N{3}=repmat(idx12{2},[M-idx_prod(end),1]);

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
        sP(1:idx12{2}(end)+2,idx12{2}(end)+3:end-(length(x)-idx_prod(end)))=(f1(x,V))'; % generalize (end-3)
        sP(idx12{2}(end)+3:end-(length(x)-idx_prod(end)),1:idx12{2}(end)+2)=f1(x,V);
        sP((idx_prod(end)+1):M,idx_prod(1):idx_prod(end))=cov312(x',V,idx312N);
        sP(idx_prod(1):idx_prod(end),(idx_prod(end)+1):M)=(cov312(x',V,idx312N))';
        sP(idx12{2}(end)+3:end-(length(x)-idx_prod(end)),idx12{2}(end)+3:end-(length(x)-idx_prod(end))) = f2(x,V);
    elseif size(idx_xprod,1)==4
        M=size(A,1);
        idx_SR1   = idx_xprod(1,:);    %SR1
        idx_phi1  = idx_xprod(2,:);    %phi1
        idx_SR2   = idx_xprod(3,:);    %SR2
        idx_phi2  = idx_xprod(4,:);    %phi2
        idx_Prod1 = idx_prod(1,:);
        idx_Prod2 = idx_prod(2,:);
        cov_SR1_phi1 = diag(V(idx_SR1,idx_phi1));
        cov_SR2_phi2 = diag(V(idx_SR2,idx_phi2));
        % Expected value of Prod 1
        E_Prod1   = x(idx_SR1).*x(idx_phi1) + cov_SR1_phi1;
        % Expected value of Prod 1
        E_Prod2   = x(idx_SR2).*x(idx_phi2) + cov_SR2_phi2;
        
        % variance of Prod 1 and Prod 2
%         V_Prod1   = diag(V(idx_SR1,idx_SR1)).*diag(V(idx_phi1,idx_phi1)) + cov_SR1_phi1.^2 + 2.*cov_SR1_phi1.*x(idx_SR1).*x(idx_phi1) + diag(V(idx_SR1,idx_SR1)).*x(idx_phi1).^2 + diag(V(idx_phi1,idx_phi1)).*x(idx_SR1).^2;
%         V_Prod2   = diag(V(idx_SR2,idx_SR2)).*diag(V(idx_phi2,idx_phi2)) + cov_SR2_phi2.^2 + 2.*cov_SR2_phi2.*x(idx_SR2).*x(idx_phi2) + diag(V(idx_SR2,idx_SR2)).*x(idx_phi2).^2 + diag(V(idx_phi2,idx_phi2)).*x(idx_SR2).^2;
%         
        % covariance of Prod 1 and Prod 2 with all X 
        cov_Prod1_X = V(idx_SR1,:).*x(idx_phi1) + V(idx_phi1,:).*x(idx_SR1);
        cov_Prod2_X = V(idx_SR2,:).*x(idx_phi2) + V(idx_phi2,:).*x(idx_SR2);
        
        % covariance within Prod 1
        idx3412_Prod1{1}=repmat(idx_SR1',[1,length(idx_phi1)]);
        idx3412_Prod1{2}=repmat(idx_phi1',[1,length(idx_phi1)]);
        idx3412_Prod1{3}=idx3412_Prod1{1}';
        idx3412_Prod1{4}=idx3412_Prod1{2}';
        fProd1 = @(m,s) cov3412(m,s,idx3412_Prod1);
        cov_Prod1 = fProd1(x,V);
        
        % covariance within Prod 2
        idx3412_Prod2{1}=repmat(idx_SR2',[1,length(idx_phi2)]);
        idx3412_Prod2{2}=repmat(idx_phi2',[1,length(idx_phi2)]);
        idx3412_Prod2{3}=idx3412_Prod2{1}';
        idx3412_Prod2{4}=idx3412_Prod2{2}';
        fProd2    = @(m,s) cov3412(m,s,idx3412_Prod2);
        cov_Prod2 = fProd2(x,V);
        % cross-covariance between Prod 1 and Prod 2
        idx3412_Prod12{1}=repmat(idx_SR1',[1,length(idx_phi1)]);
        idx3412_Prod12{2}=repmat(idx_phi1',[1,length(idx_phi1)]);
        idx3412_Prod12{3}=repmat(idx_SR2',[1,length(idx_phi2)])';
        idx3412_Prod12{4}=repmat(idx_phi2',[1,length(idx_phi2)])';
        fProd12    = @(m,s) cov3412(m,s,idx3412_Prod12);
        cov_Prod12 = fProd12(x,V);
        
        % Placing into mP and sP
        mP = zeros(size(A,1),1);
        sP = zeros(size(V));
        mP(idx_Prod1,1) = E_Prod1;
        mP(idx_Prod2,1) = E_Prod2;
        
        sP(idx_Prod1,:) = cov_Prod1_X;
        sP(:,idx_Prod1) = cov_Prod1_X';
        sP(idx_Prod2,:) = cov_Prod2_X;
        sP(:,idx_Prod2) = cov_Prod2_X';
        
        sP(idx_Prod1,idx_Prod1) = cov_Prod1;
        sP(idx_Prod2,idx_Prod2) = cov_Prod2;
        
        sP(idx_Prod1,idx_Prod2) = cov_Prod12;
        sP(idx_Prod2,idx_Prod1) = cov_Prod12;
        
        sP = (sP + sP')*0.5;
%         issymmetric((sP+sP')/2)
    elseif size(idx_xprod,1)==6
        M=size(A,1);
        idx_SR1   = idx_xprod(1,:);    %SR1
        idx_phi1  = idx_xprod(2,:);    %phi1
        idx_SR2   = idx_xprod(3,:);    %SR2
        idx_phi2  = idx_xprod(4,:);    %phi2
        idx_SR3   = idx_xprod(5,:);    %SR3
        idx_phi3  = idx_xprod(6,:);    %phi3
        
        idx_Prod1 = idx_prod(1,:);
        idx_Prod2 = idx_prod(2,:);
        idx_Prod3 = idx_prod(3,:);
        
        cov_SR1_phi1 = diag(V(idx_SR1,idx_phi1));
        cov_SR2_phi2 = diag(V(idx_SR2,idx_phi2));
        cov_SR3_phi3 = diag(V(idx_SR3,idx_phi3));
        
        % Expected value of Prod 1
        E_Prod1   = x(idx_SR1).*x(idx_phi1) + cov_SR1_phi1;
        % Expected value of Prod 2
        E_Prod2   = x(idx_SR2).*x(idx_phi2) + cov_SR2_phi2;
        % Expected value of Prod 3
        E_Prod3   = x(idx_SR3).*x(idx_phi3) + cov_SR3_phi3;
        
        % covariance of Prod 1, Prod 2 and 3 with all X 
        cov_Prod1_X = V(idx_SR1,:).*x(idx_phi1) + V(idx_phi1,:).*x(idx_SR1);
        cov_Prod2_X = V(idx_SR2,:).*x(idx_phi2) + V(idx_phi2,:).*x(idx_SR2);
        cov_Prod3_X = V(idx_SR3,:).*x(idx_phi3) + V(idx_phi3,:).*x(idx_SR3);
        
        % covariance within Prod 1
        idx3412_Prod1{1}=repmat(idx_SR1',[1,length(idx_phi1)]);
        idx3412_Prod1{2}=repmat(idx_phi1',[1,length(idx_phi1)]);
        idx3412_Prod1{3}=idx3412_Prod1{1}';
        idx3412_Prod1{4}=idx3412_Prod1{2}';
        fProd1 = @(m,s) cov3412(m,s,idx3412_Prod1);
        cov_Prod1 = fProd1(x,V);
        
        % covariance within Prod 2
        idx3412_Prod2{1}=repmat(idx_SR2',[1,length(idx_phi2)]);
        idx3412_Prod2{2}=repmat(idx_phi2',[1,length(idx_phi2)]);
        idx3412_Prod2{3}=idx3412_Prod2{1}';
        idx3412_Prod2{4}=idx3412_Prod2{2}';
        fProd2    = @(m,s) cov3412(m,s,idx3412_Prod2);
        cov_Prod2 = fProd2(x,V);
        
        % covariance within Prod 3
        idx3412_Prod3{1}=repmat(idx_SR3',[1,length(idx_phi3)]);
        idx3412_Prod3{2}=repmat(idx_phi3',[1,length(idx_phi3)]);
        idx3412_Prod3{3}=idx3412_Prod3{1}';
        idx3412_Prod3{4}=idx3412_Prod3{2}';
        fProd3    = @(m,s) cov3412(m,s,idx3412_Prod3);
        cov_Prod3 = fProd3(x,V);
        
        % cross-covariance between Prod 1 and Prod 2
        idx3412_Prod12{1}=repmat(idx_SR1',[1,length(idx_phi1)]);
        idx3412_Prod12{2}=repmat(idx_phi1',[1,length(idx_phi1)]);
        idx3412_Prod12{3}=repmat(idx_SR2',[1,length(idx_phi2)])';
        idx3412_Prod12{4}=repmat(idx_phi2',[1,length(idx_phi2)])';
        fProd12    = @(m,s) cov3412(m,s,idx3412_Prod12);
        cov_Prod12 = fProd12(x,V);
        
        % cross-covariance between Prod 1 and Prod 3
        idx3412_Prod13{1}=repmat(idx_SR1',[1,length(idx_phi1)]);
        idx3412_Prod13{2}=repmat(idx_phi1',[1,length(idx_phi1)]);
        idx3412_Prod13{3}=repmat(idx_SR3',[1,length(idx_phi3)])';
        idx3412_Prod13{4}=repmat(idx_phi3',[1,length(idx_phi3)])';
        fProd13    = @(m,s) cov3412(m,s,idx3412_Prod13);
        cov_Prod13 = fProd13(x,V);
        
        % cross-covariance between Prod 2 and Prod 3
        idx3412_Prod23{1}=repmat(idx_SR2',[1,length(idx_phi2)]);
        idx3412_Prod23{2}=repmat(idx_phi2',[1,length(idx_phi2)]);
        idx3412_Prod23{3}=repmat(idx_SR3',[1,length(idx_phi3)])';
        idx3412_Prod23{4}=repmat(idx_phi3',[1,length(idx_phi3)])';
        fProd23    = @(m,s) cov3412(m,s,idx3412_Prod23);
        cov_Prod23 = fProd23(x,V);
        
        % Placing into mP and sP
        mP = zeros(size(A,1),1);
        sP = zeros(size(V));
        mP(idx_Prod1,1) = E_Prod1;
        mP(idx_Prod2,1) = E_Prod2;
        mP(idx_Prod3,1) = E_Prod3;
        
        sP(idx_Prod1,:) = cov_Prod1_X;
        sP(:,idx_Prod1) = cov_Prod1_X';
        sP(idx_Prod2,:) = cov_Prod2_X;
        sP(:,idx_Prod2) = cov_Prod2_X';
        sP(idx_Prod3,:) = cov_Prod3_X;
        sP(:,idx_Prod3) = cov_Prod3_X';
        
        sP(idx_Prod1,idx_Prod1) = cov_Prod1;
        sP(idx_Prod2,idx_Prod2) = cov_Prod2;
        sP(idx_Prod3,idx_Prod3) = cov_Prod3;
        
        sP(idx_Prod1,idx_Prod2) = cov_Prod12;
        sP(idx_Prod2,idx_Prod1) = cov_Prod12;
        sP(idx_Prod1,idx_Prod3) = cov_Prod13;
        sP(idx_Prod3,idx_Prod1) = cov_Prod13;
        sP(idx_Prod2,idx_Prod3) = cov_Prod23;
        sP(idx_Prod3,idx_Prod2) = cov_Prod23;
        
        sP = (sP + sP')*0.5;
        
    end
    
else
    mP = 0;
    sP = 0;
    ProdQ = 0;
end







end
