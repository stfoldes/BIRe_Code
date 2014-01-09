% Script to add entries into the database
% Select files to enter, it asks user for info 
% for now, write down any mistakes (file name) and Stephen can manually fix w/o problem
% Requires server access
%
% SEE: Add_Entries_by_Folder, Batch_Preprocessing_MEG, SCRIPT_Status_BadChan_and_MaxFilter
%
% 2013-08-22 Foldes
% UPDATES:
% 2013-10-17 Foldes: Metadata-->DB

clear


DB=DB_MEG_Class;
DB=DB.build('PATHS_meg_neurofeedback'); % also sets global MY_PATHS

file_ext = '.fif';
% One time properties (session is automatically taken from the name)
props_once_per_folder = {'subject_type','gender','handedness','date'};
% Skip this property
props_skip ={'run_info'};

DB = DB.Add_Entries_by_GUI('file_ext',file_ext,'props_once_per_folder',props_once_per_folder,'props_skip',props_skip);

