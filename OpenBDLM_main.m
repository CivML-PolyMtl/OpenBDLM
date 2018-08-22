function [data, model, estimation, misc] = OpenBDLM_main(UserInput)
%OPENBDLM_MAIN Process control for OpenBDLM
%
%   SYNOPSIS:
%     [data, model, estimation, misc] = OPENBDLM_MAIN(UserInput)
%
%   INPUT:
%      UserInput          - character or cell array of characters (optional)
%
%                           If UserInput is not provided, the function runs
%                           in interactive mode, in which online user's
%                           interactions from the command line is
%                           required to perform the analysis.
%
%                           If UserInput is a character array, it should be
%                           the name of a configuration file name (see doc)
%                           The configuration file is only used to
%                           initialize the project. The function then
%                           switches to the interactive mode.
%
%                           If UserInput is a cell array, it should contain
%                           all the inputs required for analysis (see doc).
%                           The is the batch mode, in which the function runs
%                           silently by automatically reading pre-loaded
%                           commands.
%
%   OUTPUT:
%      data                - structure
%                            see documentation for details about the fields
%                            in structure "data"
%
%      model               - structure
%                            see documentation for details about the fields
%                            in structure "model"
%
%      estimation         - structure
%                            see documentation for details about the fields
%                            in structure "estimation"
%
%      misc               - structure
%                            see documentation for details about the fields
%                            in structure "misc"
%
%   DESCRIPTION:
%      OPENBDLM_MAIN is the process control function for OpenBDLM.
%      OpenBDLM is an open-source software for performing structural
%      health monitoring using Bayesian Dynamic Linear Models
%
%   EXAMPLES:
%      [data, model, estimation, misc] = OPENBDLM_MAIN()
%      [data, model, estimation, misc] = OPENBDLM_MAIN('CFG_TEST1.m')
%      [data, model, estimation, misc] = OPENBDLM_MAIN({'''CFG_TEST1.m''', '31'})
%
%
%   EXTERNAL FUNCTIONS CALLED:
%      DataLoader, saveDataBinary, verificationDataStructure, SimulateData
%      ModelConfiguration, buildModel, displayModelMatrices
%      modifyInitialHiddenStates, modifyTrainingPeriod, learnModelParameters,
%      modifyModelParameters, chooseIsDataSimulation, chooseProjectName
%      displayProjects, initializeProject, printConfigurationFile,
%      printProjectDateCreation, saveProject, testFileExistence,
%      computeInitialHiddenStates,      plotData, plotEstimations
%
%   SUBFUNCTIONS:
%      N/A
%
%   See also
%    DATALOADER, STATEESTIMATION, LEARNMODELPARAMETERS, SAVEDATABINARY,
%    SIMULATEDATA, MODELCONFIGURATION, BUILDMODEL, DISPLAYMODELMATRICES
%    MODIFYINITIALHIDDENSTATES, MODIFYTRAININGPERIOD,VERIFICATIONDATASTRUCTURE
%    MODIFYMODELPARAMETERS, CHOOSEISDATASIMULATION, CHOOSEPROJECTNAME
%     DISPLAYPROJECTS, INITIALIZEPROJECT, PRINTCONFIGURATIONFILE,
%    PRINTPROJECTDATECREATION, SAVEPROJECT, TESTFILEEXISTENCE,
%    COMPUTEINITIALHIDDENSTATES, PLOTDATA, PLOTESTIMATIONS

%   AUTHORS:
%       Luong Ha Nguyen, Ianis Gaudot, James-A Goulet
%
%      Email: <james.goulet@polymtl.ca>
%      Website: <http://www.polymtl.ca/expertises/goulet-james-alexandre>
%
%   REFERENCES:
%       [1]  Goulet, J.-A., 2017, Bayesian dynamic linear models for
%       structural health monitoring,
%       Structural Control and Health Monitoring, Vol. 24, Issue 12.
%
%       [2]  Goulet, J.-A., Koo K., 2017, Empirical validation of Bayesian
%       dynamic linear models in the context of structural health monitoring,
%       Journal of Bridge Engineering, Vol.23, Issue 2.
%
%       [3]  Nguyen, L. H., Goulet J.-A., 2018, Anomaly detection with the
%       Switching Kalman Filter for structural health monitoring,
%       Structural Control and Health Monitoring, Vol. 25, Issue 4.
%
%   MATLAB VERSION:
%      Tested on 9.1.0.441655 (R2016b)
%
%   DATE CREATED:
%       June 27, 2018
%
%   DATE LAST UPDATE:
%       August 22, 2018

%--------------------BEGIN CODE ----------------------
%% Read input argument
switch nargin
    case 0
        
        misc.InteractiveMode.isInteractiveMode = true;
        misc.BatchMode.isBatchMode = false;
        misc.ReadFromConfigFileMode.isReadFromConfigFileMode = false;
        misc.BatchMode.Answers = [];
        misc.BatchMode.AnswerIndex=NaN;
        
    case 1
        
        if iscell(UserInput)
            
            misc.InteractiveMode.isInteractiveMode = false;
            misc.BatchMode.isBatchMode = true;
            misc.ReadFromConfigFileMode.isReadFromConfigFileMode = false;
            misc.BatchMode.Answers = UserInput;
            misc.BatchMode.AnswerIndex=1;
            
        elseif ischar(UserInput)
            
            misc.InteractiveMode.isInteractiveMode = false;
            misc.BatchMode.isBatchMode = false;
            misc.ReadFromConfigFileMode.isReadFromConfigFileMode = true;
            misc.ReadFromConfigFileMode.ConfigFilename = UserInput;
            misc.BatchMode.Answers = [];
            misc.BatchMode.AnswerIndex=NaN;
        end
        
    otherwise
        disp(' ');
        disp('     ERROR: Unrecognized argument.')
        disp(' ');
        data=struct;
        model=struct;
        estimation=struct;
        misc=struct;
        return
end

%% Define path (not recommanded to change)
misc.DataPath               = 'data';
misc.ConfigPath             = 'config_files';
misc.ProjectPath            = 'saved_projects';
misc.FigurePath             = 'figures';
misc.VersionControlPath     = 'version_control';
misc.LogPath                = 'log_files';

%% Define project info filename (not recommanded to change)
misc.ProjectInfoFilename    = 'ProjectsInfo.mat';

%% Set version
version = '1.8';

%Initialize random stream number based on clock
%RandStream.setGlobalStream(RandStream('mt19937ar','seed',861040000));

%% Create log file to record messages during program run
[misc] = createLogFile(misc);

%% Set default options
[misc]=setDefaultOptions(misc);

%% Print options
%[misc]=printOptions(misc);

if misc.isQuiet
    % output messages in  a specific log file
    fileID=fopen(misc.logFileName, 'a');
else
    % output message on screen
    fileID=1;
end

if misc.InteractiveMode.isInteractiveMode || misc.BatchMode.isBatchMode
    
    %Set default font type
    set(0,'DefaultAxesFontname','Helvetica')
    %Set default font size
    set(0,'DefaultAxesFontSize',20)
    %Set display format
    format short g
    
    %% Display welcome menu
    welcomeOpenBDLM(misc, 'version', version)
    %disp('     Starting OpenBDLM')
    incTest=0;
    MaxFailAttempts = 4;
    
    isAnswerCorrect = false;
    while ~isAnswerCorrect
        
        incTest=incTest+1;
        if incTest > MaxFailAttempts ; error(['Too many failed ', ...
                'attempts (', num2str(MaxFailAttempts)  ').']) ; end
        
        fprintf(fileID, '\n');
        fprintf(fileID,'- Start a new project: \n');
        fprintf(fileID, '\n');
        fprintf(fileID,['     *      ', ...
            'Enter a configuration filename \n']);
        fprintf(fileID, '     0   -> Interactive tool \n');
        fprintf(fileID, '\n');
        
        %% Display existing & saved projects
        [~] = displayProjects(misc);
        
        fprintf(fileID, ['- Type D to Delete project(s), ', ...
            'V for Version control, Q to Save and Quit.\n']);
        if misc.BatchMode.isBatchMode
            UserChoice= ...
                eval(char(misc.BatchMode.Answers{...
                misc.BatchMode.AnswerIndex}));
            UserChoice = num2str(UserChoice);
            if ischar(UserChoice)
                fprintf(fileID, '     %s  \n', UserChoice);
            else
                fprintf(fileID, '     %s  \n', num2str(UserChoice));
            end
        else
            fprintf(fileID,'\n');
            UserChoice = input('     choice >> ', 's');
        end
        fprintf(fileID,'\n');
        
        % Remove space and quotes
        UserChoice=strrep(UserChoice,'''',''); % remove quotes
        UserChoice=strrep(UserChoice,'"','' ); % remove double quotes
        UserChoice=strrep(UserChoice, ' ','' ); % remove spaces
        
        if isempty(UserChoice)
            continue
        elseif isnan(str2double(UserChoice))
            
            misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;
            
            if strcmpi('D',UserChoice) && length(UserChoice) == 1
                %% Delete project file(s)
                piloteDeleteProject(misc)
                incTest=0;
                continue
                
            elseif strcmpi('V', UserChoice) && length(UserChoice) == 1
                %% Version control
                piloteVersionControl(misc)
                data=struct; model=struct; estimation=struct; misc=struct;
                diary off
                return
                
            elseif strcmpi('Q', UserChoice) && length(UserChoice) == 1
                
                %% Quit the program
                disp('     See you soon !');
                if misc.isQuiet ; fclose(fileID); else ; diary off ; end
                data=struct; model=struct; estimation=struct; misc=struct;
                return
                
            else
                %% Load project from configuration file
                [data, model, estimation, misc]= ...
                    loadConfigurationFile(misc, UserChoice);
                
                isAnswerCorrect = true;
                
            end
            
        elseif round(str2double(UserChoice)) == 0
            
            misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;
            
            %% Load a project from interactive mode
            [data, model, estimation, misc]=loadInteractive(misc);
            
            isAnswerCorrect = true;
        else
            misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;
            
            %% Load project from project file
            UserChoice = round(str2double(UserChoice));
            [data, model, estimation, misc]=loadProjectFile(misc, UserChoice);
            if ~isempty(model)
                isAnswerCorrect = true;
            end
        end
    end
    
elseif misc.ReadFromConfigFileMode.isReadFromConfigFileMode
    
    configFileName = misc.ReadFromConfigFileMode.ConfigFilename;
    
    %% Load project from configuration file
    [data, model, estimation, misc]= loadConfigurationFile(misc, ...
        configFileName);
end

incTest=0;
MaxFailAttempts = 4;
while(1)
    
    incTest=incTest+1;
    if incTest > MaxFailAttempts ; error(['Too many failed ', ...
            'attempts (', num2str(MaxFailAttempts)  ').']) ; end
    
    %% Display menu
    [PossibleAnswers]=displayMenuOpenBDLM(misc);
    
    %% Read user's choice
    if misc.BatchMode.isBatchMode
        user_inputs=eval( ...
            char(misc.BatchMode.Answers{misc.BatchMode.AnswerIndex}));
        user_inputs = num2str(user_inputs);
        if ischar(user_inputs)
            fprintf(fileID, '     %s  \n', user_inputs);
        else
            fprintf(fileID, '     %s  \n', num2str(user_inputs));
        end
    else
        user_inputs = input('     choice >> ', 's');
    end
    
    % Remove space and quotes
    user_inputs=strrep(user_inputs,'''',''); % remove quotes
    user_inputs=strrep(user_inputs,'"','' ); % remove double quotes
    user_inputs=strrep(user_inputs, ' ','' ); % remove spaces
    
    
    if isnan(str2double(user_inputs))
        
        if strcmpi(user_inputs, 'Q')
            
            %% Save project and quit
            fprintf(fileID, '\n');
            saveProject(data, model, estimation, misc, ...
                'FilePath', misc.ProjectPath)
            fprintf(fileID, '\n');
            disp('     See you soon !');
            if misc.isQuiet ; fclose(fileID); else ; diary off ; end
            return
        else
            fprintf(fileID, '\n');
            fprintf(fileID, '     wrong input \n');
            continue
        end
    elseif ~ischar(user_inputs) && ...
            ~any(ismember(PossibleAnswers, user_inputs ))
        fprintf(fileID, '\n');
        fprintf(fileID, '     wrong input \n');
        continue
        
    else
        misc.BatchMode.AnswerIndex = misc.BatchMode.AnswerIndex+1;
        
        user_inputs = round(str2double(user_inputs));
        
        if  user_inputs==1
            %% Learn model parameters
            [data, model, estimation, misc]= ...
                piloteOptimization(data, model, estimation, misc);
            incTest=0;
        elseif  user_inputs==2
            %% Initial hidden states estimation
            [data, model, estimation, misc]= ...
                piloteInitialStateEstimation(data, model, estimation, misc);
            incTest=0;
        elseif  user_inputs==3
            %% Hidden states estimation
            [data, model, estimation, misc]= ...
                piloteStateEstimation(data, model, estimation, misc);
            incTest=0;
        elseif  user_inputs==11
            %% Modify model parameters
            [model, misc]= ...
                piloteModifyModelParameters(data, model, estimation, misc);
            incTest=0;
        elseif  user_inputs==12
            %% Modify initial hidden states
            [model, misc]= ...
                piloteModifyInitialStates(data, model, estimation, misc);
            incTest=0;
        elseif  user_inputs==13
            %% Modify training period
            [misc]=piloteModifyTrainingPeriod(data, model, estimation, misc);
            incTest=0;
        elseif  user_inputs==14
            %% Plot tools
            pilotePlot(data, model, estimation, misc)
            incTest=0;
        elseif  user_inputs==15
            %% Display model matrices
            piloteDisplayModelMatrices(data, model, estimation, misc)
            incTest=0;
        elseif  user_inputs==16
            %% Simulate data
            [data, model, estimation, misc]= ...
                piloteSimulateData(data, model, estimation, misc);
            incTest=0;
        elseif  user_inputs==17
            %% Export project in a configuration file
            pilotePrintConfigurationFile(data, model, estimation, misc)
            incTest=0;
        elseif  user_inputs==18
            %% Export current options in a configuration file format
            [misc] = printOptions(misc);
            incTest=0;
        else
            disp(' ')
            disp('      wrong input')
        end
        
    end
    
end

end