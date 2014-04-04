% Script to help fix an error in an entry
% Does it a more safe and indirect way (no real reason)
%
% Foldes 2013-03-02

clear

% What to Change
criteria_struct.file_base_name = 'ns01s02r13';
property_name = 'Analysis_ModDepth_sss_trans_pointer';
new_value = char([]);


%% Get metadata for an entry
server_base_path = '/home/foldes/Desktop/Katz/experiments/meg_neurofeedback/';
% server_base_path = '\\192.168.1.4\data\experiments\meg_neurofeedback\';
metadatabase_location=[server_base_path filesep 'Neurofeedback_metadatabase.txt'];

% Load Metadata from text file
Metadata = Metadata_Class();
Metadata = Load_StandardStruct_from_TXT(Metadata,metadatabase_location);

% Chooses the approprate entry (makes one if you don't have one)
[metadata_entry] = Metadata_Get_Entry(Metadata,criteria_struct);


%% ===DO CHANGE HERE===

eval(['metadata_entry.' property_name '=new_value;'])




% =====================
%% Save current metadata entry back to database
Metadata=Metadata_Update_Entry(metadata_entry,Metadata);
Metadata_Write_to_TXT(Metadata,metadatabase_location);

%% Check
clear criteria_struct
criteria_struct=[];
% criteria_struct.run_task_side = 'Right';
% criteria_struct.run_action = 'Grasp';
% criteria_struct.run_intention = 'Attempt';
% criteria_struct.run_type = 'Open_Loop_MEG';
% 

[incompleted_idx_list,completed_idx_list]=Metadata_Report_Property_Check(Metadata.by_criteria(criteria_struct),property_name);


%% Changing all 

for ientry = 1:length(completed_idx_list)
    Metadata(completed_idx_list(ientry)).(property_name)=new_value;
end
Metadata_Write_to_TXT(Metadata,metadatabase_location);

