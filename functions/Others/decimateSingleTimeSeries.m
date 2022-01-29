function [dataDecimate]=decimateSingleTimeSeries(data, dt_ref)
%DECIMATESINGLETIMESERIES Decimate a time series according to given dt
%
%
%   SYNOPSIS:
%     [data]=DECIMATESINGLETIMESERIES(data)
%
%   INPUT:
%      data                 - structure (required)
%
%      dt_ref               - real (required)
%                             target timestep in days
%
%   OUTPUT:
%      dataDecimate         - structure
%
%   DESCRIPTION:
%      DECIMATESINGLETIMESERIES decimate a single time series according to
%      a given timestep given in days
%      For each reference timestamp generated from dt_ref, the function
%      picks up the closest timestamp in original data and associated
%      value. 
%      As a consequence, output timestep can differ from dt_ref and it also
%      may be time varying
%      
%   EXAMPLES:
%      [data]=DECIMATESINGLETIMESERIES(data)
%
%   EXTERNAL FUNCTIONS CALLED:
%      N/A
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also

%   AUTHORS:
%       Ianis Gaudot, Luong Ha Nguyen,  James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.4.0.813654 (R2018a)
%
%   DATE CREATED:
%       August 28, 2018
%
%   DATE LAST UPDATE:
%       August 28, 2018

%--------------------BEGIN CODE ----------------------

%% Get number of time series
numberOfTimeSeries =size(data.values, 2);

if numberOfTimeSeries > 1
    disp('ERROR: More than one time series.')
    return
end


%% Get the (unique) timestamps vector
timestamps=data.timestamps;

%% Get beg and endd date corresponding to the first and last sample 

begg = timestamps(1);
endd = timestamps(end);

%% Generate reference uniform timestamp vector with requested timestep
timestamps_ref = begg:dt_ref:endd;
timestamps_ref=timestamps_ref';

nskip=0;
for i=1:length(timestamps_ref)
    
    ts_target = timestamps_ref(i);
    % get index of end training in timestamps vector
    [~,I]=min(abs(timestamps-ts_target));
    
    if  i > 1 && ...
            timestamps(I) == dataDecimate.timestamps(i-nskip-1,1) || ...
            i > 1 && abs(timestamps(I) - dataDecimate.timestamps(i-nskip-1,1)) < dt_ref
        
        % Skip to avoid data redundancy or dt smaller than dt_ref
        nskip=nskip+1;
        continue   
    else
        % Assign new timestamps and values
        dataDecimate.timestamps(i-nskip,1)=timestamps(I);
        dataDecimate.values(i-nskip,1)=data.values(I,1);

    end

    
end

% Put labels 
dataDecimate.labels{1}=data.labels{1};

%--------------------END CODE ------------------------
end
