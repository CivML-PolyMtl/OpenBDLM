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
%       August 9, 2018

%--------------------BEGIN CODE ----------------------
%% Get arguments passed to the function and proceed to some verifications
p = inputParser;

addRequired(p,'data', @isstruct );
addRequired(p,'misc', @isstruct );
parse(p,data, misc);

data=p.Results.data;
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

%% Verify presence of field "labels" in structure data

if ~isfield(data, 'labels')
    fprintf(fileID,['     ERROR: Structure data should contain ' ...
        'a non-empty field named labels \n']);
    return
else
    if isempty(data.labels)
        fprintf(fileID,['    ERROR: Structure data should contain ' ...
            'a non-empty field named labels \n']);
        return
    end
end

%% Get number of time series

fprintf(fileID,'\n');
fprintf(fileID,'- Define timestamps \n');
fmt = 'yyyy-mm-dd';

%% Request user's input to specify start date
incTest=0;
isCorrect = false;
while ~isCorrect
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    fprintf(fileID, '  Start date (%s): \n',fmt);
    if misc.BatchMode.isBatchMode
        tts=eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
        fprintf(fileID,'     %s', tts);
    else
        tts = input('     choice >> ','s');
    end
    
    % Remove space and quotes
    tts=strrep(tts,'''','' ); % remove quotes
    tts=strrep(tts,'"','' ); % remove double quotes
    tts=strrep(tts, ' ','' ); % remove spaces
    
    if isempty(tts)
        continue
    else
        try
            datenum(tts,fmt);
        catch
            fprintf(fileID,'\n');
            fprintf(fileID,'     wrong format. Format should be %s \n',fmt);
            fprintf(fileID,'\n');
            continue
        end
        
        if ~strcmp(datestr(tts, fmt), tts )
            fprintf(fileID,'\n');
            fprintf(fileID,'     wrong input: Invalid date.\n');
            fprintf(fileID,'\n');
            continue
        end
        
    end
    isCorrect = true;
end
% Increment global variable to read next answer when required
misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex + 1;
fprintf(fileID,'\n');

%% Request user's input to specify end date
incTest=0;
isCorrect = false;
while ~isCorrect
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    fprintf(fileID, '  End date (%s): \n',fmt);
    if misc.BatchMode.isBatchMode
        tte=eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
        fprintf(fileID,'     %s', tte);
    else
        tte = input('     choice >> ','s');
    end
    
    % Remove space and quotes
    tte=strrep(tte,'''','' ); % remove quotes
    tte=strrep(tte,'"','' ); % remove double quotes
    tte=strrep(tte, ' ','' ); % remove spaces
    
    if isempty(tte)
        continue
    else
        try
            datenum(tte,fmt);
        catch
            fprintf(fileID,'\n');
            fprintf(fileID,'     wrong format. Format should be %s \n',fmt);
            fprintf(fileID,'\n');
            continue
        end
        
        if ~strcmp(datestr(tte, fmt), tte )
            fprintf(fileID,'\n');
            fprintf(fileID,'    wrong input: Invalid date.\n');
            fprintf(fileID,'\n');
            continue
        end
        
        if datenum(tte) <= datenum(tts)
            fprintf(fileID,'\n');
            fprintf(fileID,['     wrong input: end date  ' ...
                'should be more recent than start date \n']);
            fprintf(fileID,'\n');
            continue
        end
        
    end
    isCorrect = true;
end
% Increment global variable to read next answer when required
misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex + 1;
fprintf(fileID,'\n');
fprintf(fileID,'\n');
incTest=0;
isCorrect = false;
while ~isCorrect
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    fprintf(fileID,'  Time step (in day): \n');
    if misc.BatchMode.isBatchMode
        dt=eval(char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
        fprintf(fileID,'     %s', num2str(dt));
    else
        dt=input('     choice >> ');
    end
    
    if isempty(dt)
        continue
    else
        if ischar(dt)
            fprintf(fileID,'\n');
            fprintf(fileID,'     wrong input -> not an digit\n');
            fprintf(fileID,'\n');
            continue
        elseif length(dt) > 1
            fprintf(fileID,'\n');
            fprintf(fileID,'     wrong input -> should be single value\n');
            fprintf(fileID,'\n');
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

fprintf(fileID,'\n');
%--------------------END CODE ------------------------
end
