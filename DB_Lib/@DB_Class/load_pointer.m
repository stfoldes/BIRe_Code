function output = load_pointer(obj,pointer_name)
% Loads data in a pointer file 
%
% A varible is loaded into the *previous* workspace (e.g. .mat files) 
%   In this case, output = the variable's name
%
% If the pointer file is a .txt file, then output = the loaded data
%
% It tries getting from local before server and checks dates.
% Pointer of .mat type can ONLY contain 1 variable (for now)
%
% pointer_name = 'Preproc.Pointer_processed_data_for_events'
% pointer_var_name = DB_entry.load_pointer(pointer_name);
%
% 2013-06-10 Foldes
% UPDATES:
% 2013-08-16 Foldes: Cleaned up, checks date
% 2013-09-15 Foldes: evalin workspace changed from 'base' to 'caller'
% 2013-10-03 Foldes: Metadata-->DB, paths now global
% 2013-10-05 Foldes: .txt files are loaded directly into the output

global MY_PATHS

% check pointer exists
try
    eval(['pointer_link = obj.' pointer_name ';'])
catch
    error([pointer_name ' is not a valid property; you misspeled it'])
end

complete_flag=0;
txt_flag = 0;

% Try to load Events
if ~isempty(pointer_link)
    if strcmpi(pointer_link(end-3:end),'.txt')
        %     pointer_link = pointer_link(1:end-5);
        txt_flag = 1;
    end

    % Make full file paths
    local_file = [obj.file_path('local') filesep pointer_link];
    server_file = [obj.file_path('server') filesep pointer_link];

    
    % File is on server AND local
    if exist(local_file)==2 && exist(server_file)==2
        
        if date_subtraction(date_file_timestamp(server_file),date_file_timestamp(local_file))>0
            warning('SERVER pointer file is fresher than LOCAL file');
            load_type = 'server';
        elseif date_subtraction(date_file_timestamp(server_file),date_file_timestamp(local_file))<0
            warning('LOCAL pointer file is fresher than SERVER file');
            load_type = 'local';
        else % SHOULD BE SAME AGE ***THIS IS THE OPTION THAT SHOULD HAPPEN***
            load_type = 'local';
        end
        
    % Only local is found    
    elseif exist(local_file)==2
        load_type = 'local';
        warning('Pointer file is NOT on SERVER');
    % Only server is found
    elseif exist(server_file)==2
        load_type = 'server';
        warning('Pointer file is NOT LOCAL');
    else
        error('Cant Load pointer @DB_Load_Pointer_Data')
    end
    
    switch load_type
        case 'local'
            pointer_full_path = local_file;
        case 'server'
            pointer_full_path = server_file;
    end
    
    %     pointer_date = date_file_timestamp(pointer_full_path);
    %     if questdlg_YesNo_logic(['Events file already exists from ** ' pointer_date ' **, use it?'],'EVENTS?')
    disp(['Loaded ' pointer_name])
    if txt_flag == 1
        output = load(pointer_full_path);
    else
        % Get info on the varible that is being loaded
        vars = whos('-file', pointer_full_path);
        output = vars(1).name; % specifically for 1 variable        
        evalin('caller',['load(''' pointer_full_path ''');'])
    end
    %complete_flag=1;
    %     end
else
    disp(['*NOT* Loaded ' pointer_name])
    output=-1;
end

% if nargout>0 && txt_flag == 0
%     output=complete_flag;
% end

