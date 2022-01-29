 function [K_E,K_cov,K_var]=Kernel_component2(reg_parameters,x,V,x_ref,VV, idx_xprod,idx_prod,n_temp)
%KERNEL_COMPONENT Compute normalized kernel coefficients
%
%   SYNOPSIS:
%     [K_norm]=KERNEL_COMPONENT(reg_parameters,timestamp,timestamp_ref,nb_p)
% 
%   INPUT:
%      reg_parameters   - 2x1 real array (required)
%                         reg_parameters(1) = kernel width
%                         reg_parameters(1) = kernel period
%
%      timestamp        - Nx1 real array (required)                       
%                         timestamp vector
%
%      timestamp_ref    - real (required)
%                         timestamp corresponding to first point of the
%                         periodic pattern
%
%      nb_p             - integer (required)
%                         number of points to model the pattern
% 
%   OUTPUT:
%      K_norm           - nb_px1 real array
%                         normalized kernel coefficients
%
%   DESCRIPTION:
%      KERNEL_COMPONENT computes normalized kernel coefficients
%      used for kernel regression
% 
%   EXAMPLES:
%      [K_norm]=KERNEL_COMPONENT(reg_parameters,timestamp,timestamp_ref,nb_p)
% 
%   See also DEFINEMODEL, BUILDMODEL
 
%   AUTHORS: 
%      James-A Goulet, Luong Ha Nguyen, Ianis Gaudot
% 
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
% 
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
% 
%   DATE CREATED:
%       April 23, 2018
% 
%   DATE LAST UPDATE:
%       June 1, 2018
 
%--------------------BEGIN CODE ---------------------- 

%% Kernel parameters
l=reg_parameters;
%p=reg_parameters(2);
%l = 1;
%% Periodic Kernel
K=@(x,cp,l) exp(-1/(2*l.^2)*((x-cp)).^2);
Diff=@(x,cp,l) exp(-1/(2*l.^2).*((x-cp)).^2).*(-1/l.^2).*(x-cp);
%% Control points

%x_cp=linspace(timestamp_ref,timestamp_ref+p,nb_p+1);
x_cp=x_ref; % size of x_ref equal to (1xnb_p)
%x_cp(end)=[];
%x = 20;
%% Kernel regression
% x_cp = x_cp-mean(x_cp);
if length(l) > 1
    k = 1;
    K_cov = cell(1,length(l));
    K_var = cell(1,length(l));
    K0    = cell(1,length(l));
    while k <= length(l)
        K_raw      = K(x(k),x_cp(:,k),l(k));                     
        K_E(:,k)   = K_raw./(sum(K_raw)+10^-8);
        K0{k}      = Diff(x(k),x_cp(:,k),l(k)).*(K_E(:,k)./(K_raw+10^-8));
        
        idx1       = repmat([1:1:length(K0{k})]',[1,length(K0{k})]); idx2 = repmat([1:1:length(K0{k})],[length(K0{k}),1]);
        K_cov{k}   = (K0{k}*V(k,:));                                        % fill the entire rows of kernels by the covariance with all X
        K_var{k}   = ((K0{k}(idx1).*K0{k}(idx2))*VV(k));                    % fill the block of kernels with variance
        k = k + 1;
    end
    % cross covariance
    if length(l) == 2
        K_cov12 = K0{1}(idx1).*K0{2}(idx2)*(V(1,end-n_temp));
        ind_SR1 = idx_xprod(1,1:length(x_ref));
        ind_SR2 = idx_xprod(1,length(x_ref)+1:end);
        K_cov{1}(:,ind_SR2) = K_cov12;
        K_cov{2}(:,ind_SR1) = K_cov12';
    else
        K_cov12 = K0{1}(idx1).*K0{2}(idx2)*(V(1,idx_prod(1,2*20)+1)); % cov(L, AR1)
        K_cov13 = K0{1}(idx1).*K0{3}(idx2)*(V(1,idx_prod(1,3*20)+1)); % cov(L, AR1)
        K_cov23 = K0{2}(idx1).*K0{3}(idx2)*(V(2,idx_prod(1,3*20)+1)); % cov(AR1, AR2)
        N_SR    = length(x_ref);
        ind_SR1 = idx_xprod(1,1:N_SR);
        ind_SR2 = idx_xprod(1,N_SR+1:2*N_SR);
        ind_SR3 = idx_xprod(1,2*N_SR+1:3*N_SR);
        
        K_cov{1}(:,ind_SR2) = K_cov12;
        K_cov{2}(:,ind_SR1) = K_cov12';
        
        K_cov{1}(:,ind_SR3) = K_cov13;
        K_cov{3}(:,ind_SR1) = K_cov13';
        
        K_cov{2}(:,ind_SR3) = K_cov23;
        K_cov{3}(:,ind_SR2) = K_cov23';
    end
        
else
    K_raw=K(x,x_cp,l); %raw kernel evaluation
    K_E=K_raw./(sum(K_raw)+10^-8);
    
    K0 = Diff(x,x_cp,l).*(K_E./(K_raw+10^-8));
    idx1 = repmat([1:1:length(K0)]',[1,length(K0)]); idx2 = repmat([1:1:length(K0)],[length(K0),1]);
    K_cov = (K0*V);
    K_var = ((K0(idx1).*K0(idx2))*VV);
end
%--------------------END CODE ---------------------- 
end