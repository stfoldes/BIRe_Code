% 2012-02 Stephen
% Checks to see if FIF and CRX data are the same, checks raw data and PSD (FIF-PSD, CRX-Raw-PSD, and CRX-PSD)
clear
tic

%% ---REQUIRED INPUT INFORMATION---
    %---Data Set Info-----------------
    Extract.subject = 'nc01';
%     Extract.subject = 'nc02';
%     Extract.subject = 'nc03';
    
%     Extract.session = '01';
%     Extract.run_type = 'Grasp Imitate';
%     Extract.run_type = 'Grasp Observe';
%     Extract.run_type = 'Grasp Attempt';
%     Extract.run_type = 'Grasp Imagine';

    Extract.session = '02';
    Extract.run_type = 'Grasp Control';
    Extract.file_type = 'FIF';

    Extract.channel_list=[13];%DEF_left_hemi_sma_MEG_sensors;%
%     Extract.file_type = 'FIF';
    Extract=Prep_Extract_w_basic_info(Extract); % Don't worry, I'll fill in all the other info
    %-------------------------------
    
    %---Experimental Defintions (ExpDefs.)---
    ExpDefs.paradigm_type=Extract.paradigm_type; % Use Extract.paradigm_type in auto populating
    ExpDefs.sample_rate=Extract.sample_rate;
    %-------------------------------
    
    ExpDefs=Prep_ExpDefs(ExpDefs);
    
    [raw_data_FIF,TimeVecs_FIF,TrialInfo_FIF]=Load_TimeSeries_Data(Extract,ExpDefs);

    [raw_data_CRX,TimeVecs_CRX,Extract_CRX.channel_list]=Load_All_Data_from_CRX(Extract);
    FeatureVecs.target_code=FeatureVecs.target_code_org.*(FeatureVecs.state_code==ExpDefs.state_code.go);
    TrialInfo_CRX.featureseries_trial_start_idx = TrialTransitions(FeatureVecs.target_code); % indicies in the feature data (i.e. sliding-windowing rate) where target_code changes happen (i.e. trial starting points)

    
    %%
    
    fig=figure;
    for chan_num=1
        durationS = 120;
        FIF_end = length(raw_data_FIF);
        CRX_end = length(raw_data_CRX);
        %     FIF_chan_idx = chan_num;
        %     CRX_chan_idx = find(Extract.channel_list(chan_num) == Extract_CRX.channel_list);
        
        FIF_chan_idx = chan_num;
        CRX_chan_idx = 1;
        
        clf(fig);
        
        subplot(3,1,1);hold all
        plot(TimeVecs_FIF.target_code([FIF_end-(durationS*1000):FIF_end],:),'r')
        plot(TimeVecs_CRX.target_code([CRX_end-(durationS*1000):CRX_end],:),'g')
        xlim([0 durationS*1000])
        legend('FIF','CRX')
        
        subplot(3,1,2);hold all
        plot(zscore(raw_data_FIF(:,FIF_chan_idx)),'k')
        plot(TimeVecs_FIF.target_code,'r')
        xlim([FIF_end-(durationS*1000) FIF_end])
        title(['FIF: Channel #' num2str(Extract.channel_list(FIF_chan_idx))])
        
        subplot(3,1,3);hold all
        plot(zscore(raw_data_CRX(:,CRX_chan_idx)),'k')
        plot(TimeVecs_CRX.target_code,'r')
        xlim([CRX_end-(durationS*1000) CRX_end])
        title(['CRX: Channel #' num2str(Extract_CRX.channel_list(CRX_chan_idx))])
        
        pause(1.5)
        
    end
    
    
    
    %%
    
        fig=figure;
    for chan_num=1
        durationS = 500;
        FIF_chan_idx = chan_num;
        CRX_chan_idx = 1;
        
        clf(fig);
        
        subplot(2,1,1);hold all
        plot(zscore(raw_data_FIF(end-(durationS*1000):100:end,FIF_chan_idx)),'k')
%         plot(TimeVecs_FIF.target_code,'r')
        %xlim([FIF_end-(durationS*1000) FIF_end])
        title(['FIF: Channel #' num2str(Extract.channel_list(FIF_chan_idx))])
        xlim([0 (durationS*1000)/100])
        subplot(2,1,2);hold all
        plot(zscore(raw_data_CRX(end-(durationS*1000):100:end,CRX_chan_idx)),'k')
%         plot(TimeVecs_CRX.target_code,'r')
        %xlim([CRX_end-(durationS*1000) CRX_end])
        title(['CRX: Channel #' num2str(Extract_CRX.channel_list(CRX_chan_idx))])
        xlim([0 (durationS*1000)/100])
        pause(1.5)
        
    end
    
    %%
        fig=figure;
        
        
        chan_num=1;
        offset_samples = 40000;
        durationS =1000;
        
        FIF_chan_idx = chan_num;
        CRX_chan_idx = 1;
        
        clf(fig);
        
       hold all
        plot((raw_data_FIF(offset_samples+1:100:offset_samples+(durationS*1000),FIF_chan_idx)),'k')
%         plot(TimeVecs_FIF.target_code,'r')
        %xlim([FIF_end-(durationS*1000) FIF_end])
        title(['OFFSET: ' num2str(offset_samples) '; FIF: Channel #' num2str(Extract.channel_list(FIF_chan_idx))])
        plot((raw_data_CRX(1:100:(durationS*1000),CRX_chan_idx)),'Color','r')
%         plot(TimeVecs_CRX.target_code,'r')
        %xlim([CRX_end-(durationS*1000) CRX_end])
%         xlim([0 (durationS*1000)/100])
        legend('FIF','CRX')
        
        
%%

    
    %---Feature Parameters (FeatureParms.)---
    % Can be empty for loading feature data from CRX files
    FeatureParms.feature_method = 'MEM';
    FeatureParms.order = 25;
    FeatureParms.feature_resolution = 6;
    FeatureParms.ideal_freqs = [0:40]; % Pick freq or bins
    FeatureParms.window_lengthS = 0.3;
    FeatureParms.feature_update_rateS = 0.05; % progress at X second shifts
    FeatureParms.sample_rate = Extract.sample_rate;
    %-------------------------------
    FeatureParms=Prep_FeatureParms(FeatureParms);
    


[feature_data_FIF,FeatureVecs_FIF,TrialInfo_FIF]=Calc_Feature_Data(raw_data_FIF,TimeVecs_FIF,TrialInfo_FIF,FeatureParms,Extract,ExpDefs);
[feature_data_CRX,FeatureVecs_CRX,TrialInfo_CRX]=Calc_Feature_Data(raw_data_CRX(:,1),TimeVecs_CRX,TrialInfo_CRX,FeatureParms,Extract,ExpDefs);

%%

baseline_for_percent_change_FIF = squeeze(mean(feature_data_FIF(find(FeatureVecs_FIF.target_code==ExpDefs.target_code.rest),:,:),1));
[norm_feature_data_FIF] = Calc_Percent_Change_from_Baseline(feature_data_FIF,baseline_for_percent_change_FIF');
fig=Plot_PSD_Quick(norm_feature_data_FIF,FeatureParms,1);
figure(fig);hold all
plot(FeatureVecs_FIF.timeS,20*FeatureVecs_FIF.target_code,'k')
xlim([1500 1600])
baseline_for_percent_change_CRX = squeeze(mean(feature_data_CRX(find(FeatureVecs_CRX.target_code==ExpDefs.target_code.rest),:,:),1));
[norm_feature_data_CRX] = Calc_Percent_Change_from_Baseline(feature_data_CRX,baseline_for_percent_change_CRX');
fig=Plot_PSD_Quick(norm_feature_data_CRX,FeatureParms,1);   
figure(fig);hold all
xlim([1500 1600])
plot(FeatureVecs_CRX.timeS,20*FeatureVecs_CRX.target_code,'k')


%%
Extract2=Extract;
Extract2.file_type='CRX';
TimeVecs_CRX2=[];
TrialInfo_CRX2=[];
FeatureParms_CRX2=[];
clear FeatureVecs_CRX2 feature_data_CRX2
[feature_data_CRX2,FeatureVecs_CRX2,TrialInfo_CRX2,FeatureParms_CRX2]=Calc_Feature_Data([],TimeVecs_CRX2,TrialInfo_CRX2,FeatureParms_CRX2,Extract2,ExpDefs);

baseline_for_percent_change = squeeze(mean(feature_data(find(FeatureVecs.target_code==ExpDefs.target_code.rest),:,:),1));
[norm_feature_data] = Calc_Percent_Change_from_Baseline(feature_data(:,1,:),baseline_for_percent_change(1,:));
[fig,feature_time_vec]=Plot_PSD_Quick(norm_feature_data,FeatureParms,1);   
figure(fig);hold all
plot(feature_time_vec,20*FeatureVecs.target_code_org,'k')
% plot(feature_time_vec,10+FeatureVecs.target_pos*0.2,'k','LineWidth',2)
xlim([1530 1560]);ylim([10 30]);center_caxis(0.3)


