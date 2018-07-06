function [misc]=defineCustomAnomalies(data, model, misc)
%DEFINECUSTOMANOMALIES Request user's input to define custom anomalies
%
%   SYNOPSIS:
%     [misc]=DEFINECUSTOMANOMALIES(data, model, misc)
%
%   INPUT:
%      data  - structure (required)
%      model - structure (required)
%      misc  - structure (required)
%
%   OUTPUT:
%      misc  - structure
%
%   DESCRIPTION:
%      DEFINECUSTOMANOMALIES requests user's input to define custom anomalies
%
%   EXAMPLES:
%      [misc]=DEFINECUSTOMANOMALIES(data, model, misc)
%
%   See also CONFIGUREMODELFORDATASIMULATION

%   AUTHORS:
%      Ianis Gaudot, Luong Ha Nguyen, James-A Goulet,
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
addRequired(p,'model', @isstruct );
addRequired(p,'misc', @isstruct );
parse(p,data, model, misc);

data=p.Results.data;
%model=p.Results.model;
misc=p.Results.misc;

% define global variable for user's answers from input file
global isAnswersFromFile AnswersFromFile AnswersIndex


timestamps=data.timestamps{1};

isCorrect = false;
while ~isCorrect
    disp('- Define custom anomalies ? (y/n): ')
    if isAnswersFromFile
        choice_custom_anomalies = ...
            eval(char(AnswersFromFile{1}(AnswersIndex)));
        disp(['     ',choice_custom_anomalies])
    else
        choice_custom_anomalies = input('     choice >> ','s');
    end
    
    % Remove space and quotes
    % remove quotes
    choice_custom_anomalies=strrep(choice_custom_anomalies,'''','' );
    % remove double quotes
    choice_custom_anomalies=strrep(choice_custom_anomalies,'"','' );
    % remove spaces
    choice_custom_anomalies=strrep(choice_custom_anomalies, ' ','' );
    
    
    if isempty(choice_custom_anomalies)
        disp(' ')
        disp(['%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%'...
            '%%%%%%%%%%%%%%%%%%%%'])
        disp('                                                         ')
        disp([' An amomaly is a change in the baseline ' ... '
            '(level of the time series) according to the previously' ...
            'defined model classes.'])
        disp(' ')
        disp([' Answering ''yes'' enables to ' ... '
            'generate user''s defined anomalies.'])
        disp([' In such case, the user chooses the starts,' ...
            ' the durations, and the amplitudes of the anomalies.'])
        disp(' ')
        disp([' Answering ''no'' lets the program generate' ...
            ' anomalies from the default parameter values.'])
        disp(' ')
        disp(['%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%'...
            '%%%%%%%%%%%%%%%%%%%%'])
        disp(' ')
        
    elseif strcmp(choice_custom_anomalies,'y') ||  ...
            strcmp(choice_custom_anomalies,'yes') || ...
            strcmp(choice_custom_anomalies,'Y') || ...
            strcmp(choice_custom_anomalies,'Yes')  || ...
            strcmp(choice_custom_anomalies,'YES')
        
        misc.isCustomAnomalies = true;
        isCorrect = true;
    elseif strcmp(choice_custom_anomalies,'n') || ...
            strcmp(choice_custom_anomalies,'no') ||  ...
            strcmp(choice_custom_anomalies,'N') || ...
            strcmp(choice_custom_anomalies,'No')  || ...
            strcmp(choice_custom_anomalies,'NO')
        
        misc.isCustomAnomalies = false;
        isCorrect = true;
    else
        disp(' ')
        disp('     Wrong input.')
        disp(' ')
        continue
    end
    
end
AnswersIndex = AnswersIndex+1;
disp(' ')
if misc.isCustomAnomalies
    %% Request anomalies start
    isCorrect = false;
    while ~isCorrect
        disp('- Anomalies starts (in sample index)')
        if isAnswersFromFile
            start_custom_anomalies = ...
                eval(char(AnswersFromFile{1}(AnswersIndex)));
            disp(['     ',num2str(start_custom_anomalies)])
        else
            start_custom_anomalies= input('     choice >> ');
        end
        if isempty(start_custom_anomalies)
            disp(' ')
            disp('     wrong input ->  input is empty')
            disp(' ')
            continue
        elseif ischar(start_custom_anomalies)|| ...
                 any(rem(start_custom_anomalies,1)~=0) || ...
                 ~any(all(start_custom_anomalies > 0))
%                 ~all(start_custom_anomalies < length(timestamps))
            
            disp(' ')
            disp(['     wrong input -> should be strictly ' ...
                'positive integers'])
            disp(' ')
            continue
        elseif length(unique(start_custom_anomalies)) ~= ...
                length(start_custom_anomalies)
            disp(' ')
            disp(['     wrong input -> at least two '
                'anomaly starts are identical.'])
            disp(' ')
            continue
        else
            % Sort vector
            start_custom_anomalies=sort(start_custom_anomalies);
            
            % Record anomalies start
            misc.custom_anomalies.start_custom_anomalies= ...
                start_custom_anomalies;
            isCorrect = true;
            
        end
    end
    AnswersIndex = AnswersIndex+1;
    disp(' ')
    
    
    %% Request anomalies durations
    isCorrect=false;
    while ~isCorrect
        disp('- Anomalies durations (in number of points)')
        disp(' ')
        if isAnswersFromFile
            duration_custom_anomalies = ...
                eval(char(AnswersFromFile{1}(AnswersIndex)));
            disp(['     ', num2str(duration_custom_anomalies)])
        else
            duration_custom_anomalies= input( '     choice >> ');
        end
        if isempty(duration_custom_anomalies)
            disp(' ')
            disp('     wrong input ->  input is empty')
            disp(' ')
            continue
        elseif ischar( duration_custom_anomalies)|| ...
                any(rem(duration_custom_anomalies,1)~=0) || ...
                any(duration_custom_anomalies(duration_custom_anomalies ...
                <= 0))
            disp(' ')
            disp('     wrong input -> should be strictly positive integers')
            disp(' ')
            continue
        elseif length(duration_custom_anomalies) ~= ...
                length(start_custom_anomalies)
            disp(' ')
            disp(['     wrong input -> length of the vector should be ', ...
                num2str(length(start_custom_anomalies))])
            disp(' ')
            continue
        else
            overlap = false;
            for i=1:length(duration_custom_anomalies)-1
                
                if start_custom_anomalies(i)+duration_custom_anomalies(i)...
                        >= start_custom_anomalies(i+1)
                    overlap = true;
                end
            end
            
            if overlap
                disp(' ')
                disp(['     wrong input -> at ' ...
                    'least two overlapping anomalies'])
                disp(' ')
                continue
            end
            
            % Record anomalies duration
            misc.custom_anomalies.duration_custom_anomalies= ...
                duration_custom_anomalies;
            isCorrect = true;
        end
    end
    AnswersIndex = AnswersIndex+1;
    disp(' ')
    
    %% Request anomalies amplitudes
    isCorrect=false;
    while ~isCorrect        
        disp('- Anomalies amplitudes (i.e change in local trend) >> ')
        disp(' ')
        if isAnswersFromFile
            amplitude_custom_anomalies = ...
                eval(char(AnswersFromFile{1}(AnswersIndex)));
            disp(['     ', num2str(amplitude_custom_anomalies)])
        else
            amplitude_custom_anomalies=input('     choice >> ');
        end
        if isempty(amplitude_custom_anomalies)
            disp(' ')
            disp('     wrong input ->  input is empty')
            disp(' ')
            continue
        elseif ischar( amplitude_custom_anomalies)
            disp(' ')
            disp('     wrong input ->  input contains character')
            disp(' ')
            continue
        elseif length(amplitude_custom_anomalies) ~= ...
                length(start_custom_anomalies)
            disp(' ')
            disp(['     wrong input -> length of the vector should be ', ...
                num2str(length(start_custom_anomalies))])
            disp(' ')
            continue
        elseif ~all(amplitude_custom_anomalies)
            disp(' ')
            disp('     wrong input ->  input should be nonzero')
            disp(' ')
            continue
        end
        
        % Record anomalies amplitude
        misc.custom_anomalies.amplitude_custom_anomalies=...
            amplitude_custom_anomalies;
        isCorrect = true;
    end
        AnswersIndex = AnswersIndex+1;
    
else
    return
end
%--------------------END CODE ------------------------
end
