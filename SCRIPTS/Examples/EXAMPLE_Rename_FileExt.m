% Script to rename file extensions
% 2013-07-13 Foldes
new_ext = '.png';
file_names = find_Files('*', 'C:\Users\SF\Dropbox\Code\figs\', 1);

for iname = 1:length(file_names)
    clear current_file_name current_file_path current_file_ext
    [current_file_path,current_file_name,current_file_ext]=fileparts(file_names{iname});
    list_file_types{iname} = current_file_ext;

end
unique(list_file_types)

for iname = 1:length(file_names)
    clear current_file_name current_file_path current_file_ext
    [current_file_path,current_file_name,current_file_ext]=fileparts(file_names{iname});
    
    if ~strcmpi(current_file_ext,'.png') && ~strcmpi(current_file_ext,'.fig')
        movefile([current_file_path filesep current_file_name current_file_ext],[current_file_path filesep current_file_name current_file_ext new_ext])
    end
end