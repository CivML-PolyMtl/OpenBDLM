function [K_E,K_V,K_V1]=Kernel_component3(l,p,timestamp,timestamp_ref,x,V,nb_p,idx_delta)
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
delta = x;

%% Periodic Kernel

K=@(x,cp,delta) exp(-2/l.^2*sin(pi*(x+delta-cp)./p).^2);
Diff=@(x,cp,delta) exp(-2/l.^2*sin(pi*(x+delta-cp)./p).^2).*(-4./l^2).*cos(pi*(x+delta-cp)./p).^2.*(pi./p).^2.*(x+delta-cp);
%Diff=@(x,cp,delta) -(4.*pi.*exp(-(2.*sin((pi.*(delta - cp + x))./p).^2)./l.^2).*cos((pi.*(delta - cp + x))./p).*sin((pi.*(delta - cp + x))./p))./(l.^2.*p);
%Diff=@(x,cp,delta) -(4.*pi.*exp(-(2.*sin((pi.*(cp + delta - x))./p).^2)./l.^2).*cos((pi.*(cp + delta - x))./p).*sin((pi*(cp + delta - x))./p))./(l.^2*p);
%% Control points
x_cp=(linspace(timestamp_ref,timestamp_ref+p,nb_p+1))';
x_cp(end)=[];

%% Kernel regression
X_cp=x_cp;
X=repmat(timestamp,[length(x_cp),1]);
delta=repmat(delta,[length(x_cp),1]);
K_raw=K(X,X_cp,delta); %raw kernel evaluation
K_E=K_raw./(sum(K_raw)+10^-8); %normalized kernel coefficients
K0 = Diff(X,X_cp,delta).*(K_E./K_raw+10^-8);
idx1 = repmat([1:1:length(K0)]',[1,length(K0)]); idx2 = repmat([1:1:length(K0)],[length(K0),1]);
K_V = (K0*V);
K_V1 = ((K0(idx1).*K0(idx2))*V(1,idx_delta));
%--------------------END CODE ---------------------- 
end