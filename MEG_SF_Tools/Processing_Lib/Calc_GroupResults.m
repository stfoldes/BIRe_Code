function GroupResults = Calc_GroupResults(DB,pointer_name,ResultParms)
% 2013-09-20 Foldes
% UPDATES:
% 2013-10-11 Foldes: Metadata-->DB
% 2013-10-24 Foldes: ResultParms added

% CHEAT CODE:
%     % List of frequency indices (e.g. gamma_idx)
%     freq_list = ResultParms.freq_names;
%     for ifreq = 1:length(freq_list)
%         current_freq_name = freq_list{ifreq};
%         eval([freq_list{ifreq} '_idx=find_lists_overlap_idx(ResultParms.freq_names,current_freq_name);'])
%     end

global MY_PATHS

% Need for getting position
load DEF_NeuromagSensorInfo;


%% ==========================================================
%  =====UNPACKING PROCESSED DATA AND CALCULATING METRICS=====
%  ==========================================================

all_move=[];all_rest=[];
clear mod_by_location_freqband mod_by_subject p_by_sensor_freqband
% ientry = 1;
for ientry = 1:length(DB)
    
    DB_entry = DB(ientry);
    disp(' ')
    disp(['==================File #' num2str(ientry) '/' num2str(length(DB)) ' | ' DB_entry.entry_id '(' DB_entry.run_intention ' ' DB_entry.run_action ' ' DB_entry.run_task_side ')================='])
    
    % Load Results into workspace
    complete_flag = DB_entry.load_pointer(pointer_name);
    
    %subject_name_list{ientry} = DB_entry.subject;
    % Save basic info to GroupResults Struct
    prop_names = properties(DB_entry);
    for iprop = 1:length(prop_names)
        % copy all properties UNLESS they are objects
        if ~isobject(DB_entry.(prop_names{iprop}))
            GroupResults(ientry).(prop_names{iprop}) = DB_entry.(prop_names{iprop});
        end
    end    
    AnalysisParms=Results.AnalysisParms;

    
    % --- Setting Results parameters ---
    num_freq_bands = size(ResultParms.freq_ideal,1);
    
    % make list of freq
    ResultParms.freq_idx=[];
    ResultParms.freq_actual=[];
    for ifreq = 1:num_freq_bands
        ResultParms.freq_idx=[ResultParms.freq_idx; ...
            find_closest_range_idx(ResultParms.freq_ideal(ifreq,:),Results.FeatureParms.actual_freqs)]; % do that find_closet stuff to get the valid indicies (what if you don't have 1Hz res?)
        ResultParms.freq_actual=[ResultParms.freq_actual; ...
            find_closest_range(ResultParms.freq_ideal(ifreq,:),Results.FeatureParms.actual_freqs)]; % do that find_closet stuff to get the valid indicies (what if you don't have 1Hz res?)
    end
    
    %% T w/ Most Mod
    Results.moddepth_all_sensors = Calc_ModDepth(Results.feature_data_move,Results.feature_data_rest,'T');
    % Remove bad sensors (set to zero)
    bad_sensor_idx = sensors2chanidx(Results.Extract.channel_list,DB_entry.Preproc.bad_chan_list);
    Results.moddepth = Results.moddepth_all_sensors;
    Results.moddepth(:,bad_sensor_idx,:) = NaN;
    
    % Results.moddepth = Calc_ModDepth(Results.feature_data_move,Results.feature_data_rest,'T');
    
    [Results.moddepth_by_location_freqband,sensor_group_list] = Calc_ModDepth_Combine_by_Location(Results.moddepth,ResultParms.freq_idx,Results.Extract.channel_list);
    
    % Calc which channels are sig
    for ifreq_set = 1:size(ResultParms.freq_idx,1)
        current_freq_idx=[min(ResultParms.freq_idx(ifreq_set,:)):max(ResultParms.freq_idx(ifreq_set,:))];
        for isensor = 1:size(Results.moddepth,2)
            [~,p_by_sensor_freqband(ientry,isensor,ifreq_set)]=ttest( squeeze(mean(Results.moddepth(:,isensor,current_freq_idx),3)) );
        end
        
        % ===LEFT SENSORIMOTOR===
        roi_name = 'left_hemi';
        eval(['current_roi = DEF_MEG_sensors_sensorimotor_' roi_name ';']);
        roi_sensor_idx = sensors2chanidx(Results.Extract.channel_list,current_roi);
        clear sig_sensor_idx
        sig_sensor_idx = roi_sensor_idx(p_by_sensor_freqband(ientry,roi_sensor_idx,ifreq_set) < AnalysisParms.p_thres_for_sensors);
        GroupResults(ientry).(roi_name).portion_sig(ifreq_set) = length(sig_sensor_idx)/length(roi_sensor_idx);

        if ~isempty(sig_sensor_idx)   
            
            % Average modulation - SIG
            GroupResults(ientry).(roi_name).mean_sig(ifreq_set) = nanmean(squeeze(nanmean(nanmean(Results.moddepth(:,sig_sensor_idx,current_freq_idx),3),1)),2);
            GroupResults(ientry).(roi_name).std_sig(ifreq_set) = nanstd(squeeze(nanmean(nanmean(Results.moddepth(:,sig_sensor_idx,current_freq_idx),3),1)),[],2);
            
            % Maximum Magnitude - SIG
            [GroupResults(ientry).(roi_name).maxmag_sig(ifreq_set), idx] = maxmag(squeeze(nanmean(nanmean(Results.moddepth(:,sig_sensor_idx,current_freq_idx),3),1)),[],1);
            current_sensor = current_roi(roi_sensor_idx==sig_sensor_idx(idx));
            GroupResults(ientry).(roi_name).maxmag_sig_pos(ifreq_set).sensor = current_sensor;
            GroupResults(ientry).(roi_name).maxmag_sig_pos(ifreq_set).x = NeuromagSensorInfo(current_sensor).pos(1);
            GroupResults(ientry).(roi_name).maxmag_sig_pos(ifreq_set).y = NeuromagSensorInfo(current_sensor).pos(2);
            
            % Max - SIG
            [GroupResults(ientry).(roi_name).max_sig(ifreq_set), idx] = nanmax(squeeze(nanmean(nanmean(Results.moddepth(:,sig_sensor_idx,current_freq_idx),3),1)),[],2);
            current_sensor = current_roi(roi_sensor_idx==sig_sensor_idx(idx));
            GroupResults(ientry).(roi_name).max_sig_pos(ifreq_set).sensor = current_sensor;
            GroupResults(ientry).(roi_name).max_sig_pos(ifreq_set).x = NeuromagSensorInfo(current_sensor).pos(1);
            GroupResults(ientry).(roi_name).max_sig_pos(ifreq_set).y = NeuromagSensorInfo(current_sensor).pos(2);
            
            % Min - SIG
            [GroupResults(ientry).(roi_name).min_sig(ifreq_set), idx] = nanmin(squeeze(nanmean(nanmean(Results.moddepth(:,sig_sensor_idx,current_freq_idx),3),1)),[],2);
            current_sensor = current_roi(roi_sensor_idx==sig_sensor_idx(idx));
            GroupResults(ientry).(roi_name).min_sig_pos(ifreq_set).sensor = current_sensor;
            GroupResults(ientry).(roi_name).min_sig_pos(ifreq_set).x = NeuromagSensorInfo(current_sensor).pos(1);
            GroupResults(ientry).(roi_name).min_sig_pos(ifreq_set).y = NeuromagSensorInfo(current_sensor).pos(2);
        end
        
        
        % Average modulation - ROI
        GroupResults(ientry).(roi_name).mean_mod(ifreq_set) = nanmean(squeeze(nanmean(nanmean(Results.moddepth(:,roi_sensor_idx,current_freq_idx),3),1)),2);
        GroupResults(ientry).(roi_name).std_mod(ifreq_set) = nanstd(squeeze(nanmean(nanmean(Results.moddepth(:,roi_sensor_idx,current_freq_idx),3),1)),[],2);
        
        % Maximum Magnitude - ROI
        [GroupResults(ientry).(roi_name).maxmag_mod(ifreq_set), idx] = maxmag(squeeze(nanmean(nanmean(Results.moddepth(:,roi_sensor_idx,current_freq_idx),3),1)),[],1);
        current_sensor = current_roi(idx);
        GroupResults(ientry).(roi_name).maxmag_mod_pos(ifreq_set).sensor = current_sensor;
        GroupResults(ientry).(roi_name).maxmag_mod_pos(ifreq_set).x = NeuromagSensorInfo(current_sensor).pos(1);
        GroupResults(ientry).(roi_name).maxmag_mod_pos(ifreq_set).y = NeuromagSensorInfo(current_sensor).pos(2);
        
        % Max - ROI
        [GroupResults(ientry).(roi_name).max_mod(ifreq_set), idx] = nanmax(squeeze(nanmean(nanmean(Results.moddepth(:,roi_sensor_idx,current_freq_idx),3),1)),[],2);
        current_sensor = current_roi(idx);
        GroupResults(ientry).(roi_name).max_mod_pos(ifreq_set).sensor = current_sensor;
        GroupResults(ientry).(roi_name).max_mod_pos(ifreq_set).x = NeuromagSensorInfo(current_sensor).pos(1);
        GroupResults(ientry).(roi_name).max_mod_pos(ifreq_set).y = NeuromagSensorInfo(current_sensor).pos(2);
        
        % Min - ROI
        [GroupResults(ientry).(roi_name).min_mod(ifreq_set), idx] = nanmin(squeeze(nanmean(nanmean(Results.moddepth(:,roi_sensor_idx,current_freq_idx),3),1)),[],2);
        current_sensor = current_roi(idx);
        GroupResults(ientry).(roi_name).min_mod_pos(ifreq_set).sensor = current_sensor;
        GroupResults(ientry).(roi_name).min_mod_pos(ifreq_set).x = NeuromagSensorInfo(current_sensor).pos(1);
        GroupResults(ientry).(roi_name).min_mod_pos(ifreq_set).y = NeuromagSensorInfo(current_sensor).pos(2);
        
        
        % ===RIGHT SENSORIMOTOR===
        roi_name = 'right_hemi';
        eval(['current_roi = DEF_MEG_sensors_sensorimotor_' roi_name ';']);        
        roi_sensor_idx = sensors2chanidx(Results.Extract.channel_list,current_roi);
        clear sig_sensor_idx
        sig_sensor_idx = roi_sensor_idx(p_by_sensor_freqband(ientry,roi_sensor_idx,ifreq_set) < AnalysisParms.p_thres_for_sensors);
        GroupResults(ientry).(roi_name).portion_sig(ifreq_set) = length(sig_sensor_idx)/length(roi_sensor_idx);

        if ~isempty(sig_sensor_idx)            
            % Average modulation - SIG
            GroupResults(ientry).(roi_name).mean_sig(ifreq_set) = nanmean(squeeze(nanmean(nanmean(Results.moddepth(:,sig_sensor_idx,current_freq_idx),3),1)),2);
            GroupResults(ientry).(roi_name).std_sig(ifreq_set) = nanstd(squeeze(nanmean(nanmean(Results.moddepth(:,sig_sensor_idx,current_freq_idx),3),1)),[],2);
            
            % Maximum Magnitude - SIG
            [GroupResults(ientry).(roi_name).maxmag_sig(ifreq_set), idx] = maxmag(squeeze(nanmean(nanmean(Results.moddepth(:,sig_sensor_idx,current_freq_idx),3),1)),[],1);
            current_sensor = current_roi(roi_sensor_idx==sig_sensor_idx(idx));
            GroupResults(ientry).(roi_name).maxmag_sig_pos(ifreq_set).sensor = current_sensor;
            GroupResults(ientry).(roi_name).maxmag_sig_pos(ifreq_set).x = NeuromagSensorInfo(current_sensor).pos(1);
            GroupResults(ientry).(roi_name).maxmag_sig_pos(ifreq_set).y = NeuromagSensorInfo(current_sensor).pos(2);
            
            % Max - SIG
            [GroupResults(ientry).(roi_name).max_sig(ifreq_set), idx] = nanmax(squeeze(nanmean(nanmean(Results.moddepth(:,sig_sensor_idx,current_freq_idx),3),1)),[],2);
            current_sensor = current_roi(roi_sensor_idx==sig_sensor_idx(idx));
            GroupResults(ientry).(roi_name).max_sig_pos(ifreq_set).sensor = current_sensor;
            GroupResults(ientry).(roi_name).max_sig_pos(ifreq_set).x = NeuromagSensorInfo(current_sensor).pos(1);
            GroupResults(ientry).(roi_name).max_sig_pos(ifreq_set).y = NeuromagSensorInfo(current_sensor).pos(2);
            
            % Min - SIG
            [GroupResults(ientry).(roi_name).min_sig(ifreq_set), idx] = nanmin(squeeze(nanmean(nanmean(Results.moddepth(:,sig_sensor_idx,current_freq_idx),3),1)),[],2);
            current_sensor = current_roi(roi_sensor_idx==sig_sensor_idx(idx));
            GroupResults(ientry).(roi_name).min_sig_pos(ifreq_set).sensor = current_sensor;
            GroupResults(ientry).(roi_name).min_sig_pos(ifreq_set).x = NeuromagSensorInfo(current_sensor).pos(1);
            GroupResults(ientry).(roi_name).min_sig_pos(ifreq_set).y = NeuromagSensorInfo(current_sensor).pos(2);
        end
        
        % Average modulation - ROI
        GroupResults(ientry).(roi_name).mean_mod(ifreq_set) = nanmean(squeeze(nanmean(nanmean(Results.moddepth(:,roi_sensor_idx,current_freq_idx),3),1)),2);
        GroupResults(ientry).(roi_name).std_mod(ifreq_set) = nanstd(squeeze(nanmean(nanmean(Results.moddepth(:,roi_sensor_idx,current_freq_idx),3),1)),[],2);
        
        % Maximum Magnitude - ROI
        [GroupResults(ientry).(roi_name).maxmag_mod(ifreq_set), idx] = maxmag(squeeze(nanmean(nanmean(Results.moddepth(:,roi_sensor_idx,current_freq_idx),3),1)),[],1);
        current_sensor = current_roi(idx);
        GroupResults(ientry).(roi_name).maxmag_mod_pos(ifreq_set).sensor = current_sensor;
        GroupResults(ientry).(roi_name).maxmag_mod_pos(ifreq_set).x = NeuromagSensorInfo(current_sensor).pos(1);
        GroupResults(ientry).(roi_name).maxmag_mod_pos(ifreq_set).y = NeuromagSensorInfo(current_sensor).pos(2);
        
        % Max - ROI
        [GroupResults(ientry).(roi_name).max_mod(ifreq_set), idx] = nanmax(squeeze(nanmean(nanmean(Results.moddepth(:,roi_sensor_idx,current_freq_idx),3),1)),[],2);
        current_sensor = current_roi(idx);
        GroupResults(ientry).(roi_name).max_mod_pos(ifreq_set).sensor = current_sensor;
        GroupResults(ientry).(roi_name).max_mod_pos(ifreq_set).x = NeuromagSensorInfo(current_sensor).pos(1);
        GroupResults(ientry).(roi_name).max_mod_pos(ifreq_set).y = NeuromagSensorInfo(current_sensor).pos(2);
        
        % Min - ROI
        [GroupResults(ientry).(roi_name).min_mod(ifreq_set), idx] = nanmin(squeeze(nanmean(nanmean(Results.moddepth(:,roi_sensor_idx,current_freq_idx),3),1)),[],2);
        current_sensor = current_roi(idx);
        GroupResults(ientry).(roi_name).min_mod_pos(ifreq_set).sensor = current_sensor;
        GroupResults(ientry).(roi_name).min_mod_pos(ifreq_set).x = NeuromagSensorInfo(current_sensor).pos(1);
        GroupResults(ientry).(roi_name).min_mod_pos(ifreq_set).y = NeuromagSensorInfo(current_sensor).pos(2);
        
%         roi_sensor_idx = sensors2chanidx(Results.Extract.channel_list,current_roi);
%         GroupResults(ientry).right_hemi.portion_sig(ifreq_set) = sum(p_by_sensor_freqband(ientry,roi_sensor_idx,ifreq_set)<AnalysisParms.p_thres_for_sensors)/length(roi_sensor_idx);
%         
%         % Average modulation
%         GroupResults(ientry).right_hemi.mean_mod(ifreq_set) = nanmean(squeeze(nanmean(nanmean(Results.moddepth(:,roi_sensor_idx,current_freq_idx),3),1)),2);
%         GroupResults(ientry).right_hemi.std_mod(ifreq_set) = nanstd(squeeze(nanmean(nanmean(Results.moddepth(:,roi_sensor_idx,current_freq_idx),3),1)),[],2);
% 
%         % Maximum Magnitude
%         [GroupResults(ientry).right_hemi.maxmag_mod(ifreq_set), maxmag_mod_idx] = maxmag(squeeze(nanmean(nanmean(Results.moddepth(:,roi_sensor_idx,current_freq_idx),3),1)),[],1);
%         GroupResults(ientry).right_hemi.maxmag_mod_pos(ifreq_set).sensor = current_roi(maxmag_mod_idx);
%         GroupResults(ientry).right_hemi.maxmag_mod_pos(ifreq_set).x = NeuromagSensorInfo(current_roi(maxmag_mod_idx)).pos(1);
%         GroupResults(ientry).right_hemi.maxmag_mod_pos(ifreq_set).y = NeuromagSensorInfo(current_roi(maxmag_mod_idx)).pos(2);
%         
%         % Max
%         [GroupResults(ientry).right_hemi.max_mod(ifreq_set), max_mod_idx] = nanmax(squeeze(nanmean(nanmean(Results.moddepth(:,roi_sensor_idx,current_freq_idx),3),1)),[],2);
%         GroupResults(ientry).right_hemi.max_mod_pos(ifreq_set).sensor = current_roi(max_mod_idx);
%         GroupResults(ientry).right_hemi.max_mod_pos(ifreq_set).x = NeuromagSensorInfo(current_roi(max_mod_idx)).pos(1);
%         GroupResults(ientry).right_hemi.max_mod_pos(ifreq_set).y = NeuromagSensorInfo(current_roi(max_mod_idx)).pos(2);
% 
%         % Min
%         [GroupResults(ientry).right_hemi.min_mod(ifreq_set), min_mod_idx] = nanmin(squeeze(nanmean(nanmean(Results.moddepth(:,roi_sensor_idx,current_freq_idx),3),1)),[],2);
%         GroupResults(ientry).right_hemi.min_mod_pos(ifreq_set).sensor = current_roi(min_mod_idx);
%         GroupResults(ientry).right_hemi.min_mod_pos(ifreq_set).x = NeuromagSensorInfo(current_roi(min_mod_idx)).pos(1);
%         GroupResults(ientry).right_hemi.min_mod_pos(ifreq_set).y = NeuromagSensorInfo(current_roi(min_mod_idx)).pos(2);
    
    end

    
    % For group stats
    GroupResults(ientry).mod=squeeze(nanmean(Results.moddepth,1)); % bad channels removed
    GroupResults(ientry).mod_by_location_freqband=Results.moddepth_by_location_freqband;
    
%     %% PSD and Topography Plot and Save
%     if save_figs_by_subject
%         fig_psd=Plot_ModDepth_Variance(Results.moddepth,Results.FeatureParms,Results.Extract.channel_list);
%         
%         ylabel('Modulation (t-stat)')
%         title([DB_entry.subject ' ' DB_entry.run_intention ' ' DB_entry.run_task_side ' ' DB_entry.run_action])
%         text_input{1} = [AnalysisParms.event_name_move ' (x' num2str(length(AnalysisParms.events_move)) ') ' num2str(AnalysisParms.window_lengthS_move) 's window'];
%         text_input{2} = [AnalysisParms.event_name_rest ' (x' num2str(length(AnalysisParms.events_rest)) ') ' num2str(AnalysisParms.window_lengthS_rest) 's window'];
%         text_input{3} = ['Order: ' num2str(Results.FeatureParms.order)];
%         Figure_Annotate(text_input)
%         Figure_Save(['PSD_' DB_entry.subject '_' DB_entry.run_intention '_' DB_entry.run_task_side '_' DB_entry.run_action])
%         close
%         
%         %     freq2plot_list=[DEF_freq_bands('mu'); DEF_freq_bands('beta'); DEF_freq_bands('gamma')];
%         %     Plot_Topography_from_ModDepth(Results.moddepth,Results.Extract.channel_list,Results.FeatureParms,freq2plot_list,[Results.Extract.file_name{1}]);
%         %
%         % %     GUI_Inspect_ModDepth_wTopography(fig_psd,Results.feature_data_move,Results.feature_data_rest,Results.Extract.channel_list,Results.FeatureParms,0.5,Results.Extract.file_name{1});
%         %
%         
%         % Plot Topography
%         fig=figure;
%         for ifreq = 1:size(ResultParms.freq_idx,1)
%             subplot(1,size(ResultParms.freq_idx,1),ifreq);hold all
%             Plot_MEG_head_plot(Results.moddepth_by_location_freqband(:,ifreq),1,sort([1:3:306]),[],[],fig);
%             caxis_center;colorbar
%             title(ResultParms.freq_names{ifreq})
%         end
%         Figure_Stretch(3,0.5)
%         title_figure([DB_entry.subject ' ' DB_entry.run_intention ' ' DB_entry.run_task_side ' ' DB_entry.run_action])
%         Figure_Save(['Topography_' DB_entry.subject '_' DB_entry.run_intention '_' DB_entry.run_task_side '_' DB_entry.run_action])
%         close
%     end
    
    %%
    % Freq to look across
    %
    %     freq_range_idx = [find_closest_in_list_idx(min(freq_range_ideal),Results.FeatureParms.actual_freqs):find_closest_in_list_idx(max(freq_range_ideal),Results.FeatureParms.actual_freqs)];
    %
    %     % Average ModDepth in freq band
    %     moddepth_by_sensor_set = mean(mean(Results.moddepth_by_location_freqband(:,:,freq_range_idx),1),3);
    %
    %     fig_head=figure;hold all;%set(fig_head,'Tag',fig_tag);
    %     Plot_MEG_head_plot(moddepth_by_sensor_set,1,[1:3:306],[],[],fig_head); % NOTE: HARD CODED FOR MOD_DEPTH TO BE 102 SENSORS
    %     %Plot_MEG_chan_locations(DEF_MEG_sensors_sensorimotor,0,[],fig_head);
    %     caxis_center(maxmag([maxmag(get(gca,'CLim')),1]));
    %     colorbar_with_label('SD Move vs. Rest','EastOutside');
    %     title(['Beta ' DB_entry.entry_id ' (file: ' num2str(ientry) ')'])
    %     Figure_Stretch(1.25,1.25)
    %     Figure_Position(0.7,1)untitled
    
    % Save out the analysis parameters
    GroupResults(ientry).Extract = Results.Extract;
    GroupResults(ientry).FeatureParms = Results.FeatureParms;
    GroupResults(ientry).AnalysisParms = AnalysisParms;

end % entries

