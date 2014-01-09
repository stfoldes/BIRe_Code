% How to run SSP
% Foldes 2013-08-26

clear all

%% ===LOAD DATA===

    Extract.file_name{1}='nc03s01r010_tsss_trans';
    Extract.file_path='/home/foldes/Data/MEG/NC03/S01/';
    Extract.data_rate=1000;
    
    % Load MEG
    [MEG_data,TimeVecs.timeS,MEG_chan_list] = Load_from_FIF(Extract,'MEG');
    
    % EOG
    blink_data=Load_from_FIF(Extract,'EOG');

    % ECG (from EMG)
    EMG_data = Load_from_FIF(Extract,'EMG');
    
    % STI (Just to look at the experiment better)
    STI_data = Load_from_FIF(Extract,'STI');
    
%% ===MARK EVENTS===

    %     % Load Events OR preprocessed data for events
    %     load([server_path filesep metadata_entry.subject filesep 'S' metadata_entry.session filesep metadata_entry.Preproc.Pointer_Events]);
    %     load([metadata_entry.file_path(local_path) filesep metadata_entry.Preproc.Pointer_processed_data_for_events]);
    %    processed_data=Calc_Processed_EMGandACC(Extract);

    % mark blink events
    disp('CALCULATING: Processed Blink Data')
    processed_data.blink_data = Calc_Rectify_Smooth(blink_data,Extract.data_rate);
    Events.blink= GUI_Auto_Event_Markers(processed_data.blink_data,TimeVecs.timeS,STI_data,'blink');
    
    % mark cardiac events
    disp('CALCULATING: Processed Cardiac Data')
    processed_data.cardiac_data = Calc_Rectify_Smooth(EMG_data,Extract.data_rate);
    Events.cardiac= GUI_Auto_Event_Markers(processed_data.cardiac_data,TimeVecs.timeS,STI_data,'cardiac');

    
%% ===SSP===
    % Need: MEG_data, TimeVecs.timeS, Extract.data_rate, Events

    % Computer SSP
    ssp_components_blink = Calc_SSP(MEG_data,Events.blink,Extract.data_rate,'blink',MEG_chan_list);
    ssp_components_cardiac = Calc_SSP(MEG_data,Events.cardiac,Extract.data_rate,'cardiac',MEG_chan_list);
    % combine
    ssp_components = [ssp_components_blink ssp_components_cardiac];
    
    % Apply SSP
    ssp_projector = Calc_SSP_Filters(ssp_components);
    data_clean = (ssp_projector*MEG_data')';

    
%% ===CHECK===
    % Inspect how the filtering did

    % For the channel names
    for ichan = 1:size(MEG_chan_list,1)
        sensor_names{ichan} = MEG_chan_list(ichan,:);
    end
    
    % mix clean and unclean
    clear data4plot signal_marks
    cnt = 0;
%     data4plot = zeros(size(MEG_data,1),size(MEG_data,2)*2);
    for ichan = 1:100%size(MEG_data,2)
        cnt=cnt+1;
        data4plot(:,cnt) = MEG_data(:,ichan);
        signal_marks(cnt) = 0;
        sensor_names_double{cnt} = sensor_names{ichan};

        cnt=cnt+1;
        data4plot(:,cnt) = data_clean(:,ichan);
        signal_marks(cnt) = 1;
        sensor_names_double{cnt} = sensor_names{ichan};
    end
    
    data_filtered=Calc_Filter_Freq_SimpleButter(data4plot,40,Extract.data_rate);
    
    events_list = Events.cardiac;
    [~,save_flag]=Plot_Inspect_TimeSeries_Signals(zscore(data_filtered),[0:size(data_filtered,1)-1].*(1/Extract.data_rate),sensor_names_double,find(signal_marks==1),events_list,'Red = CLEAN');
    
    