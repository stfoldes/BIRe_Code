% Calculate events and write them to a BST format event file
% Starts from raw FIF file
%
% 2013-12-13 Foldes

clear
% close all

event_type              = 'emg';
event_save_label        = ['Wrist_' event_type];
Extract.full_file_name  = '/home/foldes/Data/MEG/DBI05/S01/dbi05s01r14.fif';
ExpDefs.paradigm_type   = 'Mapping';


% Extract.full_file_name = '/home/foldes/Data/MEG/NC01/S01/nc01s01r03_tsss_trans.fif';
% ExpDefs.paradigm_type = 'Open_Loop_MEG';

%
% %% Preparing Data Set Info and Analysis-related Parameters
% %---Extraction Info-------------
% Extract.data_rate       = 1000;
% %-------------------------------
%
%

%% EVENT DEFINITION

% Cue signal
[TimeVecs.target_code_org,TimeVecs.timeS,~,Extract] = Load_from_FIF(Extract,'STI');
TimeVecs.data_rate = Extract.data_rate;

ExpDefs=Prep_ExpDefs(ExpDefs);
% remove 255 on-off signals
TimeVecs.target_code_org = remove_pport_trigger_from_CRX_startstop(TimeVecs.target_code_org);
TimeVecs=Prep_TargetCode(TimeVecs,ExpDefs);

switch lower(event_type)
    case 'emg'
        [TimeVecs.EMG_data] =  Load_from_FIF(Extract,'EMG');
        % Calculate time series data that will be used for marking events SLOW
        processed_data=Calc_Processed_EMGandACC(Extract,'emg');
        Events = Calc_Events('gui_wprocessed_data',processed_data,TimeVecs,'EMG');
        events2write = Events.Original.EMG;
    case 'acc'
        [TimeVecs.EMG_data] =  Load_from_FIF(Extract,'MISC');
        % Calculate time series data that will be used for marking events SLOW
        processed_data=Calc_Processed_EMGandACC(Extract,'acc');
        Events = Calc_Events('gui_wprocessed_data',processed_data,TimeVecs,'ACC');
        events2write = Events.Original.ACC;
    case 'cue'
        events2write = Calc_Events('cue',TimeVecs.target_code,ExpDefs.target_code.move);
end


%
% % % Calculate time series data that will be used for marking events SLOW
% % processed_data=Calc_Processed_EMGandACC(Extract,'acc');
% % Events = Calc_Events('gui_wprocessed_data',processed_data,TimeVecs,'ACC');
% % AnalysisParms.events = Events.Original.ACC;
%
% % figure;plot(TimeVecs.timeS,processed_data.ACC_data);
% % AnalysisParms.events = Calc_Events('cue',TimeVecs.target_code,ExpDefs.target_code.move);
% % AnalysisParms.events = Calc_Events('cue',TimeVecs.target_code,ExpDefs.target_code.block_start);
%
%
%
% %% Edit auto markers
% event_data  = TimeVecs.target_code_org;
% timeS       = TimeVecs.timeS;
% events_idx  = AnalysisParms.events;
%
% [save_flag,events_idx]= GUI_Edit_Event_Markers(event_data,timeS,events_idx);
%
% events_idx = sort(events_idx); % SORT
% if save_flag~=0  % 0=redo,
%     break
% end

%% Write to BST event file

event_timeS = TimeVecs.timeS(events2write);
events = Export_BSTEvent_File(event_timeS,Extract.data_rate,Extract.full_file_name,'label',event_save_label);



