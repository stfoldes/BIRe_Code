
% Stephen Foldes (2012-03-07)
% folder_path = uigetdir
% 
% menu


folder_path = 'C:\CRX_rtMEG\Modules\Application\StimulusPresentation\stimuli\MappingVideos\';

prepend = '';
append = '_CRX'; % appends, only if string isn't already appended
file_type{1} = '.avi';
file_type{2} = '.wmv';

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
        
        if file_type_okay_flag>0
            already_appended_flag = 0;
            % if file name is big enough to check if already appended
            if length(current_file_name)>=length(append) && strcmp(current_file_name(end-length(append)+1:end),append)
                already_appended_flag = 1;
            end
            
            if ~already_appended_flag
                movefile([folder_path '\' current_file_name current_file_extention],[folder_path '\' current_file_name append current_file_extention]);
            end
        end
        
    end
    
end

