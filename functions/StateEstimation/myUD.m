function [U, D] = myUD(mat,varargin)
%MYUD Compute the UD decomposition
%
%   SYNOPSIS:
%     [U,D]=MYUD(mat,varargin)
%
%   INPUT:
%      mat                        - real valued array (required)
%                                   symmetric, positive definite square matrix
%
%      isError                    - logical (optional)
%                                   throw error when mat is not positive
%                                   definite
%                                   default: true
%
%   OUTPUT:
%      U                          - real valued array 
%                                   
%
%      D                          - real valued array 
%                                   
%   DESCRIPTION:
%      MYUD computes the UD decomposition of the input
%      square, positive definite, and (assumed) symmetric matrix.
%      If mat is not positive definite, an error message is
%      displayed.
%
%      MYUD forces mat symmetric by only accessing
%      its upper triangle and assuming mat(i,j) = mat(j,i)
%
%      U is a unit upper triangular matrix and 
%      D is a diagonal matrix such that mat = U * D * U' 
%              
%
%      Note: The UD decomposition is a specific form of Cholesky
%      decomposition.
%
%   EXAMPLES:
%      [U,D]=MYUD(mat)
%      [U,D]=MYUD(mat, 'isError', false)
% 
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
% 
%   SUBFUNCTIONS:
%      N/A
% 
%   See also UDFILTER, STATEESTIMATION, SWITCHINGKALMANFILTER,
%   RTS_SWITCHINGKALMANSMOOTHER

%   AUTHORS: 
%       Brian Moore, Luong Ha Nguyen, Ianis Gaudot, James-A Goulet
% 
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%      
%      Initial program by Brian Moore (brimoor@umich.edu)
%      July 12, 2012
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
% 
%   DATE CREATED:
%       June 28, 2018
% 
%   DATE LAST UPDATE:
%       June 28, 2018
%--------------------BEGIN CODE ---------------------- 

%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

validationFunction_mat = @(x) isnumeric(x) && ...
    ismatrix(x) && (size(x, 1) == size(x, 2));

defaultisError = true;
addRequired(p,'mat', validationFunction_mat );
addParameter(p, 'isError', defaultisError, @islogical)
parse(p,mat,varargin{:});

mat=p.Results.mat;
isError=p.Results.isError;



UD_TOL = 1e-55;

% Verify input matrix is square matrix
% [n, m] = size(mat);
% if (n ~= m)
%     error('Input matrix must be square');
% end

% Get matrix dimension
[n, ~] = size(mat);

% Initialization
U = zeros(n);
D = zeros(n);

for j = n:-1:1
    for i = j:-1:1
        sum = mat(i,j);
        for k = (j+1):n
            sum = sum - U(i,k) * D(k,k) * U(j,k);
        end
        if (i == j)
            if (sum <= UD_TOL)
                if isError
                    error('Input matrix is not positive definite');
                end
                D(j,j) = 1;
                U(j,j) = 0;
            else
                D(j,j) = sum;
                U(j,j) = 1;
            end
        else
            U(i,j) = sum / D(j,j);
        end
    end
end
