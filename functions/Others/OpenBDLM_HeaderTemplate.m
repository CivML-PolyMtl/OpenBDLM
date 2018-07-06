function OpenBDLM_HeaderTemplate(name)
%OPENBDLM_HEADERTEMPLATE Create header template for OpenBDLM Matlab functions
%
%   SYNOPSIS:
%     OPENBDLM_HEADERTEMPLATE(name)
%
%   INPUT:
%      name - name of the Matlab m-file (i.e name of the Matlab function)
%
%   OUTPUT:
%      Create a Matlab m-file named 'name'.m in current directory that
%      contains the template
%
%   DESCRIPTION:
%      OPENBDLM_HEADERTEMPLATE creates the header template for OpenBDLM
%      Matlab functions.
%      The created header respect Matlab convention for generating help.
%
%   EXAMPLES:
%    OPENBDLM_HEADERTEMPLATE('myfunction') will create a Matlab m-file named
%    'myfunction.m' in current directory with the template
%
%   EXTERNAL FUNCTIONS CALLED:
%       N/A
%
%   SUBFUNCTIONS:
%       N/A
%   
%   See also

%   AUTHORS:
%      Ianis Gaudot
%      Email: <ianis.gaudot@polymtl.ca>
%
%   REFERENCES:
%       N/A
%
%   DATE CREATED:
%       March 20, 2018
%
%   DATE LAST UPDATE:
%       July 2, 2018

%--------------------BEGIN CODE ----------------------

% Get filename without extension
name_split = strsplit(name,'.');

% Build full filename
name=[name_split{1} , '.m'];

% Test existence of the file
if exist(name, 'file') == 2
    disp(' ')
    fprintf('Warning: %s already exists. ', name)
    while 1
        prompt = 'Do you want to overwrite? Y/N: ';
        user_choice = input(prompt, 's');
        switch user_choice
            case {'Y' 'YES' 'yes' 'y' 'Yes'}
                break
            case {'N' 'NO' 'no' 'n' 'No'}
                disp('Quit !')
                return
            case ''
                disp(' ')
                disp('Make a choice, either ''yes'' or ''no''')
                disp(' ')
                continue
            otherwise
                disp('Wrong input')
                continue
        end
    end
end

% Open file
fid=fopen(name, 'w');

fprintf(fid, ['function [output_1,output_2, output_3]', ...
    '=%s(input_1,input_2)\n'],name_split{1});
fprintf(fid, ['%%%s One line description of what the function ', ...
    'or script performs (H1 line)\n'], upper(name_split{1}));
fprintf(fid, '%%\n');
fprintf(fid, '%%   SYNOPSIS:\n');
fprintf(fid, ['%%     [output_1,output_2, output_3]', ...
    '=%s(input_1,input_2)\n'], upper(name_split{1}));
fprintf(fid, '%% \n');
fprintf(fid, '%%   INPUT:\n');
fprintf(fid, '%%      input_1 - Description\n');
fprintf(fid, '%%      input_2 - Description\n');
fprintf(fid, '%% \n');
fprintf(fid, '%%   OUTPUT:\n');
fprintf(fid, '%%      output_1 - Description\n');
fprintf(fid, '%%      output_2 - Description\n');
fprintf(fid, '%%      output_3 - Description\n');
fprintf(fid, '%% \n');
fprintf(fid, '%%   DESCRIPTION:\n');
fprintf(fid, ['%%      Description with %s in upper case when ', ...
    'mentionned\n'], upper(name_split{1}));
fprintf(fid, ['%%      Description with %s in upper case when ', ...
    'mentionned\n'], upper(name_split{1}));
fprintf(fid, ['%%      Description with %s in upper case when ', ...
    'mentionned\n'], upper(name_split{1}));
fprintf(fid, '%% \n');
fprintf(fid, '%%   EXAMPLES:\n');
fprintf(fid, '%%      Line 1 of example\n');
fprintf(fid, '%%      Line 2 of example\n');
fprintf(fid, '%%      Line 3 of example\n');
fprintf(fid, '%% \n');
fprintf(fid, '%%   EXTERNAL FUNCTIONS CALLED:\n');
fprintf(fid, '%%      %s\n', [upper(name_split{1}), '_1']);
fprintf(fid, '%%      %s\n', [upper(name_split{1}), '_2']);
fprintf(fid, '%% \n');
fprintf(fid, '%%   SUBFUNCTIONS:\n');
fprintf(fid, '%%      Name of subfunction_1\n');
fprintf(fid, '%%      Name of subfunction_1\n');
fprintf(fid, '%% \n');
fprintf(fid, '%%   See also %s %s\n', [upper(name_split{1}), '_1']' , ...
    [upper(name_split{1}), '_2']  );
fprintf(fid, ' \n');
fprintf(fid, '%%   AUTHORS: \n');
fprintf(fid, '%%       Luong Ha Nguyen, Ianis Gaudot, James-A Goulet,\n');
fprintf(fid, '%% \n');
fprintf(fid, '%%      Email: <james.goulet@polymtl.ca>\n');
fprintf(fid, ['%%      Website:' , ...
    ' <http://www.polymtl.ca/expertises/goulet-james-alexandre>\n']);
fprintf(fid, '%% \n');
fprintf(fid, '%%   REFERENCES: \n');
fprintf(fid, '%%       [1]  Goulet, J.-A., 2017, Bayesian dynamic linear');
fprintf(fid, ' models for \n%%       structural health monitoring,\n');
fprintf(fid, '%%       Structural Control and Health Monitoring, ');
fprintf(fid, 'Vol. 24, Issue 12.\n');
fprintf(fid, '%% \n');
fprintf(fid, '%%       [2]  Goulet, J.-A., Koo K., 2017, Empirical');
fprintf(fid, ' validation of Bayesian\n');
fprintf(fid, '%%       dynamic linear models ');
fprintf(fid, 'in the context of structural health monitoring, \n');
fprintf(fid, '%%       Journal of Bridge Engineering, Vol.23, Issue 2.\n');
fprintf(fid, '%% \n');
fprintf(fid, '%%       [3]  Nguyen, L. H., Goulet J.-A., 2018, Anomaly ');
fprintf(fid, 'detection with the \n%%       Switching Kalman Filter' );
fprintf(fid, ' for structural health monitoring, \n');
fprintf(fid, '%%       Structural Control and Health');
fprintf(fid, ' Monitoring, Vol. 25, Issue 4.\n');
fprintf(fid, '%% \n');
fprintf(fid, '%%   MATLAB VERSION:\n');
fprintf(fid, '%%      Tested on %s\n', version);
fprintf(fid, '%% \n');
fprintf(fid, '%%   DATE CREATED:\n');
fprintf(fid, '%%      %s\n', datetime('now','Format',' MMMM d, y'));
fprintf(fid, '%% \n');
fprintf(fid, '%%   DATE LAST UPDATE:\n');
fprintf(fid, '%%      %s\n', datetime('now','Format',' MMMM d, y'));
fprintf(fid, ' \n');
fprintf(fid, '%%--------------------BEGIN CODE ---------------------- \n');
fprintf(fid, ' \n');
fprintf(fid, ' \n');
fprintf(fid, ' \n');
fprintf(fid, '%%   Enter the content of the Matlab function here      \n');
fprintf(fid, ' \n');
fprintf(fid, ' \n');
fprintf(fid, ' \n');
fprintf(fid, '%%--------------------END CODE ------------------------ \n');
fprintf(fid, 'end\n');
fclose(fid);

disp(' ')
fprintf('The template for function %s has been created in %s.\n', ...
    name_split{1}, name)
disp('Done !')
%--------------------END CODE ------------------------
end

