% Easy script to load a dataset to get to the point of calculating power
%
% Requires SSPs and Events already made
%
% 2013-07-05 Foldes

clear
close all
overwrite_flag=0;
results_save_name = 'ModDepth_sss_trans_Cue';

% Choose criteria for data set to analyize
clear criteria_struct
criteria_struct.subject = 'NC01';
criteria_struct.run_type = 'Open_Loop_MEG';
criteria_struct.run_task_side = 'Right';
criteria_struct.run_action = 'Grasp';
% criteria_struct.run_intention = 'Imagine';
criteria_struct.run_intention = 'Attempt';
% criteria_struct.session = '01'
% Metadata_lookup_unique_entries(Metadata,'run_action') % check the entries

Extract.file_type='sss_trans'; % What type of data?

%% Load Database
% PATHS
local_path = '/home/foldes/Data/MEG/';
server_path = '/home/foldes/Desktop/Katz/experiments/meg_neurofeedback/';
metadatabase_path = '/home/foldes/Desktop/Katz/experiments/meg_neurofeedback/';
metadatabase_location=[metadatabase_path filesep 'Neurofeedback_metadatabase.txt'];
%metadatabase_location='/home/foldes/Dropbox/Code/MEG_SF_Tools/Databases/Neurofeedback_metadatabase_backup.txt';

% Load Metadata from text file

Metadata = Metadata_Class();
Metadata = Load_StandardStruct_from_TXT(Metadata,metadatabase_location);


Extract.data_path_default = local_path;

% Chooses the approprate entry (makes one if you don't have one)
[entry_idx_list] = Metadata_Find_Entries_By_Criteria(Metadata,criteria_struct);

% % CHECK FIRST
% property_name = 'Preproc.Pointer_processed_data_for_events';
property_name = ['ResultPointers.' results_save_name];
Metadata_Report_Property_Check(Metadata(entry_idx_list),property_name);

%%
ientry = 1;

metadata_entry = Metadata(entry_idx_list(ientry));
disp(' ')
disp(['==================File #' num2str(ientry) '/' num2str(length(entry_idx_list)) ' | ' metadata_entry.file_base_name '================='])
% Copy local (can be used to copy all that match criteria)
Metadata_Copy_Data_from_Server(metadata_entry,[],local_path,server_path,[MEG_file_type2file_extension(Extract.file_type) '.fif']);

%% Preparing Data Set Info and Analysis-related Parameters

%---Extraction Info-------------
Extract = Prep_Extract_w_Metadata(Extract,metadata_entry);
Extract.channel_list=sort([1:3:306 2:3:306]); % only gradiometers
%-------------------------------

%---Feature Parameters (FeatureParms.)---
FeatureParms = FeatureParms_Class;
% Can be empty for loading feature data from CRX files
FeatureParms.feature_method = 'MEM';
FeatureParms.order = 12; % changed from 30 b/c couldn't get mu (2013-06-25 Foldes)
FeatureParms.feature_resolution = 1;
FeatureParms.ideal_freqs = [0:150]; % Pick freq or bins
FeatureParms.sample_rate = Extract.data_rate;
%-------------------------------

%---Analysis Parameters (AnalysisParms.)---
AnalysisParms.event_name_move = 'ParallelPort_Move';
AnalysisParms.rx_timeS_move=0;
AnalysisParms.window_lengthS_move = .5;

AnalysisParms.event_name_rest = 'ArtifactFreeRest';
AnalysisParms.rx_timeS_rest=0;
AnalysisParms.window_lengthS_rest = 3;
%-------------------------------

%% ----------------------------------------------------------------
%  -----------------CODE STARTS------------------------------------
%  ----------------------------------------------------------------

%% Load MEG data

[MEG_data,TimeVecs.timeS] =  Load_from_FIF(Extract,'MEG');
TimeVecs.data_rate = Extract.data_rate;
[TimeVecs.target_code_org] =  Load_from_FIF(Extract,'STI');

%% Load SSP

% try to load if possible, or calculate
if exist([Extract.file_path filesep metadata_entry.Preproc.Pointer_SSP])==2
    load([Extract.file_path filesep metadata_entry.Preproc.Pointer_SSP]);
else
    % ***TEMPORARY, THIS MEANS THE POINTER WASN'T WRITTEN FOR SOME REASON***
    pointer_name = ['SSP_' Extract.file_type];
    if exist([Extract.file_path filesep Extract.file_base_name '_' pointer_name '.mat'])==2
        load([Extract.file_path filesep Extract.file_base_name '_' pointer_name]);
        metadata_entry.Preproc.Pointer_SSP = [Extract.file_base_name '_' pointer_name '.mat'];
    else
        warning('NO SSP found')
    end
end

clear MEG_data_clean % 2013-06-26 Foldes
% Apply
ssp_projector = Calc_SSP_Filters(ssp_components);
MEG_data_clean = (ssp_projector*MEG_data')';
clear MEG_data

%% Load Events

% try to load if possible
if exist([Extract.file_path filesep metadata_entry.Preproc.Pointer_Events])==2
    load([Extract.file_path filesep metadata_entry.Preproc.Pointer_Events]);
else
    % ***TEMPORARY, THIS MEANS THE POINTER WASN'T WRITTEN FOR SOME REASON***
    pointer_name = ['Events_' Extract.file_type];
    if exist([Extract.file_path filesep Extract.file_base_name '_Events.mat'])==2
        load([Extract.file_path filesep Extract.file_base_name '_Events.mat']);
        metadata_entry.Preproc.Pointer_Events = [Extract.file_base_name '_Events.mat'];
    end
end

%% Modulation Calculation



%%
% disp(length(Events.(event_name_move)))
% disp(length(Events.(event_name_rest)))

% % Calc Move Power *AFTER* movement onset (event is in center of analysis window)
% FeatureParms.window_lengthS=AnalysisParms.window_lengthS_move;
% FeatureParms.window_length = floor(FeatureParms.window_lengthS*Extract.data_rate);
% [feature_data_move,FeatureParms]=Calc_PSD_TimeLocked(MEG_data_clean,Events.(AnalysisParms.event_name_move),FeatureParms);
% 
% % Calc Rest power *AROUND* cue
% FeatureParms.window_lengthS = AnalysisParms.window_lengthS_rest;
% FeatureParms.window_length = floor(FeatureParms.window_lengthS*Extract.data_rate);
% [feature_data_rest,FeatureParms]=Calc_PSD_TimeLocked(MEG_data_clean,Events.(AnalysisParms.event_name_rest)-floor(FeatureParms.window_length/2),FeatureParms);

disp('***Ready for Feature Analysis***')