function OverlayFile_str = BST_Build_OverlayFile_str(Extract)
% Just builds the OverlayFile input string for view_surface_data.m
% link must already in db to use
%
% SEE: BST_Load_Inverse_Data.m
% 2014-02-03 Foldes


global BST_DB_PATH

% EXAMPLE: link|Subject01_copy/1/results_wMNE_MEG_GRAD_KERNEL_140124_1807.mat|Subject01_copy/1/data_1_average_140128_1525.mat


% Search for file (ASSUMES ONLY ONE FILE THAT MATCH THIS CRITERA; easy to update later)
inverse_fullfile = cell2mat(search_dir(fullfile(BST_DB_PATH,Extract.project,'data',Extract.subject_id,Extract.stim_name),['results_' Extract.inverse_method '*']));
[~,inverse_file] = fileparts(inverse_fullfile); % get just the file name

% Search for file (ASSUMES ONLY ONE FILE THAT MATCH THIS CRITERA; easy to update later)
average_fullfile = cell2mat(search_dir(fullfile(BST_DB_PATH,Extract.project,'data',Extract.subject_id,Extract.stim_name),['data_' Extract.stim_name '_average_' '*']));
[~,average_file] = fileparts(average_fullfile); % get just the file name

% Construct the text that goes in the OverlayFile input of view_surface_data.m
OverlayFile_str =   ['link|' ...
    Extract.subject_id filesep Extract.stim_name filesep inverse_file '.mat|' ...
    Extract.subject_id filesep Extract.stim_name filesep average_file '.mat'];