%% Control script to run OpenBDLM demos
FilePath = fullfile(pwd, 'input_files');

%% List of input files to read
InputFileList = {fullfile(FilePath, 'input_INIT.m')};

for i=1:length(InputFileList)
    
    InputFile = InputFileList{i};
    
    %% Try to load answer from input file
    [Answers]= loadAnswersFromFile(InputFile);
        
    %% Run BDLM
    [data, model, estimation, misc] = OpenBDLM_main(Answers);
    
end