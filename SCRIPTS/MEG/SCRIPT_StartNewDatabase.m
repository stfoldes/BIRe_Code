% Script make a new database (or can be used to manually enter data)
%
% SEE: SCRIPT_Neurofeedback_Database_Entry and Database_Add_Entries_by_GUI
%
% 2013-09-30 Foldes
% UPDATES:
%

clear

project_name = 'Presurgical';

%% Generate Database Paths
[local_path,server_base_path]=DEF_MEG_paths;
server_path = uigetdir(server_base_path,'SELECT PROJECT FOLDER');
database_path = uigetdir(server_path,'SELECT FOLDER FOR DATABASE');
database_location=[database_path filesep project_name '_meta.txt'];

%% ENTRIES

Meda = Metadata_Class();


% Pick files on server
files = uigetfile('.fif','Select Files to Add',local_path,...
    'MultiSelect','on');

% Fill in basic info AUTO
for ifile=1:length(files)
    % ***DATABASE SPECIFIC***
    Meda(ifile).file_base_name = files{ifile}(1:end-4); % remove the .fif
    [Meda(ifile).subject, Meda(ifile).session, Meda(ifile).run] = file_name_spliter(Meda(ifile).file_base_name,5);
    % ***********************
end
 
% SESSION WIDE DATA   
for ifile=1:length(files)
    Meda(ifile).subject_type = 'SCI';
    Meda(ifile).gender = 'M';
    Meda(ifile).handedness = 'R';
    Meda(ifile).date = '20130923';
end
    

% type out helper code to the workspace for copying and pasting here
for ifile=1:length(files)
    fprintf('current_file = ''%s'';\n',(Meda(ifile).file_base_name))
    fprintf('\tcurrent_entry = Metadata_find_idx(Meda,''file_base_name'',current_file);\n')
    
    fprintf('\tMeda(current_entry).run_type = ''Mapping'';\n')
    fprintf('\tMeda(current_entry).run_action = '' '';\n')
    fprintf('\tMeda(current_entry).run_task_side = '' '';\n')
    fprintf('\tMeda(current_entry).run_intention = '' '';\n')
    fprintf('\n')
end

%% EACH FILE
current_file = 'dbi04s01preemptyroom';
	current_entry = Metadata_find_idx(Meda,'file_base_name',current_file);
	Meda(current_entry).run_type = 'Empty_Room';

current_file = 'dbi04s01r01';
	current_entry = Metadata_find_idx(Meda,'file_base_name',current_file);
	Meda(current_entry).run_type = 'Baseline';

current_file = 'dbi04s01r02';
	current_entry = Metadata_find_idx(Meda,'file_base_name',current_file);
	Meda(current_entry).run_type = 'Artifacts';

current_file = 'dbi04s01r03';
	current_entry = Metadata_find_idx(Meda,'file_base_name',current_file);
	Meda(current_entry).run_type = 'Mapping';
	Meda(current_entry).run_action = 'Fingers';
	Meda(current_entry).run_task_side = 'Right';
	Meda(current_entry).run_intention = 'Imitate';

current_file = 'dbi04s01r04';
	current_entry = Metadata_find_idx(Meda,'file_base_name',current_file);
	Meda(current_entry).run_type = 'Mapping';
	Meda(current_entry).run_action = 'Elbow';
	Meda(current_entry).run_task_side = 'Right'; 
	Meda(current_entry).run_intention = 'Imitate';

current_file = 'dbi04s01r05';
	current_entry = Metadata_find_idx(Meda,'file_base_name',current_file);
	Meda(current_entry).run_type = 'Mapping';
	Meda(current_entry).run_action = 'Grasp';
	Meda(current_entry).run_task_side = 'Right'; 
	Meda(current_entry).run_intention = 'Imitate';

current_file = 'dbi04s01r06';
	current_entry = Metadata_find_idx(Meda,'file_base_name',current_file);
	Meda(current_entry).run_type = 'Mapping';
	Meda(current_entry).run_action = 'Mouth';
	Meda(current_entry).run_task_side = ''; 
	Meda(current_entry).run_intention = 'Imitate';

current_file = 'dbi04s01r07';
	current_entry = Metadata_find_idx(Meda,'file_base_name',current_file);
	Meda(current_entry).run_type = 'Mapping';
	Meda(current_entry).run_action = 'Wrist';
	Meda(current_entry).run_task_side = 'Right'; 
	Meda(current_entry).run_intention = 'Imitate';

current_file = 'dbi04s01r08';
	current_entry = Metadata_find_idx(Meda,'file_base_name',current_file);
	Meda(current_entry).run_type = 'Mapping';
	Meda(current_entry).run_action = 'Shoulder';
	Meda(current_entry).run_task_side = 'Right'; 
	Meda(current_entry).run_intention = 'Imitate';

current_file = 'dbi04s01r09';
	current_entry = Metadata_find_idx(Meda,'file_base_name',current_file);
	Meda(current_entry).run_type = 'Mapping';
	Meda(current_entry).run_action = 'Grasp';
	Meda(current_entry).run_task_side = 'Left'; 
	Meda(current_entry).run_intention = 'Imitate';

current_file = 'dbi04s01r10';
	current_entry = Metadata_find_idx(Meda,'file_base_name',current_file);
	Meda(current_entry).run_type = 'Mapping';
	Meda(current_entry).run_action = 'Fingers';
	Meda(current_entry).run_task_side = 'Left'; 
	Meda(current_entry).run_intention = 'Imitate';

current_file = 'dbi04s01r21';
	current_entry = Metadata_find_idx(Meda,'file_base_name',current_file);
	Meda(current_entry).run_type = 'Mapping';
	Meda(current_entry).run_action = 'SensoryPalm';
	Meda(current_entry).run_task_side = 'Left'; 
	Meda(current_entry).run_intention = 'Imitate';

current_file = 'dbi04s01r22';
	current_entry = Metadata_find_idx(Meda,'file_base_name',current_file);
	Meda(current_entry).run_type = 'Mapping';
	Meda(current_entry).run_action = 'SensoryPalm';
	Meda(current_entry).run_task_side = 'Right'; 
	Meda(current_entry).run_intention = 'Imitate';

current_file = 'dbi04s01r23';
	current_entry = Metadata_find_idx(Meda,'file_base_name',current_file);
	Meda(current_entry).run_type = 'Mapping';
	Meda(current_entry).run_action = 'Ankle';
	Meda(current_entry).run_task_side = 'Right'; 
	Meda(current_entry).run_intention = 'Imitate';

current_file = 'dbi04s01r24';
	current_entry = Metadata_find_idx(Meda,'file_base_name',current_file);
	Meda(current_entry).run_type = 'Mapping';
	Meda(current_entry).run_action = 'Grasp_Neurofeedback';
	Meda(current_entry).run_task_side = 'Right'; 
	Meda(current_entry).run_intention = 'Imitate';

current_file = 'dbi04s01r25';
	current_entry = Metadata_find_idx(Meda,'file_base_name',current_file);
	Meda(current_entry).run_type = 'Mapping';
	Meda(current_entry).run_action = 'MotorEvent';
	Meda(current_entry).run_task_side = 'Right'; 
	Meda(current_entry).run_intention = 'Imitate';

current_file = 'dbi04s01r26';
	current_entry = Metadata_find_idx(Meda,'file_base_name',current_file);
	Meda(current_entry).run_type = 'Empty_Room';
    


%% Write to file
if questdlg_YesNo_logic(['Create new project? ' database_location])   
    warning off
    Write_StandardStruct2TXT(Meda,database_location);
    warning on
end
