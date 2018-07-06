
dat=load('LaTuque_processed_data.mat');

fields=fieldnames(dat);

for i=1:numel(fields)

npts=length(dat.(fields{i}){1});
    
if i <= 3
    instrument='PEN';
    axis= 'X';
else
    instrument='THE';
    axis= 'N/A'; 
end

date_string=datestr(dat.(fields{i}){1}(1,1),'yyyy-mm-dd HH:MM');

col_1=repmat(strcat('''',{fields{i}},''''),npts,1);

col_2=repmat(strcat('''',{instrument}, ''''),npts,1);

col_3=repmat(strcat('''',{'LTU'}, ''''),npts,1);

col_4=repmat(strcat('''',{'LTUBAR'}, ''''),npts,1);

col_5=repmat(strcat('''',{axis}, '''') ,npts,1);

col_6_1=repmat(strcat('''',{date_string},''''),1,1);
col_6_2=repmat(strcat('''',{'N/A'}, ''''),npts-1,1);
col_6=[ col_6_1;  col_6_2];

col_7=dat.(fields{i}){1}(:,1);

col_8=dat.(fields{i}){1}(:,2);

col_9=NaN(npts,1);

col_10=repmat(strcat('''',{'N/A'}, ''''),npts,1);

col_11=repmat(strcat('''',{'N/A'}, ''''),npts,1);

col_12=repmat(strcat('''',{'N/A'}, ''''),npts,1);

% 
 T = table(col_1,col_2,col_3,col_4, col_5, col_6, col_7, col_8, col_9, col_10, col_11, col_12);
% 
% 
 writetable(T, [fields{i} '.csv'])
 
end