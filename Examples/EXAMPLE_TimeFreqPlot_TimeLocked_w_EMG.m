% Easy script to load a dataset to get to the point of calculating power
%
% Requires SSPs and Events already made
%
% 2013-07-05 Foldes
% UPDATES:
% 2013-07-24 Foldes: Bug fix. FeatureParms.Window_Size was not correct for 'move' data (i.e. the spectral analysis)

clearvars -except Metadata
results_save_name = 'ModDepth_sss_trans_Cue';

% Choose criteria for data set to analyize
clear criteria_struct
criteria_struct.subject = 'NC01';
criteria_struct.run_type = 'Open_Loop_MEG';
criteria_struct.run_task_side = 'Right';
criteria_struct.run_action = 'Grasp';
% criteria_struct.run_intention = 'Imagine';
criteria_struct.run_intention = 'Attempt';
% criteria_struct.session = '01'
% Metadata_lookup_unique_entries(Metadata,'run_action') % check the entries

Extract.file_type='sss_trans'; % What type of data?

%% Load Database
% PATHS
local_base_path = '/home/foldes/Data/MEG/';
server_base_path = '/home/foldes/Desktop/Katz/experiments/meg_neurofeedback/';
metadatabase_base_path = '/home/foldes/Desktop/Katz/experiments/meg_neurofeedback/';
metadatabase_location=[metadatabase_base_path filesep 'Neurofeedback_metadatabase.txt'];
%metadatabase_location='/home/foldes/Dropbox/Code/MEG_SF_Tools/Databases/Neurofeedback_metadatabase_backup.txt';

% Load Metadata from text file
if ~exist('Metadata')
    Metadata = Metadata_Class();
    Metadata = Load_StandardStruct_from_TXT(Metadata,metadatabase_location);
end

Extract.data_path_default = local_base_path;

% Chooses the approprate entry (makes one if you don't have one)
[entry_idx_list] = Metadata_Find_Entries_By_Criteria(Metadata,criteria_struct);

% % CHECK FIRST
% property_name = 'Preproc.Pointer_processed_data_for_events';
property_name = ['ResultPointers.' results_save_name];
Metadata_Report_Property_Check(Metadata(entry_idx_list),property_name);

%%
ientry = 1;

metadata_entry = Metadata(entry_idx_list(ientry));
disp(' ')
disp(['==================File #' num2str(ientry) '/' num2str(length(entry_idx_list)) ' | ' metadata_entry.file_base_name '================='])
% Copy local (can be used to copy all that match criteria)
Metadata_Copy_Data_from_Server(metadata_entry,[],local_base_path,server_base_path,[MEG_file_type2file_extension(Extract.file_type) '.fif']);

%% Preparing Data Set Info and Analysis-related Parameters

%---Extraction Info-------------
Extract = Prep_Extract_w_Metadata(Extract,metadata_entry);
Extract.channel_list=sort([1:3:306 2:3:306]); % only gradiometers
%-------------------------------

%---Feature Parameters (FeatureParms.)---
FeatureParms = FeatureParms_Class;
% Can be empty for loading feature data from CRX files
FeatureParms.feature_method = 'MEM';
FeatureParms.order = 30; %
FeatureParms.feature_resolution = 1;
FeatureParms.ideal_freqs = [0:150]; % Pick freq or bins
FeatureParms.sample_rate = Extract.data_rate;
FeatureParms.feature_update_rateS = 0.05; % Only needed for timefreq analysis
%-------------------------------

%---Analysis Parameters (AnalysisParms.)---
AnalysisParms.event_name_move = 'ParallelPort_Move';
AnalysisParms.rx_timeS_move=0;
AnalysisParms.window_lengthS_move = 0.5;

AnalysisParms.event_name_rest = 'ArtifactFreeRest';
AnalysisParms.rx_timeS_rest=0;
AnalysisParms.window_lengthS_rest = 3;
%-------------------------------

%% ----------------------------------------------------------------
%  -----------------CODE STARTS------------------------------------
%  ----------------------------------------------------------------

%% Load MEG data

[MEG_data,TimeVecs.timeS] =  Load_from_FIF(Extract,'MEG');
TimeVecs.data_rate = Extract.data_rate;
[TimeVecs.target_code_org] =  Load_from_FIF(Extract,'STI');

%% Load SSP

% try to load if possible, or calculate
if exist([Extract.file_path filesep metadata_entry.Preproc.Pointer_SSP])==2
    load([Extract.file_path filesep metadata_entry.Preproc.Pointer_SSP]);
else
    % ***TEMPORARY, THIS MEANS THE POINTER WASN'T WRITTEN FOR SOME REASON***
    pointer_name = ['SSP_' Extract.file_type];
    if exist([Extract.file_path filesep Extract.file_base_name '_' pointer_name '.mat'])==2
        load([Extract.file_path filesep Extract.file_base_name '_' pointer_name]);
        metadata_entry.Preproc.Pointer_SSP = [Extract.file_base_name '_' pointer_name '.mat'];
    else
        warning('NO SSP found')
    end
end

MEG_data_clean = MEG_data;
% clear MEG_data_clean % 2013-06-26 Foldes
% % Apply
% ssp_projector = Calc_SSP_Filters(ssp_components);
% MEG_data_clean = (ssp_projector*MEG_data')';
clear MEG_data

%% Load Events

% try to load if possible
if exist([Extract.file_path filesep metadata_entry.Preproc.Pointer_Events])==2
    load([Extract.file_path filesep metadata_entry.Preproc.Pointer_Events]);
else
    % ***TEMPORARY, THIS MEANS THE POINTER WASN'T WRITTEN FOR SOME REASON***
    pointer_name = ['Events_' Extract.file_type];
    if exist([Extract.file_path filesep Extract.file_base_name '_Events.mat'])==2
        load([Extract.file_path filesep Extract.file_base_name '_Events.mat']);
        metadata_entry.Preproc.Pointer_Events = [Extract.file_base_name '_Events.mat'];
    end
end

%% Modulation Calculation
% Takes 1min for 10 sensors

chan_list = [44];%DEF_MEG_sensors_sensorimotor_left_hemi_BEST;
chan_list_idx = sensors2chanidx(Extract.channel_list,chan_list);

move_events = sort(Events.ParallelPort_BlockStart);
rest_events = Events.(AnalysisParms.event_name_rest);
AnalysisParms.pre_event_timeS=5;
AnalysisParms.post_event_timeS=25;

% REST Power for modulation calculation
FeatureParms.window_lengthS = AnalysisParms.window_lengthS_rest;
FeatureParms.window_length = floor(FeatureParms.window_lengthS*Extract.data_rate);
[feature_data_rest,FeatureParms]=Calc_PSD_TimeLocked(MEG_data_clean,rest_events,FeatureParms);

% Timelocked TimeFreq Data
pre_event_time=AnalysisParms.pre_event_timeS*FeatureParms.sample_rate;
post_event_time=AnalysisParms.post_event_timeS*FeatureParms.sample_rate;
FeatureParms.window_lengthS = AnalysisParms.window_lengthS_move;
FeatureParms.window_length = floor(FeatureParms.window_lengthS*Extract.data_rate);
[feature_data_by_event_by_trial,analysis_window_center_time,FeatureParms]=Calc_TimeFreqAnalysis_TimeLocked(MEG_data_clean(:,chan_list_idx),move_events,pre_event_time,post_event_time,FeatureParms);
% trial x chan x freq x event
feature_timeS=analysis_window_center_time/FeatureParms.sample_rate;

% Calculate modulation
moddepth = Calc_ModDepth(mean(feature_data_by_event_by_trial,4),feature_data_rest(:,chan_list_idx,:),'T');

%% Cue and EMG timelocking
% Target Code
ExpDefs.paradigm_type=metadata_entry.run_type;
ExpDefs=Prep_ExpDefs(ExpDefs);
TimeVecs=Prep_TargetCode(TimeVecs,ExpDefs);
[target_code_by_event]=Organize_TimeLockToEvents(TimeVecs.target_code==ExpDefs.target_code.move,move_events,pre_event_time,post_event_time);
mean_target_code_by_event = mean(cell2mat(target_code_by_event),2);
new_time = min(feature_timeS):1/(Extract.data_rate):max(feature_timeS);

% EMG
% Get processed EMG
load([Extract.file_path filesep metadata_entry.Preproc.Pointer_processed_data_for_events]);
[EMG_by_event]=Organize_TimeLockToEvents(processed_data.EMG_data(:,1),move_events,pre_event_time,post_event_time);
mean_EMG_by_event = mean(cell2mat(EMG_by_event),2);

% %% ACC
% % Get processed ACC
% load([Extract.file_path filesep metadata_entry.Preproc.Pointer_processed_data_for_events]);
% [ACC_by_event]=Organize_TimeLockToEvents(processed_data.ACC_data(:,1),move_events,pre_event_time,post_event_time);
% mean_ACC_by_event = mean(cell2mat(ACC_by_event),2);

% Smooth out misc signals for cleaner plotting
EMG_smooth = Normalize(Calc_Filter_Freq_SimpleButter(mean_EMG_by_event,1,Extract.data_rate,'low'));
EMG_smooth_short = EMG_smooth(find_closest_in_list_idx(feature_timeS,new_time));
Target_smooth = (Calc_Filter_Freq_SimpleButter(mean_target_code_by_event>0,1,Extract.data_rate,'low'));
Target_smooth_short = Target_smooth(find_closest_in_list_idx(feature_timeS,new_time));
Target_short = mean_target_code_by_event(find_closest_in_list_idx(feature_timeS,new_time));

%% Plot
sensor2plot_list = chan_list;
for sensor2plot = sensor2plot_list
    time2plotS = 2.5; % time related to cue (e.g. 2 = 2s after block start = analysis window that was centered around the first move cue)
    
    freqplotrange = [0 120];
    fig_psd=figure;
    subplot(2,2,[1 2]);hold all
    
    sensor2plot_idx = find_lists_overlap_idx(Extract.channel_list(chan_list_idx),sensor2plot);
    Plot_PSD_Quick(moddepth(:,sensor2plot_idx,:),feature_timeS,FeatureParms,:,fig_psd);
    ylim(freqplotrange)
    caxis_center(10)
    colorbar_with_label('T score')
    hold all
    % Plot_VerticalMarkers(new_time(TrialTransitions(mean_target_code_by_event==1)))
    plot(feature_timeS,(max(freqplotrange)-(min(freqplotrange)+20))*(Target_short)+(min(freqplotrange)+10),'Color',0.7*[1 1 1],'LineWidth',1.5);
    plot(feature_timeS,(max(freqplotrange)-(min(freqplotrange)+20))*(EMG_smooth_short)+(min(freqplotrange)+10),'k','LineWidth',1.5);
    title(['Sensor: ' num2str(sensor2plot)])
    Figure_Stretch(3,2);
    
    % Plot PSD
    time2plot = find_closest_in_list_idx(time2plotS,feature_timeS);
    subplot(2,2,3);hold all
    plot(FeatureParms.actual_freqs,squeeze(mean(moddepth(time2plot,sensor2plot_idx,:),1)))
    plot( [min(FeatureParms.actual_freqs),max(FeatureParms.actual_freqs)],[0 0],'--k')
    set(gca,'XTick',[round(min(FeatureParms.actual_freqs)):10:round(max(FeatureParms.actual_freqs))])
    xlabel('Frequency [Hz]');ylabel('Modulation')
    title(['Beta w/ window centered at ' num2str(time2plotS) 'S'])
    xlim([0 50])
    subplot(2,2,4);hold all
    plot(FeatureParms.actual_freqs,squeeze(mean(moddepth(time2plot,sensor2plot_idx,:),1)))
    plot( [min(FeatureParms.actual_freqs),max(FeatureParms.actual_freqs)],[0 0],'--k')
    set(gca,'XTick',[round(min(FeatureParms.actual_freqs)):10:round(max(FeatureParms.actual_freqs))])
    xlabel('Frequency [Hz]');ylabel('Modulation')
    title(['Gamma w/ window centered at ' num2str(time2plotS) 'S'])
    xlim([65 115])
    %title_figure(['Sensor: ' num2str(sensor2plot)])
end

%% Plot By Freq Band
% 
% freqrange_name = 'beta';
% freqplotrange = [0 50];
% 
% fig_psd=figure;
% subplot(2,1,1);hold all
% Plot_PSD_Quick(moddepth(:,sensor2plot_idx,:),feature_timeS,FeatureParms,:,fig_psd);
% ylim(freqplotrange)
% caxis_center
% hold all
% % Plot_VerticalMarkers(new_time(TrialTransitions(mean_target_code_by_event==1)))
% plot(feature_timeS,(max(freqplotrange)-(min(freqplotrange)+20))*(Target_short)+(min(freqplotrange)+10),'Color',0.7*[1 1 1],'LineWidth',1.5);
% plot(feature_timeS,(max(freqplotrange)-(min(freqplotrange)+20))*(EMG_smooth_short)+(min(freqplotrange)+10),'k','LineWidth',1.5);
% title(['Freq: ' freqrange_name ', Sensor: ' num2str(sensor2plot)])
% colorbar 'off'
% 
% subplot(2,1,2);hold all
% plot(feature_timeS,Normalize(Target_smooth_short),'LineWidth',1,'Color',0.7*[1 1 1]);
% plot(feature_timeS,Normalize(Target_short),'--','LineWidth',1,'Color',0.7*[1 1 1]);
% plot(feature_timeS,EMG_smooth_short,'k','LineWidth',1);
% current_freq_idx = unique(find_closest_in_list_idx([min(DEF_freq_bands(freqrange_name)):max(DEF_freq_bands(freqrange_name))],FeatureParms.actual_freqs));
% % PSD_smooth.(freqrange_name) = Normalize(Calc_Filter_Freq_SimpleButter(-1*mean(moddepth(:,sensor2plot_idx,current_freq_idx),3),1,FeatureParms.timeS_to_feature_sample,'low'));
% % plot(feature_timeS,PSD_smooth.(freqrange_name),'b','LineWidth',2);
% plot(feature_timeS,Normalize(-1*mean(moddepth(:,sensor2plot_idx,current_freq_idx),3)),'b','LineWidth',2);
% xlim([min(feature_timeS) max(feature_timeS)])
% ylim([0 1])
% 
% % title(['R2: EMG ' num2str(round_sig(R2_wEMG.(freqrange_name),-2)) ' | Cue ' num2str(round_sig(R2_wTarget,-2)) ' | Shuf ' num2str(round_sig(R2_wShuf,-3)) ' || Grasping: EMG ' num2str(round_sig(R2_wEMG_during_grasps,-2)) ' | Cue ' num2str(round_sig(R2_wTarget_during_grasps,-2)) ' | Shuf ' num2str(round_sig(R2_wShuf_during_grasps,-3)) ])
% Figure_Stretch(3);
% 
% 
% freqrange_name = 'gamma';
% freqplotrange = [60 100];
% 
% fig_psd=figure;
% subplot(2,1,1);hold all
% Plot_PSD_Quick(moddepth(:,sensor2plot_idx,:),feature_timeS,FeatureParms,:,fig_psd);
% ylim(freqplotrange)
% caxis_center
% hold all
% % Plot_VerticalMarkers(new_time(TrialTransitions(mean_target_code_by_event==1)))
% plot(feature_timeS,(max(freqplotrange)-(min(freqplotrange)+20))*(Target_short)+(min(freqplotrange)+10),'Color',0.7*[1 1 1],'LineWidth',1.5);
% plot(feature_timeS,(max(freqplotrange)-(min(freqplotrange)+20))*(EMG_smooth_short)+(min(freqplotrange)+10),'k','LineWidth',1.5);
% title(['Freq: ' freqrange_name ', Sensor: ' num2str(sensor2plot)])
% colorbar 'off'
% 
% subplot(2,1,2);hold all
% plot(feature_timeS,Normalize(Target_smooth_short),'LineWidth',1,'Color',0.7*[1 1 1]);
% plot(feature_timeS,Normalize(Target_short),'--','LineWidth',1,'Color',0.7*[1 1 1]);
% plot(feature_timeS,EMG_smooth_short,'k','LineWidth',1);
% current_freq_idx = unique(find_closest_in_list_idx([min(DEF_freq_bands(freqrange_name)):max(DEF_freq_bands(freqrange_name))],FeatureParms.actual_freqs));
% % PSD_smooth.(freqrange_name) = Normalize(Calc_Filter_Freq_SimpleButter(mean(moddepth(:,sensor2plot_idx,current_freq_idx),3),1,FeatureParms.timeS_to_feature_sample,'low'));
% % plot(feature_timeS,PSD_smooth.(freqrange_name),'r','LineWidth',2);
% plot(feature_timeS,Normalize(mean(moddepth(:,sensor2plot_idx,current_freq_idx),3)),'r','LineWidth',2);
% xlim([min(feature_timeS) max(feature_timeS)])
% ylim([0 1])
% 
% % title(['R2: EMG ' num2str(round_sig(R2_wEMG.(freqrange_name),-2)) ' | Cue ' num2str(round_sig(R2_wTarget,-2)) ' | Shuf ' num2str(round_sig(R2_wShuf,-3)) ' || Grasping: EMG ' num2str(round_sig(R2_wEMG_during_grasps,-2)) ' | Cue ' num2str(round_sig(R2_wTarget_during_grasps,-2)) ' | Shuf ' num2str(round_sig(R2_wShuf_during_grasps,-3)) ])
% Figure_Stretch(3);
