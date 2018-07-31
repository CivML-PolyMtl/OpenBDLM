function [data, misc]=defineDataLabels(data, misc)
%DEFINEDATALABELS Request user's input to define data labels
%
%   SYNOPSIS:
%     [data, misc]=DEFINEDATALABELS(data, misc)
%
%   INPUT:
%      data     - structure (required)
%      misc     - structure (required)
%
%   OUTPUT:
%      data     - structure
%      misc     - structure
%
%   DESCRIPTION:
%      DEFINEDATALABELS request user input to define data labels
%      DEFINEDATALABELS create the field labels of the structure data
%
%   EXAMPLES:
%      [data, misc]=DEFINEDATALABELS(data, misc)
%
%   See also DEFINETIMESTAMPS, DEFINECUSTOMANOMALIES

%   AUTHORS:
%    Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       April 24, 2018
%
%   DATE LAST UPDATE:
%       July 24, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'data', @isstruct );
addRequired(p,'misc', @isstruct );
parse(p,data, misc);

data=p.Results.data;
misc=p.Results.misc;

MaxFailAttempts=4;

%% Request user's input to get the number of time series to simulate

incTest=0;
isCorrect =false;
while ~isCorrect
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    disp('- Give the number of time series to simulate:')
    if misc.BatchMode.isBatchMode
        user_choice=eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
        disp(user_choice)
    else
        user_choice=input('     choice >> ');
    end
    
    if isempty(user_choice)
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('                                                         ')
        disp([' Provide an integer to indicate the number of time ', ...
            'series to simulate.'])
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp(' ')
        continue
    elseif (rem(user_choice,1) == 0) && (user_choice > 0)
        nts = user_choice;
        isCorrect =  true;
    else
        disp('     Wrong input.')
        continue
    end
end

%% Automatically generate time series labels and store them in data.labels

% Base name
BaseName = 'TS';

for i=1:nts
    data.labels{i}=[BaseName num2str(i,'%02d')];
end

% Increment AnswerIndex to read next answer when required
misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex + 1;

%% Request user's input to get the data labels
% isCorrect =false;
% while ~isCorrect
%     disp(['- Provide time series reference names [max. 10 characters]' ...
%         '(ex: {''CF001'', ''D0023''}) : '])
%     if misc.BatchMode.isBatchMode
%         choice_labels=eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
%         disp(choice_labels)
%     else
%         choice_labels=input('     reference names >> ');
%     end
%     if isempty(choice_labels)
%         disp(' ')
%         disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
%         disp('                                                         ')
%         disp([' The reference names are used to' ...
%             ' name the simulated time series.       '])
%         disp([' The list of reference names should be provided' ...
%         ' using a cell array of character vectors.'])
%         disp([' The number of reference names entered provides' ...
%             ' the number of time series to simulate.'])
%         disp([' Example : {''CF001'', ''D0023''} prepares ' ...
%             'simulation for 2 time series.'])
%         disp(' ')
%         disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
%         disp(' ')
%         continue
%     elseif ~iscellstr(choice_labels)
%         disp(' ')
%         disp(['     wrong input -> should be a cell array' ...
%             'of character vectors. Example : {''CF001'', ''D0023''} '])
%         disp(' ')
%         continue
%     else
%         % count number of character in each character vector
%         ll=length(choice_labels);
%
%         if any(ll(ll>10))
%             disp(' ')
%             disp(['     wrong input -> each reference name' ...
%                 'should have 10 characters max. '])
%             disp(' ')
%             continue
%         end
%
%         % Remove spaces in the reference names (if existing)
%         choice_labels=cellfun(@(x) x(x~=' '), choice_labels, 'un', 0);
%
%         % remove empty cells
%         choice_labels(cellfun('isempty',choice_labels)) = [];
%
%         % verify that each reference name does not start with a digit
%         TF = isstrprop(choice_labels,'digit');
%         rec=zeros(1,length(TF));
%         for  i=1:length(TF)
%             rec(i)=TF{i}(1);
%         end
%
%         if any(rec)
%             disp(' ')
%             disp(['     wrong input -> first character of'  ...
%                 ' reference name should not start with a digit '])
%             disp(' ')
%             continue
%         end
%
%         % Remove redundancy
%         choice_labels=unique(choice_labels);
%
%         isCorrect = true;
%     end
% end
% Increment global variable to read next answer when required
% misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex + 1;

%% Store labels in structure "labels"
%data.labels = choice_labels;
%--------------------END CODE ------------------------
end
