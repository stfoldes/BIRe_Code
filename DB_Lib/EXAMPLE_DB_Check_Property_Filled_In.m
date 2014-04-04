% Metadata Script to look at which entries in the database have a given process complete

server_path = '/home/foldes/Desktop/Katz/experiments/meg_neurofeedback/';
metadatabase_location=[server_path filesep 'Neurofeedback_metadatabase.txt'];
% Load Metadata from text file
Metadata = Metadata_Class();
Metadata = Load_StandardStruct_from_TXT(Metadata,metadatabase_location);

clear criteria_struct
criteria_struct.run_task_side = 'Right';
criteria_struct.run_action = 'Grasp';
criteria_struct.run_intention = 'Attempt';
criteria_struct.run_type = 'Open_Loop_MEG';

% property_name = 'Preproc.Pointer_Events';
property_name = 'Preproc.Pointer_prebadchan';

[incompleted_idx_list,completed_idx_list]=Metadata_Report_Property_Check(Metadata.by_criteria(criteria_struct),property_name);




