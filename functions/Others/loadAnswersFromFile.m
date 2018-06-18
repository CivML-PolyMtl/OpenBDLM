function [isAnswersFromFile, AnswersFromFile, AnswersIndex]=loadAnswersFromFile(filename)
%LOADANSWERSFROMFILE Load user's answers from an input text file
%
%   SYNOPSIS:
%     [isAnswersFromFile, AnswersFromFile]=LOADANSWERSFROMFILE(filename)
%
%   INPUT:
%      filename         - character (required)
%                         Name of the text file to read
%
%   OUTPUT:
%      isAnswersFromFile - logical
%                         if isAnswerFromFile = true, read answer from file
%                         if isAnswerFromFile = false, interactive user
%                         input
%
%      AnswersFromFile  - cell array
%                         the cell array contains all answers
%
%      AnswersIndex     - integer
%                         
%   DESCRIPTION:
%      LOADANSWERSFROMFILE loads user answer from input text file
%      The text file should contain one answer per line
%
%   EXAMPLES:
%      [isAnswersFromFile, AnswersFromFile]=loadAnswersFromFile('./input.txt')
%
%   See also

%   AUTHORS:
%     Ianis Gaudot,, Luong Ha Nguyen, James-A Goulet
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
%       April 18, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications

p = inputParser;
addRequired(p,'filename');
parse(p,filename);

filename=p.Results.filename;

% Validation of filename
if ~ischar(filename) || isempty(filename(~isspace(filename)))
    disp(' ')
    disp('ERROR: Filename should be a non-empty character array.')
    disp(' ')
    return
end

%% Open and read the file
fid = fopen(filename,'r');

if fid == -1
    disp(' ')
    fprintf('WARNING: Impossible to open %s. \n', filename)
    disp(' ')
    AnswersFromFile = [];
    AnswersIndex=[];
    isAnswersFromFile = false;
else
    AnswersFromFile=textscan(fid, '%s', 'Delimiter', '\n');
    isAnswersFromFile = true;
    AnswersIndex=1;
    fclose(fid);
end
%--------------------END CODE ------------------------
end
