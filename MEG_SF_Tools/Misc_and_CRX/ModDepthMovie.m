    AnalysisParms.Mod_Depth.freq_idx{1}=[3:5]; % NOTE this might not match what was used during control, might need to use CRX data file explicietly
        
    AnalysisParms.Mod_Depth.start_timeS=0.5+0.150; % +150ms to center analysis window (instead of pRT)
    AnalysisParms.Mod_Depth.end_timeS=1.5+0.150;

    TrialInfo.training_flag = FeatureVecs.training_flag(TrialInfo.featureseries_trial_start_idx);
    TrialInfo.move_test_trial_nums = find(FeatureVecs.target_code(TrialInfo.featureseries_trial_start_idx)==ExpDefs.target_code.move & FeatureVecs.training_flag(TrialInfo.featureseries_trial_start_idx)==0 );
    TrialInfo.move_training_trial_nums = find(FeatureVecs.target_code(TrialInfo.featureseries_trial_start_idx)==ExpDefs.target_code.move & FeatureVecs.training_flag(TrialInfo.featureseries_trial_start_idx)==1 );

    AnalysisParms.Mod_Depth.baseline_idx2use = find(FeatureVecs.target_code==ExpDefs.target_code.rest & FeatureVecs.training_flag ==1);

    fig=figure;
    time_list = [0:0.25:5];
for itime = 1:length(time_list)
    
    
    AnalysisParms.Mod_Depth.start_timeS=time_list(itime)+0.150; % +150ms to center analysis window (instead of pRT)
    AnalysisParms.Mod_Depth.end_timeS=time_list(itime)+0.150;

    % Looking at All Data
    % modulation depth calculated during move times only (with AnalysisParms.Mod_Depth.rxtimeS)
    %     AnalysisParms.Mod_Depth.idx2use=[];
    %     for itrial = 1:length(TrialInfo.move_trial_nums)
    %         % consider the whole 'trial'
    %         % AnalysisParms.Mod_Depth.idx2use=[AnalysisParms.Mod_Depth.idx2use TrialInfo.featureseries_trial_start_idx(TrialInfo.move_trial_nums(itrial))+floor(AnalysisParms.Mod_Depth.rxtimeS*FeatureParms.timeS_to_feature_sample):TrialInfo.featureseries_trial_start_idx(TrialInfo.move_trial_nums(itrial)+1)-1];
    %         % consider only some of the 'trial'
    %         AnalysisParms.Mod_Depth.idx2use=[AnalysisParms.Mod_Depth.idx2use floor(TrialInfo.featureseries_trial_start_idx(TrialInfo.move_trial_nums(itrial))+(AnalysisParms.Mod_Depth.start_timeS*FeatureParms.timeS_to_feature_sample)):floor(TrialInfo.featureseries_trial_start_idx(TrialInfo.move_trial_nums(itrial))+(AnalysisParms.Mod_Depth.end_timeS*FeatureParms.timeS_to_feature_sample))];
    %     end
    
    % Looking at Control Data only
    % modulation depth calculated during move times only (with AnalysisParms.Mod_Depth.rxtimeS)
    AnalysisParms.Mod_Depth.idx2use=[];
    for itrial = 1:length(TrialInfo.move_test_trial_nums)
        % consider the whole 'trial'
        % AnalysisParms.Mod_Depth.idx2use=[AnalysisParms.Mod_Depth.idx2use TrialInfo.featureseries_trial_start_idx(TrialInfo.move_test_trial_nums(itrial))+floor(AnalysisParms.Mod_Depth.rxtimeS*FeatureParms.timeS_to_feature_sample):TrialInfo.featureseries_trial_start_idx(TrialInfo.move_test_trial_nums(itrial)+1)-1];
        % consider only some of the 'trial'
        AnalysisParms.Mod_Depth.idx2use=[AnalysisParms.Mod_Depth.idx2use floor(TrialInfo.featureseries_trial_start_idx(TrialInfo.move_test_trial_nums(itrial))+(AnalysisParms.Mod_Depth.start_timeS*FeatureParms.timeS_to_feature_sample)):floor(TrialInfo.featureseries_trial_start_idx(TrialInfo.move_test_trial_nums(itrial))+(AnalysisParms.Mod_Depth.end_timeS*FeatureParms.timeS_to_feature_sample))];
    end
    
    % Looking at Training Data only
    %     AnalysisParms.Mod_Depth.idx2use=[];
    %     for itrial = 1:length(TrialInfo.move_training_trial_nums)    
    %         % consider the whole 'trial'
    % %         AnalysisParms.Mod_Depth.idx2use=[AnalysisParms.Mod_Depth.idx2use TrialInfo.featureseries_trial_start_idx(TrialInfo.move_training_trial_nums(itrial))+floor(AnalysisParms.Mod_Depth.rxtimeS*FeatureParms.timeS_to_feature_sample):TrialInfo.featureseries_trial_start_idx(TrialInfo.move_training_trial_nums(itrial)+1)-1];
    %         % consider only some of the 'trial'
    %         AnalysisParms.Mod_Depth.idx2use=[AnalysisParms.Mod_Depth.idx2use floor(TrialInfo.featureseries_trial_start_idx(TrialInfo.move_training_trial_nums(itrial))+(AnalysisParms.Mod_Depth.start_timeS*FeatureParms.timeS_to_feature_sample)):floor(TrialInfo.featureseries_trial_start_idx(TrialInfo.move_training_trial_nums(itrial))+(AnalysisParms.Mod_Depth.end_timeS*FeatureParms.timeS_to_feature_sample))];
    %     end    
    
    for ifreq_set=1%:size(AnalysisParms.Mod_Depth.ideal_freq_range,1) DONT UNCOMMENT
        % calculate total power in SMR during move cues, the relate to baseline
        for ichan = 1:size(feature_data,2)
            clear move_power baseline_for_mod_depth
            move_power = mean(sum(feature_data(AnalysisParms.Mod_Depth.idx2use,ichan,AnalysisParms.Mod_Depth.freq_idx{ifreq_set}),3),1);
            baseline_for_mod_depth = mean(sum(feature_data(AnalysisParms.Mod_Depth.baseline_idx2use,ichan,AnalysisParms.Mod_Depth.freq_idx{ifreq_set}),3),1);
            mod_depth(:,ichan) = (move_power-baseline_for_mod_depth)./abs(baseline_for_mod_depth);
        end

        % head plot of mod_depth
%         fig=figure;hold all;set(gca,'FontSize',12)
%         Plot_MEG_head_plot(100*mod_depth,3,Extract.channel_list,[],0,fig);
%         colorbar_with_label(['% Change from ' AnalysisParms.Mod_Depth.baseline_type])
%         center_caxis(7)
%         Plot_MEG_chan_locations(Extract.channel_list,0,'r',fig);
%         title(['Magnetometers: ' num2str(min(AnalysisParms.Mod_Depth.actual_freqs{ifreq_set})) '-' num2str(max(AnalysisParms.Mod_Depth.actual_freqs{ifreq_set})) 'Hz, ' Extract.run_type ', ' Extract.subject])

        
        clf
        rect = get(fig,'Position'); rect(1:2) = [0 0];
        
        hold all;set(gca,'FontSize',12)
        
%         Plot_MEG_head_plot(100*mod_depth,1,Extract.channel_list,[],0,fig);
%         colorbar_with_label(['% Change from ' AnalysisParms.Mod_Depth.baseline_type])
%         center_caxis(7)
%         Plot_MEG_chan_locations(Extract.channel_list,0,'r',fig);
% %         title(['Longitudinal Grads: ' num2str(min(AnalysisParms.Mod_Depth.actual_freqs{ifreq_set})) '-' num2str(max(AnalysisParms.Mod_Depth.actual_freqs{ifreq_set})) 'Hz, ' Extract.run_type ', ' Extract.subject ', ' num2str(time_list(itime)) 'S'])
%         title([num2str(time_list(itime)) 'S'])

        Plot_MEG_head_plot(100*mod_depth,2,Extract.channel_list,[],0,fig);
        colorbar_with_label(['% Change from ' AnalysisParms.Mod_Depth.baseline_type])
        center_caxis(7)
        Plot_MEG_chan_locations(Extract.channel_list,0,'r',fig);
%         title(['Latitudinal Grads: ' num2str(min(AnalysisParms.Mod_Depth.actual_freqs{ifreq_set})) '-' num2str(max(AnalysisParms.Mod_Depth.actual_freqs{ifreq_set})) 'Hz, ' Extract.run_type ', ' Extract.subject])
        title([num2str(time_list(itime)) 'S'])
    end

    
    %%
        pause(0.5)
    
        new_mov(itime) = getframe(gcf,rect);
        
        end % making movie
        
%% Saving

    movie_name='ns02s02_grasp_control_modulation_depth';
    record_speed=1;
    movie2avi(new_mov, ['C:\Users\hRNEL\Documents\MATLAB\' movie_name],'fps',record_speed);