function [cellOut]=writeParameterProperties(cellIn, arrayIn, Position)
%WRITEPARAMETERPROPERTIES Write updated model parameter properties
%
%   SYNOPSIS:
%     [CellOut]=WRITEPARAMETERPROPERTIES(cellIn, arrayIn, Position)
%
%   INPUT:
%      cellIn       - NxM cell array (required)
%                     original cell array with previous model parameters
%                     properties
%
%      arrayIn      - NxP array (required)
%                     updated model parameters properties in a an array
%
%      Position     - integer (required)
%                     insertion of arrayIn in cellIn starts at Position
%                     if Position > M, column(s) is (are) added
%
%   OUTPUT:
%      cellOut      - updated cellIn with values of arrayIn inserted in
%                     columns index given by Position
%
%   DESCRIPTION:
%      WRITEPARAMETERPROPERTIES write updated model parameter properties
%      from array
%
%   EXAMPLES:
%      [CellOut]=WRITEPARAMETERPROPERTIES(cellIn, arrayIn, Position)
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   SUBFUNCTIONS:
%      insertArrayInCell
%
%   See also

%   AUTHORS:
%       Ianis Gaudot,  Luong Ha Nguyen, James-A Goulet
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

validationFct_Position = @(n) (rem(n,1) == 0) & (n > 0);

addRequired(p,'cellIn', @iscell );
addRequired(p,'arrayIn', @isnumeric );
addRequired(p,'Position', validationFct_Position);
parse(p,cellIn, arrayIn, Position);

cellIn=p.Results.cellIn;
arrayIn=p.Results.arrayIn;
Position=p.Results.Position;

%% Incorporate arrayIn in cellIn
[cellOut] = insertArrayInCell(cellIn, arrayIn, Position);

%% Modify cellOut to take into account parameter constraint

% Get model parameter constrains
p_ref = arrayIn(:,2);

p_ref_unique = unique(p_ref);
Ncount = histc(p_ref, p_ref_unique);

p_ref_target = p_ref_unique(Ncount~=1);

if ~isempty(p_ref_target)
    for i=1:length(p_ref_target)
        idx=find(p_ref == p_ref_target(i));
        
        idx_to_replace = idx(2:end);
        
        % Bounds to NaN/NaN
        cellOut(idx_to_replace, 5) = {[NaN, NaN]};
        
        % Duplicate prior type/mean/std
%         cellOut(idx_to_replace, 6) = cellOut(p_ref_target(i), 6);
%         cellOut(idx_to_replace, 7) = cellOut(p_ref_target(i), 7);
%         cellOut(idx_to_replace, 8) = cellOut(p_ref_target(i), 8);
%         
%         % Duplicate parameter value
%         cellOut(idx_to_replace, 9) = cellOut(p_ref_target(i), 9);


        % Duplicate prior type/mean/std
        cellOut(idx_to_replace, 6) = {'N/A'};
        cellOut(idx_to_replace, 7) = {NaN};
        cellOut(idx_to_replace, 8) = {NaN};
%         
%         % Duplicate parameter value
         cellOut(idx_to_replace, 9) = {NaN};

    end
end

%--------------------END CODE ------------------------
end

function [cellOutput] = insertArrayInCell(cellInput, arrayInput, Pos)
% INPUT
% cellInput     : NxM cell
% arrayInput    : NxP array
% Pos           : insertion of arrayIn starts at Position
%                 if Pos > M , the cell array is extended (i.e columns
%                 will be added)
% OUTPUT
% cellOutput    : updated cellIn with insertion of arrayIn inside

% Verify compatibility size
if size(arrayInput, 1) ~= size(cellInput,1)
    error('     Impossible to concatenate. Size does not match. ')
end

Position_end = Pos+size(arrayInput,2)-1;

cellInput(:,Pos:Position_end) = num2cell(arrayInput);
cellOutput=cellInput;

end