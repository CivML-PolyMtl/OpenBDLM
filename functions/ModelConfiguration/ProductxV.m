function [mP,sP,ProdQ] = ProductxV(A,x,V,idx_xprod,idx_prod,ProdQ,idx_prod_,index_1)
if ~isempty(idx_xprod)||~isempty(idx_prod)
    %% Non-Gaussian GC Z=X*Y (Saeid Amiri)
    m12=@(m,S,idx) (m(idx{1}).*m(idx{2}))+S(sub2ind(size(S),idx{1},idx{2}))';
    cov312=@(m,S,idx) S(sub2ind(size(S),idx{3},idx{1})).*m(idx{2})+S(sub2ind(size(S),idx{2},idx{1})).*m(idx{3});
    cov3412=@(m,S,idx) S(sub2ind(size(S),idx{1},idx{3})).*S(sub2ind(size(S),idx{2},idx{4}))+S(sub2ind(size(S),idx{2},idx{3})).*S(sub2ind(size(S),idx{1},idx{4}))+S(sub2ind(size(S),idx{1},idx{3})).*m(idx{2}).*m(idx{4})+S(sub2ind(size(S),idx{1},idx{4})).*m(idx{2}).*m(idx{3})+S(sub2ind(size(S),idx{2},idx{3})).*m(idx{1}).*m(idx{4})+S(sub2ind(size(S),idx{2},idx{4})).*m(idx{1}).*m(idx{3});
    N = 1;
    M=size(A,1);
    idx12{1}  =idx_xprod(1,:);
    idx12{2}  =idx_xprod(2,:);
    %index_1   = idx12{2}(end)+(idx_prod(1)-idx12{2}(end)-1);
%     idx312{1} =[1:1:idx_xprod(2,:)];
%     idx312{2} =[repmat(idx_xprod(1,:)',[1,M])];
%     idx312{3} =[repmat(idx_xprod(2,:)',[1,M])];
    
    idx312{1}=repmat(1:1:index_1,[length(idx12{2}),1]);
    idx312{2}=repmat(idx12{1}',[1,index_1]);
    idx312{3}=repmat(idx12{2}',[1,index_1]);
    
    index_2 = size(A,1)-idx_prod_(end);
    idx312N{1}=repmat((idx_prod_(end)+1:1:M)',[1,size(idx_xprod,2)]);
    idx312N{2}=repmat(idx12{1},[index_2,1]);
    idx312N{3}=repmat(idx12{2},[index_2,1]);

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
    sP(1:index_1,idx_prod)=(f1(x,V))'; % generalize (end-3)
    sP(idx_prod,1:index_1)=f1(x,V);
    sP(idx_prod_(end)+1:1:M,idx_prod)=cov312(x',V,idx312N);
    sP(idx_prod,idx_prod_(end)+1:1:M)=(cov312(x',V,idx312N))';
    sP(idx_prod,idx_prod) = f2(x,V);
else
    mP = 0;
    sP = 0;
    ProdQ = 0;
end







end
