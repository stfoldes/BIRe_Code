% After Source and Sensor data is made, this will make plots and junk
% Needs an ROI
% Uses DB, w/ saving
%
% 2014-03-27 Foldes

clearvars -except DB

save_DB_flag = true;

%% PARAMETERS

% Choose criteria for data set to analyize
clear criteria
% criteria.subject =          {'NC11','NC12','NS08','NS10','NS11'};
criteria.run_intention =    'Attempt';
criteria.run_task_side =    'Right';
criteria.run_action =       'Grasp';
criteria.run_type =         'Open_Loop_MEG';

% criteria.subject_type = 'AB';
criteria.subject_type = 'SCI';

%% Build database (unless loaded)
if ~exist('DB','var')
    DB = DB_MEG_Class;
    DB = DB.build('PATHS_meg_neurofeedback'); % also sets global MY_PATHS
end

%% Loop

% ===TESTING SCRIPT===
if ~isempty(criteria)
    DB_short = DB.get_entry(criteria);
else
    DB_short = DB;
end
% ientry = 1;
% DB_entry = DB_short(ientry);
% ====================

tic
% Loop for All Entries
clear moddepth_group
entry_cnt = 0;
for ientry = 1:length(DB_short)
    % ientry = 1;
    DB_entry = DB_short(ientry);
    disp(' ')
    disp(['===START: File #' num2str(ientry) '/' num2str(length(DB_short)) ' | ' DB_entry.entry_id '==='])  
    
    
    % ===Load pointers===
    clear SourceData SensorData
    % SourceData
    DB_entry.load_pointer('ResultPointers.SourceModDepth_tsss_Cue');
    % SensorData
    DB_entry.load_pointer('ResultPointers.SensorModDepth_tsss_Cue');
    if ~exist('SourceData') || ~exist('SensorData')
        continue
    end
    AnalysisParms = SensorData.AnalysisParms;
        
    AnalysisParms.freq4sources = [DEF_freq_bands('beta'); DEF_freq_bands('gamma')];
    AnalysisParms.moddepth_method = '%';
    
    %% Got to source space
    % For all freq and trials, SourceData will be 1.3Gb
    % Only do for given freq band OR ROI
    
    nFreq =     length(SensorData.FeatureParms.freq_bins);
    nSources =  size(SourceData.SmoothSourceKernel,1);
    
    % % Calc sources from all trials and freq [20s]
    % % This takes alot of memory, not worth is
    % SourceData.feature_data_move = zeros(size(SensorData.feature_data_move,1),nSources,nFreq);
    % SourceData.feature_data_rest = zeros(size(SensorData.feature_data_rest,1),nSources,nFreq);
    % for ifreq = 1:nFreq
    %     for itrial = 1:size(SensorData.feature_data_move,1)
    %         SourceData.feature_data_move(itrial,:,ifreq) = (SourceData.SmoothSourceKernel * SensorData.feature_data_move(itrial,:,ifreq)')';
    %     end
    %     for itrial = 1:size(SensorData.feature_data_rest,1)
    %         SourceData.feature_data_rest(itrial,:,ifreq) = (SourceData.SmoothSourceKernel * SensorData.feature_data_rest(itrial,:,ifreq)')';
    %     end
    % end
    
    entry_cnt = entry_cnt + 1;
    for ifreq = 1:size(AnalysisParms.freq4sources,1)
        freq_band_idx =     [find_closest_range_idx(AnalysisParms.freq4sources(ifreq,:),SensorData.FeatureParms.actual_freqs)]; % do that find_closet stuff to get the valid indicies (what if you don't have 1Hz res?)
        current_freq_idx =  [min(freq_band_idx):max(freq_band_idx)];
        % Avg across freq band and trial
        sensor_data =       squeeze(mean(mean(SensorData.moddepth(:,:,current_freq_idx),3),1));
        source_feature_data_move = zeros(size(SensorData.feature_data_move,1),nSources);
        source_feature_data_rest = zeros(size(SensorData.feature_data_rest,1),nSources);
        for itrial = 1:size(SensorData.feature_data_move,1)
            source_feature_data_move(itrial,:) = (SourceData.SmoothSourceKernel * mean(SensorData.feature_data_move(itrial,:,current_freq_idx),3)')';
        end
        for itrial = 1:size(SensorData.feature_data_rest,1)
            source_feature_data_rest(itrial,:) = (SourceData.SmoothSourceKernel * mean(SensorData.feature_data_rest(itrial,:,current_freq_idx),3)')';
        end
        %SourceData.moddepth(:,:,ifreq) = Calc_ModDepth(source_feature_data_move,source_feature_data_rest,AnalysisParms.moddepth_method);
        % moddepth_group{entry_cnt}(:,:,ifreq) = Calc_ModDepth(source_feature_data_move,source_feature_data_rest,AnalysisParms.moddepth_method);
        moddepth_group(entry_cnt,:,ifreq) = mean(Calc_ModDepth(source_feature_data_move,source_feature_data_rest,AnalysisParms.moddepth_method),1);
        subject_name{entry_cnt} = DB_entry.subject;
    end
       
    
end % group loop
toc

%% Display sources (must have approrate figure up)

freq_idx = 1;
source_data = median(moddepth_group(:,:,freq_idx),1)';
% source_data = mean(moddepth_group(:,:,freq_idx),1)';
BST_Set_Sources(gcf,source_data);

%% Each subject

for isubject = 1:size(moddepth_group,1)
    source_data = moddepth_group(isubject,:,freq_idx)';
    BST_Set_Sources(gcf,source_data);
    subject_name{isubject}
    pause(2)
end

isubject = 0;


isubject = isubject+1;
source_data = moddepth_group(isubject,:,freq_idx)';
BST_Set_Sources(gcf,source_data);
subject_name{isubject}


%%


isubject = isubject+1;
source_data = moddepth_group(isubject,:,freq_idx)';






%% Save database out to file
% if save_DB_flag == 1
%     DB.save_DB;
% end




