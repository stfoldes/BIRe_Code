% 
% Writes event files for programs like Brainstorm or MNE
%
% Stephen Foldes (2012-07-06)
% UPDATES:
% 2012-11-14 Foldes: Now writes more information for multiple marker types at once.

function Export_Eve_File(sample_list,file_suffix,Extract)

%% defaults
if ~exist('file_suffix') || isempty(file_suffix)
   file_suffix = ''; 
end

try
    sample_rate = Extract.data_rate;
catch
    sample_rate = 1000;
end


%% write events to file
file_name_to_write = [Extract.file_path Extract.file_name{1} '_' file_suffix '.eve'];
fid = fopen(file_name_to_write,'w');
for ievent = 1:length(sample_list)
    fprintf(fid,' %i %f 0 1 \n',round(sample_list(ievent)*sample_rate),sample_list(ievent));
    
end
fclose(fid);

disp(['Wrote File: ' file_name_to_write])
