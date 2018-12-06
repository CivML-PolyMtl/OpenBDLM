function [Answers]=loadAnswersFromFile(filename)
%LOADANSWERSFROMFILE Load user's answers from an input text file
%
%   SYNOPSIS:
%     [Answers]=LOADANSWERSFROMFILE(filename)
%
%   INPUT:
%      filename         - character (required)
%                         Name of the text file to read
%
%   OUTPUT:
%      Answers  - cell array
%                         the cell array contains all answers
%                         
%   DESCRIPTION:
%      LOADANSWERSFROMFILE loads user answer from input text file
%      The text file should contain one answer per line
%
%   EXAMPLES:
%      [Answers]=loadAnswersFromFile('./input.txt')
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
%       December 3, 2018

%--------------------BEGIN CODE ----------------------

%% Get arguments passed to the function and proceed to some verifications

p = inputParser;
addRequired(p,'filename');
parse(p,filename);

filename=p.Results.filename;

% Validation of filename
if ~ischar(filename) || isempty(filename(~isspace(filename)))
    disp(' ')
    error('Filename should be a non-empty character array.')
end

%% Open and read the file
fid = fopen(filename,'r');

if fid == -1
    disp(' ')
    error('Impossible to open %s. \n', filename)
%     disp(' ')
%     Answers = [];
else
    AnswersFromFile=textscan(fid, '%s', 'Delimiter', '\n');
    Answers = AnswersFromFile{1};
    fclose(fid);
end
%--------------------END CODE ------------------------
end
