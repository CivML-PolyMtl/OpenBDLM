function [K_norm]=Static_kernel_component(reg_parameters,timestamp,timestamp_ref,nb_p)
%STATIC_KERNEL_COMPONENT Compute normalized kernel coefficients
%
%   SYNOPSIS:
%     [K_norm]=STATIC_KERNEL_COMPONENT(reg_parameters,timestamp,timestamp_ref,nb_p)
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
%      STATIC_KERNEL_COMPONENT computes normalized kernel coefficients
%      used for static and dynamic kernel regression
% 
%   EXAMPLES:
%      [K_norm]=STATIC_KERNEL_COMPONENT(reg_parameters,timestamp,timestamp_ref,nb_p)
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
l=reg_parameters(1);
p=reg_parameters(2);

%% Periodic Kernel
K=@(x,cp) exp(-2/l.^2*sin(pi*(x-cp)./p).^2);

%% Control points
x_cp=linspace(timestamp_ref,timestamp_ref+p,nb_p+1);
x_cp(end)=[];

%% Kernel regression
X_cp=repmat(x_cp,[length(timestamp),1]);
X=repmat(timestamp,[1,length(x_cp)]);

K_raw=K(X,X_cp); %raw kernel evaluation
K_norm=K_raw./repmat(sum(K_raw,2)+10^-8,[1,length(x_cp)]); %normalized kernel coefficients
K_norm = K_norm - mean(K_norm); % force the mean to be zero
%--------------------END CODE ---------------------- 
end