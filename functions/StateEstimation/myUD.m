function [U D] = myUD(mat,varargin)
%--------------------------------------------------------------------------
% Syntax:       [U D] = myUD(mat);
%               [U D] = myUD(mat,'noerror');
%
% Inputs:       mat is a symmetric, positive definite square matrix
%               
%               'noerror' suppresses the error thrown when mat is not
%               positive  definite
%
%               Note: myUD() forces mat symmetric by only accesing
%               its upper triangle and assuming mat(i,j) = mat(j,i)
%
% Outputs:      U is a unit upper triangular matrix and D is a diagonal
%               matrix such that mat = U * D * U'; 
%              
% Description:  This function computes the UD decomposition of the input
%               square, positive definite, and (assumed) symmetric matrix.
%               If mat is not positive definite, an error message is
%               displayed.
%
%               Note: The UD decomposition is a specific form of Cholesky
%               decomposition.
%
% Author:       Brian Moore
%               brimoor@umich.edu
%
% Date:         July 12, 2012
%--------------------------------------------------------------------------

UD_TOL = 1e-55;

if (nargin == 2)
   noerror = varargin{1}; 
else
    noerror = '';
end

[n m] = size(mat);

if (n ~= m)
    error('Input matrix must be square');
end

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
                if ~strcmpi(noerror,'noerror')
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
