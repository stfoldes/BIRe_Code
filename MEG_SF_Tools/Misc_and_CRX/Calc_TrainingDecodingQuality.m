%% ---DECODING OFFLINE---

% TrialInfo=rmfield(TrialInfo,'training');
% TrialInfo=rmfield(TrialInfo,'target_code');
% TrialInfo=rmfield(TrialInfo,'initial_target_pos');

% set up (should be done above)
TrialInfo.training = FeatureVecs.training_flag(TrialInfo.featureseries_go_start_idx)==1;
TrialInfo.target_code = FeatureVecs.target_code(TrialInfo.featureseries_go_start_idx);
TrialInfo.initial_target_pos = FeatureVecs.target_pos(TrialInfo.featureseries_go_start_idx);

% AnalysisParms.Decoding.using trrainingin ro juste vereytyhing

AnalysisParms.Decoding.training_trial_rxtimeS=0; % training starts 1 feature-sample after this time point
AnalysisParms.Decoding.training_trial_early_stopS=10000; % will limit to whole trial

AnalysisParms.Decoding.test_trial_rxtimeS=0; % test starts 1 feature-sample after this time point
AnalysisParms.Decoding.test_trial_early_stopS=10000; % will limit to whole trial

% How come there are 82 trials? should be 80



%%

Decoder.Masks.feature_removal_threshold = 0.1;%0.1;
Decoder.Masks.ERD_mask_flag=0;


CV.trial_list = [1:40];

CV.num_repeats=5;
CV.num_folds=5;
[CV.train_idx CV.test_idx]=Calc_CVIndices(length(CV.trial_list)/2,CV.num_repeats,CV.num_folds,1);

clear Results
for icv = 1:size(CV.test_idx,1)
        
    CV.training_trial_list=sort([2*(CV.train_idx(icv,:)-1)+1 2*(CV.train_idx(icv,:)-1)+2]);
    CV.test_trial_list=sort([2*(CV.test_idx(icv,:)-1)+1 2*(CV.test_idx(icv,:)-1)+2]);
  
        % trials_with_training_data = find((TrialInfo.target_code~=0) & (TrialInfo.training==0));
        % trials_with_test_data = find((TrialInfo.target_code~=0) & (TrialInfo.training==0));
        trials_with_training_data = find((TrialInfo.target_code~=0));
        trials_with_test_data = find((TrialInfo.target_code~=0));
        
        % Define testing and training time sections
        training_trial_rxtime=floor(AnalysisParms.Decoding.training_trial_rxtimeS/(FeatureParms.feature_update_rate/FeatureParms.sample_rate));
        training_trial_early_stop=floor(AnalysisParms.Decoding.training_trial_early_stopS/(FeatureParms.feature_update_rate/FeatureParms.sample_rate));
        
        test_trial_rxtime=floor(AnalysisParms.Decoding.test_trial_rxtimeS/(FeatureParms.feature_update_rate/FeatureParms.sample_rate));
        test_trial_early_stop=floor(AnalysisParms.Decoding.test_trial_early_stopS/(FeatureParms.feature_update_rate/FeatureParms.sample_rate));
        
        % Defining Training Data
        training_idx = [];
        training_data_trialavg = [];
        num_training_trials_used=min(length(CV.training_trial_list),length(trials_with_training_data));
        
        clear training_code_trialavg training_data_trialavg training_pos_trialavg
        for itrial =1:num_training_trials_used
            clear current_trial_idx current_trial_idx_for_training
            %     current_trial_idx = TrialInfo.featureseries_trial_start_idx(trials_with_training_data(itrial)):TrialInfo.featureseries_trial_start_idx(trials_with_training_data(itrial)+1)-1;
            current_trial_idx = TrialInfo.featureseries_trial_start_idx(trials_with_training_data(CV.training_trial_list(itrial))):TrialInfo.featureseries_trial_start_idx(trials_with_training_data(CV.training_trial_list(itrial))+1)-1;
            
            % lim what part of the data you use for training
            current_trial_idx_for_training = current_trial_idx(training_trial_rxtime+1:min(training_trial_early_stop,length(current_trial_idx))); %
            
            training_idx = [training_idx current_trial_idx_for_training];
            training_data_trialavg(itrial,:) = mean(reshape(feature_data(current_trial_idx_for_training,:,:),length(current_trial_idx_for_training),[]));
            training_code_trialavg(itrial,:) = mean(FeatureVecs.target_code(current_trial_idx_for_training,:))-1.5; % all should be the same
            training_pos_trialavg(itrial,:) = mean(FeatureVecs.target_pos(current_trial_idx_for_training,:)); % all should be the same
        end
        training_data = reshape(feature_data(training_idx,:,:),length(training_idx),[]);
        training_code = FeatureVecs.target_code(training_idx,:)-1.5;
        training_pos = FeatureVecs.target_pos(training_idx,:);
        
        % figure;plot([training_data_trialavg(training_code_trialavg<0,:); training_data_trialavg(training_code_trialavg>0,:)],'.-')
        
        
        % Define Testing Data       
        test_idx = [];
        num_test_trials_used=min(length(CV.test_trial_list),length(trials_with_test_data));
        for itrial =1:num_test_trials_used
            current_trial_idx = [];
            %     current_trial_idx = TrialInfo.featureseries_trial_start_idx(trials_with_test_data(itrial)):TrialInfo.featureseries_trial_start_idx(trials_with_test_data(itrial)+1)-1;
            current_trial_idx = TrialInfo.featureseries_trial_start_idx(trials_with_test_data(CV.test_trial_list(itrial))):TrialInfo.featureseries_trial_start_idx(trials_with_test_data(CV.test_trial_list(itrial))+1)-1;
            
            % lim what part of the data you use for training
            current_trial_idx_for_test = current_trial_idx(test_trial_rxtime+1:min(test_trial_early_stop,length(current_trial_idx))); %
            
            test_idx = [test_idx current_trial_idx_for_test];
        end
        
        test_data = reshape(feature_data(test_idx,:,:),length(test_idx),[]);
        test_code = FeatureVecs.target_code(test_idx,:)-1.5;
        test_pos = FeatureVecs.target_pos(test_idx,:);
        
        %% Simple Feature Removal
        
        for ifeature = 1:size(training_data,2)
            Results.feature_R2(ifeature)=find_Rsquared(training_data(:,ifeature),training_code);
            Results.feature_avg_R2(ifeature)=find_Rsquared(training_data_trialavg(:,ifeature),training_code_trialavg);
            
            Results.feature_test_R2(ifeature)=find_Rsquared(test_data(:,ifeature),test_code);
        end
        
        % figure;hold all
        % plot(Results.feature_R2,'k')
        % plot(Results.feature_avg_R2,'r')
        % plot(Results.feature_test_R2,'m')

        feature_mask = ones(size(training_data,2),1);
        feature_mask(Results.feature_avg_R2<Decoder.Masks.feature_removal_threshold)=0;

        % ERD Mask
        if Decoder.Masks.ERD_mask_flag
            for ifeature = 1:size(training_data,2)
                ERD_mask(ifeature,1)=mean(training_data_trialavg(training_code_trialavg>0,ifeature)) >= mean(training_data_trialavg(training_code_trialavg<0,ifeature));
            end
        else
            ERD_mask = ones(size(feature_mask));
        end

        disp(['Num Features: ' num2str(size(training_data,2)) ', R2 mask: ' num2str(sum(feature_mask)) ', ERD mask: ' num2str(sum(ERD_mask)) ', all masks: ' num2str(sum(ERD_mask.*feature_mask))])


        % Apply mask
        % training_data = training_data.*(feature_mask*ones(1,size(training_data,1)))';
        % test_data = test_data.*(feature_mask*ones(1,size(test_data,1)))';
        training_data = training_data.*(feature_mask*ones(1,size(training_data,1)))'.*(ERD_mask*ones(1,size(training_data,1)))';
        test_data = test_data.*(feature_mask*ones(1,size(test_data,1)))'.*(ERD_mask*ones(1,size(test_data,1)))';

% !!!!!!!!!!! Pseudo Zscore !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        % Remove training-mean
        training_data_mean = mean(training_data);
        training_data_wo_mean = training_data-ones(size(training_data,1),1)*training_data_mean;
        training_data_trialavg_wo_mean = training_data_trialavg-ones(size(training_data_trialavg,1),1)*training_data_mean;
        test_data_wo_mean = test_data-ones(size(test_data,1),1)*training_data_mean;
        
        %% ---Direct OLE---
        % CT (pinv = \)
        OLE_CT_decoder= pinv(training_data_wo_mean)*training_code;
        Results.OLE_CT_training(icv)=find_Rsquared(training_code,training_data_wo_mean * OLE_CT_decoder);
        % find_Rsquared(training_code_trialavg,training_data_trialavg_wo_mean * OLE_CT_decoder);
        Results.OLE_CT(icv)=find_Rsquared(test_code,test_data_wo_mean * OLE_CT_decoder);
        
        % TRIAL AVG
        OLE_TA_decoder= pinv(training_data_trialavg_wo_mean)*training_code_trialavg;
        Results.OLE_TA_training(icv)=find_Rsquared(training_code,training_data_wo_mean * OLE_TA_decoder);
        % find_Rsquared(training_code_trialavg,training_data_trialavg_wo_mean * OLE_TA_decoder);
        Results.OLE_TA(icv)=find_Rsquared(test_code,test_data_wo_mean * OLE_TA_decoder);
        
        % ---Indirect OLE---
        
        % N = Neural features [observations x features] --> pinv(N) = [features x obersvations]
        % K = Kinematics [observations x dimensions] --> pinv(K) = [dimensions x observations]
        %
        % Decoding Model
        % N*W = K
        % W = pinv(N)*K : Decoder Weights [features x kinematic dimensions]
        %
        % Encoding Model
        % K*E = N
        % E = pinv(K)*N : Encoding Weights [kinematic dimensions x features]
        %
        % Decoding with Encoding Model
        % N*W = K
        % (K*E)*W = K
        % (K*pinv(K)*N)*W = K
        % W = pinv(K*pinv(K)*N)*K
        
        % CT
        iOLE_CT_decoder= pinv(training_code*pinv(training_code)*training_data_wo_mean)*training_code;
        Results.iOLE_CT_training(icv)=find_Rsquared(training_code,training_data_wo_mean * iOLE_CT_decoder);
        % find_Rsquared(training_code_trialavg,training_data_trialavg_wo_mean * iOLE_CT_decoder);
        Results.iOLE_CT(icv)=find_Rsquared(test_code,test_data_wo_mean * iOLE_CT_decoder);
        
        % TRIAL AVG
        iOLE_TA_decoder= pinv(training_code_trialavg*pinv(training_code_trialavg)*training_data_trialavg_wo_mean)*training_code_trialavg;
        Results.iOLE_TA_training(icv)=find_Rsquared(training_code,training_data_wo_mean * iOLE_TA_decoder);
        % find_Rsquared(training_code_trialavg,training_data_trialavg_wo_mean * iOLE_TA_decoder);
        Results.iOLE_TA(icv)=find_Rsquared(test_code,test_data_wo_mean * iOLE_TA_decoder);
        
end % CV

%%


fig=figure;hold all
QuantileBarPlot({Results.OLE_TA Results.OLE_CT Results.iOLE_TA Results.iOLE_CT},{'OLE TA','OLE CT','iOLE TA','iOLE CT'},fig,[]);
title([num2str(CV.num_repeats) 'x' num2str(CV.num_folds) ' CV (' num2str(num_test_trials_used) ':' num2str(num_training_trials_used) ' Test:Training trials)']);
ylabel('R2')


% fig=figure;hold all
% QuantileBarPlot({Results.OLE_TA_training Results.OLE_CT_training Results.iOLE_TA_training Results.iOLE_CT_training},{'OLE TA','OLE CT','iOLE TA','iOLE CT'},fig,[]);
% title([num2str(CV.num_repeats) 'x' num2str(CV.num_folds) ' CV (' num2str(num_test_trials_used) ':' num2str(num_training_trials_used) ' Test:Training trials)']);
% ylabel('R2')

%%

