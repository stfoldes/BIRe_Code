clear
% close all

% Choose criteria for data set to analyize
    clear criteria_struct
    criteria_struct.subject = 'NS01';
    criteria_struct.run_type = 'Open_Loop_MEG';
    criteria_struct.run_task_side = 'Right';
    criteria_struct.run_action = 'Grasp';
    criteria_struct.run_intention = 'Attempt';
    % criteria_struct.session = '01';
    % Metadata_lookup_unique_entries(Metadata,'run_action') % check the entries

    Extract.file_type='fif'; % What type of data?

%% Load Database
    % PATHS
    local_base_path = '/home/foldes/Data/MEG/';
    server_base_path = '/home/foldes/Desktop/Katz/experiments/meg_neurofeedback/';
    metadatabase_base_path = '/home/foldes/Desktop/Katz/experiments/meg_neurofeedback/';
    metadatabase_location=[metadatabase_base_path filesep 'Neurofeedback_metadatabase.txt'];
    %metadatabase_location='/home/foldes/Dropbox/Code/MEG_SF_Tools/Databases/Neurofeedback_metadatabase_backup.txt';

    % Load Metadata from text file
    Metadata = Metadata_Class();
    Metadata = Load_StandardStruct_from_TXT(Metadata,metadatabase_location);

    % Chooses the approprate entry (makes one if you don't have one)
    [metadata_entry] = Metadata_Get_Entry(Metadata,criteria_struct);
    % Copy data local (can be used to copy all that match criteria)
%     Metadata_Copy_Data_from_Server(metadata_entry,[],local_base_path,server_base_path,[MEG_file_type2file_extension(Extract.file_type) '.fif']);
    
    Extract.data_path_default = local_base_path;
    
    
    metadata_entry.file_base_name
    
    
    %%
    
    %---Extraction Info-------------
    Extract = Prep_Extract_w_Metadata(Extract,metadata_entry);
%     Extract.channel_list=sort([1:3:306 2:3:306]); % only gradiometers
%     
%     
%     TimeVecs.data_rate = Extract.data_rate;
    [TimeVecs.target_code_org,TimeVecs.timeS] =  Load_from_FIF(Extract,'STI');
%     
    load([Extract.file_path filesep Extract.file_base_name '_Events.mat']);
    %% Write BST-event file (if NaN, don't write)
    clear events
    
    event_cnt = 0;
    event_name_str = 'blink';
    if ~isnan(Events.(event_name_str))
        event_cnt = event_cnt+1;
        events(event_cnt).label = event_name_str;
        events(event_cnt).times = TimeVecs.timeS(Events.(event_name_str));
        events(event_cnt).color = [0 0 1];
    end
    
    event_name_str = 'cardiac';
    if ~isnan(Events.(event_name_str))
        event_cnt = event_cnt+1;
        events(event_cnt).label = event_name_str;
        events(event_cnt).times = TimeVecs.timeS(Events.(event_name_str));
        events(event_cnt).color = [0 1 0];
    end
    
    event_name_str = 'photodiode';
    if ~isnan(Events.(event_name_str))
        event_cnt = event_cnt+1;
        events(event_cnt).label = event_name_str;
        events(event_cnt).times = TimeVecs.timeS(Events.(event_name_str));
        events(event_cnt).color = [0 1 1];
    end
    
    event_name_str = 'ACC';
    if ~isnan(Events.(event_name_str))
        event_cnt = event_cnt+1;
        events(event_cnt).label = event_name_str;
        events(event_cnt).times = TimeVecs.timeS(Events.(event_name_str));
        events(event_cnt).color = [1 0 0];
    end
    
    event_name_str = 'EMG';
    if ~isnan(Events.(event_name_str))
        event_cnt = event_cnt+1;
        events(event_cnt).label = event_name_str;
        events(event_cnt).times = TimeVecs.timeS(Events.(event_name_str));
        events(event_cnt).color = [1 0 1];
    end
    
    event_name_str = 'ArtifactFreeRest';
    if ~isnan(Events.(event_name_str))
        event_cnt = event_cnt+1;
        events(event_cnt).label = event_name_str;
        events(event_cnt).times = TimeVecs.timeS(Events.(event_name_str));
        events(event_cnt).color = [1 1 0];
    end
    
    event_name_str = 'ParallelPort_Move';
    if ~isnan(Events.(event_name_str))
        event_cnt = event_cnt+1;
        events(event_cnt).label = event_name_str;
        events(event_cnt).times = TimeVecs.timeS(Events.(event_name_str));
        % events(event_cnt).color = [1 1 0];
    end
    event_name_str = 'ParallelPort_Rest';
    if ~isnan(Events.(event_name_str))
        event_cnt = event_cnt+1;
        events(event_cnt).label = event_name_str;
        events(event_cnt).times = TimeVecs.timeS(Events.(event_name_str));
        % events(event_cnt).color = [1 1 0];
    end
%     event_name_str = 'ParallelPort_BlockStart';
%     if ~isnan(Events.(event_name_str))
%         event_cnt = event_cnt+1;
%         events(event_cnt).label = event_name_str;
%         events(event_cnt).times = TimeVecs.timeS(Events.(event_name_str));
%         % events(event_cnt).color = [1 1 0];
%     end
    
    % WRITE OUT (COULD USE HELP)
    events = Export_Event_File(events,[Extract.file_path metadata_entry.file_base_name],Extract.data_rate);
    
    
    
    