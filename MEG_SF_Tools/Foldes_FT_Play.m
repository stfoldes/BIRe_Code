% Learning FieldTrip 2013-11-20
% http://fieldtrip.fcdonders.nl/walkthrough
% ft_defaults

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

% Chooses the approprate entries
DB_entry = DB.get_entry(criteria);

%% File Info

% Build file name
Extract.file_type='tsss_trans';
[Extract.file_suffix,Extract.file_extension]=MEG_file_type2file_extension(Extract.file_type);
Extract.file_name_ending = [Extract.file_suffix Extract.file_extension];
% Copy local (can be used to copy all that match criteria)
DB_entry.download(Extract.file_name_ending);

ExpDefs.paradigm_type = DB_entry.run_type;
ExpDefs = Prep_ExpDefs(ExpDefs);


%% CFG START

cfg_base = [];
cfg_base.dataset = [DB_entry.file Extract.file_name_ending];
cfg_base.channel    = {'MEG'};   

% Filtering parameters
% line noise
cfg_base.bsfilter = 'yes';
cfg_base.bsfreq = [59 61; 119 121; 179 181];

% BandPass
cfg_base.bpfilter = 'yes';
cfg_base.bpfilter = [2 200];

%% Events defined by me

% events to trl
Extract.data_rate = 1000;

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


% load events file to workspace (from serveevent_idx = AnalysisParms.events_move;r)
events_loaded_flag = DB_entry.load_pointer('Preproc.Pointer_Events');
if events_loaded_flag == -1 % its not really a flag, but it will work like this
    warning(['NO EVENTS FILE for ' DB_entry.entry_id])
end
% Remove bad segments being used (likely already done, but do it incase)
Events = Calc_Event_Removal_wBadSegments(Events,Extract.data_rate);

% Calc Move Power *AROUND* movement onset (with rx time adjustment); pick first X per block
new_move_events=Calc_Event_Reps_PerBlock(Events.(AnalysisParms.event_name_move),Events.Original.ParallelPort_BlockStart,AnalysisParms.num_reps_per_block);
% add in RX time to each event
AnalysisParms.events_move = new_move_events+floor(AnalysisParms.rx_timeS_move*Extract.data_rate);

% Calc Rest Power *AROUND* cue
% add in RX time to each event
AnalysisParms.events_rest = Events.(AnalysisParms.event_name_rest)+floor(AnalysisParms.rx_timeS_rest*Extract.data_rate);


event_idx = AnalysisParms.events_move;
window_lengthS = AnalysisParms.window_lengthS_move;
window_length = window_lengthS*Extract.data_rate;
cfg_move = ft_Events2trl(cfg_base,event_idx,window_length);
trialdata_move = ft_preprocessing(cfg_move);

event_idx = AnalysisParms.events_rest;
window_lengthS = AnalysisParms.window_lengthS_rest;
window_length = window_lengthS*Extract.data_rate;
cfg_rest = ft_Events2trl(cfg_base,event_idx,window_length);
trialdata_rest = ft_preprocessing(cfg_rest);

event_idx = Events.ParallelPort_BlockStart;
window_lengthS = 4;
window_length = window_lengthS*Extract.data_rate;
cfg_block = ft_Events2trl(cfg_base,event_idx,window_length);
trialdata_block = ft_preprocessing(cfg_block);


% % Set Events FROM FILE
% 
% cfg_move = cfg_base;
% cfg_move.trialdef.eventtype = 'STI101';
% cfg_move.trialdef.eventvalue = ExpDefs.target_code.move;
% cfg_move.trialdef.prestim = 0; % in seconds
% cfg_move.trialdef.poststim = 1; % in seconds
% cfg_move = ft_definetrial(cfg_move);
% % Make Trial Organized variable
% trialdata_move = ft_preprocessing(cfg_move);
% 
% cfg_rest = cfg_base;
% cfg_rest.trialdef.eventtype = 'STI101';
% cfg_rest.trialdef.eventvalue = ExpDefs.target_code.rest;
% cfg_rest.trialdef.prestim = -2; % in seconds
% cfg_rest.trialdef.poststim = 4; % in seconds
% cfg_rest = ft_definetrial(cfg_rest);
% % Make Trial Organized variable
% trialdata_rest = ft_preprocessing(cfg_rest);
% 
% % cfg_block = cfg;
% % cfg_block.trialdef.eventtype = 'STI101';
% % cfg_block.trialdef.eventvalue = ExpDefs.target_code.block_start;
% % cfg_block.trialdef.pblockim = 0; % in seconds
% % cfg_block.trialdef.poststim = 4; % in seconds
% % cfg_block = ft_definetrial(cfg_block);
% % % Make Trial Organized variable
% % trialdata_block = ft_preprocessing(cfg_block);
% % 
% % STI_data = Load_from_FIF(cfg.dataset,'STI');
% % % figure;
% % % plot(STI_data)

%% SOURCE

% http://fieldtrip.fcdonders.nl/tutorial/headmodel_meg

local_MRI_path_design='/home/foldes/Data/subjects/[subject]/Initial/Freesurfer_Reconstruction/mri'; % eg. NS01/Initial/Freesurfer_Reconstruction/mri
MRI_file = [str_from_design(DB_entry,local_MRI_path_design) filesep 'T1.mgz'];

mri = ft_read_mri(MRI_file);
cfg = [];
% cfg.method = 'headshape'; %  FAILS!!!
% cfg.headshape=MEG_file;
cfg.coordsys = 'neuromag';
[mri] = ft_volumerealign(cfg, mri);
% https://wiki.cimec.unitn.it/tiki-index.php?page=MRICoreg
% Left is left
% select r,l,n,z

cfg           = [];
cfg.output    = {'skullstrip' 'brain'};
segmentedmri  = ft_volumesegment(cfg, mri);

cfg = [];
cfg.method='singleshell';
vol = ft_prepare_headmodel(cfg, segmentedmri);

% Plotting
MEG_file = [DB_entry.file '.fif'];
% MEG_file = [DB_entry.file Extract.file_name_ending];

vol = ft_convert_units(vol,'cm');
sens = ft_read_sens(MEG_file);

figure
ft_plot_sens(sens, 'style', '.k');

hold on
ft_plot_vol(vol);

hs=ft_read_headshape(MEG_file); %get headshape points
ft_plot_headshape(hs);



cfg=[];
cfg.vol=vol;
% cfg.channel=trialdata_move.;
cfg.grid.xgrid='auto';
cfg.grid.ygrid='auto';
cfg.grid.zgrid='auto';
cfg.grid.resolution=1; %1cm ... beware of units!!
cfg.grad=trialdata_move.grad;

lf=ft_prepare_leadfield(cfg);


%%
export MNE_ROOT='/usr/local/MNE'
cd $MNE_ROOT/bin
. ./mne_setup_sh
export SUBJECTS_DIR='/home/foldes/Data/subjects'
export SUBJECT=NC01
mne_setup_source_space --ico -6
% requires NC01/surf (etc)


% export SUBJECT_FS_PATH='/Initial/Freesurfer_Reconstruction'
% 
% mne_setup_source_space_wSubject_Path --ico -6

bnd = ft_read_headshape('/home/foldes/Data/subjects/NC01/bem/NC01-oct-6-src.fif', 'format', 'mne_source');
figure;ft_plot_mesh(bnd);







%% Simple PSD

% general power config
cfg = [];
cfg.method    = 'mtmfft';
cfg.output    = 'pow';
cfg.pad       = 'maxperlen';
cfg.foilim    = [10 120];
cfg.taper     = 'dpss';%'hanning';
cfg.tapsmofrq = 5; % the amount of spectral smoothing through multi-tapering. +-XHz

% ??? DOES THIS AVERAGE THEN POWER, OR OTHER WAY ???
cfg_move = cfg;
cfg_move.trials    = 1:length(trialdata_move.trialinfo); % STEPHEN LOOK MORE
freq_move          = ft_freqanalysis(cfg_move, trialdata_move);

cfg_rest = cfg;
cfg_rest.trials    = 1:length(trialdata_rest.trialinfo); % STEPHEN LOOK MORE
freq_rest          = ft_freqanalysis(cfg_rest, trialdata_rest);

plot_sensor_list=[40 37];
for isensor = 1:length(plot_sensor_list)
    figure;hold all
    current_sensor_idx = plot_sensor_list(isensor);
    semilogy(freq_move.freq, freq_move.powspctrm(current_sensor_idx,:), 'g-');
    semilogy(freq_rest.freq, freq_rest.powspctrm(current_sensor_idx,:), 'r-');
    title(current_sensor_idx)
    ylabel('Power');xlabel('Hz')
    xlim([10 120])
end


% general power config
cfg = [];
cfg.method    = 'mtmfft';
cfg.output    = 'pow';
cfg.pad       = 'maxperlen';
cfg.foilim    = [20 30];
cfg.taper     = 'dpss';%'hanning';
cfg.tapsmofrq = 5; % the amount of spectral smoothing through multi-tapering. +-XHz

% ??? DOES THIS AVERAGE THEN POWER, OR OTHER WAY ???
cfg_move = cfg;
cfg_move.trials    = 1:length(trialdata_move.trialinfo); % STEPHEN LOOK MORE
freq_move          = ft_freqanalysis(cfg_move, trialdata_move);

cfg = [];
cfg.zlim = 'maxabs';
cfg.channel = [2:3:306];
cfg.colorbar = 'yes';
ft_topoplotER(cfg, freq_move)

power = mean(freq_move.powspctrm(1:3:306,:),2);
figure
Plot_MEG_head_plot([],power,'display_chan_flag',0)
caxis_center(1.1e-24)
colorbar


power = squeeze(mean(mean(feature_data_move(:,1:2:end,21:30),1),3));
figure
Plot_MEG_head_plot([],power,'display_chan_flag',0)
caxis_center(1.1e-24)
colorbar



%%
% Plot Topography QUICK
fig_topo = figure;
current_freq_range = [20 30];
subplot(1,2,1);hold all
freq_idx = find_closest_range_idx(current_freq_range,freq_move.freq);
power = mean(freq_move.powspctrm(1:3:306,freq_idx)-freq_rest.powspctrm(1:3:306,freq_idx),2)./mean(freq_rest.powspctrm(1:3:306,freq_idx),2);
Plot_MEG_head_plot([],100*power,'display_chan_flag',0,'fig',fig_topo)
colorbar_with_label('% Change','EastOutside')
title([num2str(min(current_freq_range)) '-' num2str(max(current_freq_range)) 'Hz'])

current_freq_range = [65 85];
subplot(1,2,2);hold all
freq_idx = find_closest_range_idx(current_freq_range,freq_move.freq);
power = mean(freq_move.powspctrm(1:3:306,freq_idx)-freq_rest.powspctrm(1:3:306,freq_idx),2)./mean(freq_rest.powspctrm(1:3:306,freq_idx),2);
Plot_MEG_head_plot([],100*power,'display_chan_flag',0,'fig',fig_topo)
colorbar_with_label('% Change','EastOutside')
title([num2str(min(current_freq_range)) '-' num2str(max(current_freq_range)) 'Hz'])
Figure_Stretch(2)


% cfg_move.layout = 'neuromag306cmb';
% ft_topoplotER(cfg_move,freq_move)

%% Simple Spectrogram

current_sensor_idx = 40;

% general config
cfg = [];
cfg.output         = 'pow';
cfg.method         = 'mtmconvol';
cfg.taper          = 'hanning';
cfg.foi            = 0:120;
cfg.t_ftimwin      = 4 ./ cfg.foi;
cfg.toi            = trialdata_block.time{1};%-1:0.05:1;
cfg.channel        = current_sensor_idx;

% cfg.trials    = 1:length(trialdata_rest.trialinfo); % STEPHEN LOOK MORE
cfg.trials    = 1:10;
freq          = ft_freqanalysis(cfg, trialdata_block);

figure
pcolor(freq.time,freq.freq,squeeze(freq.powspctrm))
shading interp


cfg = [];
cfg.baseline     = [0 2];	
cfg.baselinetype = 'absolute';
cfg.xlim         = 'maxmin';   
cfg.zlim         = 'maxabs';
cfg.ylim         = 'maxmin';
cfg.marker       = 'on';
figure 
ft_topoplotTFR(cfg, freq);


% cfg = [];
% % cfg.baseline     = [-0.5 -0.1];
% % cfg.baselinetype = 'absolute';
% cfg.zlim         = [0 8e-24];
% cfg.showlabels   = 'yes';
% cfg.layout       = 'neuromag306all.lay';
% figure
% ft_singleplotTFR(cfg, freq);



% current_sensor_num = 40;
% sensors2chanidx
% trialdata_move.label

% current_sensor_idx = 40;
%
% % general config
% cfg = [];
% cfg.output         = 'pow';
% cfg.method         = 'mtmconvol';
% cfg.taper          = 'hanning';
% cfg.foi            = 10:100;
% cfg.t_ftimwin      = 4 ./ cfg.foi;
% cfg.toi            = -0.5:0.05:1;
%
% cfg_move = cfg;
% cfg_move.trials    = 1:length(trialdata_move.trialinfo); % STEPHEN LOOK MORE
% freq_move          = ft_freqanalysis(cfg_move, trialdata_move);
%
% cfg_rest = cfg;
% cfg_rest.trials    = 1:length(trialdata_rest.trialinfo); % STEPHEN LOOK MORE
% freq_rest          = ft_freqanalysis(cfg_rest, trialdata_rest);
%
%
% cfg = [];
% % cfg.baseline     = [-0.5 -0.1];
% % cfg.baselinetype = 'absolute';
% % cfg.zlim         = [-3e-27 3e-27];
% % cfg.showlabels   = 'yes';
% cfg.layout       = 'neuromag306all.lay';
% figure
% ft_multiplotTFR(cfg, freq_move);
%
% figure;hold all
% semilogy(freq_move.freq, freq_move.powspctrm(current_sensor_idx,:), 'g-');
% semilogy(freq_rest.freq, freq_rest.powspctrm(current_sensor_idx,:), 'r-');

%% Freq stuff

cfg.trials         = 1:length(trialdata.trialinfo); % STEPHEN LOOK MORE
freq               = ft_freqanalysis(cfg, trialdata);


%   ft_singleplotER(cfg,freq);
% ft_prepare_layout
%   ft_topoplotER(cfg,freq);








%%



%% LOOK LATER
cfg.channel
cfg.detrend





%%

overwrite_flag=1;
saved_pointer_flag = 1;

save_pointer_name = 'ResultPointers.Power_tsss_trans_Cue_burg';
Extract.file_type='tsss_trans'; % What type of data?

%% Loop for All Entries
fail_list{1} = [];
for ientry = 1:length(DB_short)
    
    DB_entry = DB_short(ientry);
    disp(' ')
    disp(['==================File #' num2str(ientry) '/' num2str(length(DB_short)) ' | ' DB_entry.entry_id '================='])
    
    try
        
        %% ----------------------------------------------------------------
        %  -----------------CODE STARTS------------------------------------
        %  ----------------------------------------------------------------
        
        %% Preparing Data Set Info and Analysis-related Parameters
        %---Extraction Info-------------
        Extract.file_path = DB_entry.file_path('local');
        Extract.channel_list=sort([1:3:306 2:3:306]); % only gradiometers
        Extract.filter_stop=[59 61];
        Extract.filter_bandpass=[2 200];
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
        
        %         event_file = [DB_entry.file_path('server') filesep DB_entry.Preproc.Pointer_Events];
        %         % if the file doesn't exist, OR its older than 2013-08-01, then yell!
        %         if exist(event_file)~=2
        %             warning([event_file ' does not exist'])
        %         elseif date_subtraction(datestr('2013-08-01'),date_file_timestamp(event_file))<0
        %             warning([event_file ' is too old'])
        %         else
        %             load(event_file);
        %             % Just make sure there aren't bad segments being used
        %             Events = Calc_Event_Removal_wBadSegments(Events,Extract.data_rate);
        %         end
        
        %% Define Events
        
        % Calc Move Power *AROUND* movement onset (with rx time adjustment); pick first X per block
        new_move_events=Calc_Event_Reps_PerBlock(Events.(AnalysisParms.event_name_move),Events.Original.ParallelPort_BlockStart,AnalysisParms.num_reps_per_block);
        % add in RX time to each event
        AnalysisParms.events_move = new_move_events+floor(AnalysisParms.rx_timeS_move*Extract.data_rate);
        
        % Calc Rest Power *AROUND* cue
        % add in RX time to each event
        AnalysisParms.events_rest = Events.(AnalysisParms.event_name_rest)+floor(AnalysisParms.rx_timeS_rest*Extract.data_rate);
        
        %% Load MEG data
        
        [MEG_data] =  Load_from_FIF(Extract,'MEG');
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
