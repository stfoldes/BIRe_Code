function download(obj,file_name_ending,force_transfer_flag,pointer_name)
% Tool to easily copy files from the server to local hard drive.
% Even if there is a local copy, checks that the date isn't too off (1day)
%
% Default is to download the .entry_id with ending added. 
% If pointer_name is used, the .(pointer_name) will be downloaded
%
% force_transfer_flag[OPTIONAL]: if =1, will overwrite local files (defaults to 0)
%
% EXAMPLE:
% Downlad all NC03, Session 1, Grasp Attempt files that are _sss_trans type
%
%   [DB,DBbase_location,local_path,server_path]=DB_Load_Database_Cheat('meg_neurofeedback');
%
%   criteria.subject = 'NC03';
%   criteria.session = '01';
%   criteria.run_action = 'Grasp';
%   criteria.run_intention = 'Attempt';
%
%   Extract.file_type='_sss_trans.fif';
%
%   download(DB.get(criteria),Extract.file_type);
%
% SEE: DB_Copy_Data_from_Server for older version
%
% Foldes 2013-08-15
% UPDATES:
% 2013-08-16 Foldes: Added Preproc pointer option...DIDN'T TEST!
% 2013-08-22 Foldes: Works for hidden properties/fields
% 2013-10-04 Foldes: Metadata --> DB

global MY_PATHS

%% DEFAULTS
if ~exist('force_transfer_flag') || isempty(force_transfer_flag)
    force_transfer_flag=0;
end

% Initial Check
if exist(MY_PATHS.local_base) ~= 7
    error('local_path does not exist...seriously?!')
    return
end
if exist(MY_PATHS.server_base) ~= 7
    error('server_path does not exist...seriously?!')
    return
end

% if you tell it a pointer name it will try to do that instead of the basefile
if exist('pointer_name') && ~isempty(pointer_name)
    pointer_flag = 1;
else
    pointer_flag = 0;
end

%% Check and Copy

transfer_flag = 1;
for ientry = 1:length(obj) % for each entry
    clear DB_entry
    DB_entry = obj(ientry);
    
    % Build file path
    if pointer_flag == 0 % Base file
        goal_file_name = [DB_entry.entry_id file_name_ending];
    elseif pointer_flag == 1 % go to the pointer file instead
        eval(['goal_file_name = [DB_entry. ' pointer_name ' file_name_ending];']);
    end
    
    % Check file on server
    if exist([DB_entry.file_path('server') filesep goal_file_name])~=2
        warning(['FILE NOT FOUND ON SERVER: ' goal_file_name])
        transfer_flag = 0;
    end
    
    % If file already exists localally, check it out
    if exist([DB_entry.file_path('local') filesep goal_file_name])==2
        % Check servers time stamp to yours
        [local_age,local_age_num]   = date_file_timestamp([DB_entry.file_path('local') filesep goal_file_name]);
        [server_age,server_age_num] = date_file_timestamp([DB_entry.file_path('server') filesep goal_file_name]);
        
        % If local_age is very different, then recopy (3 day)
        if daysact(local_age_num,server_age_num) > 13
            warning(['Local file found, but too old compared to server file: Forcing copy ' goal_file_name])
            transfer_flag = 1;
            
        else % file found and is fresh, dont re copy
            transfer_flag = 0;
        end
    end
    
    % COPY
    if transfer_flag || force_transfer_flag
        % Check Local Folder Structure before copying
        if exist(DB_entry.file_path('local')) ~= 7
            disp(['Session folder did not exist locally: Made folder ' goal_file_name])
            mkdir(DB_entry.file_path('local'))
        end
        
        disp(['COPYING FILE ' goal_file_name '... PLEASE BE PATIENT...'])
        status = copyfile([DB_entry.file_path('server') filesep goal_file_name],[DB_entry.file_path('local') filesep goal_file_name]);
        if status==0
            error(['FAILURE WITH: ' goal_file_name])
        else
            disp('**********COPY COMPLETE*************')
            disp(' ')
        end
    end % copy
    
end % Entries

