function [arrayOut]=readParameterProperties(cellIn, Position)
%READPARAMETERPROPERTIES Extract some columns of a cell array
%
%   SYNOPSIS:
%     [arrayOut]=READPARAMETERPROPERTIES(cellIn, Position)
% 
%   INPUT:
%      cellIn           - NxM cell array (required)
%
%      Position         - 1xP array of integer (required)
%                         Index column to be extracted from cellIn
% 
%   OUTPUT:
%      arrayOut         - NxP array
%                         All extracted columns stored a single array
% 
%   DESCRIPTION:
%      READPARAMETERPROPERTIES extracts some columns of a cell array 
% 
%   EXAMPLES:
%      [arrayOut]=READPARAMETERPROPERTIES(cellIn, Position)
% 
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
% 
%   SUBFUNCTIONS:
%      N/A
% 
%   See also 
 
%   AUTHORS: 
%       Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
% 
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
% 
%   MATLAB VERSION:
%      Tested on 9.4.0.813654 (R2018a)
% 
%   DATE CREATED:
%       August 2, 2018
% 
%   DATE LAST UPDATE:
%       August 2, 2018
 
%--------------------BEGIN CODE ---------------------- 
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

validationFct_Position = @(n) all(rem(n,1) == 0) & all(n > 0);

addRequired(p,'cellIn', @iscell );
addRequired(p,'Position', validationFct_Position );
parse(p, cellIn, Position);

cellIn=p.Results.cellIn;
Position=p.Results.Position;

if ~all(Position <= size(cellIn,2))
    disp(' ')
    disp('     Impossible to extract column. Index out of range. ')
    disp(' ')
    arrayOut= [];
    return
end
 
%% Extract specified columns
arrayOut=cell2mat(cellIn(:,Position));

%--------------------END CODE ------------------------ 
end
