




% nc02s01r04 - Drop
% X nc07s01r12 - Anat
% nc08s01r14 - Anat
% nc09s01r03 - Anat
% nc10s01r08 - Anat
% nc11/12 - anything in DB? (need Anat for 11) need MEG
% 
% ns04s02r06 - 2nd session
% X ns07s01r13 - Anat
% X ns08s01r09 - NO MRI
% X ns10s01r06 - NO MRI
% X ns11s01r03 - NO MRI


% Check anatomy b/f doing my stuff.
% thickness --> groups, for all subjects
% What if using template already? It doesn't move to GroupAnalysis




%% Got to source space
% % To do all freq and trials, SourceData will be 1.3Gb
% % This defaults to doing only the given freq
% tic
% 
% 
% 
% nFreq =     length(SensorData.FeatureParms.freq_bins);
% nSources =  size(SourceData.ImagingKernel,1);
% 
% % % Calc sources from all trials and freq [20s]
% % % This takes alot of memory, not worth is
% % SourceData.feature_data_move = zeros(size(SensorData.feature_data_move,1),nSources,nFreq);
% % SourceData.feature_data_rest = zeros(size(SensorData.feature_data_rest,1),nSources,nFreq);
% % for ifreq = 1:nFreq
% %     for itrial = 1:size(SensorData.feature_data_move,1)
% %         SourceData.feature_data_move(itrial,:,ifreq) = (SourceData.ImagingKernel * SensorData.feature_data_move(itrial,:,ifreq)')';
% %     end
% %     for itrial = 1:size(SensorData.feature_data_rest,1)
% %         SourceData.feature_data_rest(itrial,:,ifreq) = (SourceData.ImagingKernel * SensorData.feature_data_rest(itrial,:,ifreq)')';
% %     end
% % end
% 
% 
% for ifreq = 1:size(AnalysisParms.freq4sources,1)
%     freq_band_idx =     [find_closest_range_idx(AnalysisParms.freq4sources(ifreq,:),SensorData.FeatureParms.actual_freqs)]; % do that find_closet stuff to get the valid indicies (what if you don't have 1Hz res?)
%     current_freq_idx =  [min(freq_band_idx):max(freq_band_idx)];
%     % Avg across freq band and trial
%     sensor_data =       squeeze(mean(mean(SensorData.moddepth(:,:,current_freq_idx),3),1));
%     source_feature_data_move = zeros(size(SensorData.feature_data_move,1),nSources);
%     source_feature_data_rest = zeros(size(SensorData.feature_data_rest,1),nSources);
%     for itrial = 1:size(SensorData.feature_data_move,1)
%         source_feature_data_move(itrial,:) = (SourceData.SmoothSourceKernel * mean(SensorData.feature_data_move(itrial,:,current_freq_idx),3)')';
%     end
%     for itrial = 1:size(SensorData.feature_data_rest,1)
%         source_feature_data_rest(itrial,:) = (SourceData.SmoothSourceKernel * mean(SensorData.feature_data_rest(itrial,:,current_freq_idx),3)')';
%     end
%     SourceData.moddepth(:,:,ifreq) = Calc_ModDepth(source_feature_data_move,source_feature_data_rest,AnalysisParms.moddepth_method);    
% end
% 
% toc
% 
% %% Display sources (must have approrate figure up)
% source_data = mean(SourceData.moddepth(:,:,2),1)';
% BST_Set_Sources(gcf,source_data);
% % Turn off absolute value
% 
% % copyobj(gcf,0)