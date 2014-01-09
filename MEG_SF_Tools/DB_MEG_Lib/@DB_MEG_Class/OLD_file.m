function file_full_path = file(obj,base_path,file_type)
% Builds the full path of a single entry
%
% base_path: local_path or server_path (default uses computer name, but must be in list)
% file_type: see MEG_file_type2file_extension.m for options ('fif','crx','sss','sss_trans',tsss','tsss_trans')
%   file_type left out or blank will default to NO extension
%
% EXAMPLE:
%   Get file name for NC01's right grasp imagine, but the sss trans file
%   Metadata.by_criteria('run_info','NC01_Grasp_Right_Imagine').file('sss_trans')
%
% Foldes 2013-08-15
% UPDATES:

%% DEFAULTS
if ~exist('file_type') || isempty(file_type)
    file_name_ending = [];
else
    [file_suffix,file_extension]=MEG_file_type2file_extension(file_type);
    file_name_ending = [file_suffix file_extension];
end

% Default path
if ~exist('base_path') || isempty(base_path)
    % Set up Base paths
    switch computer_info
        case 'FoldesPC'
            base_path = '/home/foldes/Data/MEG/';
    end
end

%% Build

for ientry = 1:length(obj) % for each entry
    clear metadata_entry
    metadata_entry = obj(ientry);
    file_full_path{ientry} = [metadata_entry.file_path(base_path) metadata_entry.file_base_name file_name_ending];
    
    %     % if file doesn't exist, flip out
    %     if exist(file_full_path{ientry})~=2
    %         warning(['File doesnt exist ' file_full_path{ientry}])
    %         file_full_path{ientry} = '';
    %     end
end

if max(size(file_full_path))==1
    file_full_path = cell2mat(file_full_path);
end

