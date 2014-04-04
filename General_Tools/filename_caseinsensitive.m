% real_file_name = filename_caseinsensitive(file_name, file_path)
% Stephen Foldes [2012-09-11]
%
% Looks in file path for the given file name (ext not necessary) and returns the file name if it has a different case
% e.g. you think file = NC01S02R01, though it is really nc01S02R01

function real_file_name = filename_caseinsensitive(file_name, file_path)
    if iscell(file_name)
        file_name_str = char(file_name{1});
    else
        file_name_str = file_name;
    end

    all_file_info = dir(file_path);
    
    for ifile = 3:length(all_file_info)
        [~, current_file_name]= fileparts(all_file_info(ifile).name);
        if strcmpi(current_file_name,file_name_str)
            real_file_name = current_file_name;
            return
        end
    end
    
    
    