% Automated way to Calculate SourceKernel AND SensorModDepth
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


%---Analysis Parameters (AnalysisParms.)---
AnalysisParms.file_type =           'tsss'; % What type of data
AnalysisParms.SSP_Flag =            0;

% Window-timing Parameters
% AnalysisParms.event_name_move =   PROGRAMTICALLY DEFINED BELOW
AnalysisParms.window_lengthS_move = 1; % 1s to help with rx variablity
AnalysisParms.rx_timeS_move =       0.1;    % 2013-10-11: 100ms b/c of parallel-port/video offset
% 1/2s should be for center at 500ms post parallel port 2013-08-23
AnalysisParms.num_reps_per_block =  4; % Only use the first 4 reps per block

AnalysisParms.event_name_rest =     'ArtifactFreeRest';
AnalysisParms.window_lengthS_rest = 3; % window is centered (this IS the WindowS from auto-event-parms)
AnalysisParms.rx_timeS_rest =       0; % shift window (this is NOT the rx_time from auto-event-parms, this should be 0)

% Inverse Parms
AnalysisParms.noisecov_time =       [0 2];
AnalysisParms.inverse_method =      'wmne';
AnalysisParms.inverse_orientation = 'fixed'; % fixed = constrained
AnalysisParms.sensortypes =         'MEG GRAD';

AnalysisParms.moddepth_method =     'T';
AnalysisParms.FWHM =                6;
%AnalysisParms.freq4sources =        [DEF_freq_bands('beta'); DEF_freq_bands('gamma')];
%-------------------------------


%% Build database (unless loaded)
if ~exist('DB','var')
    DB = DB_MEG_Class;
    DB = DB.build('PATHS_meg_neurofeedback'); % also sets global MY_PATHS
end

%% Loops

% ===Calculate Source Info===
compute_str =   'SourceData = Calc_SourceInverse_wDB(DB_entry,AnalysisParms);';
save_var =      'SourceData';
save_pointer =  'ResultPointers.SourceModDepth_tsss_Cue';
[DB, ErrorList] = DB_Loop_Wrapper(DB,criteria,save_pointer,save_var,compute_str,AnalysisParms);


% ===Calculate Power in Sensor Space===
compute_str =[...
    'switch lower(DB_entry.run_intention);'...
    'case {''imitate'' ''attempt''};'...
    'AnalysisParms.event_name_move = ''ParallelPort_Move_Good'';'...
    'case {''observe'' ''imagine''};'...
    'AnalysisParms.event_name_move = ''ArtifactFreeMove'';'...
    'end;'...
    'SensorData = Calc_Power_MoveRest_wDB(DB_entry,AnalysisParms);'...
    'SensorData.moddepth = Calc_ModDepth(SensorData.feature_data_move,SensorData.feature_data_rest,AnalysisParms.moddepth_method);'...
    ];
save_var = 'SensorData';
save_pointer = 'ResultPointers.SensorModDepth_tsss_Cue';
[DB, ErrorList2] = DB_Loop_Wrapper(DB,criteria,save_pointer,save_var,compute_str,AnalysisParms);


%% Save database out to file
if save_DB_flag == 1
    DB.save_DB;
end





