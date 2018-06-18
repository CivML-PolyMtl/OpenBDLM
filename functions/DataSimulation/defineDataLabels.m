function [data]=defineDataLabels(data)
%DEFINEDATALABELS Request user's input to define data labels
%
%   SYNOPSIS:
%     [data]=DEFINEDATALABELS(data)
%
%   INPUT:
%      data - structure (required)
%
%   OUTPUT:
%      data - structure (required)
%
%   DESCRIPTION:
%      DEFINEDATALABELS request user input to define data labels
%      DEFINEDATALABELS create the field labels of the structure data
%
%   EXAMPLES:
%      [data]=DEFINEDATALABELS(data)
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
%       April 24, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'data', @isstruct );
parse(p,data);

data=p.Results.data;

% define global variable for user's answers from input file
global isAnswersFromFile AnswersFromFile AnswersIndex

%% Request user's input to get the data labels
isCorrect =false;
while ~isCorrect
    disp(['- Provide time series reference names [max. 10 characters]' ...
        '(ex: {''CF001'', ''D0023''}) : '])   
    if isAnswersFromFile
        choice_labels=eval(char(AnswersFromFile{1}(AnswersIndex)));
        disp(choice_labels)       
    else
        choice_labels=input('     reference names >> ');
    end
    if isempty(choice_labels)
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('                                                         ')
        disp([' The reference names are used to' ...  
            ' name the simulated time series.       '])
        disp([' The list of reference names should be provided' ...  
        ' using a cell array of character vectors.'])
        disp([' The number of reference names entered provides' ...
            ' the number of time series to simulate.'])
        disp([' Example : {''CF001'', ''D0023''} prepares ' ...
            'simulation for 2 time series.'])
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp(' ')
        continue        
    elseif ~iscellstr(choice_labels)
        disp(' ')
        disp(['     wrong input -> should be a cell array' ... 
            'of character vectors. Example : {''CF001'', ''D0023''} '])
        disp(' ')
        continue
    else
        % count number of character in each character vector
        ll=length(choice_labels);
        
        if any(ll(ll>10))
            disp(' ')
            disp(['     wrong input -> each reference name' ...
                'should have 10 characters max. '])
            disp(' ')
            continue
        end
        
        % Remove spaces in the reference names (if existing)
        choice_labels=cellfun(@(x) x(x~=' '), choice_labels, 'un', 0);
        
        % remove empty cells
        choice_labels(cellfun('isempty',choice_labels)) = [];
        
        % verify that each reference name does not start with a digit
        TF = isstrprop(choice_labels,'digit');
        rec=zeros(1,length(TF));
        for  i=1:length(TF)
            rec(i)=TF{i}(1);
        end
        
        if any(rec)
            disp(' ')
            disp(['     wrong input -> first character of'  ...
                ' reference name should not start with a digit '])
            disp(' ')
            continue
        end
        
        % Remove redundancy
        choice_labels=unique(choice_labels);
        
        isCorrect = true;
    end
end
% Increment global variable to read next answer when required
AnswersIndex = AnswersIndex + 1;

%% Store labels in structure "labels"
data.labels = choice_labels;
%--------------------END CODE ------------------------
end
