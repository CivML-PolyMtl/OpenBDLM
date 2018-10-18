function [dataOrig, misc]=loadData(misc)
%LOADDATA Load data from csv file
%
%   SYNOPSIS:
%     [dataOrig, misc]=LOADDATA(misc, varargin)
%
%   INPUT:
%      misc                - structure
%                             see the documentation for details about the
%                             field in misc
%   OUTPUT:
%       dataOrig           - structure (required)
%
%                            dataOrig must contain three fields :
%
%                               'timestamps' is a 1×N cell array
%                               each cell is a M_ix1 real array
%
%                               'values' is a 1×N cell array
%                               each cell is a M_ix1 real array
%
%                               'labels' is a 1×N cell array
%                               each cell is a character array
%
%                               N: number of time series
%                               M_i: number of samples of time series i
%
%      misc                - structure
%                             see the documentation for details about the
%                             field in misc
%
%   DESCRIPTION:
%      LOADDATA loads data from csv file. 
%
%   EXAMPLES:
%      [dataOrig, misc] = LOADDATA(misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%      readMultipleCSVFiles.m
%
%   See also READMULTIPLECSVFILES

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
%       April 18, 2018
%
%   DATE LAST UPDATE:
%       October 16, 2018
%
%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p, 'misc', @isstruct)

parse(p, misc);

misc=p.Results.misc;

%% Read .csv files
[dataOrig, misc] = readMultipleCSVFiles(misc);
        
%--------------------END CODE ------------------------
end
