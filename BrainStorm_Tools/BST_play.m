
% figure;hold all
% plot3(GridLoc(:,1),GridLoc(:,2),GridLoc(:,3),'.')
%
% % http://neuroimage.usc.edu/forums/showthread.php?918



%% Load DB

clearvars -except DB
% Build database
if ~exist('DB','var')
    DB=DB_MEG_Class;
    DB=DB.build('PATHS_meg_neurofeedback'); % also sets global MY_PATHS
end

%% Get desired metadata

% Choose criteria for data set to analyize
clear criteria
criteria.subject = 'NC01';
criteria.run_type = 'Open_Loop_MEG';
criteria.run_task_side = 'Right';
criteria.run_action = 'Grasp';
criteria.run_intention = 'Attempt';

Extract.file_type='tsss_trans'; % What type of data?

% Chooses the approprate entries
DB_entry = DB.get_entry(criteria);



%% Preparing Data Set Info and Analysis-related Parameters
    %---Extraction Info-------------
    Extract.file_path = DB_entry.file_path('local');
    Extract.data_rate = 1000;
    Extract.channel_list=sort([1:306]); % only gradiometers
    Extract.filter_stop=[59 61];
    Extract.filter_bandpas=[2 200];
    Extract = DB_entry.Prep_Extract(Extract);
    % Copy local (can be used to copy all that match criteria)
    DB_entry.download(Extract.file_name_ending);
    %-------------------------------

    %---Feature Parameters (FeatureParms.)---
    FeatureParms = FeatureParms_Class;
    % Can be empty for loading feature data from CRX files
    FeatureParms.feature_method = 'burg';
    FeatureParms.order = 30; % changed 2013-07-12 Foldes
    FeatureParms.feature_resolution = 1;
    FeatureParms.ideal_freqs = [0:120]; % Pick freq or bins
    FeatureParms.sample_rate = Extract.data_rate;
    %-------------------------------

    %---Analysis Parameters (AnalysisParms.)---
    AnalysisParms.SSP_Flag = 0;
    switch lower(DB_entry.run_intention)
        case {'imitate' 'attempt'}
            AnalysisParms.event_name_move = 'ParallelPort_Move_Good';
        case {'observe' 'imagine'}
            AnalysisParms.event_name_move = 'ArtifactFreeMove';
    end
    % Window-timing Parameters
    AnalysisParms.window_lengthS_move = 1; % 1s to help with rx variablity
    AnalysisParms.rx_timeS_move=0.1;    % 2013-10-11: 100ms b/c of parallel-port/video offset
    % 1/2s should be for center at 500ms post parallel port 2013-08-23
    AnalysisParms.num_reps_per_block = 4; % Only use the first 4 reps per block

    AnalysisParms.event_name_rest = 'ArtifactFreeRest';
    AnalysisParms.window_lengthS_rest = 3; % window is centered (this IS the WindowS from auto-event-parms)
    AnalysisParms.rx_timeS_rest = 0; % shift window (this is NOT the rx_time from auto-event-parms, this should be 0)
    %-------------------------------


[Power,Extract,FeatureParms,AnalysisParms]=Calc_Power_MoveRest(DB_entry,Extract,FeatureParms,AnalysisParms);



%% File Info

% pointer_name = 'ResultPointers.Power_tsss_trans_Cue_burg'; 
% % Load Results into workspace
% pointer_var_name = DB_entry.load_pointer(pointer_name);

% modulation depth calculations (stored in Power. until below)
Power.moddepth_all_sensors = Calc_ModDepth(Power.feature_data_move,Power.feature_data_rest,'T');

% Remove bad sensors (set to zero)
bad_sensor_idx = sensors2chanidx(Power.Extract.channel_list,DB_entry.Preproc.bad_chan_list);
Power.moddepth = Power.moddepth_all_sensors;
Power.moddepth(:,bad_sensor_idx,:) = NaN;

clear ResultParms
ResultParms.freq_idx = [15 30; 60 80];
[Power.moddepth_by_location_freqband,sensor_group_list] = Calc_ModDepth_Combine_by_Location(Power.moddepth,ResultParms.freq_idx,Power.Extract.channel_list);

Power.moddepth_by_freqband =[];
for ifreq_set = 1:size(ResultParms.freq_idx,1)
    current_freq_idx=[min(ResultParms.freq_idx(ifreq_set,:)):max(ResultParms.freq_idx(ifreq_set,:))];
    % Avg across freq band and trial
    Power.moddepth_by_freqband(:,ifreq_set) = squeeze(nanmean(nanmean(Power.moddepth(:,:,current_freq_idx),3),1));
end
Power.moddepth_by_freqband(bad_sensor_idx,:) = 0; % Set all bad channels to 0

%%
ifreq_set=1;
source_diff_beta = inverse_kernel.ImagingKernel*Power.moddepth_by_freqband(:,ifreq_set);

Beta_4BST = MNE_full;
Beta_4BST.ImageGridAmp = source_diff_beta;
% Beta_4BST.Comment = ['MNE Beta (' num2str(min(freq_list_beta)) '-' num2str(max(freq_list_beta)) 'Hz) (Foldes)'];
Beta_4BST.Comment = ['MNE Beta (Foldes)'];
Beta_4BST.Time = [min(Beta_4BST.Time) max(Beta_4BST.Time)];

Plot_MEG_head_plot([],Power.moddepth_by_freqband(1:3:306,ifreq_set))






source_diff_gamma = inverse_kernel.ImagingKernel*power_diff_gamma;

Gamma_4BST = MNE_full;
Gamma_4BST.ImageGridAmp = source_diff_gamma;
Gamma_4BST.Comment = ['MNE Gamma (' num2str(min(freq_list_gamma)) '-' num2str(max(freq_list_gamma)) 'Hz) (Foldes)'];
Gamma_4BST.Time = [min(Gamma_4BST.Time) max(Gamma_4BST.Time)];


% [hFig, iDS, iFig] = script_view_sources(Beta_4BST, 'cortex'); % Must be in database first
% Call surface viewer
% [hFig, iDS, iFig] = view_surface_data(Beta_4BST.SurfaceFile, Beta_4BST, [], 'NewFigure');
