

%% File parms
% Extract.full_file_name      = '/home/foldes/Data/MEG/DBI05/S01/dbi05s01r03_tsss.fif';
% Extract.full_file_name =    'C:\Data\MEG\DBI05\S01\dbi05s01r03_tsss.fif';
Extract.full_file_name      = '/home/foldes/Data/MEG/NC01/S01/nc01s01r05_tsss.fif';
Extract.channel_list =      sort([1:3:306 2:3:306]);
% ExpDefs.paradigm_type       = 'Mapping';
ExpDefs.paradigm_type       = 'open_loop_meg';
AnalysisParms.event_type    = 'cue';


%% Load MEG and Time
[MEG_data,TimeVecs.timeS,~,Extract] =  Load_from_FIF(Extract,'MEG');
TimeVecs.data_rate = Extract.data_rate;


%% Load Events 
% Cue signal
[TimeVecs.target_code_org] = Load_from_FIF(Extract,'STI');

ExpDefs=Prep_ExpDefs(ExpDefs);
% remove 255 on-off signals
TimeVecs.target_code_org = remove_pport_trigger_from_CRX_startstop(TimeVecs.target_code_org);
TimeVecs=Prep_TargetCode(TimeVecs,ExpDefs);

load('/home/foldes/Data/MEG/NC01/S01/nc01s01r05_Events.mat');

AnalysisParms.window_lengthS_move = 0.5;
AnalysisParms.events_move = Events.ParallelPort_Move_Good;

AnalysisParms.window_lengthS_rest = 3;
AnalysisParms.events_rest = Events.ArtifactFreeRest;



% AnalysisParms.window_lengthS_move = 0.5;
% AnalysisParms.events_move = AnalysisParms.events;
% AnalysisParms.window_lengthS_rest = 3;
% AnalysisParms.events_rest = AnalysisParms.events_move-4000;
% 

% FROM FILE?
% load('C:\Data\MEG\DBI05\S01\events_4BSTfromMatlab_dbi05s01r03_tsss_trans.mat')
% move_events = events.samples;
% 
% 
% %---Analysis Parameters (AnalysisParms.)---
% % Window-timing Parameters
% AnalysisParms.rx_timeS_move =       0;
% AnalysisParms.window_lengthS_move = 0.3;
% AnalysisParms.rx_timeS_rest =       -0.5;
% AnalysisParms.window_lengthS_rest = 10;
% %-------------------------------
% 
% AnalysisParms.events_move = move_events+floor(AnalysisParms.rx_timeS_move*Extract.data_rate);
% % AnalysisParms.events_rest = move_events+floor(AnalysisParms.rx_timeS_rest*Extract.data_rate);
% 
% AnalysisParms.events_rest = 8000;

%% Calc Power
%---Feature Parameters (FeatureParms.)---
FeatureParms = FeatureParms_Class;
FeatureParms.feature_method =       'burg';
FeatureParms.order =                30; % changed 2013-07-12 Foldes
FeatureParms.feature_resolution =   1;
FeatureParms.ideal_freqs =          [0:120]; % Pick freq or bins
FeatureParms.sample_rate =          Extract.data_rate;
%-------------------------------

% Calc Rest Power
FeatureParms.window_lengthS = AnalysisParms.window_lengthS_rest;
FeatureParms.window_length = floor(FeatureParms.window_lengthS*Extract.data_rate);
[feature_data_rest,FeatureParms]=Calc_PSD_TimeLocked(MEG_data,AnalysisParms.events_rest,FeatureParms);

% Calc Move Move
FeatureParms.window_lengthS=AnalysisParms.window_lengthS_move;
FeatureParms.window_length = floor(FeatureParms.window_lengthS*Extract.data_rate);
[feature_data_move,FeatureParms]=Calc_PSD_TimeLocked(MEG_data,AnalysisParms.events_move,FeatureParms);


%% PLOT: PSD for an ROI
ROI_name = 'sensorimotor_left_hemi';
eval(['ROI_idx = sensors2chanidx([Extract.channel_list],[DEF_MEG_sensors_' ROI_name ']);'])
data4psd = Calc_ModDepth(feature_data_move,feature_data_rest,'T');

fig_psd = figure;hold all
Figure_Stretch(2,1)
% Left Sensorimotor
Plot_Variance_as_Patch(FeatureParms.actual_freqs,squeeze(mean(data4psd,1))',...
    'variance_method',[.05 .95],'patch_color','k','patch_alpha',0.6,'fig',fig_psd); % STD across all sensor groups
plot(FeatureParms.actual_freqs,squeeze(mean(data4psd(:,ROI_idx,:),1))',...
    'g','LineWidth',2)
clear text_input
text_input{1} = [ROI_name ' (' num2str(length(ROI_idx)) ' sensors)'];
text_input{end+1} = ['MOVE: ' num2str(length(AnalysisParms.events_move)) 'Events , ' num2str(AnalysisParms.window_lengthS_move) 's window'];
text_input{end+1} = ['REST: ' num2str(length(AnalysisParms.events_rest)) 'Events , ' num2str(AnalysisParms.window_lengthS_rest) 's window'];
text_input{end+1} = ['Order: ' num2str(FeatureParms.order)];
Figure_Annotate(text_input)
title(str4plot(Extract.full_file_name))
xlabel('Freq [Hz]')
ylabel('Modulation [T]')

% PLOT: Interactive Topography by freq band
% GUI_Inspect_ModDepth_wTopography(fig_psd,feature_data_move,feature_data_rest,Extract.channel_list,FeatureParms,'p_thres',0.1);

%%
% freq_band = [65:80];% DEF_freq_bands('gamma')
freq_band = [15:25];% DEF_freq_bands('gamma')
FOI_idx = find_closest_range_idx(min(freq_band):max(freq_band),FeatureParms.actual_freqs);

Sensors = mean(mean(data4psd(:,:,FOI_idx),3),1)';
Plot_MEG_head_plot(Extract.channel_list,Sensors)

%%

global BST_DB_PATH
BST_DB_PATH = '/home/foldes/Data/brainstorm_db/';

ExpInfo.project =           'Test';
ExpInfo.subject =           'NC01';
ExpInfo.group_or_ind =      'ind';
% ExpInfo.task_name =         'Trigger_Move'; % name of stimulus
ExpInfo.task_name =         'Trigger_Block_Start'; % name of stimulus
ExpInfo.inverse_method =    'wMNE'; % 'dSPM' % The name of the method used


% Load BST data

% Get all the data from inverse file and surface
[Inverse,Inverse_filename] = BST_Load_File(ExpInfo,'inverse');

Sources = Inverse.ImagingKernel * (Sensors);
% Sources = Inverse.ImagingKernel * (ones(204,1));
BST_Set_Sources(gcf,Sources);




