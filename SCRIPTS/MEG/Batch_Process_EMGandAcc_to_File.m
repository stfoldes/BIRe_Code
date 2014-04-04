% Batch_Process_EMGandAcc_to_File
% See Mark_Events.m
%
% Runs a bunch of EMG and MISC channel processing and saves the data to file and to the database.
% Forces an overwrite
%
% Foldes 2013-03-06
% UPDATES:
% 2013-04-08 Foldes: Update what is processed
% 2013-05-22 Foldes: checked
% 2013-07-23 Foldes: Trying now......
% 2013-10-17 Foldes: Metadata-->DB

%% USER DEFINED
clear all

clear criteria
criteria.subject = {'NC10','NS11'};
criteria.run_type = 'Open_Loop_MEG';
%criteria.run_task_side = 'Right';
criteria.run_action = 'Grasp';
%     criteria.run_intention = 'Imagine';
% criteria.session = '01';
% criteria.subject_type = 'SCI';


overwrite_flag=1; % 1=overwrite

%% Prep

% Build database
if ~exist('DB','var')
    DB=DB_MEG_Class;
    DB=DB.build('PATHS_meg_neurofeedback'); % also sets global MY_PATHS
end

% Chooses the approprate entries
DB_short = DB.get_entry(criteria);

% % Chooses the approprate entry (makes one if you don't have one)
% [entry_idx_list] = DB_Find_Entries_get_entry(DB,criteria);
% % Copy local (can be used to copy all that match criteria)
% DB_Copy_Data_from_Server(DB,criteria,local_path,server_path,[]);
% 
% % CHECK FIRST
% property_name = 'Preproc.Pointer_processed_data_for_events';
% DB_Report_Property_Check(DB(entry_idx_list),property_name);

%%

for ientry = 1:length(DB_short)
    
    try
        DB_entry = DB_short(ientry);
        disp(' ')
        disp(['==================File #' num2str(ientry) '/' num2str(length(DB_short)) ' | ' DB_entry.entry_id '================='])
        
        % Setting Parameters
        Extract.file_type='fif'; % What type of data?
        Extract.file_path = DB_entry.file_path('local');
        Extract.channel_list=[1:306];
        Extract = DB_entry.Prep_Extract(Extract);
        % Copy local (can be used to copy all that match criteria)
        DB_entry.download(Extract.file_name_ending);
        
        
        % Calculate time series data that will be used for marking events SLOW
        processed_data=Calc_Processed_EMGandACC(Extract);
        
        % Save processed data to file & write to DB entry
        [DB_entry,saved_pointer_flag] = DB_entry.save_pointer(processed_data,...
            'Preproc.Pointer_processed_data_for_events','mat',overwrite_flag);
        
        % Save current DB entry back to database
        if saved_pointer_flag==1
            DB=DB.update_entry(DB_entry);
        end
    catch
        warning(['FAIL w/ entry #' num2str(ientry) ', ' DB_entry.entry_id])
    end
end
DB.save_DB;

DB_Report_Property_Check(DB.get_entry(criteria),'Preproc.Pointer_processed_data_for_events');


