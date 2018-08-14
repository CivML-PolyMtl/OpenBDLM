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
%       August 9, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'data', @isstruct );
addRequired(p,'model', @isstruct );
addRequired(p,'misc', @isstruct );
parse(p,data, model, misc);

misc=p.Results.misc;

MaxFailAttempts=4;

% Set fileID for logfile
if misc.isQuiet
    % output message in logfile
    fileID=fopen(misc.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end


incTest=0;
isCorrect = false;
while ~isCorrect
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    fprintf(fileID,'- Define custom anomalies ? (y/n): \n');
    if misc.BatchMode.isBatchMode
        choice_custom_anomalies = ...
            eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
        fprintf(fileID,'     %s\n',choice_custom_anomalies);
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
        continue        
    elseif strcmpi(choice_custom_anomalies,'y') ||  ...
            strcmpi(choice_custom_anomalies,'yes')
        
        misc.isCustomAnomalies = true;
        isCorrect = true;
    elseif strcmpi(choice_custom_anomalies,'n') || ...
            strcmpi(choice_custom_anomalies,'no')
        
        misc.isCustomAnomalies = false;
        isCorrect = true;
    else
        fprintf(fileID,'\n');
        fprintf(fileID,'     Wrong input.\n');
        fprintf(fileID,'\n');
        continue
    end
    
end
misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;
fprintf(fileID,'\n');
if misc.isCustomAnomalies
    %% Request anomalies start
    incTest=0;
    isCorrect = false;
    while ~isCorrect
        
        incTest=incTest+1;
        if incTest > MaxFailAttempts ; error(['Too many failed ', ...
                'attempts (', num2str(MaxFailAttempts)  ').']) ; end
        
        fprintf(fileID,'- Anomalies starts (in sample index) ?\n');
        if misc.BatchMode.isBatchMode
            start_custom_anomalies = ...
                eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
            x=start_custom_anomalies;
            fprintf(fileID, ['', ...
                '     [%s]\n'], strjoin(cellstr(num2str(x(:))),', '));
        else
            start_custom_anomalies= input('     choice >> ');
        end
        if isempty(start_custom_anomalies)
            fprintf(fileID,'\n');
            fprintf(fileID,'     wrong input ->  input is empty\n');
            fprintf(fileID,'\n');
            continue
        elseif ischar(start_custom_anomalies)|| ...
                any(rem(start_custom_anomalies,1)~=0) || ...
                ~any(all(start_custom_anomalies > 0))
            
            fprintf(fileID,'\n');
            fprintf(fileID,['     wrong input -> should be strictly ' ...
                'positive integers\n']);
            fprintf(fileID,'\n');
            continue
        elseif length(unique(start_custom_anomalies)) ~= ...
                length(start_custom_anomalies)
            fprintf(fileID,'\n');
            fprintf(fileID,['     wrong input -> at least two '
                'anomaly starts are identical.\n']);
            fprintf(fileID,'\n');
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
    misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;
    fprintf(fileID,'\n');
        
    %% Request anomalies durations
    incTest=0;
    isCorrect=false;
    while ~isCorrect
        
        incTest=incTest+1;
        if incTest > MaxFailAttempts ; error(['Too many failed ', ...
                'attempts (', num2str(MaxFailAttempts)  ').']) ; end
        
        fprintf(fileID,'- Anomalies durations (in number of points) ?\n');
        if misc.BatchMode.isBatchMode
            duration_custom_anomalies = ...
                eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
            
            x=duration_custom_anomalies;
            fprintf(fileID, ['', ...
                '     [%s]\n'], strjoin(cellstr(num2str(x(:))),', '));
            
        else
            duration_custom_anomalies= input( '     choice >> ');
        end
        if isempty(duration_custom_anomalies)
            fprintf(fileID,'\n');
            fprintf(fileID,'     wrong input ->  input is empty\n');
            fprintf(fileID,'\n');
            continue
        elseif ischar( duration_custom_anomalies)|| ...
                any(rem(duration_custom_anomalies,1)~=0) || ...
                any(duration_custom_anomalies(duration_custom_anomalies ...
                <= 0))
            fprintf(fileID,'\n');
            fprintf(fileID,['     wrong input -> ', ...
                'should be strictly positive integers\n']);
            fprintf(fileID,'\n');
            continue
        elseif length(duration_custom_anomalies) ~= ...
                length(start_custom_anomalies)
            fprintf(fileID,'\n');
            fprintf(fileID,['     wrong input -> ', ...
                'length of the vector should be %s\n'], ...
                num2str(length(start_custom_anomalies)));
            fprintf(fileID,'\n');
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
                fprintf(fileID,'\n');
                fprintf(fileID,['     wrong input -> ', ...
                    ' at least two overlapping anomalies\n']);
                fprintf(fileID,'\n');
                continue
            end
            
            % Record anomalies duration
            misc.custom_anomalies.duration_custom_anomalies= ...
                duration_custom_anomalies;
            isCorrect = true;
        end
    end
    misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;
    fprintf(fileID,'\n');
    
    %% Request anomalies amplitudes
    incTest=0;
    isCorrect=false;
    while ~isCorrect
        
        incTest=incTest+1;
        if incTest > MaxFailAttempts ; error(['Too many failed ', ...
                'attempts (', num2str(MaxFailAttempts)  ').']) ; end
        
        fprintf(fileID,'- Anomalies amplitudes (i.e change in local trend) ?\n');
        if misc.BatchMode.isBatchMode
            amplitude_custom_anomalies = ...
                eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
            
            x=amplitude_custom_anomalies;
            fprintf(fileID, ['', ...
                '     [%s]\n'], strjoin(cellstr(num2str(x(:))),', '));
            
        else
            amplitude_custom_anomalies=input('     choice >> ');
        end
        if isempty(amplitude_custom_anomalies)
            fprintf(fileID,'\n');
            fprintf(fileID,'     wrong input ->  input is empty\n');
            fprintf(fileID,'\n');
            continue
        elseif ischar( amplitude_custom_anomalies)
            fprintf(fileID,'\n');
            fprintf(fileID,['     wrong input ->  ', ...
                'input contains character\n']);
            fprintf(fileID,'\n');
            continue
        elseif length(amplitude_custom_anomalies) ~= ...
                length(start_custom_anomalies)
            fprintf(fileID,'\n');
            fprintf(fileID,['     wrong input -> ', ...
                'length of the vector should be %s'], ...
                num2str(length(start_custom_anomalies)));
            fprintf(fileID,'\n');
            continue
        elseif ~all(amplitude_custom_anomalies)
            fprintf(fileID,'\n');
            fprintf(fileID,['     wrong input ->  ', ...
                'input should be nonzero\n']);
            fprintf(fileID,'\n');
            continue
        end
        
        % Record anomalies amplitude
        misc.custom_anomalies.amplitude_custom_anomalies=...
            amplitude_custom_anomalies;
        
        isCorrect = true;
    end
    
    misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;   
else
    return
end
fprintf(fileID,'\n');
%--------------------END CODE ------------------------
end
