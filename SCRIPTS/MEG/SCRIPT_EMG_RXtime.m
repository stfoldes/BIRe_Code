% Load STI and events, calc RX time from movement Cue onset
%
% 2013-07-11 Foldes
% UPDATES:
% 2013-10-07 Foldes: Metadata-->DB

% Needs basic loading
% SEE: SCRIPT_Plot_RxTime_Bar


clearvars -except DB
% close all

% Choose criteria for data set to analyize
clear criteria
criteria.run_type = 'Open_Loop_MEG';
% criteria.run_task_side = 'Right';
criteria.run_intention = {'Observe','Imitate'};
criteria.run_action = 'Grasp';


%% Load Database
% Build database
if ~exist('DB','var')
    DB=DB_MEG_Class;
    DB=DB.build('PATHS_meg_neurofeedback'); % also sets global MY_PATHS
end

% Chooses the approprate entries
[~,entry_list] = DB.get_entry(criteria);

clear Extract

Extract.file_type = 'fif';
[file_suffix,file_extension]=MEG_file_type2file_extension(Extract.file_type);
file_name_ending = [file_suffix file_extension];


%% Loop for All Entries
subject_cnt_EMG = 0;subject_cnt_ACC = 0;
fail_list = [];
for ientry = 1:length(entry_list)
    
    DB_entry = DB(entry_list(ientry));
    disp(' ')
    disp(['==================File #' num2str(ientry) '/' num2str(length(entry_list)) ' | ' DB_entry.run_info '================='])
    
    %try
    % Copy local (can be used to copy all that match criteria)
    DB_entry.download(file_name_ending);
    
    %% Preparing Data Set Info and Analysis-related Parameters
    
    %---Extraction Info-------------
    Extract.file_path = DB_entry.file_path('local');
    Extract.channel_list=sort([1:3:306 2:3:306]); % only gradiometers
    Extract = Prep_Extract_w_DB(Extract,DB_entry);
    %-------------------------------
    
    %% Load MEG data
    
    % [MEG_data,TimeVecs.timeS] =  Load_from_FIF(Extract,'MEG');
    TimeVecs.data_rate = Extract.data_rate;
    [TimeVecs.target_code_org,TimeVecs.timeS] = Load_from_FIF(Extract,'STI');
    ExpDefs.paradigm_type=DB_entry.run_type;
    ExpDefs=Prep_ExpDefs(ExpDefs);
    TimeVecs=Prep_TargetCode(TimeVecs,ExpDefs);
    
    %% Load Events
    
    % try to load if possible
    if exist([DB_entry.file_path filesep DB_entry.Preproc.Pointer_Events])==2
        load([DB_entry.file_path filesep DB_entry.Preproc.Pointer_Events]);
    else
        % Run event maker
    end
    
    %% ----------------------------------------------------------------
    %  -----------------CODE STARTS------------------------------------
    %  ----------------------------------------------------------------
    
    %% Calc RX time
    
    move_event_name = 'EMG';
    % Check if markers are made or not
    if ~isfield(Events,move_event_name)
        if questdlg_YesNo_logic(['No ' move_event_name ' markers found. Run?'],DB_entry.entry_id)
            Events = DB_entry.Calc_Event_Markers(move_event_name,TimeVecs);
        end
    end
    % RX time from Cue based on autodetect
    move_events = Events.(move_event_name);
    if ~isnan(move_events)
        clear closest_cue
        for ievent = 1:length(move_events)
            closest_cue(ievent) = Events.ParallelPort_Move(find(move_events(ievent)>Events.ParallelPort_Move,1,'last'));
            RX.(move_event_name)(ievent) = (TimeVecs.timeS(move_events(ievent)) - TimeVecs.timeS(closest_cue(ievent)));
        end
    end
    DB_entry.Preproc.Rx_EMG_from_move_cue = RX.EMG;
    
    move_event_name = 'ACC';
    % Check if markers are made or not
    if ~isfield(Events,move_event_name)
        if questdlg_YesNo_logic(['No ' move_event_name ' markers found. Run?'],DB_entry.entry_id)
            Events = DB_entry.Calc_Event_Markers(move_event_name,TimeVecs);
        end
    end
    % RX time from Cue based on autodetect
    move_events = Events.(move_event_name);
    if ~isnan(move_events)
        clear closest_cue
        for ievent = 1:length(move_events)
            closest_cue(ievent) = Events.ParallelPort_Move(find(move_events(ievent)>Events.ParallelPort_Move,1,'last'));
            RX.(move_event_name)(ievent) = (TimeVecs.timeS(move_events(ievent)) - TimeVecs.timeS(closest_cue(ievent)));
        end
    end
    DB_entry.Preproc.Rx_ACC_from_move_cue = RX.ACC;
    
    move_event_name = 'photodiode';
    % Check if markers are made or not
    if ~isfield(Events,move_event_name)
        if questdlg_YesNo_logic(['No ' move_event_name ' markers found. Run?'],DB_entry.entry_id)
            Events = DB_entry.Calc_Event_Markers(move_event_name,TimeVecs);
        end
    end
    % RX time from Cue based on autodetect
    move_events = Events.(move_event_name);
    if ~isnan(move_events)
        clear closest_cue
        for ievent = 1:length(move_events)
            closest_cue(ievent) = Events.ParallelPort_Move(find(move_events(ievent)>Events.ParallelPort_Move,1,'last'));
            RX.(move_event_name)(ievent) = (TimeVecs.timeS(move_events(ievent)) - TimeVecs.timeS(closest_cue(ievent)));
        end
        DB_entry.Preproc.Rx_photodiode_from_move_cue = RX.photodiode;
    end
    
    % Update database local
    DB = DB.update_entry(DB_entry);
    
    %         % Plot_QuantileBar({RX.EMG RX.ACC});
    %         Plot_Bars({'EMG','ACC'},{RX.EMG RX.ACC});
    %         ylabel('Time from Parallel Port onset [S]')
    %     end
end
% Write database to file
if questdlg_YesNo_logic('Save DB?')
    DB.save_DB;
end

