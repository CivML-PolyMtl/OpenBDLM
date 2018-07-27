function [OverlapRange, Index]=getTimeOverlap(Start_End)
%GETTIMEOVERLAP Detect time overlap range among a set of start/end dates
%
%   SYNOPSIS:
%     [OverlapRange, Index]=GETTIMEOVERLAP(Start_End)
% 
%   INPUT:
%      Start_End     - Nx2 real array (required)
%                      first column contains start date of each time series
%                      second column contains end date of each time series
%                      N is the number of time series
%   OUTPUT:
%      OverlapRange  - 1x2 real array
%                      first column contains start date of detected overlap
%                      end column contains end date of detected overlap
%
%      Index         - Mx1 integer array
%                      It stores the index of time series participating to
%                      the detected overlap
% 
%   DESCRIPTION:
%      GETTIMEOVERLAP extracts overlap among time 
%      series
%      It may happen that several overlap occur.
%      Example with N=4 time series:
%                A
%      1 -----|---|   B   C
%      2      |---|-|---|--|  D
%      3                |--|----|-------
%      4            |---|--|----|
%
%      4 overlaps, labeled A, B, C, D
%
%      In such case, GETTIMEOVERLAP proceeds as follows:
%      1) Select the overlap that include the maximum of the 
%      time series
%      2) If 1) is not discriminant criterion, select the longest overlap.
% 
%      Consequently, GETTIMEOVERLAP would select range C.
% 
%   EXAMPLES:
%      [OverlapRange, Index]=GETTIMEOVERLAP(Start_End)
% 
%   See also EXTRACTSYNCHRONOUSRECORDS
 
%   AUTHORS: 
%      Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
% 
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
% 
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
% 
%   DATE CREATED:
%       April 13, 2018
% 
%   DATE LAST UPDATE:
%       April 13, 2018
 
%--------------------BEGIN CODE ----------------------     
 %% Get arguments passed to the function and proceed to some verifications
p = inputParser;
validationFcn = @(x) isnumeric(x) && size(x,2) == 2 ;
addRequired(p,'Start_End', validationFcn );    
parse(p,Start_End);
 
%% Get number of time series in dataset
numberOfTimeSeries = size(Start_End,1);

%% Initialization
beg_end_idx=cell(numberOfTimeSeries,3);
for i=1:numberOfTimeSeries
    beg_end_idx{i,1}=Start_End(i,1);
    beg_end_idx{i,2}=Start_End(i,2);
    beg_end_idx{i,3}=i;
end


%% Detect overlapping
isOverlapping = true;

while isOverlapping
    
    % "Compress matrix" to remove redondancies
    beggendd=cell2mat(beg_end_idx(:,1:2));
    match = squeeze(all((bsxfun(@eq, beggendd, permute(beggendd, [3 2 1]))), 2));
    
    ts=zeros(length(beg_end_idx));
    for i=1:length(match)
        idx=find(match(i,:)~=0);
        ts(i,1:length(idx))=idx;
    end
    
    tsu=unique(ts,'rows');
    
    tsu( ~any(tsu,2), : ) = []; % remove zero
    
    beg_end_idx_compressed=cell(size(tsu,1),3);
    
    for i=1:size(tsu,1)
        beg_end_idx_compressed{i,1}=beg_end_idx{tsu(i,1),1};
        beg_end_idx_compressed{i,2}=beg_end_idx{tsu(i,1),2};
        
        idx_ts=beg_end_idx( tsu(i,(tsu(i,:)~=0)) ,3);
        
        concat=[];
        
        for j=1:length(idx_ts)
            concat=[ idx_ts{j} concat];
        end
        
        beg_end_idx_compressed{i,3}=unique(concat);
        
    end
        
    if size(beg_end_idx_compressed,1) == 1
        beg_end_idx=beg_end_idx_compressed;
        break
    end
    
    beg_end_idx=beg_end_idx_compressed;
    
    beg_end_idx_new=[];
    
    % Detect if overlap
    over=0;
    pos=1;
    for i=1:size(beg_end_idx,1)
               
        for j=(i+1):size(beg_end_idx,1)
            
            if (( beg_end_idx{i,1} >= beg_end_idx{j,1} ) && ...
                    ( beg_end_idx{i,1} <= beg_end_idx{j,2} ) ) || ...
                    (( beg_end_idx{i,2}  >= beg_end_idx{j,1} ) && ...
                    ( beg_end_idx{i,2} <= beg_end_idx{j,2} ) )
                
                begg=max(beg_end_idx{i,1},beg_end_idx{j,1});
                endd=min(beg_end_idx{i,2},beg_end_idx{j,2});
                
                beg_end_idx_new{pos,1}=begg;
                beg_end_idx_new{pos,2}=endd;
                beg_end_idx_new{pos,3}=[beg_end_idx{i,3}, beg_end_idx{j,3}];
                pos=pos+1;
                over=over+1;  % overlap occurs between the time series i and j
                
            else
                
                if ( beg_end_idx{i,1} < beg_end_idx{j,1} ) && ( beg_end_idx{i,2} > beg_end_idx{j,2} )
                    
                    begg=max(beg_end_idx{i,1},beg_end_idx{j,1});
                    endd=min(beg_end_idx{i,2},beg_end_idx{j,2});
                    
                    beg_end_idx_new{pos,1}=begg;
                    beg_end_idx_new{pos,2}=endd;
                    beg_end_idx_new{pos,3}=[beg_end_idx{i,3}, beg_end_idx{j,3}];
                    
                    pos=pos+1;
                    over=over+1; % overlap occurs between the time series i and j
                else
                    % the time series i and j does not overlap
                end
            end
            
        end
        
    end
    
    if over == 0
        isOverlapping = false;
    else
        isOverlapping = true;
        beg_end_idx=beg_end_idx_new;
    end
    
end

%% Select a unique overlap range among all detected overlap
%  1) Select the overlap that include the maximum of the time series
%  2) If 1) is not discriminant criterion, select the longest overlap.

ll=zeros(1,size(beg_end_idx,1));
for i=1:size(beg_end_idx,1)
    ll(i)=length(beg_end_idx{i,3});
end

pos=find(ll==max(ll));

if length(pos) == 1
    
    begg_overlap=beg_end_idx{pos,1};
    endd_overlap=beg_end_idx{pos,2};
    Index=unique(beg_end_idx{pos,3});
    
else
    
    max_duration=0;
    for i=1:length(pos)
        
        duration=beg_end_idx{pos(i),2}-beg_end_idx{pos(i),1};
        
        if duration > max_duration
            max_duration = duration;
            begg_overlap=beg_end_idx{pos(i),1};
            endd_overlap=beg_end_idx{pos(i),2};
            Index=unique(beg_end_idx{pos(i),3});
        end
        
    end
        
end

OverlapRange=[begg_overlap, endd_overlap];
%--------------------END CODE ------------------------ 
end
