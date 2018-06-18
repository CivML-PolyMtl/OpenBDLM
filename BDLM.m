%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program : BDLM
% Description : Process control for Bayesian Dynamic Linear model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear
% clc

% define global variable for user's answers from input file
global isAnswersFromFile AnswersFromFile AnswersIndex


distribution='public';                                                %Distribution type (public/research)
%RandStream.setGlobalStream(RandStream('mt19937ar','seed',861040000));  %Initialize random stream number based on clock
set(0,'DefaultAxesFontname','Helvetica')                                %Set default font type
set(0,'DefaultAxesFontSize',20)                                         %Set default font size
format short g                                                          %Set display format
disp(' ')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])
disp('Bayesian Dynamic Linear Model')
disp('  Version: 2.2 (Sept 2017)')
disp('  Contact: James.A.Goulet@gmail.com')
disp(' ')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])
disp('////////////////////////Start BDLM\\\\\\\\\\\\\\\\\\\\\\')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])
% disp(' ')
% disp('Start a new project: ')
% disp(' ')
% fprintf('     %-3s\n', '*      Enter a configuration filename')
% fprintf('     %-3s\n', '0   -> Interactive tool')
% disp(' ')
% [ProjectInfo] = displayProjects('FilePath', 'saved_projects');

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
            [data, dataFilename ] = DataLoader('FilePath', 'processed_data', ...
                'NaNThreshold', 0, ...
                'Tolerance', 10E-6, ...
                'isOverlapDetection', false);
            misc.dataFilename = dataFilename;
        end
        
        % Configure the model
        [data, model, estimation, misc] = ...
            ModelConfiguration(data, model, estimation, misc);
        
        % Simulate data
        if misc.isDataSimulation
            [data, model, estimation, misc]= ...
                SimulateData(data, model, misc, 'isPlot', true);
            
            [dataFilename] = saveDataBinary(data, ...
                'FilePath', 'processed_data');
            misc.dataFilename = dataFilename;
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

disp(' ')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])
disp(' / Choose from')
disp(['-----------------------------------------', ...
    '-----------------------------------------------------'])

disp(' ')
disp('     1  ->  Learn model parameters')
disp('     2  ->  Estimate initial hidden states x_0')
disp('     3  ->  Estimate hidden states x_t')
disp(' ')
disp('     11 ->  Modify current parameter values')
disp('     12 ->  Modify current initial x_0 values')
disp('     13 ->  Modify current training period')
disp('     14 ->  Plots')
disp('     15 ->  Display model matrices')
disp('     16 ->  Simulate data')
disp('     17 ->  Export project in configuration file format')
disp(' ')
disp('     21 ->  Version control')
disp(' ')
disp('     31 ->  Quit')
disp(' ')

% List possible answers
PossibleAnswers = [1 2 3 11 12 13 14 15 16 17 21 31];

isCorrectAnswer_1 =  false;
while ~isCorrectAnswer_1
    
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
    else
        isCorrectAnswer_1 = true;
    end
    
end
AnswersIndex = AnswersIndex +1;

if  user_inputs.inp_1==1
    disp(' ')
    disp(['-----------------------------------------', ...
        '-----------------------------------------------------'])
    disp([num2str(user_inputs.inp_1) '/ Learn model parameters'])
    disp(['-----------------------------------------', ...
        '-----------------------------------------------------'])
    
    % Convert cell2mat
    [data] = convertCell2Mat(data);
    
    isCorrectAnswer_2 =  false;
    while ~isCorrectAnswer_2
        disp(' ')
        disp('     1 ->  Newton-Raphson')
        disp('     2 ->  Stochastic Gradient Ascent')
        disp(' ')
        if isAnswersFromFile
            user_inputs.inp_2=eval(char(AnswersFromFile{1}(AnswersIndex)));
            disp(user_inputs.inp_2)
        else
            user_inputs.inp_2 = input('     choice >> ');
        end
        
        if user_inputs.inp_2 == 1
            [data, model, estimation, misc]= ...
                learnModelParameters(data, model, ...
                estimation, misc, ...
                'FilePath', 'saved_projects', ...
                'Method', 'NR');
            isCorrectAnswer_2 =  true;
        elseif user_inputs.inp_2 == 2
            [data, model, estimation, misc]= ...
                learnModelParameters(data, model, ...
                estimation, misc, ...
                'FilePath', 'saved_projects', ...
                'Method', 'SGA');
            isCorrectAnswer_2 =  true;
        else
            disp(' ')
            disp('      wrong input')
            continue
        end
        
    end
    
    % Convert mat2cell
    [data] = convertMat2Cell(data);
    
    % Save project
    saveProject(data, model, estimation, misc, ...
        'FilePath', 'saved_projects')
    
    
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
        'FilePath', 'saved_projects', 'Percent', 25);
    
    % Convert mat2cell
    [data] = convertMat2Cell(data);
    
    % Save project
    saveProject(data, model, estimation, misc, ...
        'FilePath', 'saved_projects')
    
    isCorrectAnswer_1 = true;
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
            user_inputs.inp_2=eval(char(AnswersFromFile{1}(AnswersIndex)));
            disp(user_inputs.inp_2)
        else
            user_inputs.inp_2 = input('     choice >> ');
        end
        
        if user_inputs.inp_2 == 1
            misc.isSmoother = false;
            smooth = 0;
            isCorrectAnswer_2 =  true;
        elseif user_inputs.inp_2 == 2
            misc.isSmoother = true;
            smooth=1;
            isCorrectAnswer_2 =  true;
        else
            disp(' ')
            disp('      wrong input')
            continue
        end
        
    end
    
    % Convert cell2mat
    [data] = convertCell2Mat(data);
    
    % Filter / Smoother
    [estimation]=state_estimation(data, model, estimation, misc, ...
        'smooth',smooth);
    
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
    isCorrectAnswer_1 = true;
    
    AnswersIndex = AnswersIndex+1;
    
elseif  user_inputs.inp_1==11
    disp(' ')
    disp(['-----------------------------------------', ...
        '-----------------------------------------------------'])
    disp([num2str(user_inputs.inp_1) ...
        '/ Modify current parameters values'])
    disp(['-----------------------------------------', ...
        '-----------------------------------------------------'])
    
    modifyModelParameters(data, model, estimation, misc, ...
        'FilePath', 'saved_projects');
    isCorrectAnswer_1 = true;
    
elseif  user_inputs.inp_1==12
    disp(' ')
    disp(['-----------------------------------------', ...
        '-----------------------------------------------------'])
    disp([num2str(user_inputs.inp_1) ...
        '/ Modify current initial x_0 values'])
    disp(['-----------------------------------------', ...
        '-----------------------------------------------------'])
    
    modifyInitialHiddenStates(data, model, estimation, misc, ...
        'FilePath', 'saved_projects');
    isCorrectAnswer_1 = true;
    
elseif  user_inputs.inp_1==13
    disp(' ')
    disp(['-----------------------------------------', ...
        '-----------------------------------------------------'])
    disp([num2str(user_inputs.inp_1) ...
        '/ Modify training period'])
    disp(['-----------------------------------------', ...
        '-----------------------------------------------------'])
    
    modifyTrainingPeriod(data, model, estimation, misc, ...
        'FilePath', 'saved_projects');
    
    isCorrectAnswer_1 = true;
    
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
        user_inputs.inp_2 = input('     choice >> ');
        
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
        else
            disp(' ')
            disp('      wrong input')
            continue
        end
        
    end
    
    isCorrectAnswer_1 = true;
    
    
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
    isCorrectAnswer_1 = true;
    
    
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
    
    isCorrectAnswer_1 = true;
    
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
    isCorrectAnswer_1 = true;
    
    
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
    isCorrectAnswer_1 = true;
    
elseif  user_inputs.inp_1==31
    disp(' ')
    disp(['-----------------------------------------', ...
        '-----------------------------------------------------'])
    disp([num2str(user_inputs.inp_1) '/ Quit'])
    disp(['-----------------------------------------', ...
        '-----------------------------------------------------'])
    disp('     See you soon !')
    return
    
end

%     else
%         disp(' ')
%         disp('     Wrong input. ')
%         disp(' ')
%         continue
%     end
%end