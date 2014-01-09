% Script to edit events
%
% 2013-08-29 Foldes
% UPDATES:
%


clear

% Choose criteria for data set to analyize
clear criteria
criteria.file_base_name = 'nc02s01r04';
event_name = 'Original.ParallelPort_Move_Good';

%% Load Database

% Load Metadata from text file
[Metadata,metadatabase_location,local_path,server_path]=Metadata_Load('meg_neurofeedback');

Extract.data_path_default = local_path;
Extract.file_type='fif'; % What type of data?

%% Loop for All Entries

% Chooses the approprate entry (makes one if you don't have one)
[~,entry_idx_list] = Metadata.by_criteria(criteria);

fail_list = [];
for ientry = 1:length(entry_idx_list)
    
    metadata_entry = Metadata(entry_idx_list(ientry));
    disp(' ')
    disp(['==================File #' num2str(ientry) '/' num2str(length(entry_idx_list)) ' | ' metadata_entry.file_base_name '================='])
    
    % Copy local (can be used to copy all that match criteria)
    metadata_entry.Download_Data(local_path,server_path,Extract.file_type);
    
    %% Preparing Data Set Info and Analysis-related Parameters
    %---Extraction Info-------------
    Extract = Prep_Extract_w_Metadata(Extract,metadata_entry);
    Extract.channel_list=[1:306];
    %-------------------------------
    
    % Load data
    clear TimeVecs
    TimeVecs.data_rate = Extract.data_rate;
    [TimeVecs.target_code_org,TimeVecs.timeS] = Load_from_FIF(Extract,'STI');
    
    ExpDefs.paradigm_type =metadata_entry.run_type;
    ExpDefs=Prep_ExpDefs(ExpDefs);
    TimeVecs=Prep_TargetCode(TimeVecs,ExpDefs);
    
    event_file = [metadata_entry.file_path(server_path) filesep metadata_entry.Preproc.Pointer_Events];
    load(event_file);
    
    load([metadata_entry.file_path(server_path) filesep metadata_entry.Preproc.Pointer_processed_data_for_events]);
    
    
    eval(['events2check = Events.' event_name ';'])
    [save_flag,new_events]= GUI_Edit_Event_Markers([TimeVecs.target_code processed_data.EMG_data processed_data.ACC_data],TimeVecs.timeS,events2check,event_name);
    if save_flag
        eval(['Events.' event_name '=new_events;'])
        Events = Calc_Event_Removal_wBadSegments(Events,TimeVecs.data_rate);
        
        % SAVE OUT NOW (should inspect first)
        [metadata_entry,saved_pointer_flag] = Metadata_Save_Pointer_Data(metadata_entry,Events,'Preproc.Pointer_Events','mat',local_path,server_path);
        % Save current metadata entry back to database
        if saved_pointer_flag==1
            Metadata=Metadata_Update_Entry(metadata_entry,Metadata);
        end
        
    end
    
end

% % Shouldn't be changing names
% Metadata_Write_to_TXT(Metadata,metadatabase_location);




