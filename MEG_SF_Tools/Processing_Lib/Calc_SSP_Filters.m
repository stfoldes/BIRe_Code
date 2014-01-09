% [ssp_projector] = Calc_SSP_Filters(ssp_components);
% Turns a list of SSP-components into projector (i.e. SSP-Filter)
%
% INPUTS
%     ssp_components: [sensors x components] see: Calc_SSP.m
% OUTPUTS
%     ssp_projector: [sensors x sensors] can be used to remove just these components
%         data_clean = (ssp_projector*MEG_data')';
%
% EXAMPLE
%     % Data Look Up Info
%     clear criteria_struct
%     criteria_struct.subject = 'NC03';
%     criteria_struct.run_type = 'Open_Loop_MEG';
%     criteria_struct.run_task_side = 'Right';
%     criteria_struct.run_action = 'Grasp';
%     criteria_struct.run_intention = 'Attempt';
% 
%     % Load Metadata for file
%     server_base_path = '/home/foldes/Desktop/Katz/experiments/meg_neurofeedback/';
%     local_base_path = '/home/foldes/Data/MEG/';
%     metadatabase_base_path = server_base_path;
%     metadatabase_location=[metadatabase_base_path filesep 'Neurofeedback_metadatabase.txt'];
%     Metadata = Metadata_Class();
%     Metadata = Load_StandardStruct_from_TXT(Metadata,metadatabase_location);
%     [metadata_entry] = Metadata_Get_Entry(Metadata,criteria_struct);
%     Extract.file_type='sss';
%     Extract.data_path_default = local_base_path;
%     Extract = Prep_Extract_w_Metadata(Extract,metadata_entry);
%     
%     % Load Data and Events
%     [MEG_data,TimeVecs.timeS] = Load_from_FIF(Extract,'MEG');
%     load([server_base_path filesep metadata_entry.subject filesep 'S' metadata_entry.session filesep metadata_entry.Preproc.Pointer_Events]);
% 
%     % Computer SSP
%     ssp_components_blink = Calc_SSP(MEG_data,Events.blink,Extract.data_rate,'blink');
%     ssp_components_cardiac = Calc_SSP(MEG_data,Events.cardiac,Extract.data_rate,'cardiac');
%     ssp_projector = Calc_SSP_Filters([ssp_components_blink ssp_components_cardiac]);
%     
%     % Apply SSP
%     data_clean = (ssp_projector*MEG_data')';
%
% Foldes 2013-04-24
% UPDATES:
%

function [ssp_projector] = Calc_SSP_Filters(ssp_components)

% Reorthogonalize the vectors (SEE BST: process_ssp.m)
[U,S,V] = svd(ssp_components,0);
S = diag(S);
% Throw away the linearly dependent components (threshold on singular values: 0.01 * the first one)
iThresh = find(S < 0.01 * S(1),1);
if ~isempty(iThresh)
    disp(sprintf('SSP> %d linearly depedent vectors removed...', size(U,2)-iThresh+1));
    U = U(:, 1:iThresh-1);
end

% Compute projector in the form: I-UUt
ssp_projector = eye(size(U,1)) - (U*U');    
    
    
    