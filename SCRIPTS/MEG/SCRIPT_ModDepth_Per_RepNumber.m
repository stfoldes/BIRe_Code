% Looks a moddepth for each rep of the block
% i.e. 1st rep of all blocks | 2nd rep of all blocks |etc
%
% Requires SSPs and Events already made
%
% 2013-07-05 Foldes

clear
close all
overwrite_flag=0;
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

Metadata = Metadata_Class();
Metadata = Load_StandardStruct_from_TXT(Metadata,metadatabase_location);


Extract.data_path_default = local_base_path;

% Chooses the approprate entry (makes one if you don't have one)
[entry_idx_list] = Metadata_Find_Entries_By_Criteria(Metadata,criteria_struct);

% % CHECK FIRST
% property_name = 'Preproc.Pointer_processed_data_for_events';
property_name = ['ResultPointers.' results_save_name];
Metadata_Report_Property_Check(Metadata(entry_idx_list),property_name);

%%
ientry = 1;
for ientry = 1:length(entry_idx_list)
    
    metadata_entry = Metadata(entry_idx_list(ientry));
    disp(' ')
    disp(['==================File #' num2str(ientry) '/' num2str(length(entry_idx_list)) ' | ' metadata_entry.file_base_name '================='])
    try
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
        FeatureParms.order = 12; % changed from 30 b/c couldn't get mu (2013-06-25 Foldes)
        FeatureParms.feature_resolution = 1;
        FeatureParms.ideal_freqs = [0:150]; % Pick freq or bins
        FeatureParms.sample_rate = Extract.data_rate;
        %-------------------------------
        
        %---Analysis Parameters (AnalysisParms.)---
        AnalysisParms.event_name_move = 'ParallelPort_Move';
        AnalysisParms.rx_timeS_move=0;
        AnalysisParms.window_lengthS_move = .5;
        
        AnalysisParms.event_name_rest = 'ArtifactFreeRest';
        AnalysisParms.rx_timeS_rest=0;
        AnalysisParms.window_lengthS_rest = 3;
        %-------------------------------
        
        %% ----------------------------------------------------------------
        %  -----------------CODE STARTS------------------------------------
        %  ----------------------------------------------------------------
        
        %% Load MEG data
        
        [MEG_data] =  Load_from_FIF(Extract,'MEG');
        TimeVecs.data_rate = Extract.data_rate;
        [TimeVecs.target_code_org,TimeVecs.timeS] =  Load_from_FIF(Extract,'STI');
        %         ExpDefs.paradigm_type=metadata_entry.run_type;
        %         ExpDefs=Prep_ExpDefs(ExpDefs);
        %         TimeVecs=Prep_TargetCode(TimeVecs,ExpDefs);
        
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
        
        clear MEG_data_clean % 2013-06-26 Foldes
        % Apply
        ssp_projector = Calc_SSP_Filters(ssp_components);
        MEG_data_clean = (ssp_projector*MEG_data')';
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
        
        %% Modulation Calculation for each rep
        
        tic
        clear max_PSD*
        
        num_move_cues= length(Events.ParallelPort_Move);
        num_moves_per_block = num_move_cues/length(Events.ParallelPort_BlockStart);
        
        set_names = [1:num_moves_per_block];
        for iparm = 1:num_moves_per_block
            % move_events = sort(Events.ParallelPort_Move([iparm:num_moves_per_block:num_move_cues]));
            
%             % First Few Move Reps
%             num_trials_per_block = iparm;
%             move_events=[];
%             for iblock = 1:length(Events.ParallelPort_BlockStart)
%                 move_events = [move_events Events.ParallelPort_Move(find(Events.ParallelPort_Move>Events.ParallelPort_BlockStart(iblock),num_trials_per_block,'first'))'];
%             end
            
            
            % First Few Move Reps
            num_trials_per_block = iparm;
            move_events=[];
            for iblock = 1:length(Events.ParallelPort_BlockStart)
                
                first_trial_rx_timeS = 0;
                first_trial_rx_time = first_trial_rx_timeS*Extract.data_rate;
                
                block_rx_vec = zeros(1,num_trials_per_block)';
                block_rx_vec(1) = first_trial_rx_time;
                
                move_events = [move_events (Events.ParallelPort_Move(find(Events.ParallelPort_Move>Events.ParallelPort_BlockStart(iblock),num_trials_per_block,'first')) + block_rx_vec)'];
            end
            
            % First EMG trials
            %         num_trials_per_block = iparm;
            %         move_events=[];
            %         for iblock = 1:length(Events.ParallelPort_BlockStart)
            %             move_events = [move_events Events.EMG(find(Events.EMG>Events.ParallelPort_BlockStart(iblock),num_trials_per_block,'first'))];
            %         end
            
            %     % Plot current events
            %     figure;hold all
            %     plot(TimeVecs.timeS,TimeVecs.target_code')
            %     stem(TimeVecs.timeS(move_events),5*ones(1,length(move_events))','r.-')
            %     Figure_Stretch(2)
            
            FeatureParms.feature_update_rateS=0.05;
            AnalysisParms.pre_event_timeS=1;
            AnalysisParms.post_event_timeS=1;
            pre_event_time=AnalysisParms.pre_event_timeS*FeatureParms.sample_rate;
            post_event_time=AnalysisParms.post_event_timeS*FeatureParms.sample_rate;
            
            
            chan_list = DEF_MEG_sensors_sensorimotor_left_hemi_BEST;
            
            % REST for zscore Calc Rest power *AROUND* cue
            FeatureParms.window_lengthS = AnalysisParms.window_lengthS_rest;
            FeatureParms.window_length = floor(FeatureParms.window_lengthS*Extract.data_rate);
            [feature_data_rest,FeatureParms]=Calc_PSD_TimeLocked(MEG_data_clean,Events.(AnalysisParms.event_name_rest)-floor(FeatureParms.window_length/2),FeatureParms);
            
            
            % Time locked PSD
            best_chan_idx = sensors2chanidx(Extract.channel_list,chan_list);
            [feature_data_by_event_by_trial,analysis_window_center_time,FeatureParms]=Calc_TimeFreqAnalysis_TimeLocked(MEG_data_clean(:,best_chan_idx,:),move_events,pre_event_time,post_event_time,FeatureParms);
            % trial x chan x freq x event
            feature_timeS=analysis_window_center_time/FeatureParms.sample_rate;
            
            clear pzscore_moddepth
            for ichan = 1:size(feature_data_by_event_by_trial,2)
                for ifreq = 1:size(feature_data_by_event_by_trial,3)
                    pzscore_moddepth(:,ichan,ifreq)=mean(( feature_data_by_event_by_trial(:,ichan,ifreq,:)-mean(feature_data_rest(:,best_chan_idx(ichan),ifreq),1) )./std(feature_data_rest(:,best_chan_idx(ichan),ifreq),[],1),4);
                end
            end
            
            
            % Modulation depth
            % clear pzscore_moddepth
            % feature_data_by_event=squeeze(mean(feature_data_by_event_by_trial,4));
            % [pzscore_moddepth,sensor_group_list] = Calc_MEG_ModDepth(feature_data_by_event,feature_data_rest(:,best_chan_idx,:),Extract.channel_list(best_chan_idx),0);
           
            % Organize by time lock
            % Target Code
            %         ExpDefs.paradigm_type=metadata_entry.run_type;
            %         ExpDefs=Prep_ExpDefs(ExpDefs);
            %         TimeVecs=Prep_TargetCode(TimeVecs,ExpDefs);
            %         [target_code_by_event]=Organize_TimeLockToEvents(TimeVecs.target_code==ExpDefs.target_code.move,move_events,pre_event_time,post_event_time);
            %         mean_target_code_by_event = mean(cell2mat(target_code_by_event),2);
            %         new_time = min(feature_timeS):1/(Extract.data_rate):max(feature_timeS);
            
            %         % EMG
            %         % Get processed EMG
            %         load([Extract.file_path filesep metadata_entry.Preproc.Pointer_processed_data_for_events]);
            %         [EMG_by_event]=Organize_TimeLockToEvents(processed_data.EMG_data(:,1),move_events,pre_event_time,post_event_time);
            %         mean_EMG_by_event = mean(cell2mat(EMG_by_event),2);
            %
            %         % %% ACC
            %         % % Get processed ACC
            %         % load([Extract.file_path filesep metadata_entry.Preproc.Pointer_processed_data_for_events]);
            %         % [ACC_by_event]=Organize_TimeLockToEvents(processed_data.ACC_data(:,1),move_events,pre_event_time,post_event_time);
            %         % mean_ACC_by_event = mean(cell2mat(ACC_by_event),2);
            %
            %         EMG_smooth = Normalize(Calc_Filter_Freq_SimpleButter(mean_EMG_by_event,1,Extract.data_rate,'low'));
            %         EMG_smooth_short = EMG_smooth(find_closest_in_list_idx(feature_timeS,new_time));
            %         Target_smooth = (Calc_Filter_Freq_SimpleButter(mean_target_code_by_event>0,1,Extract.data_rate,'low'));
            %         Target_smooth_short = Target_smooth(find_closest_in_list_idx(feature_timeS,new_time));
            
            current_sensors = DEF_MEG_sensors_sensorimotor_left_hemi_BEST;
            freqrange_name = 'beta';
            current_freq_idx = unique(find_closest_in_list_idx([min(DEF_freq_bands(freqrange_name)):max(DEF_freq_bands(freqrange_name))],FeatureParms.actual_freqs));
            PSD_smooth.(freqrange_name) = (Calc_Filter_Freq_SimpleButter(mean(pzscore_moddepth(:,find_lists_overlap_idx(Extract.channel_list(best_chan_idx),current_sensors),current_freq_idx),3),1,FeatureParms.timeS_to_feature_sample,'low'));
            % PSD_smooth.(freqrange_name) = mean(pzscore_moddepth(:,find_lists_overlap(Extract.channel_list(best_chan_idx),current_sensors),current_freq_idx),3);
            
            [max_PSD.(freqrange_name)(iparm,:),max_PSD_idx]=max(-1.*PSD_smooth.(freqrange_name));
            max_PSD_timeS.(freqrange_name)(iparm,:) = feature_timeS(max_PSD_idx);
            
            freqrange_name = 'gamma';
            current_freq_idx = unique(find_closest_in_list_idx([min(DEF_freq_bands(freqrange_name)):max(DEF_freq_bands(freqrange_name))],FeatureParms.actual_freqs));
            PSD_smooth.(freqrange_name) = (Calc_Filter_Freq_SimpleButter(mean(pzscore_moddepth(:,find_lists_overlap_idx(Extract.channel_list(best_chan_idx),current_sensors),current_freq_idx),3),1,FeatureParms.timeS_to_feature_sample,'low'));
            % PSD_smooth.(freqrange_name) = mean(pzscore_moddepth(:,find_lists_overlap(Extract.channel_list(best_chan_idx),current_sensors),current_freq_idx),3);
            
            [max_PSD.(freqrange_name)(iparm,:),max_PSD_idx]=max(PSD_smooth.(freqrange_name));
            max_PSD_timeS.(freqrange_name)(iparm,:) = feature_timeS(max_PSD_idx);
            %     disp([num2str(max(max_PSD.(freqrange_name)(iparm,:))) ' @' num2str(max_PSD_timeS.(freqrange_name)(iparm,max_idx(max_PSD.(freqrange_name)(iparm,:)))) 's'])
            %     disp_mean_std(max_PSD_timeS.(freqrange_name)(iparm,:)')
            
        end
        disp('Done')
        toc
        
        fig=figure;
        subplot(2,1,1);hold all
        Plot_QuantileBar(max_PSD.beta',set_names,fig);
        
        Figure_TightFrame
        title(['Max Beta [' metadata_entry.subject '] (CUMREP)'])
        ylabel('STD')
        subplot(2,1,2);hold all
        Plot_QuantileBar(max_PSD.gamma',set_names,fig);
        % xlabel_rotate
        Figure_Stretch(2)
        Figure_TightFrame
        title('Max Gamma')
        ylabel('STD')
        
        fig=figure;
        subplot(2,1,1);hold all
        Plot_QuantileBar(max_PSD_timeS.beta',set_names,fig);
        ylim([-AnalysisParms.pre_event_timeS AnalysisParms.post_event_timeS])
        title(['Time of Max Beta [S] [' metadata_entry.subject '] (CUMREP)'])
        ylabel('S')
        subplot(2,1,2);hold all
        Plot_QuantileBar(max_PSD_timeS.gamma',set_names,fig);
        ylim([-AnalysisParms.pre_event_timeS AnalysisParms.post_event_timeS])
        % xlabel_rotate
        Figure_Stretch(2)
        % Figure_TightFrame
        title('Time of Max Gamma [S]')
        ylabel('S')
    end
end

%% ==============================================================================
%% ==============================================================================
%% ==============================================================================

%%
%         
%         %% Modulation Calculation for each rep
%         
%         tic
%         clear max_PSD*
%         
%         num_move_cues= length(Events.ParallelPort_Move);
%         num_moves_per_block = num_move_cues/length(Events.ParallelPort_BlockStart);
%         
%         set_names = [1:num_moves_per_block];
%         for iparm = 1:num_moves_per_block
%             move_events = sort(Events.ParallelPort_Move([iparm:num_moves_per_block:num_move_cues]));
%             
%             %             % First Few Move Reps
%             %             num_trials_per_block = iparm;
%             %             move_events=[];
%             %             for iblock = 1:length(Events.ParallelPort_BlockStart)
%             %                 move_events = [move_events Events.ParallelPort_Move(find(Events.ParallelPort_Move>Events.ParallelPort_BlockStart(iblock),num_trials_per_block,'first'))'];
%             %             end
%             
%             % First EMG trials
%             %         num_trials_per_block = iparm;
%             %         move_events=[];
%             %         for iblock = 1:length(Events.ParallelPort_BlockStart)
%             %             move_events = [move_events Events.EMG(find(Events.EMG>Events.ParallelPort_BlockStart(iblock),num_trials_per_block,'first'))];
%             %         end
%             
%             %     % Plot current events
%             %     figure;hold all
%             %     plot(TimeVecs.timeS,TimeVecs.target_code')
%             %     stem(TimeVecs.timeS(move_events),5*ones(1,length(move_events))','r.-')
%             %     Figure_Stretch(2)
%             
%             FeatureParms.feature_update_rateS=0.05;
%             AnalysisParms.pre_event_timeS=1;
%             AnalysisParms.post_event_timeS=1;
%             pre_event_time=AnalysisParms.pre_event_timeS*FeatureParms.sample_rate;
%             post_event_time=AnalysisParms.post_event_timeS*FeatureParms.sample_rate;
%             
%             
%             chan_list = DEF_MEG_sensors_sensorimotor_left_hemi_BEST;
%             
%             % REST for zscore Calc Rest power *AROUND* cue
%             FeatureParms.window_lengthS = AnalysisParms.window_lengthS_rest;
%             FeatureParms.window_length = floor(FeatureParms.window_lengthS*Extract.data_rate);
%             [feature_data_rest,FeatureParms]=Calc_PSD_TimeLocked(MEG_data_clean,Events.(AnalysisParms.event_name_rest)-floor(FeatureParms.window_length/2),FeatureParms);
%             
%             
%             % Time locked PSD
%             best_chan_idx = sensors2chanidx(Extract.channel_list,chan_list);
%             clear feature_data_by_event_by_trial analysis_window_center_time
%             [feature_data_by_event_by_trial,analysis_window_center_time,FeatureParms]=Calc_TimeFreqAnalysis_TimeLocked(MEG_data_clean(:,best_chan_idx,:),move_events,pre_event_time,post_event_time,FeatureParms);
%             % trial x chan x freq x event
%             feature_timeS=analysis_window_center_time/FeatureParms.sample_rate;
%             
%             clear pzscore_moddepth
%             for ichan = 1:size(feature_data_by_event_by_trial,2)
%                 for ifreq = 1:size(feature_data_by_event_by_trial,3)
%                     pzscore_moddepth(:,ichan,ifreq)=mean(( feature_data_by_event_by_trial(:,ichan,ifreq,:)-mean(feature_data_rest(:,best_chan_idx(ichan),ifreq),1) )./std(feature_data_rest(:,best_chan_idx(ichan),ifreq),[],1),4);
%                 end
%             end
%             
%             
%             % Modulation depth
%             % clear pzscore_moddepth
%             % feature_data_by_event=squeeze(mean(feature_data_by_event_by_trial,4));
%             % [pzscore_moddepth,sensor_group_list] = Calc_MEG_ModDepth(feature_data_by_event,feature_data_rest(:,best_chan_idx,:),Extract.channel_list(best_chan_idx),0);
%             
%             
% %             
% %             % Organize by time lock
% %             % Target Code
% %             ExpDefs.paradigm_type=metadata_entry.run_type;
% %             ExpDefs=Prep_ExpDefs(ExpDefs);
% %             TimeVecs=Prep_TargetCode(TimeVecs,ExpDefs);
% %             [target_code_by_event]=Organize_TimeLockToEvents(TimeVecs.target_code==ExpDefs.target_code.move,move_events,pre_event_time,post_event_time);
% %             mean_target_code_by_event = mean(cell2mat(target_code_by_event),2);
% %             new_time = min(feature_timeS):1/(Extract.data_rate):max(feature_timeS);
% %             
% %             % EMG
% %             % Get processed EMG
% %             load([Extract.file_path filesep metadata_entry.Preproc.Pointer_processed_data_for_events]);
% %             [EMG_by_event]=Organize_TimeLockToEvents(processed_data.EMG_data(:,1),move_events,pre_event_time,post_event_time);
% %             mean_EMG_by_event = mean(cell2mat(EMG_by_event),2);
% %             
% %             % %% ACC
% %             % % Get processed ACC
% %             % load([Extract.file_path filesep metadata_entry.Preproc.Pointer_processed_data_for_events]);
% %             % [ACC_by_event]=Organize_TimeLockToEvents(processed_data.ACC_data(:,1),move_events,pre_event_time,post_event_time);
% %             % mean_ACC_by_event = mean(cell2mat(ACC_by_event),2);
% %             
% %             EMG_smooth = Normalize(Calc_Filter_Freq_SimpleButter(mean_EMG_by_event,1,Extract.data_rate,'low'));
% %             EMG_smooth_short = EMG_smooth(find_closest_in_list_idx(feature_timeS,new_time));
% %             Target_smooth = (Calc_Filter_Freq_SimpleButter(mean_target_code_by_event>0,1,Extract.data_rate,'low'));
% %             Target_smooth_short = Target_smooth(find_closest_in_list_idx(feature_timeS,new_time));
%             
%             
%             current_sensors = DEF_MEG_sensors_sensorimotor_left_hemi_BEST;
%             freqrange_name = 'beta';
%             current_freq_idx = unique(find_closest_in_list_idx([min(DEF_freq_bands(freqrange_name)):max(DEF_freq_bands(freqrange_name))],FeatureParms.actual_freqs));
%             PSD_smooth.(freqrange_name) = (Calc_Filter_Freq_SimpleButter(mean(pzscore_moddepth(:,find_lists_overlap(Extract.channel_list(best_chan_idx),current_sensors),current_freq_idx),3),1,FeatureParms.timeS_to_feature_sample,'low'));
%             % PSD_smooth.(freqrange_name) = mean(pzscore_moddepth(:,find_lists_overlap(Extract.channel_list(best_chan_idx),current_sensors),current_freq_idx),3);
%             
%             [max_PSD.(freqrange_name)(iparm,:),max_PSD_idx]=max(-1.*PSD_smooth.(freqrange_name));
%             max_PSD_timeS.(freqrange_name)(iparm,:) = feature_timeS(max_PSD_idx);
%             
%             freqrange_name = 'gamma';
%             current_freq_idx = unique(find_closest_in_list_idx([min(DEF_freq_bands(freqrange_name)):max(DEF_freq_bands(freqrange_name))],FeatureParms.actual_freqs));
%             PSD_smooth.(freqrange_name) = (Calc_Filter_Freq_SimpleButter(mean(pzscore_moddepth(:,find_lists_overlap(Extract.channel_list(best_chan_idx),current_sensors),current_freq_idx),3),1,FeatureParms.timeS_to_feature_sample,'low'));
%             % PSD_smooth.(freqrange_name) = mean(pzscore_moddepth(:,find_lists_overlap(Extract.channel_list(best_chan_idx),current_sensors),current_freq_idx),3);
%             
%             [max_PSD.(freqrange_name)(iparm,:),max_PSD_idx]=max(PSD_smooth.(freqrange_name));
%             max_PSD_timeS.(freqrange_name)(iparm,:) = feature_timeS(max_PSD_idx);
%             %     disp([num2str(max(max_PSD.(freqrange_name)(iparm,:))) ' @' num2str(max_PSD_timeS.(freqrange_name)(iparm,max_idx(max_PSD.(freqrange_name)(iparm,:)))) 's'])
%             %     disp_mean_std(max_PSD_timeS.(freqrange_name)(iparm,:)')
%             
%         end
%         disp('Done')
%         toc
%         
%         fig=figure;
%         subplot(2,1,1);hold all
%         Plot_QuantileBar(max_PSD.beta',set_names,fig);
%         
%         Figure_TightFrame
%         title(['Max Beta [' metadata_entry.subject '] (By REP)'])
%         ylabel('STD')
%         subplot(2,1,2);hold all
%         Plot_QuantileBar(max_PSD.gamma',set_names,fig);
%         % xlabel_rotate
%         Figure_Stretch(2)
%         Figure_TightFrame
%         title('Max Gamma')
%         ylabel('STD')
%         
%         fig=figure;
%         subplot(2,1,1);hold all
%         Plot_QuantileBar(max_PSD_timeS.beta',set_names,fig);
%         ylim([-AnalysisParms.pre_event_timeS AnalysisParms.post_event_timeS])
%         title(['Time of Max Beta [S] [' metadata_entry.subject '] (By REP)'])
%         ylabel('S')
%         subplot(2,1,2);hold all
%         Plot_QuantileBar(max_PSD_timeS.gamma',set_names,fig);
%         ylim([-AnalysisParms.pre_event_timeS AnalysisParms.post_event_timeS])
%         % xlabel_rotate
%         Figure_Stretch(2)
%         % Figure_TightFrame
%         title('Time of Max Gamma [S]')
%         ylabel('S')
%     end
% end