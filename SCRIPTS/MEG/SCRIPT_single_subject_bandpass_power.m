% Calculate power and save at ResultPointers.Power_tsss_trans_Cue
% 2013-06-08 Foldes [Branched]
% UPDATES:
% 2013-10-11 Foldes: Metadata-->DB


clearvars -except DB
Extract.file_type='tsss_trans'; % What type of data?

% Choose criteria for data set to analyize
clear criteria
criteria.subject = 'NC01';
criteria.run_type = 'Open_Loop_MEG';
criteria.run_task_side = 'Right';
criteria.run_action = 'Grasp';
criteria.run_intention = 'Attempt';


%% Load Database

% Build database
if ~exist('DB','var')
    DB=DB_MEG_Class;
    DB=DB.build('PATHS_meg_neurofeedback'); % also sets global MY_PATHS
end

% Chooses the approprate entries
DB_short = DB.get_entry(criteria);

ientry = 1;

DB_entry = DB_short(ientry);
disp(' ')
disp(['==================File #' num2str(ientry) '/' num2str(length(DB_short)) ' | ' DB_entry.entry_id '================='])


%% ----------------------------------------------------------------
%  -----------------CODE STARTS------------------------------------
%  ----------------------------------------------------------------

%% Preparing Data Set Info and Analysis-related Parameters
%---Extraction Info-------------
Extract.file_path = DB_entry.file_path('local');
Extract.channel_list=sort([1:3:306 2:3:306]); % only gradiometers
Extract.filter_stop=[59 61];
Extract.filter_bandpas=[2 200];
Extract = DB_entry.Prep_Extract(Extract);
% Copy local (can be used to copy all that match criteria)
DB_entry.download(Extract.file_name_ending);
%-------------------------------

%---Feature Parameters (FeatureParms.)---
FeatureParms = FeatureParms_Class;
% Can be empty for loading feature data from CRX files
FeatureParms.feature_method = 'MEM';
FeatureParms.order = 12; % changed 2013-07-12 Foldes
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

%% ----------------------------------------------------------------
%  -----------------CODE STARTS------------------------------------
%  ----------------------------------------------------------------

%% Load Events (from server)
events_loaded_flag = DB_entry.load_pointer('Preproc.Pointer_Events');
if events_loaded_flag == -1 % its not really a flag, but it will work like this
    warning(['NO EVENTS FILE for ' DB_entry.entry_id])
end
% make sure there aren't bad segments being used
Events = Calc_Event_Removal_wBadSegments(Events,Extract.data_rate);

%% Define Events

% Calc Move Power *AROUND* movement onset (with rx time adjustment); pick first X per block
new_move_events=Calc_Event_Reps_PerBlock(Events.(AnalysisParms.event_name_move),Events.ParallelPort_BlockStart,AnalysisParms.num_reps_per_block);
% add in RX time to each event
AnalysisParms.events_move = new_move_events+floor(AnalysisParms.rx_timeS_move*Extract.data_rate);

% Calc Rest Power *AROUND* cue
% add in RX time to each event
AnalysisParms.events_rest = Events.(AnalysisParms.event_name_rest)+floor(AnalysisParms.rx_timeS_rest*Extract.data_rate);

%% Load MEG data

[MEG_data] =  Load_from_FIF(Extract,'MEG');
TimeVecs.data_rate = Extract.data_rate;
[TimeVecs.target_code_org,TimeVecs.timeS] = Load_from_FIF(Extract,'STI');
MEG_data_clean = MEG_data;
clear MEG_data
%%
%%
%%



        %---Feature Parameters (FeatureParms.)---
        FeatureParms = FeatureParms_Class;
        % Can be empty for loading feature data from CRX files
        FeatureParms.feature_method = 'burg';
        FeatureParms.order = 30; % changed 2013-07-12 Foldes
        FeatureParms.feature_resolution = 1;
        FeatureParms.ideal_freqs = [0:160]; % Pick freq or bins
        FeatureParms.sample_rate = Extract.data_rate;
        %-------------------------------

        % Calc Power
        % disp(length(Events.(event_name_move)))
        % disp(length(Events.(event_name_rest)))
        
        % Calc Rest Power
        tic
        FeatureParms.window_lengthS = AnalysisParms.window_lengthS_rest;
        FeatureParms.window_length = floor(FeatureParms.window_lengthS*Extract.data_rate);
        [feature_data_rest,FeatureParms]=Calc_PSD_TimeLocked(MEG_data_clean,AnalysisParms.events_rest,FeatureParms);
        toc
        % Calc Move Move
        FeatureParms.window_lengthS=AnalysisParms.window_lengthS_move;
        FeatureParms.window_length = floor(FeatureParms.window_lengthS*Extract.data_rate);
        [feature_data_move,FeatureParms]=Calc_PSD_TimeLocked(MEG_data_clean,AnalysisParms.events_move,FeatureParms);



        
        sensorimotor_left_idx = sensors2chanidx(Extract.channel_list,DEF_MEG_sensors_sensorimotor_left_hemi);
        data4psd = Calc_ModDepth(feature_data_move,feature_data_rest,'T');
        
        fig_psd = figure;hold all
        Figure_Stretch(2,2)
        subplot(2,2,[1,2])
        % Left Sensorimotor
        Plot_Variance_as_Patch(FeatureParms.actual_freqs,squeeze(mean(data4psd,1))',...
            'variance_method','std','patch_color','k','patch_alpha',0.6,'fig',fig_psd); % STD across all sensor groups
        plot(FeatureParms.actual_freqs,squeeze(mean(data4psd(:,sensorimotor_left_idx,:),1))',...
            'g','LineWidth',2)
        xlim([min(FeatureParms.actual_freqs) max(FeatureParms.actual_freqs)])
        clear text_input
        text_input{1} = [DB_entry.run_info];
        text_input{2} = [AnalysisParms.event_name_move ' (x' num2str(length(AnalysisParms.events_move)) ') ' num2str(AnalysisParms.window_lengthS_move) 's window'];
        text_input{3} = [AnalysisParms.event_name_rest ' (x' num2str(length(AnalysisParms.events_rest)) ') ' num2str(AnalysisParms.window_lengthS_rest) 's window'];
        text_input{4} = ['Order: ' num2str(FeatureParms.order)];
        Figure_Annotate(text_input)
        title(DB_entry.subject)
        xlabel('Freq [Hz]')
        ylabel('Modulation [T]')
        
        % Head Plot of Power
        AnalysisParms.freq_names_4grouping = {'beta','gamma'};
        
        % make list of freqs
        AnalysisParms.freq_idx_4grouping=[];
        for ifreq = 1:size(AnalysisParms.freq_names_4grouping,2)
            AnalysisParms.freq_idx_4grouping=[AnalysisParms.freq_idx_4grouping; ...
                find_closest_range_idx(DEF_freq_bands(AnalysisParms.freq_names_4grouping{ifreq}),FeatureParms.actual_freqs)]; % do that find_closet stuff to get the valid indicies (what if you don't have 1Hz res?)
        end
        
        moddepth = Calc_ModDepth(feature_data_move,feature_data_rest,'t');
        [moddepth_by_location_freqband,sensor_group_list] = Calc_ModDepth_Combine_by_Location(moddepth,AnalysisParms.freq_idx_4grouping,Extract.channel_list);
        
        %fig=figure;
        for ifreq = 1:size(AnalysisParms.freq_idx_4grouping,1)
            subplot(2,2,ifreq+2);hold all
            %subplot(1,size(AnalysisParms.freq_idx_4grouping,1),ifreq);hold all
            Plot_MEG_head_plot([1:3:306],moddepth_by_location_freqband(:,ifreq),'fig',fig_psd);
            Plot_MEG_chan_locations(DEF_MEG_sensors_sensorimotor_left_hemi,'MarkerType',1,'Color','k'); % 2013-08-13
            caxis_center;colorbar
            title([AnalysisParms.freq_names_4grouping{ifreq} ' ' num2str(DEF_freq_bands(AnalysisParms.freq_names_4grouping{ifreq}))])
        end
        %         Figure_Stretch(2,1)
        %         title_figure([DB_entry.subject])


%%
current_freq = DEF_freq_bands('beta');
% current_freq = DEF_freq_bands('gamma');
MEG_filt = Calc_Filter_Freq_SimpleButter(MEG_data_clean,current_freq,Extract.data_rate,'bandpass');
MEG_power = Calc_Filter_Freq_SimpleButter(MEG_filt.^2,0.1,Extract.data_rate,'low'); % pretty close to moving average

sensorimotor_left_idx = sensors2chanidx(Extract.channel_list,DEF_MEG_sensors_sensorimotor_left_hemi);

% Make relative to rest
baseline_idx=[];
for iblock =1:length(AnalysisParms.events_rest)
    baseline_idx = [baseline_idx AnalysisParms.events_rest(iblock)-3000+1:AnalysisParms.events_rest(iblock)];
end
baseline = MEG_power(baseline_idx,:);

MEG_z = pseudozscore(MEG_power,mean(baseline),std(baseline));

% figure;hold all
% plot(TimeVecs.timeS,MEG_z(:,sensorimotor_left_idx(8)),'k')
% Plot_VerticalMarkers(TimeVecs.timeS(AnalysisParms.events_move),'Color','g')
% plot([min(TimeVecs.timeS),max(TimeVecs.timeS)],[0 0],'--r')
% Figure_Stretch(2,1)
% Figure_TightFrame

move_idx=[];
for iblock =1:length(AnalysisParms.events_move)
    move_idx = [move_idx AnalysisParms.events_move(iblock)-500+1:AnalysisParms.events_move(iblock)+500];
end
move = median(MEG_z(move_idx,:));

fig_head = figure;
subplot(1,2,1);hold all
Plot_MEG_head_plot(Extract.channel_list,move,'sensor_type',1,'fig',fig_head)
colorbar
subplot(1,2,2);hold all
Plot_MEG_head_plot(Extract.channel_list,move,'sensor_type',2,'fig',fig_head)
colorbar
Figure_Stretch(2,1)
title_figure('Beta')
Figure_Position(0,1)


%%
current_freq = DEF_freq_bands('gamma');
% current_freq = DEF_freq_bands('gamma');
MEG_filt = Calc_Filter_Freq_SimpleButter(MEG_data_clean,current_freq,Extract.data_rate,'bandpass');
MEG_power = Calc_Filter_Freq_SimpleButter(MEG_filt.^2,0.1,Extract.data_rate,'low'); % pretty close to moving average


sensorimotor_left_idx = sensors2chanidx(Extract.channel_list,DEF_MEG_sensors_sensorimotor_left_hemi);

% Make relative to rest
baseline_idx=[];
for iblock =1:length(AnalysisParms.events_rest)
    baseline_idx = [baseline_idx AnalysisParms.events_rest(iblock)-3000+1:AnalysisParms.events_rest(iblock)];
end
baseline = MEG_power(baseline_idx,:);

MEG_z = pseudozscore(MEG_power,mean(baseline),std(baseline));

% figure;hold all
% plot(TimeVecs.timeS,MEG_z(:,sensorimotor_left_idx(8)),'k')
% Plot_VerticalMarkers(TimeVecs.timeS(AnalysisParms.events_move),'Color','g')
% plot([min(TimeVecs.timeS),max(TimeVecs.timeS)],[0 0],'--r')
% Figure_Stretch(2,1)
% Figure_TightFrame

move_idx=[];
for iblock =1:length(AnalysisParms.events_move)
    move_idx = [move_idx AnalysisParms.events_move(iblock)-500+1:AnalysisParms.events_move(iblock)+500];
end
move = median(MEG_z(move_idx,:));

fig_head = figure;
subplot(1,2,1);hold all
Plot_MEG_head_plot(Extract.channel_list,move,'sensor_type',1,'fig',fig_head)
colorbar
subplot(1,2,2);hold all
Plot_MEG_head_plot(Extract.channel_list,move,'sensor_type',2,'fig',fig_head)
colorbar
Figure_Stretch(2,1)
title_figure('Gamma')
Figure_Position(0,0)





