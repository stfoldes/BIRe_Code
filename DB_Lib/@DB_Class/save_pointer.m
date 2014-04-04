function [obj,save_flag] = save_pointer(obj,pointer_data,pointer_name,save_type,overwrite_flag)
% Saves variables out to file and records the name in a pointer
% Features:
%         Checks if data already exists
%         Tries to move data to server
%         Addes pointer to obj
%
% Uses standard DB info
% Currently only works for one variable
%
% INPUTS:
%     pointer_data: the variable to save
%     pointer_name: string of pointer, must exist in DB object -- obj.'pointer_name'
%         Will automatically remove 'Pointer_' characters before, and including, 'Pointer_' (if present)
%     save_type:
%         str2txt | txt --> saves a list of strigs to as a txt file (for bad channel list)
%         struct2txt --> save structure as a txt file (see Write_StandardStruct2TXT)
%         mat --> save as .mat (really this can be anything, its the default)
%     overwrite_flag: 1=overwrite
%
% Foldes 2013-03-05
% UPDATES:
% 2013-04-16 Foldes: save_type changed to save_type, added bad channel file writing
% 2013-04-24 Foldes: Now works with sub-objects
% 2013-05-22 Foldes: added Overwrite option
% 2013-06-10 Foles: SMALL, says date for overwrite, outputs save flag
% 2013-10-07 Foldes: Metadata-->DB, renamed from Metadata_Save_Pointer_Data

global MY_PATHS

if ~exist('overwrite_flag') || isempty(overwrite_flag)
    overwrite_flag = 0;
end

% read in the variables name from the previous workspace
pointer_data_var_name = inputname(2); 
eval([pointer_data_var_name '= pointer_data;'])

% Remove '*Pointer_' from name
look_up_str = 'Pointer_';
name_start_char_num=(strfind(pointer_name,look_up_str))+length(look_up_str);
if ~isempty(name_start_char_num)
    pointer_name_short=pointer_name(name_start_char_num:end);
else % keep old name if you cant find Pointer_
    pointer_name_short=pointer_name;
end

% disp(['SAVING Pointer: ' pointer_name_short])

switch lower(save_type)
    case {'struct2txt','str2txt','txt','.txt'}
        save_ext_type = '.txt';
    case {'mat','.mat'}
        save_ext_type = '.mat';
end

save_base_name = [obj.entry_id '_' pointer_name_short save_ext_type];
local_fullfile_name = [obj.file_path('local') filesep save_base_name];
% 
% save_flag = 1;
% Check if file already exists
% if exist(local_fullfile_name)==2 && (overwrite_flag~=1) % file exists
%     file_date = date_file_timestamp(local_fullfile_name);
%     ButtonName=questdlg_wPosition([],['File already exists from **' file_date ' **, OVERWRITE?'],'OVERWRITE?','yes','no','yes');
%     if strcmp(ButtonName,'no')
%         disp('NO FILE MADE')
%         save_flag = 0;
%     end
% end
save_flag = 1;
if overwrite_flag == 0
    save_flag = ~pointer_check(obj,pointer_name,'location_name','local','dialog_flag',1);
end

if save_flag
    
    switch lower(save_type)
        case {'struct2txt'} % this is like a DB file
            Write_StandardStruct2TXT(pointer_data,local_fullfile_name);
            
        case {'str2txt','txt','.txt'}
            % Opens the text doucment for OVER-writing
            file_id = fopen(local_fullfile_name,'w');
            
            for istr =1:size(pointer_data,1)
                fprintf(file_id,'%s ', num2str( pointer_data(istr,:) ));
            end
            fclose(file_id);
            disp(['***WROTE TXT FILE: ' local_fullfile_name '***'])
            
        case {'mat','.mat'}
            eval(['save(local_fullfile_name,''' pointer_data_var_name ''');'])
            disp(['***WROTE FILE: ' save_base_name '***'])
    end
    DB_Move_Pointer_File_To_Server(obj,local_fullfile_name,overwrite_flag);
    eval(['obj.' pointer_name ' = save_base_name;'])
else
    warning(['Pointer NOT saved: ' pointer_name_short ' --> ' save_base_name])
end



function DB_Move_Pointer_File_To_Server(obj,original_file,overwrite_flag)
% Simply tries to move a file from a local place to a server location
% Really this is just a space-saver.
%
% Foldes 2013-03-05

if ~exist('overwrite_flag') || isempty(overwrite_flag)
    overwrite_flag = 0;
end

[original_file_path, fname, extension]=fileparts(original_file);
original_file_name=[fname extension];

server_file_path = [obj.file_path('server')];

if strcmp(original_file_path,server_file_path)
    disp('Local path and server path are the same; no need to move files')
    return
end

% attempt to move bad chan file to server
save_to_server_flag = 1;
if ~strcmp(server_file_path,original_file_path) % don't save to server if server == local
    if exist([server_file_path filesep original_file_name])==2  && (overwrite_flag~=1) % file exists
        ButtonName=questdlg_wPosition([],'File already exists on Server, over write?','Over Write on Server?','yes','no','yes');
        if strcmp(ButtonName,'no')
            disp('NO FILE MOVED TO SERVER')
            save_to_server_flag = 0;
        end
    end
    if save_to_server_flag
        try
            disp(['--> Moving to the Server [' original_file_name ']'])
            copyfile(original_file,[server_file_path filesep original_file_name]);
        catch
            warning(['-X-> FAILED Move to the Server - Move Manually to Server [' original_file_name ']'])
        end
    end
end % server == local
