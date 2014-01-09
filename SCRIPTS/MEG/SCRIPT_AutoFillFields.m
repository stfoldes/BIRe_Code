% Script to go through all DB entries and add standardized data that might have been missed, like pointers
% Now does Pointers: prebadchan, processed_data_for_events, Events; bad_chan_list, sensorimotor_chan_quality; datatypeXXX
% Takes a minute or so
%
% SEE: DB_Script_Plot_BadChans.m
%
% 2013-08-16 Foldes
% UPDATES
% 2013-10-03 Foldes: Renamed from DB_Script_AutoFillFields
% 2013-10-15 Foldes: Metadata-->DB

clear

% if you only want to do someie
clear criteria
criteria.run_type = 'Open_Loop_MEG';
% criteria.run_task_side = 'Right';
% criteria.run_action = 'Grasp';

%% Load DB
DB=DB_MEG_Class;
DB=DB.build('PATHS_meg_neurofeedback'); % also sets global MY_PATHS

%% List of fields to auto fill for *.Preproc.*

ifill=1;
auto_fills(ifill).field_name = 'Pointer_prebadchan';
auto_fills(ifill).file_suffix = '_prebadchan.txt'; % follows entry_id
ifill=ifill+1;
auto_fills(ifill).field_name = 'Pointer_processed_data_for_events';
auto_fills(ifill).file_suffix = '_processed_data_for_events.mat'; % follows entry_id
ifill=ifill+1;
auto_fills(ifill).field_name = 'Pointer_Events';
auto_fills(ifill).file_suffix = '_Events.mat'; % follows entry_id



%% 1st Mark .datatypeXXX based on server
DB = DB.DB_MEG_DataTypeCheck;

%% Autofill fields (and bad_chan info)
entry_idx_list = 1:length(DB);

[~,entry_idx_list] = DB.get_entry(criteria);



for ientry = 1:length(entry_idx_list)
    DB_entry = DB(entry_idx_list(ientry));
    
    entry_server_path = DB_entry.file_path('server');
    
    DB_entry.run_info = [DB_entry.subject '_' DB_entry.run_action '_' DB_entry.run_task_side '_' DB_entry.run_intention];
    
    % Try to fill in all auto_fills
    for ifill = 1:length(auto_fills)
        if isempty(DB_entry.Preproc.(auto_fills(ifill).field_name))
            % standard file must exist to mark it
            ideal_file_name = [entry_server_path filesep DB_entry.entry_id auto_fills(ifill).file_suffix];
            if exist(ideal_file_name)==2
                DB_entry.Preproc.(auto_fills(ifill).field_name) = ideal_file_name;
                disp(['Had to write ' auto_fills(ifill).field_name ' for: ' DB_entry.run_info ' (' DB_entry.entry_id ')'])
            end
        end
    end % fills
    
    % Bad Channels from SSS
    badchan_file = [entry_server_path filesep DB_entry.entry_id '_badchans.txt'];
    if exist(badchan_file)==2
        % Translate NeuroMag Sensor Numbering to Order Numbering
        
        try
            DB_entry.Preproc.bad_chan_list =NeuromagCode2ChanNum(load(badchan_file));
            DB_entry.Preproc.sensorimotor_chan_quality = 1-length(find_lists_overlap_idx(DB_entry.Preproc.bad_chan_list,DEF_MEG_sensors_sensorimotor))/length(DEF_MEG_sensors_sensorimotor);
        catch
            warning(['FAILURE WITH MAXFILTER FOR ' DB_entry.run_info ' (' DB_entry.entry_id ')'])
        end
    else
        disp(['NO BAD CHANNELS RAN: ' DB_entry.run_info ' (' DB_entry.entry_id ')'])
    end
    
    DB = DB.update_entry(DB_entry);
end % entries

DB.save_DB;





%% Plot bad channels

[incompleted_idx_list,completed_idx_list]=DB_Report_Property_Check(DB.get_entry(criteria),'Preproc.bad_chan_list');

qual_cnt = 0;
for ientry = 1:length(entry_idx_list)
    current_qual = (DB(entry_idx_list(ientry)).Preproc.sensorimotor_chan_quality);
    if ~isempty(current_qual)
        qual_cnt = qual_cnt+1;
        all_qual(qual_cnt) = current_qual;
    end
end
disp_mean_std(all_qual)

% Plot_BadChans(DB,server_path,'quality_thres',0.90);
% Figure_Run_on_All_Open_Figs('Figure_Save')




