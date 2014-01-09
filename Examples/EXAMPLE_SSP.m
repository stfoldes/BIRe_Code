% How to run SSP
% Foldes 2013-04-24

clear all

%% ===LOAD DATA===

    % Data Look Up Info
    clear criteria
    criteria.subject = 'NC03';
    criteria.run_type = 'Open_Loop_MEG';
    criteria.run_task_side = 'Right';
    criteria.run_action = 'Grasp';
    criteria.run_intention = 'Attempt';

    % Load Metadata from text file
    [Metadata,metadatabase_location,local_path,server_path]=Metadata_Load('meg_neurofeedback');

    [metadata_entry] = Metadata.by_criteria(criteria);
    Extract.file_type='tsss_trans';
    Extract.data_path_default = local_path;
    Extract = Prep_Extract_w_Metadata(Extract,metadata_entry);
    
    % Load Data and Events
    [MEG_data,TimeVecs.timeS] = Load_from_FIF(Extract,'MEG');
    
    
    
%% ===MARK EVENTS===

    %     % Load Events OR preprocessed data for events
    %     load([server_path filesep metadata_entry.subject filesep 'S' metadata_entry.session filesep metadata_entry.Preproc.Pointer_Events]);
    %     load([metadata_entry.file_path(local_path) filesep metadata_entry.Preproc.Pointer_processed_data_for_events]);
    %    processed_data=Calc_Processed_EMGandACC(Extract);


    % EOG
    blink_data=Load_from_FIF(Extract,'EOG');
    processed_data.blink_data = Calc_Rectify_Smooth(blink_data,Extract.data_rate);

    % ECG (from EMG)
    EMG_data = Load_from_FIF(Extract,'EMG');
    processed_data.cardiac_data = Calc_Rectify_Smooth(EMG_data,Extract.data_rate);

    % ===blink===
    if ~exist('Events') || ~isfield(Events,'blink')
        Events.blink= GUI_Auto_Event_Markers(processed_data.blink_data,TimeVecs.timeS,TimeVecs.target_code,'blink');
        [metadata_entry,saved_pointer_flag] = Metadata_Save_Pointer_Data(metadata_entry,Events,pointer_name,'mat',local_path,server_path);
        if saved_pointer_flag==1
            Metadata=Metadata_Update_Entry(metadata_entry,Metadata);
        end
    end
    
    % ===cardiac===
    if ~exist('Events') || ~isfield(Events,'cardiac')
        Events.cardiac= GUI_Auto_Event_Markers(processed_data.cardiac_data,TimeVecs.timeS,TimeVecs.target_code,'cardiac');
        [metadata_entry,saved_pointer_flag] = Metadata_Save_Pointer_Data(metadata_entry,Events,pointer_name,'mat',local_path,server_path);
        if saved_pointer_flag==1
            Metadata=Metadata_Update_Entry(metadata_entry,Metadata);
        end
    end

    
%% ===SSP===
    % Need: MEG_data, TimeVecs.timeS, Extract.data_rate, Events

    % Computer SSP
    ssp_components_blink = Calc_SSP(MEG_data,Events.blink,Extract.data_rate,'blink');
    ssp_components_cardiac = Calc_SSP(MEG_data,Events.cardiac,Extract.data_rate,'cardiac');
    ssp_components = [ssp_components_blink ssp_components_cardiac];
    %     % Save
    %     metadata_entry = Metadata_Save_Pointer_Data(metadata_entry,ssp_components,['Preproc.Pointer_SSP_' Extract.file_type],'mat',local_base_path,server_path);
    %     Metadata=Metadata_Update_Entry(metadata_entry,Metadata);
    %     Metadata_Write_to_TXT(Metadata,metadatabase_location);
    
    % Apply SSP
    load([server_path filesep metadata_entry.subject filesep 'S' metadata_entry.session filesep metadata_entry.Preproc.Pointer_SSP_sss]);
    ssp_projector = Calc_SSP_Filters(ssp_components);
    data_clean = (ssp_projector*MEG_data')';

    
%% ===CHECK===

    % Inspect how the filtering did
    % mix clean and unclean
    clear data4plot signal_marks
    cnt = 0;
    for ichan = 1:10
        cnt=cnt+1;
        data4plot(:,cnt) = MEG_data(:,ichan);
        signal_marks(cnt) = 0;
        cnt=cnt+1;
        data4plot(:,cnt) = data_clean(:,ichan);
        signal_marks(cnt) = 1;
    end
    
    data_filtered=Calc_Filter_Freq_SimpleButter(data4plot,40,Extract.data_rate);
    
    events_list = Events.cardiac;
    [~,save_flag]=Plot_Inspect_TimeSeries_Signals(zscore(data_filtered),[0:size(data_filtered,1)-1].*(1/Extract.data_rate),[],find(signal_marks==1),events_list,'Red = CLEAN');
    
    