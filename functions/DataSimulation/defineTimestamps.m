function [data, misc]=defineTimestamps(data, misc)
%DEFINETIMESTAMPS Request user's input to define data timestamps
%
%   SYNOPSIS:
%     [data, misc]=DEFINETIMESTAMPS(data, misc)
%
%   INPUT:
%      data - structure(required)
%      misc - structure(required)
%
%   OUTPUT:
%      data - structure
%      data - structure
%
%   DESCRIPTION:
%      DEFINETIMESTAMPS request user input to define data timestamps
%      DEFINETIMESTAMPS create the field timestamps of the structure data
%
%   EXAMPLES:
%      [data, misc]=DEFINETIMESTAMPS(data, misc)
%
%   See also DEFINEDATALABELS, DEFINECUSTOMANOMALIES

%   AUTHORS:
%     Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
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
%       July 20, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'data', @isstruct );
addRequired(p,'misc', @isstruct );
parse(p,data, misc);

data=p.Results.data;
misc=p.Results.misc;

MaxFailAttempts=4;

%% Verify presence of field "labels" in structure data

if ~isfield(data, 'labels')
    disp(['     ERROR: Structure data should contain ' ...
        'a non-empty field named labels '])
    return
else
    if isempty(data.labels)
        disp(['    ERROR: Structure data should contain ' ...
            'a non-empty field named labels '])
        return
    end
end

%% Get number of time series

%snumberOfTimeSeries = length(data.labels);

disp('- Define timestamps ')
fmt = 'yyyy-mm-dd';

%% Request user's input to specify start date
incTest=0;
isCorrect = false;
while ~isCorrect
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    fprintf('  Start date (%s): \n',fmt);
    if misc.BatchMode.isBatchMode
        tts=eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
        disp(['     ', tts])
    else
        tts = input('     choice >> ','s');
    end
    
    % Remove space and quotes
    tts=strrep(tts,'''','' ); % remove quotes
    tts=strrep(tts,'"','' ); % remove double quotes
    tts=strrep(tts, ' ','' ); % remove spaces
    
    if isempty(tts)
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp(' ')
        disp([' This is the date corresponding with the ' ...
            'first sample of the simulated time series.'])
        disp(' The date should be provided in yyyy-mm-dd format.       ')
        disp([' Note that all the simulated time series' ...
            'share the same timestamps (i.e. same start date, same' ...
            ' end date, same time step).'])
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp(' ')
        continue
    else
        try
            datenum(tts,fmt);
        catch
            disp(' ')
            disp(['     wrong format. Format should be ',fmt ])
            disp(' ')
            continue
        end
        
        if ~strcmp(datestr(tts, fmt), tts )
            disp(' ')
            disp('     wrong input: Invalid date. ')
            disp(' ')
            continue
        end
        
    end
    isCorrect = true;
end
% Increment global variable to read next answer when required
misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex + 1;
disp(' ')

%% Request user's input to specify end date
incTest=0;
isCorrect = false;
while ~isCorrect
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    fprintf('  End date (%s): \n',fmt);
    if misc.BatchMode.isBatchMode
        tte=eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
        disp(['     ', tte])
    else
        tte = input('     choice >> ','s');
    end
    
    % Remove space and quotes
    tte=strrep(tte,'''','' ); % remove quotes
    tte=strrep(tte,'"','' ); % remove double quotes
    tte=strrep(tte, ' ','' ); % remove spaces
    
    if isempty(tte)
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp(' ')
        disp([' This is the date corresponding with the' ...
            'last sample of the simulated time series.'])
        disp(' The date should be provided in yyyy-mm-dd format.       ')
        disp([' Note that all the simulated time series' ...
            'share the same timestamps (i.e. same start date, same' ...
            ' end date, same time step).'])
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp(' ')
        continue
    else
        try
            datenum(tte,fmt);
        catch
            disp(' ')
            disp(['     wrong format. Format should be ',fmt ])
            disp(' ')
            continue
        end
        
        if ~strcmp(datestr(tte, fmt), tte )
            disp(' ')
            disp('    wrong input: Invalid date. ')
            disp(' ')
            continue
        end
        
        if datenum(tte) <= datenum(tts)
            disp(' ')
            disp(['     wrong input: end date  ' ...
                'should be more recent than start date'])
            disp(' ')
            continue
        end
        
    end
    isCorrect = true;
end
% Increment global variable to read next answer when required
misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex + 1;
disp(' ')
incTest=0;
isCorrect = false;
while ~isCorrect
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    disp('  Time step (in day): ');
    if misc.BatchMode.isBatchMode
        dt=eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
        disp(['     ', num2str(dt)])
    else
        dt=input('     choice >> ');
    end
    
    if isempty(dt)
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('                                                         ')
        disp([' This is the time step for the time vector, ' ...
            ' i.e. the number of days that separate two timestamps' ...
            ' in the generated time vector.'])
        disp([' Note that all the simulated time '...
            ' series share the same timestamps ' ...
            '(i.e. same start date, same end date, same time step).'])
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp(' ')
        continue
    else
        if ischar(dt)
            disp(' ')
            disp('     wrong input -> not an digit ')
            disp(' ')
            continue
        elseif length(dt) > 1
            disp(' ')
            disp('     wrong input -> should be single value ')
            disp(' ')
            continue
        else
            isCorrect = true;
        end
    end
end
% Increment global variable to read next answer when required
misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex + 1;

% Generate timestamp vector

data.timestamps=(datenum(tts):dt:datenum(tte))';


%--------------------END CODE ------------------------
end
