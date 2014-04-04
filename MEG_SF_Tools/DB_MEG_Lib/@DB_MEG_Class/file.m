function file_full_path = file(obj,file_type,location_name)
% Builds the full path of a single entry
% Specific to MEG (i.e. file names are 'entry_id'+'MEG_file_type2file_extension(file_type)')
% Will check letter case incase you messed with that (NOTE: the file_path does NOT do this)
% Does not add .fif
%
% location_name = 'local' or 'server' (only options) [DEFAULT = 'local']
% file_type: see MEG_file_type2file_extension.m for options ('fif','crx','sss','sss_trans',tsss','tsss_trans')
%	file_ext left out or blank will default to NO extension
%
% EXAMPLE:
%   Get file name for NC01's right grasp imagine, but the sss trans file
%   DB.get('run_info','NC01_Grasp_Right_Imagine').file('sss_trans','local')
%         OR
%     DB.get('run_info','NC01_Grasp_Right_Imagine').file('sss_trans')
%
% Foldes 2013-08-15
% UPDATES:
% 2013-10-03 Foldes: Metadata-->DB, paths not needed b/c global
% 2014-02-07 Foldes: Now checks letter-case for file name

%% DEFAULTS
if ~exist('file_type') || isempty(file_type)
    file_name_ending = [];
else
    [file_suffix,file_extension]=MEG_file_type2file_extension(file_type);
    file_name_ending = [file_suffix file_extension];
end

% Default path list is DEF_MEG_paths
% Default location is local
if ~exist('location_name') || isempty(location_name)
    location_name = 'local';
end


%% Build

for ientry = 1:length(obj) % for each entry
    clear DB_entry
    DB_entry = obj(ientry);
    file_full_path{ientry} = [DB_entry.file_path(location_name) DB_entry.entry_id file_name_ending];
    
    %     % if file doesn't exist, flip out
    %     if exist(file_full_path{ientry})~=2
    %         warning(['File doesnt exist ' file_full_path{ientry}])
    %         file_full_path{ientry} = '';
    %     end
end

if max(size(file_full_path))==1
    file_full_path = cell2mat(file_full_path);
end

%% Check that its the right case (and exists)
[p,f]=fileparts(file_full_path);
file_full_path = fullfile(p,filename_caseinsensitive(f,p));