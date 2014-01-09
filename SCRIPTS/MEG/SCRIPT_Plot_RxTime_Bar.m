% After Script_EMG_RX_time
%
% 2013-07-11 Foldes
% 2013-10-07 Foldes

clear
close all

% Choose criteria for data set to analyize
clear criteria_struct
% criteria_struct.subject = 'NC01';
criteria_struct.run_type = 'Open_Loop_MEG';
criteria_struct.run_task_side = 'Right';
criteria_struct.run_action = 'Grasp';
% criteria_struct.run_intention = 'Imagine';
% criteria_struct.run_intention = 'Attempt';
criteria_struct.run_intention = 'Imitate';
% criteria_struct.session = '01'
% Metadata_lookup_unique_entries(Metadata,'run_action') % check the entries

Extract.file_type='fif'; % What type of data?

%% Load Database
% PATHS
local_base_path = '/home/foldes/Data/MEG/';
server_base_path = '/home/foldes/Desktop/Katz/experiments/meg_neurofeedback/';
metadatabase_base_path = '/home/foldes/Desktop/Katz/experiments/meg_neurofeedback/';
metadatabase_location=[metadatabase_base_path filesep 'Neurofeedback_metadatabase.txt'];

% Load Metadata from text file
Metadata = Metadata_Class();
Metadata = Load_StandardStruct_from_TXT(Metadata,metadatabase_location);


Extract.data_path_default = local_base_path;

% Chooses the approprate entry (makes one if you don't have one)
[entry_idx_list] = Metadata_Find_Entries_By_Criteria(Metadata,criteria_struct);

% % CHECK FIRST
% property_name = 'Preproc.Pointer_processed_data_for_events';
% property_name = ['ResultPointers.' results_save_name];
% Metadata_Report_Property_Check(Metadata(entry_idx_list),[],property_name);

%%
ientry = 1;
clear subject_names* RX_EMG_quant RX_EMG_count RX_ACC_quant RX_ACC_count
subject_cnt_EMG = 0;subject_cnt_ACC = 0;
for ientry = 1:length(entry_idx_list)
    
    metadata_entry = Metadata(entry_idx_list(ientry));
    disp(' ')
    disp(['==================File #' num2str(ientry) '/' num2str(length(entry_idx_list)) ' | ' metadata_entry.file_base_name '================='])
    if ~isempty(metadata_entry.Preproc.Rx_EMG_from_move_cue)
        subject_cnt_EMG = subject_cnt_EMG +1;
        subject_names_EMG{subject_cnt_EMG}=metadata_entry.subject();
        RX_EMG_quant(:,subject_cnt_EMG) = quantile(metadata_entry.Preproc.Rx_EMG_from_move_cue,[0 .25 .50 .75 1.00]);
        RX_EMG_count(subject_cnt_EMG) = length(metadata_entry.Preproc.Rx_EMG_from_move_cue);
    end
    if ~isempty(metadata_entry.Preproc.Rx_ACC_from_move_cue)
        subject_cnt_ACC = subject_cnt_ACC +1;
        subject_names_ACC{subject_cnt_ACC}=metadata_entry.subject();

        RX_ACC_quant(:,subject_cnt_ACC) = quantile(metadata_entry.Preproc.Rx_ACC_from_move_cue,[0 .25 .50 .75 1.00]);
        RX_ACC_count(subject_cnt_ACC) = length(metadata_entry.Preproc.Rx_ACC_from_move_cue);
    end
end
%%
[~,sort_name_idx] = sort(subject_names_EMG);

figure;
hold all
baredge_color=.6*[1 1 1];
x_plot=[1:size(RX_EMG_quant,2)];
bar(x_plot,RX_EMG_quant(3,sort_name_idx),'FaceColor',baredge_color,'EdgeColor',0*[1 1 1],'LineWidth',1.5)
errorbar(x_plot,RX_EMG_quant(3,sort_name_idx),RX_EMG_quant(2,sort_name_idx)-RX_EMG_quant(3,sort_name_idx),RX_EMG_quant(4,sort_name_idx)-RX_EMG_quant(3,sort_name_idx),'.','Color',0*[1 1 1],'LineWidth',2)
plot([0 length(x_plot)+1],[0.5 0.5],'r--')
Figure_Stretch(2)
Figure_TightFrame
ylabel('EMG-Cue [S]')

% X labels if desired
x_class_labels = subject_names_EMG;
set(gca,'XTick',x_plot)
set(gca,'XTickLabel',x_class_labels(sort_name_idx))
set(gca,'FontSize',12)
xlabel_rotate

[~,sort_name_idx] = sort(subject_names_ACC);

figure;
hold all
baredge_color=.6*[1 1 1];
x_plot=[1:size(RX_ACC_quant,2)];
bar(x_plot,RX_ACC_quant(3,sort_name_idx),'FaceColor',baredge_color,'EdgeColor',0*[1 1 1],'LineWidth',1.5)
errorbar(x_plot,RX_ACC_quant(3,sort_name_idx),RX_ACC_quant(2,sort_name_idx)-RX_ACC_quant(3,sort_name_idx),RX_ACC_quant(4,sort_name_idx)-RX_ACC_quant(3,sort_name_idx),'.','Color',0*[1 1 1],'LineWidth',2)
plot([0 length(x_plot)+1],[0.5 0.5],'r--')
Figure_Stretch(2)
Figure_TightFrame
ylabel('ACC-Cue [S]')

% X labels if desired
x_class_labels = subject_names_ACC;
set(gca,'XTick',x_plot)
set(gca,'XTickLabel',x_class_labels(sort_name_idx))
set(gca,'FontSize',12)
xlabel_rotate

% figure;plot(RX_ACC_count)