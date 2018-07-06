%% Live demo 4
clear -global isAnswersFromFile AnswersFromFile AnswersIndex

%% Define global variables
global isAnswersFromFile AnswersFromFile AnswersIndex

FilePath = fullfile(pwd, 'input_files');

%% List of input files to read
InputFileList = {fullfile(FilePath, 'input_1.txt')} ;
%, ...
%    fullfile(FilePath, 'input_2.txt'), ...
%    fullfile(FilePath, 'input_3.txt') };

for i=1:length(InputFileList)
    
    InputFile = InputFileList{i};
    
    %% Try to load answer from input file
    [isAnswersFromFile, AnswersFromFile, AnswersIndex]= ...
        loadAnswersFromFile(InputFile);
        
    %% Run BDLM
    run('OpenBDLM_main.m')
    
end

clear -global isAnswersFromFile AnswersFromFile AnswersIndex