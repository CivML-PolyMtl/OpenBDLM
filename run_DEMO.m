%% Control script to run demos

clear -global isAnswersFromFile AnswersFromFile AnswersIndex

% Clean directory tree
Clean

%% Define global variables
global isAnswersFromFile AnswersFromFile AnswersIndex

FilePath = fullfile(pwd, 'input_files');

%% List of input files to read
InputFileList = {fullfile(FilePath, 'input_DEMO1.m'), ...
    fullfile(FilePath, 'input_DEMO2.m'), ...
    fullfile(FilePath, 'input_DEMO3.m'), ...
    fullfile(FilePath, 'input_DEMO4.m'), ...
    } ;

for i=1:length(InputFileList)
    
    InputFile = InputFileList{i};
    
    %% Try to load answer from input file
    [isAnswersFromFile, AnswersFromFile, AnswersIndex]= ...
        loadAnswersFromFile(InputFile);
        
    %% Run BDLM
    run('OpenBDLM_main.m')
    
end

clear -global isAnswersFromFile AnswersFromFile AnswersIndex