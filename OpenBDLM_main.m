%OPENBDLM_MAIN Process control for OpenBDLM  
%
%   SYNOPSIS:
%     OPENBDLM_MAIN
% 
%   INPUT:
%      N/A
% 
%   OUTPUT:
%      N/A
% 
%   DESCRIPTION:
%      OPENBDLM_MAIN process control for OpenBDLM.
%      OpenBDLM is an open-source software for performing structural
%      health monitoring using Bayesian Dynamic Linear Models
% 
%   EXAMPLES:
%      OPENBDLM
% 
%   EXTERNAL FUNCTIONS CALLED:
%      DataLoader, saveDataBinary, verificationDataStructure, SimulateData
%      ModelConfiguration, buildModel, displayModelMatrices	
%      modifyInitialHiddenStates, modifyTrainingPeriod, learnModelParameters,   
%      modifyModelParameters, chooseIsDataSimulation, chooseProjectName	
%      convertCell2Mat, convertMat2Cell, displayProjects, initializeProject
%      printConfigurationFile, printProjectDateCreation, readConfigurationFile	
%      saveProject, testFileExistence, computeInitialHiddenStates	
%      plotData, plotEstimations	
% 
%   SUBFUNCTIONS:
%      N/A
% 
%   See also 
%    DATALOADER, STATEESTIMATION, LEARNMODELPARAMETERS, SAVEDATABINARY, 
%    SIMULATEDATA, MODELCONFIGURATION, BUILDMODEL, DISPLAYMODELMATRICES 
%    MODIFYINITIALHIDDENSTATES, MODIFYTRAININGPERIOD,VERIFICATIONDATASTRUCTURE 
%    MODIFYMODELPARAMETERS, CHOOSEISDATASIMULATION, CHOOSEPROJECTNAME 
%    CONVERTCELL2MAT, CONVERTMAT2CELL, DISPLAYPROJECTS 
%    INITIALIZEPROJECT, PRINTCONFIGURATIONFILE, PRINTPROJECTDATECREATION 
%    READCONFIGURATIONFILE, SAVEPROJECT, TESTFILEEXISTENCE 
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
%       July 2, 2018
 
%--------------------BEGIN CODE ----------------------

% Set version
version = '1.1';

% define global variable for user's answers from input file
global isAnswersFromFile AnswersFromFile AnswersIndex

%Initialize random stream number based on clock
%RandStream.setGlobalStream(RandStream('mt19937ar','seed',861040000)); 

%Set default font type
set(0,'DefaultAxesFontname','Helvetica')                                
 %Set default font size
set(0,'DefaultAxesFontSize',20)     
%Set display format 
format short g                                                         
disp(' ')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])
disp(['///////////////////////////',...
    '///////////////OpenBDLM_V', version ,'\\\\\\\\\\\\\\\\\\\\\\\', ...
    '\\\\\\\\\\\\\\\\'])
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])
disp(' ')
disp(['            Structural Health Monitoring ',...
    'using Bayesian Dynamic Linear Models'])
disp(' ')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])
% disp(['Version: 2 beta (July 2018)'])
% disp(['Contact: James.A.Goulet@gmail.com'])
% disp(' ')

isAnswerCorrect = false;
while ~isAnswerCorrect
    
    disp(' ')
    disp('- Start a new project: ')
    disp(' ')
    fprintf('     %-3s\n', '*      Enter a configuration filename')
    fprintf('     %-3s\n', '0   -> Interactive tool')
    disp(' ')
    [ProjectInfo] = displayProjects('FilePath', 'saved_projects');
    
    if isAnswersFromFile
        UserChoice=eval(char(AnswersFromFile{1}(AnswersIndex)));
        disp(['     ', UserChoice])
    else
        UserChoice = input('     choice >> ');
    end
    
    if isempty(UserChoice)
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%')
        disp(' ')
        disp('Several choices are possible: ')
        disp(' ')
        disp(' Type a configuration file name.')
        disp([' Type 0 to start the interactive tool' , ...
            ' for creating a new project.'])
        disp(' Type # to load the  project number #.')
        disp(' Type ''delete_#'' to delete the project number #.')
         disp(' Type ''Quit'' to quit.')
        disp(' ')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%% > HELP < %%%%%%%%%%%%%%%%%%%%%%%')
        disp(' ')
        continue
    elseif ischar(UserChoice)
        AnswersIndex = AnswersIndex +1;
        
        if strncmp('delete_',UserChoice,7) % Delete a preloaded file
            UserChoice=char(UserChoice);
            UserChoice=str2double(UserChoice(1,8:end));
            
            if ~isempty(ProjectInfo)
                if UserChoice <= 0 || UserChoice > size(ProjectInfo,1)
                    disp(' ')
                    disp('     wrong input')
                    disp(' ')
                    continue
                end
            else
                disp(' ')
                disp('     wrong input')
                disp('     There is no saved project to delete.')
                disp(' ')
                continue
            end
            
            
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            disp('    Deleting data file')
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            disp([' Are you sure you want to ' ...
                'delete the following file ? (y/n)'])
            disp(' ')
            disp(['     -> ', ProjectInfo{UserChoice,3}])
            disp(' ')
            while(1)
                choice = input('     choice >> ','s');
                
                % Remove space and quotes
                choice=strrep(choice,'''','' ); % remove quotes
                choice=strrep(choice,'"','' ); % remove double quotes
                choic=strrep(choice, ' ','' ); % remove spaces
                
                if isempty(choice)
                    disp(' ')
                    disp('     wrong input --> please make a choice')
                    disp(' ')
                    continue
                elseif strcmp(choice,'y') || strcmp(choice,'yes') ||  ...
                        strcmp(choice,'Y') || strcmp(choice,'Yes')  || ...
                        strcmp(choice,'YES')
                    delete(ProjectInfo{UserChoice,3});
                    
                    ProjectInfo(UserChoice,:) = [];
                    FilePath = 'saved_projects';
                    ProjectsInfoFilename = 'ProjectsInfo.mat';
                    save(fullfile(FilePath, ProjectsInfoFilename), 'ProjectInfo' );
                    
                    disp(' ')
                    disp(' The file has been deleted')
                    disp(' ')
                    break
                elseif strcmp(choice,'n') || strcmp(choice,'no') ||  ...
                        strcmp(choice,'N') || strcmp(choice,'No')  || ...
                        strcmp(choice,'NO')
                    disp(' ')
                    disp(' The file was not deleted')
                    disp(' ')
                    break
                else
                    disp(' ')
                    disp('     wrong input')
                    disp(' ')
                    continue
                end
            end
            clear choice
            disp('    -> done.')
            disp(' ')
            disp('//////////////////////////////////////End')
            return
        
            
        elseif strncmpi('QUIT',UserChoice,4)
            disp(' ')
            disp('     See you soon !')
            return
                        
        else % Load a new file
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            disp('    Load result files ')
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            disp('    ...in progress')
            disp(' ')
            
            % Verify if the file exist
            [isFileExist]=testFileExistence(fullfile(pwd, ...
                '/config_files/', UserChoice), 'file');
            
            if ~isFileExist
                disp(' ')
                fprintf('     wrong input: File %s is not found.', UserChoice )
                disp(' ')
                continue
            end
            
            % Read the configuration file
            [data, model, estimation, misc, isValid] =  ...
                readConfigurationFile([cd '/config_files/' UserChoice], ...
                'isVerification', false);
            
            if ~isValid
                return
            end
            
            % Build model
            [model] = buildModel(data, model, misc);
            % Save project
            saveProject(data, model, estimation, misc, ...
                'FilePath','saved_projects')
            
            isAnswerCorrect = true;
        end
        
        
    elseif UserChoice == 0
        
        AnswersIndex = AnswersIndex +1;
        
        % Initialize project
        [data, model, estimation, misc] = initializeProject;
        % Choose project name
        [misc] =  chooseProjectName(misc, 'FilePath', 'saved_projects');
        % Choose if project or data simulation
        [misc] =  chooseIsDataSimulation(misc);
        % Store date creation
        [misc] =  printProjectDateCreation(misc);
        % Load data
        if ~misc.isDataSimulation
            % Load the data
            [data, dataFilename ] = DataLoader('FilePath', 'processed_data');
            misc.dataFilename = dataFilename;
        end
        
        % Configure the model
        [data, model, estimation, misc] = ...
            ModelConfiguration(data, model, estimation, misc);
        
        % Simulate data
        if misc.isDataSimulation
            [data, model, estimation, misc]= ...
                SimulateData(data, model, misc, 'isPlot', true);
            
            % Save data in binary format
            [dataFilename] = saveDataBinary(data, ...
                'FilePath', 'processed_data');
            misc.dataFilename = dataFilename;
            
            % Save data in CSV format
            saveDataCSV(data,'FilePath', 'raw_data')
            
            % Save project
            saveProject(data, model, estimation, misc, ...
                'FilePath','saved_projects')
        end
        
        % Create config file
        [configFilename] = ...
            printConfigurationFile(data, model, estimation, misc, ...
            'FilePath', 'config_files');
        
        isAnswerCorrect = true;
    else
        
        if ~isempty(ProjectInfo)
            if UserChoice <= 0 || UserChoice > size(ProjectInfo,1)
                disp(' ')
                disp('     wrong input')
                disp(' ')
                continue
            end
        else
            disp(' ')
            disp('     wrong input')
            disp('     There is no saved project to load.')
            disp(' ')
            continue
        end
        
        load(ProjectInfo{UserChoice,3});
        isAnswerCorrect = true;
    end
end

% List possible answers
PossibleAnswers = [1 2 3 11 12 13 14 15 16 17 21 31];

while(1)
    
    
    disp(' ')
    disp(['-----------------------------------------', ...
        '-----------------------------------------------------'])
    disp(' / Choose from')
    disp(['-----------------------------------------', ...
        '-----------------------------------------------------'])
    
    disp(' ')
    disp('     1  ->  Learn model parameters values')
    disp('     2  ->  Estimate initial hidden states values')
    disp('     3  ->  Estimate hidden states values')
    disp(' ')
    disp('     11 ->  Display and modify current model parameter values')
    disp('     12 ->  Display and modify current initial hidden states values')
    disp('     13 ->  Display and modify current training period')
    disp('     14 ->  Plots')
    disp('     15 ->  Display model matrices')
    disp('     16 ->  Simulate data')
    disp('     17 ->  Export project in configuration file format')
    disp(' ')
    disp('     21 ->  Version control')
    disp(' ')
    disp('     31 ->  Quit')
    disp(' ')
    
    if isAnswersFromFile
        user_inputs.inp_1=eval(char(AnswersFromFile{1}(AnswersIndex)));
        disp(['     ',num2str(user_inputs.inp_1)])
    else
        user_inputs.inp_1 = input('     choice >> ');
    end
    
    if ~any(ismember( PossibleAnswers, user_inputs.inp_1 ))
        disp(' ')
        disp('     wrong input')
        disp(' ')
        continue
        
    elseif user_inputs.inp_1 == 31
        disp(' ')
        disp(['-----------------------------------------', ...
            '-----------------------------------------------------'])
        disp([num2str(user_inputs.inp_1) '/ Quit'])
        disp(['-----------------------------------------', ...
            '-----------------------------------------------------'])
        disp('     See you soon !')
        return
    else
        AnswersIndex = AnswersIndex+1;
        
        if  user_inputs.inp_1==1
            disp(' ')
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            disp([num2str(user_inputs.inp_1) '/ Learn model parameters'])
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            
            isCorrectAnswer_2 =  false;
            while ~isCorrectAnswer_2
                disp(' ')
                disp('     1 ->  Newton-Raphson')
                disp('     2 ->  Stochastic Gradient Ascent')
                disp(' ')
                disp('     3 ->  Return to menu')
                disp(' ')
                
                if isAnswersFromFile
                    user_inputs.inp_2=eval(char(AnswersFromFile{1} ...
                        (AnswersIndex)));
                    disp(user_inputs.inp_2)
                else
                    user_inputs.inp_2 = input('     choice >> ');
                end
                
                if user_inputs.inp_2 == 1
                    
                    % Convert cell2mat
                    [data] = convertCell2Mat(data);
                    
                    % Learn model parameters
                    [data, model, estimation, misc]= ...
                        learnModelParameters(data, model, ...
                        estimation, misc, ...
                        'FilePath', 'saved_projects', ...
                        'Method', 'NR');
                                       
                    % Convert mat2cell
                    [data] = convertMat2Cell(data);
                    
                    % Save project
                    saveProject(data, model, estimation, misc, ...
                        'FilePath', 'saved_projects')
                    
                    
                    isCorrectAnswer_2 =  true;
                elseif user_inputs.inp_2 == 2
                    
                    % Convert cell2mat
                    [data] = convertCell2Mat(data);
                    
                    % Learn model parameters
                    [data, model, estimation, misc]= ...
                        learnModelParameters(data, model, ...
                        estimation, misc, ...
                        'FilePath', 'saved_projects', ...
                        'Method', 'SGA');
                    
                    % Convert mat2cell
                    [data] = convertMat2Cell(data);
                    
                    % Save project
                    saveProject(data, model, estimation, misc, ...
                        'FilePath', 'saved_projects')
                    
                    isCorrectAnswer_2 =  true;
                elseif user_inputs.inp_2 == 3
                    break
                else
                    disp(' ')
                    disp('      wrong input')
                    continue
                end
                
            end
                        
            AnswersIndex = AnswersIndex+1;
            
        elseif  user_inputs.inp_1==2
            disp(' ')
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            disp([num2str(user_inputs.inp_1) ...
                '/ Estimate initial hidden states x_0'])
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            
            disp(' ')
            
            % Convert cell2mat
            [data] = convertCell2Mat(data);
            
            % Compute initial hidden states values
            [model] = computeInitialHiddenStates(data, model, estimation, misc, ...
                'FilePath', 'saved_projects', 'Percent', 100);
            
            % Convert mat2cell
            [data] = convertMat2Cell(data);
            
            % Save project
            saveProject(data, model, estimation, misc, ...
                'FilePath', 'saved_projects')
            
        elseif  user_inputs.inp_1==3
            disp(' ')
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            disp([num2str(user_inputs.inp_1) '/ State estimation'])
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            isCorrectAnswer_2 =  false;
            while ~isCorrectAnswer_2
                disp(' ')
                disp('     1 ->  Filter')
                disp('     2 ->  Smoother')
                disp(' ')
                if isAnswersFromFile
                    user_inputs.inp_2=eval(char(AnswersFromFile{1}...
                        (AnswersIndex)));
                    disp(user_inputs.inp_2)
                else
                    user_inputs.inp_2 = input('     choice >> ');
                end
                
                if user_inputs.inp_2 == 1
                    isSmoother = false;
                    misc.isSmoother = isSmoother;
                    isCorrectAnswer_2 =  true;
                elseif user_inputs.inp_2 == 2
                    isSmoother = true;
                     misc.isSmoother = isSmoother;
                    isCorrectAnswer_2 =  true;
                else
                    disp(' ')
                    disp('      wrong input')
                    continue
                end
                
            end
            
            % Convert cell2mat
            [data] = convertCell2Mat(data);
            
            % save true hidden states values if they exist
            if isfield(estimation, 'ref')
                ref=estimation.ref;
            end
            
            % Filter / Smoother
            [estimation]=StateEstimation(data, model, misc, ...
                'isSmoother',isSmoother);
            
            % store back true hidden states values if they exist
            if exist('ref', 'var') == 1 
                estimation.ref=ref;
            end
                        
            % Convert mat2cell
            [data] = convertMat2Cell(data);
            
            % Save project
            saveProject(data, model, estimation, misc, ...
                'FilePath','saved_projects')
            
            % Plot estimations
            disp(' ')
            disp('     Plot hidden variables in progress...')
            plotEstimations(data, model, estimation, misc, ...
                'FilePath', 'figures', ...
                'isExportPDF', false, ...
                'isExportPNG', false, ...
                'isExportTEX', false)
            disp('    -> done.')
            clear smooth
            
            AnswersIndex = AnswersIndex+1;
            
        elseif  user_inputs.inp_1==11
            disp(' ')
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            disp([num2str(user_inputs.inp_1) ...
                '/ Modify current parameters values'])
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            
            [model] = modifyModelParameters(data, model, estimation, misc, ...
                'FilePath', 'saved_projects');
            
        elseif  user_inputs.inp_1==12
            disp(' ')
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            disp([num2str(user_inputs.inp_1) ...
                '/ Modify current initial x_0 values'])
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            
            [model] = modifyInitialHiddenStates(data, model, estimation, misc, ...
                'FilePath', 'saved_projects');
            
        elseif  user_inputs.inp_1==13
            disp(' ')
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            disp([num2str(user_inputs.inp_1) ...
                '/ Modify training period'])
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            
            [misc] = modifyTrainingPeriod(data, model, estimation, misc, ...
                'FilePath', 'saved_projects');
            
            
        elseif  user_inputs.inp_1==14
            disp(' ')
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            disp([num2str(user_inputs.inp_1) '/ Plot'])
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            
            
            isCorrectAnswer_2 =  false;
            while ~isCorrectAnswer_2
                disp(' ')
                disp('     1 ->  Plot data')
                disp('     2 ->  Plot hidden states')
                disp(' ')
                disp('     3 ->  Return to menu')
                disp(' ')
                
                if isAnswersFromFile
                    user_inputs.inp_2=eval(char(AnswersFromFile{1} ...
                        (AnswersIndex)));
                    disp(user_inputs.inp_2)
                else
                    user_inputs.inp_2 = input('     choice >> ');
                end
                
                if user_inputs.inp_2 == 1
                    
                    [isValid] = verificationDataStructure(data);
                    
                    if isValid
                        plotData(data, model, estimation, misc, ...
                            'FilePath', 'figures', ...
                            'isPdf', false, ...
                            'isSaveFigure', false)
                        isCorrectAnswer_2 =  true;
                    else
                        continue
                    end
                    
                elseif user_inputs.inp_2 == 2
                    plotEstimations(data, model, estimation, misc, ...
                        'FilePath', 'figures', ...
                        'isExportTEX', false, ...
                        'isExportPNG', false, ...
                        'isExportPDF', false);
                    isCorrectAnswer_2 =  true;
                    
                elseif user_inputs.inp_2 == 3
                    break
                else
                    disp(' ')
                    disp('      wrong input')
                    continue
                end
                
            end
            
            AnswersIndex = AnswersIndex+1;
            
        elseif  user_inputs.inp_1==15
            disp(' ')
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            disp([num2str(user_inputs.inp_1) '/ Display model matrices'])
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            disp(' ')
            isCorrectAnswer_2 =  false;
            disp('Timestamp index ? ')
            while ~isCorrectAnswer_2
                user_inputs.inp_2 = input('     choice >> ');
                if isempty(user_inputs.inp_2)
                    disp(' ')
                    disp(['%%%%%%%%%%%%%%%%%%%%%%%%% ' ...
                        ' > HELP < %%%%%%%%%%%%%%%%%%%%%%%'])
                    disp(' ')
                    disp('Choose timestamp index. ')
                    disp('Timestamp index should be an integer value.')
                    disp(' ')
                    continue
                elseif ~any(rem(user_inputs.inp_2,1)) && ...
                        (user_inputs.inp_2 < length(data.timestamps{1})) && ...
                        (user_inputs.inp_2 ~= 0)
                    TimestampIndex = user_inputs.inp_2;
                    displayModelMatrices(model, data, estimation, ...
                        misc, TimestampIndex)
                    isCorrectAnswer_2 =  true;
                else
                    disp(' ')
                    disp('Wrong input.')
                    disp(' ')
                    continue
                end
                disp(' ')
            end
            
            
        elseif  user_inputs.inp_1==16
            disp(' ')
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            disp([num2str(user_inputs.inp_1) '/ Simulate data'])
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            disp(' ')
            [data, model, estimation, misc]= ...
                SimulateData(data, model, misc, 'isPlot', true);
            
            % Save simulated data
            [dataFilename] = saveDataBinary(data, ...
                'Filepath', 'processed_data');
            misc.dataFilename = dataFilename;
            % Store date creation
            [misc] =  printProjectDateCreation(misc);
            % Save project
            saveProject(data, model, estimation, misc, ...
                'FilePath', 'saved_projects')
            
            
            
        elseif  user_inputs.inp_1==17
            disp(' ')
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            disp([num2str(user_inputs.inp_1) '/ Export project in ' ...
                'configuration file format'])
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            disp(' ')
            [configFilename] = printConfigurationFile(data, model, ...
                estimation, misc, 'FilePath', 'config_files');
            
            
            
        elseif  user_inputs.inp_1==21
            disp(' ')
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            disp([num2str(user_inputs.inp_1) '/ Version control'])
            disp(['-----------------------------------------', ...
                '-----------------------------------------------------'])
            disp(' ')
            disp('     Coming soon... ')
            disp(' ')
            
        end
        
    end
    
end