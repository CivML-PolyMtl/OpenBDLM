function [data, misc]=selectTimePeriod(data, misc)
%SELECTTIMEPERIOD Select data between two dates
%
%   SYNOPSIS:
%     [data, misc]=SELECTTIMEPERIOD(data, misc)
%
%   INPUT:
%       data            - structure (required)
%                               data must contain three fields:
%
%                               'timestamps' is a M×1 array
%
%                               'values' is a MxN  array
%
%                               'labels' is a 1×N cell array
%                               each cell is a character array
%
%                           N: number of time series
%                           M: number of samples
%
%      misc             - structure
%                          see the documentation for details about the
%                          field in misc
%
%   OUTPUT:
%      data             - structure
%                          data must contain three fields :
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
%                                   N: number of time series
%                                   M_i: number of samples of time series i
%
%      misc             - structure
%                          see the documentation for details about the
%                          field in misc
%
%   DESCRIPTION:
%      SELECTTIMEPERIOD select data between two dates.
%      SELECTTIMEPERIOD request user's input to get the two dates.
%
%      If end date > last date of the dataset, add trailing missing data at
%      the end of the dataset. In this case, the timestep for the missing
%      data is provided by user's input.
%      Padding with missing data is useful for prediction.
%
%   EXAMPLES:
%      [data, misc]=SELECTTIMEPERIOD(data, misc)
%
%   EXTERNAL FUNCTIONS CALLED:
%      convertMat2Cell, convertCell2Mat
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also EDITDATA, CONVERTMAT2CELL, CONVERTCELL2MAT

%   AUTHORS:
%       Ianis Gaudot, Luong Ha Nguyen, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       July 4, 2018
%
%   DATE LAST UPDATE:
%       August 13, 2018

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
if misc.internalVars.isQuiet
    % output message in logfile
    fileID=fopen(misc.internalVars.logFileName, 'a');
else
    % output message on screen and logfile using diary command
    fileID=1;
end

%% Get number of time series
numberOfTimeSeries =size(data.values, 2);

%% Get timestamps
timestamps=data.timestamps;

fprintf(fileID, '- Define timestamps\n');
fmt = 'yyyy-mm-dd';

%% Request user's input to specify start date
incTest=0;
isCorrect = false;
while ~isCorrect
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    fprintf(fileID,'     Start date (%s): \n',fmt);
    if misc.internalVars.BatchMode.isBatchMode
        tts=eval(char(misc.internalVars.BatchMode.Answers{misc.internalVars.BatchMode.AnswerIndex}));
        fprintf(fileID, '     %s\n', tts);
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
            fprintf(fileID, '\n');
            fprintf(fileID, '     wrong format. Format should be %s\n',fmt );
            fprintf(fileID, '\n');
            continue
        end
        
        if ~strcmp(datestr(tts, fmt), tts )
            fprintf(fileID, '\n');
            fprintf(fileID, '     wrong input: Invalid date.\n');
            fprintf(fileID, '\n');
            continue
        end
        
    end
    isCorrect = true;
end
% Increment global variable to read next answer when required
misc.internalVars.BatchMode.AnswerIndex = misc.internalVars.BatchMode.AnswerIndex + 1;
fprintf(fileID, '\n');

%% Request user's input to specify end date
incTest=0;
isCorrect = false;
while ~isCorrect
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    fprintf(fileID, '     End date (%s): \n',fmt);
    if misc.internalVars.BatchMode.isBatchMode
        tte=eval(char(misc.internalVars.BatchMode.Answers{misc.internalVars.BatchMode.AnswerIndex}));
        fprintf(fileID, '     %s\n', tte);
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
            fprintf(fileID, '\n');
            fprintf(fileID, '     wrong format. Format should be %s\n',fmt );
            fprintf(fileID, '\n');
            continue
        end
        
        if ~strcmp(datestr(tte, fmt), tte )
            fprintf(fileID, '\n');
            fprintf(fileID, '    wrong input: Invalid date.\n');
            fprintf(fileID, '\n');
            continue
        end
        
        if datenum(tte) <= datenum(tts)
            fprintf(fileID, '\n');
            fprintf(fileID, ['     wrong input: end date  ' ...
                'should be more recent than start date\n']);
            fprintf(fileID, '\n');
            continue
        end
        
        if datenum(tte) <= datenum(timestamps(1))
            fprintf(fileID, '\n');
            fprintf(fileID, ['     wrong input: end date  ' ...
                'should be more recent that the ', ...
                'date of first data sample\n']);
            fprintf(fileID, '\n');
            continue
        end
        
        
    end
    isCorrect = true;
end
% Increment global variable to read next answer when required
misc.internalVars.BatchMode.AnswerIndex = misc.internalVars.BatchMode.AnswerIndex + 1;


if datenum(tte, fmt) > timestamps(end)
    
    isPadding = true;
    incTest=0;
    isAnswerCorrect = false;
    while ~isAnswerCorrect
        
        incTest=incTest+1;
        if incTest > MaxFailAttempts ; error(['Too many failed ', ...
                'attempts (', num2str(MaxFailAttempts)  ').']) ; end
        
        fprintf(fileID, '\n');
        fprintf(fileID, '     The end date > last date.\n');
        fprintf(fileID, '     Padding with NaN will be done.');
        fprintf(fileID, ['     Give a time step (in day) ', ...
            'to perform the data padding.\n']);
        if misc.internalVars.BatchMode.isBatchMode
            dt_ref= ...
                eval(char(misc.internalVars.BatchMode.Answers{misc.internalVars.BatchMode.AnswerIndex}));
            fprintf(fileID, '     %s\n',num2str(dt_ref));
        else
            dt_ref = input('     choice >> ');
        end
        
        if  isnumeric(dt_ref) && length(dt_ref) == 1
            isAnswerCorrect = true;
        else
            fprintf(fileID, '     wrong input\n');
            continue
        end
        
    end
    
    % Increment global variable to read next answer when required
    misc.internalVars.BatchMode.AnswerIndex = misc.internalVars.BatchMode.AnswerIndex + 1;
    
else
    isPadding = false;
    
end


%% Select requested time period

% Get sample index the closest to user's requested start date
[~, IdxStart] = min(abs(timestamps-datenum(tts, fmt)));

% Get sample index the closest to user's requested end date
[~, IdxEnd] = min(abs(timestamps-datenum(tte, fmt)));

% Extract corresponding portion of data

if ~isPadding
    data.timestamps = data.timestamps(IdxStart:IdxEnd,:);
    data.values = data.values(IdxStart:IdxEnd,:);
else
    extra_ts = timestamps(end)+dt_ref:dt_ref:datenum(tte, fmt);
    
    %data.timestamps = [ repmat(data.timestamps(IdxStart:IdxEnd,1), ...
    %    1,numberOfTimeSeries); repmat( extra_ts', 1, numberOfTimeSeries)];
    
        data.timestamps = [ repmat(data.timestamps(IdxStart:IdxEnd,1), ...
        1,1); repmat( extra_ts', 1, 1)];
    
    data.values = [ data.values(IdxStart:IdxEnd,:) ; ...
        NaN(length(extra_ts),numberOfTimeSeries ) ];
end

%--------------------END CODE ------------------------
end
