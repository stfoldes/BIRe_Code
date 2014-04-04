% Uses DB to calculate move and rest power from timelocked events
% Can be used to loop through many files that match the 'criteria'
% AnalysisParms need to be defined here.
% Currently: Events are cue based
% 
% SEE: Calc_Power_MoveRest_wDB.m
%
% 2013-06-08 Foldes [Branched]
% UPDATES:
% 2013-10-11 Foldes: Metadata-->DB
% 2013-10-24 Foldes: Results --> Power
% 2014-03-17 Foldes: Branched as a SCRIPT
% 2014-03-28 Foldes: SEE: SCRIPT_ModDepth_Sources.m for how to do with DB_Loop_Wrapper

clearvars -except DB

% Choose criteria for data set to analyize
clear criteria
criteria.subject =          'NC01';
criteria.run_intention =    'Attempt';
criteria.run_task_side =    'Right';
criteria.run_action =       'Grasp';
criteria.run_type =         'Open_Loop_MEG';

save_flag =                 true; % save the data to the db?
overwrite_results_flag =    true; % if saving, prevents asking bf overwriting
save_pointer_name =         'ResultPointers.Power_tsss_Cue';
Plot_Flags.Events =         false;
Plot_Flags.PSD =            true;
Plot_Flags.Topo =           true;

%---Analysis Parameters (AnalysisParms.)---
AnalysisParms.file_type =   'tsss'; % What type of data
AnalysisParms.SSP_Flag =    0;
% Window-timing Parameters
% AnalysisParms.event_name_move = PROGRAMTICALLY DEFINED BELOW
AnalysisParms.window_lengthS_move = 1; % 1s to help with rx variablity
AnalysisParms.rx_timeS_move =       0.1;    % 2013-10-11: 100ms b/c of parallel-port/video offset
% 1/2s should be for center at 500ms post parallel port 2013-08-23
AnalysisParms.num_reps_per_block =  4; % Only use the first 4 reps per block

AnalysisParms.event_name_rest =     'ArtifactFreeRest';
AnalysisParms.window_lengthS_rest = 3; % window is centered (this IS the WindowS from auto-event-parms)
AnalysisParms.rx_timeS_rest =       0; % shift window (this is NOT the rx_time from auto-event-parms, this should be 0)
%-------------------------------



%% Load Database

% Build database
if ~exist('DB','var')
    DB = DB_MEG_Class;
    DB = DB.build('PATHS_meg_neurofeedback'); % also sets global MY_PATHS
end

% Chooses the approprate entries
DB_short = DB.get_entry(criteria);

%% Loop for All Entries
fail_list = [];
for ientry = 1:length(DB_short)
    
    DB_entry = DB_short(ientry);
    disp(' ')
    disp(['==================File #' num2str(ientry) '/' num2str(length(DB_short)) ' | ' DB_entry.entry_id '================='])
    
    try
        % Analysis Parameters (Programatic)
        switch lower(DB_entry.run_intention)
            case {'imitate' 'attempt'}
                AnalysisParms.event_name_move = 'ParallelPort_Move_Good';
            case {'observe' 'imagine'}
                AnalysisParms.event_name_move = 'ArtifactFreeMove';
        end
        
        % Calculate
        Power = Calc_Power_MoveRest_wDB(DB_entry,AnalysisParms,Plot_Flags);
        
        % Save processed data to file & write to DB entry
        if save_flag == 1
            [DB_entry,saved_pointer_flag] = DB_entry.save_pointer(Power,save_pointer_name,'mat',overwrite_results_flag);
            % Save current DB entry back to database
            if saved_pointer_flag == 1
                DB = DB.update_entry(DB_entry);
            end
        end
        
    catch
        disp('***********************************')
        disp('*********** FAIL ******************')
        disp('***********************************')
        fail_list{end+1} = DB_entry.entry_id;
    end
end

% Save database out to file
if save_flag == 1 && saved_pointer_flag == 1
    DB.save_DB;
end
