function [file_date, file_date_num]= date_file_timestamp(file)

% Returns timestamp (str) of when a file was modified
% 2013-06-10 Foldes
% UPDATES
% 2013-08-06 Foldes: Now returns datenum also

file_info=dir(file);
if ~isempty(file_info)
    file_date_num = file_info.datenum;
    
    file_date = datestr(file_info.datenum,'yyyy-mm-dd');
    
else
    file_date_num = [];
    file_date = [];
end