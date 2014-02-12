% From .fif, do a power analysis from manually picked events
%
% 2013-12-05 Foldes
% Verified 2014-02-07

clear
close all

Extract.full_file_name      = '/home/foldes/Data/MEG/DBI05/S01/dbi05s01r03_tsss_trans.fif';
ExpDefs.paradigm_type       = 'Mapping';
AnalysisParms.event_type    = 'cue';

% Extract.full_file_name = '/home/foldes/Data/MEG/NC01/S01/nc01s01r03_tsss_trans.fif';
% ExpDefs.paradigm_type = 'Open_Loop_MEG';


%% Preparing Data Set Info and Analysis-related Parameters
%---Extraction Info-------------
Extract.channel_list    = sort([1:3:306 2:3:306]); % only gradiometers
Extract.data_rate       = 1000;
Extract.filter_stop     = [59 61];
Extract.filter_bandpas  = [2 200];
%-------------------------------

%---Feature Parameters (FeatureParms.)---
FeatureParms = FeatureParms_Class;
% Can be empty for loading feature data from CRX files
FeatureParms.feature_method     = 'burg';
FeatureParms.order              = 30; % changed 2013-07-12 Foldes
FeatureParms.feature_resolution = 1;
FeatureParms.ideal_freqs        = [0:120]; % Pick freq or bins
FeatureParms.sample_rate        = Extract.data_rate;
%-------------------------------

%---Analysis Parameters (AnalysisParms.)---
AnalysisParms.SSP_Flag                  = 0;
% AnalysisParms.event_name_move = 'ParallelPort_Move_Good';
% Window-timing Parameters
AnalysisParms.event_window_lengthS      = 1; % 1s to help with rx variablity
% AnalysisParms.event_rx_timeS=0.1;    % 2013-10-11: 100ms b/c of parallel-port/video offset
% 1/2s should be for center at 500ms post parallel port 2013-08-23
% AnalysisParms.num_reps_per_block = 4; % Only use the first 4 reps per block

% AnalysisParms.ref_event_name = 'ArtifactFreeRest';
AnalysisParms.ref_event_window_lengthS  = 3; % window is centered (this IS the WindowS from auto-event-parms)
% AnalysisParms.ref_event_rx_timeS = 0; % shift window (this is NOT the rx_time from auto-event-parms, this should be 0)
%-------------------------------

save_events_flag = 1; % Save events? will save as Events_Temp_

%% ----------------------------------------------------------------
%  -----------------CODE STARTS------------------------------------
%  ----------------------------------------------------------------
%
%% Load MEG data

[MEG_data,TimeVecs.timeS,~,Extract] =  Load_from_FIF(Extract,'MEG');
TimeVecs.data_rate = Extract.data_rate;

%% SSP - NOPE

MEG_data_clean = MEG_data;


%% EVENT DEFINITION

% Cue signal
[TimeVecs.target_code_org] = Load_from_FIF(Extract,'STI');

ExpDefs=Prep_ExpDefs(ExpDefs);
% remove 255 on-off signals
TimeVecs.target_code_org = remove_pport_trigger_from_CRX_startstop(TimeVecs.target_code_org);
TimeVecs=Prep_TargetCode(TimeVecs,ExpDefs);

switch lower(AnalysisParms.event_type)
    case 'cue'
        AnalysisParms.events = Calc_Events('cue',TimeVecs.target_code_org,ExpDefs.video_target_code.move);
        
        
        % % Calculate time series data that will be used for marking events SLOW
        % processed_data=Calc_Processed_EMGandACC(Extract,'acc');
        % Events = Calc_Events('gui_wprocessed_data',processed_data,TimeVecs,'ACC');
        % AnalysisParms.events = Events.Original.ACC;
        
        % figure;plot(TimeVecs.timeS,processed_data.ACC_data);
        % AnalysisParms.events = Calc_Events('cue',TimeVecs.target_code,ExpDefs.target_code.move);
        % AnalysisParms.events = Calc_Events('cue',TimeVecs.target_code,ExpDefs.target_code.block_start);
        
        
end
%% Time Freq plot time-locked and averaged

% PARAMETERS
sensor_list                             = [37 40 67 70 43 73]; % 37 67 70-front 43-back 73-back +1
sensor_list                             = sort([sensor_list sensor_list+1]); 

% sensor_list  = [40 262 100 115 295 163];
% sensor_list                             = [67 70 64 112 73]; % 37 67 70-front 43-back 73-back +1
% sensor_list                             = sort([sensor_list sensor_list+1]); 


for isensor = 1:length(sensor_list)
    sensor_num = sensor_list(isensor);
    
    %---Feature Parameters (FeatureParms.)---
    %     FeatureParms                        = FeatureParms_Class;
    %     FeatureParms.feature_method         = 'burg';
    %     FeatureParms.order                  = 30;
    %     FeatureParms.feature_resolution     = 1;
    %     FeatureParms.ideal_freqs            = [0:120];
    %     FeatureParms.sample_rate            = Extract.data_rate;
    FeatureParms.window_lengthS         = 1;
    FeatureParms.feature_update_rateS   = 0.1;
    
    % CALC TIME-FREQ
    sensor_idx = sensors2chanidx(Extract.channel_list,sensor_num);
    FeatureParms = S2samples_struct(FeatureParms,Extract.data_rate);
    
    % Define feature-times; bin_center_list = samples for time-freq plot
    bin_center_list = [ceil(FeatureParms.window_length/2)+1:FeatureParms.feature_update_rate:size(MEG_data_clean,1)-ceil(FeatureParms.window_length/2)];
    
    % POWER CALC
    tic
    [feature_data,FeatureParms]=Calc_PSD_TimeLocked(MEG_data_clean(:,sensor_idx),bin_center_list,FeatureParms);
    toc
    
    % TIMELOCKING
    
    AnalysisParms.pre_timeS             = 2;
    AnalysisParms.post_timeS            = 22;
    
    % samples to feature samples *CHECK NAMES*
    event_onset_feature_time = find_closest_in_list_idx(AnalysisParms.events,bin_center_list);
    
    % ORGANIZE
    AnalysisParms.pre_time = floor(AnalysisParms.pre_timeS * FeatureParms.timeS_to_feature_sample);
    AnalysisParms.post_time = floor(AnalysisParms.post_timeS * FeatureParms.timeS_to_feature_sample);
    [data_by_event,event_idx_by_trial]=Organize_TimeLockToEvents(squeeze(feature_data(:,1,:)),event_onset_feature_time,AnalysisParms.pre_time,AnalysisParms.post_time);
    data_by_event = cell2array(data_by_event);
    event_data_mean = mean(data_by_event,3);
    
    % REFERENCE
    % Reference is time BEFORE event
    ref = event_data_mean(1:AnalysisParms.pre_time,:);
    
    % apply reference
    event_data_mean_refed = Calc_ModDepth(event_data_mean,ref,'Z');
    
    % PLOT
    figure;%hold all
    Figure_Stretch(2,1)
    time_axis = (-AnalysisParms.pre_time:AnalysisParms.post_time)./FeatureParms.timeS_to_feature_sample;
    pcolor(time_axis,FeatureParms.actual_freqs,event_data_mean_refed');
    caxis_center
    colorbar_with_label('Z-score')
    shading interp
    Plot_VerticalMarkers(0,'MarkerText','Cue Onset')
    ylabel('Frequency [Hz]')
    xlabel('Time [S]')
    title(['Sensor: ' num2str(sensor_num) ', File: ' Extract.file_name])
end

% Figure_Run_on_All_Open_Figs('caxis_center(6)')

% % % Full time-freq plot
% % % BASELINE REFEERNCE
% % % FeatureParms.window_lengthS         = 5;
% % % FeatureParms.window_length = floor(FeatureParms.window_lengthS*Extract.data_rate);
% % % feature_data_ref=Calc_PSD_TimeLocked(MEG_data_clean(:,sensor_idx),floor(FeatureParms.window_length/2)+1,FeatureParms);
% % feature_data_ref=feature_data_rest(:,sensor_idx,:);
% % make relative to rest
% % mod_data = Calc_ModDepth(feature_data,feature_data_ref,'Z');
% % figure;%hold all
% % Figure_Stretch(3,0.5)
% % pcolor(bin_center_list/Extract.data_rate,FeatureParms.actual_freqs,squeeze(mod_data(:,1,:))');
% %
% % caxis_center
% % colorbar_with_label('T')
% % shading interp
% %
% % hold on
% % plot(bin_center_list/Extract.data_rate,(TimeVecs.target_code_org(bin_center_list)==event_cue_code)*max(get(gca,'Ylim')),...
% %     'LineWidth',3)
% 
% 
% 
% 
% %% Calc Time Locked Power
% 
% AnalysisParms = S2samples_struct(AnalysisParms,TimeVecs.data_rate);
% 
% % AnalysisParms.events = Calc_Events('cue',TimeVecs.target_code,ExpDefs.target_code.block_start);%+3*Extract.data_rate;
% AnalysisParms.ref_events = AnalysisParms.events-AnalysisParms.ref_event_window_length;
% 
% tic
% 
% % Calc Rest Power
% FeatureParms.window_lengthS = AnalysisParms.ref_event_window_lengthS;
% FeatureParms.window_length = floor(FeatureParms.window_lengthS*Extract.data_rate);
% [feature_data_ref,FeatureParms]=Calc_PSD_TimeLocked(MEG_data_clean,AnalysisParms.ref_events,FeatureParms);
% 
% % Calc Move Move
% FeatureParms.window_lengthS=AnalysisParms.event_window_lengthS;
% FeatureParms.window_length = floor(FeatureParms.window_lengthS*Extract.data_rate);
% [feature_data_event,FeatureParms]=Calc_PSD_TimeLocked(MEG_data_clean,AnalysisParms.events-round(FeatureParms.window_length/2),FeatureParms);
% toc
% 
% 
% %% PLOT: PSD for an ROI
% ROI_name = 'sensorimotor_left_hemi';
% eval(['ROI_idx = sensors2chanidx([Extract.channel_list],[DEF_MEG_sensors_' ROI_name ']);'])
% data4psd = Calc_ModDepth(feature_data_event,feature_data_ref,'T');
% 
% fig_psd = figure;hold all
% Figure_Stretch(2,1)
% % Left Sensorimotor
% Plot_Variance_as_Patch(FeatureParms.actual_freqs,squeeze(mean(data4psd,1))',...
%     'variance_method',[.05 .95],'patch_color','k','patch_alpha',0.6,'fig',fig_psd); % STD across all sensor groups
% plot(FeatureParms.actual_freqs,squeeze(mean(data4psd(:,ROI_idx,:),1))',...
%     'g','LineWidth',2)
% clear text_input
% text_input{1} = [ROI_name ' (' num2str(length(ROI_idx)) ' sensors)'];
% text_input{end+1} = ['EVENTS: ' num2str(length(AnalysisParms.events)) 'Events , ' num2str(AnalysisParms.event_window_lengthS) 's window'];
% text_input{end+1} = ['REF: ' num2str(length(AnalysisParms.ref_events)) 'Events , ' num2str(AnalysisParms.ref_event_window_lengthS) 's window'];
% text_input{end+1} = ['Order: ' num2str(FeatureParms.order)];
% Figure_Annotate(text_input)
% title(str4plot(Extract.full_file_name))
% xlabel('Freq [Hz]')
% ylabel('Modulation [T]')
% 
% % PLOT: Topography for freq bands
% GUI_Inspect_ModDepth_wTopography(fig_psd,feature_data_event,feature_data_ref,Extract.channel_list,FeatureParms,'p_thres',0.1);



