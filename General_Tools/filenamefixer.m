% If you named a bunch of files the wrong thing (like wrong subject id), this will fix that.
% Right now its only for the first part of the file name
%
% Stephen Foldes (2012-04-11)

folder_path = 'C:\Data\MEG\NS02\S02\CRX_data\';

str_fix = 'NS02'; % will replace first characters with this string;
num_char_to_remove = []; % number of characters to remove, defaults to size of str_fix

file_type{1} = '.mat';
% file_type{2} = '.wmv';

%% number of characters to remove, defaults to size of str_fix

if ~isdefined('num_char_to_remove')
    num_char_to_remove=size(str_fix,2);
end


%%
dir_info = dir(folder_path);
num_files = size(dir_info,1);

for ifile = 3:num_files
    
    if ~dir_info(ifile).isdir
        
        current_file_name = dir_info(ifile).name(1:end-4);
        current_file_extention = dir_info(ifile).name(end-3:end);
        
        % must be one the accepted file types
        file_type_okay_flag = 0;
        for ifile_type = 1:size(file_type,2)
            file_type_okay_flag=max(strcmp(current_file_extention,file_type{ifile_type}),file_type_okay_flag);
        end
        
        % correct file type, continue with rename
        if file_type_okay_flag>0            
            movefile([folder_path '\' current_file_name current_file_extention],[folder_path '\' str_fix current_file_name(1,num_char_to_remove+1:end) current_file_extention]);            
        end
    end
end

