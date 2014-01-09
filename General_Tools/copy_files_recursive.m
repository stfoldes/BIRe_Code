function copy_files_recursive(org_search_str,org_path,out_path,varargin) % 'add_prefix','add_prefix_from_path','remove_from_name','avoid','move','case_insensitive'
% Copies (or moves) files that match a search string to a destiation folder
% Searchs for files recursively (i.e. within subfolders of org_path)
% Destiation folder will be made if doesn't exist
%
% INPUTS:
%   org_search_str: string for how to search for files. Can use *,.,\,/,etc.
%   org_path:       folder where to begin search for matching files
%   out_path:       folder to copy to
%
% VARARGIN:
%   add_prefix:             Add string to the begining of the copied file
%   remove_from_name:       String to remove from original file name (e.g. removing the org_search_str)  
%   avoid:                  Will skip files that have this string in them (case sensitive for now)
%   move:                   1 = remove original (i.e. move, not copy) [DEFAULT: Copy (0)]
%   case_insensitive:       1 = search is case insensitive (see: search_dir) [DEFAULT: case sensitive (0)]
%   add_prefix_from_path:   Use folder name in the prefix of the new file [add_prefix folder_prefix '_' filename]
%                           e.g. ../DBI05/NIFTI/Hand/spmT.nii --> add_prefix_from_path = 1 --> 'Hand_spmT.nii'
%                                add_prefix_from_path = 3 --> 'DBI05_spmT.nii'
%                           Prefix is the folder's name that is X folders back from where the data is (1 = data's folder)
%                           This is NOT necessarily the org_path since the data can live in a subfolder
%
% EXAMPLES:
%   Copy all nii files in /Subject1/ to new folder /NIIs/
%       copy_files_recursive('*.nii','~/Data/Subject1/','~/Data/NIIs/')
%
%   Move all nii files with 'stephen' in the name (case insensitive)
%       copy_files_recursive('*stephen*.nii','~/Data/Subject1/','~/Data/NIIs/','move',1,'case_insensitive',1)
%
%   Copy all nii files that start with 'epi_', but not it can't have 'MPRAGE' in the name
%       copy_files_recursive('epi_*.nii','~/Data/Subject1/','~/Data/NIIs/','avoid','MPRAGE')Foldes
%
%   Copy all nii files that start with 'epi_', but not it can't have 'MPRAGE' in the name
%   Remove the 'epi_' from the name, but add 'Subject1_' to the name
%       copy_files_recursive('epi_*.nii','~/Data/Subject1/','~/Data/NIIs/',...
%           'avoid','MPRAGE','remove_from_name','epi_','add_prefix','Subject1_')
% 
%   Specific example. Uses designs (see: str_from_design.m)
%   Copy all 'epi_*.nii' files in C:\Data\NT10\fMRI\NIFTI\ to C:\Data\NT10\fMRI\Functional\
%   avoid 'MPRAGE', remove 'epi_' from the file name (not dependent on org_file_design!), add 'fMRI_NT10_'
%
%       % Designs used to build paths and strings 
%       org_path_design =           '[study_path]\NIFTI\';
%       org_file_design =           'epi_*.nii';
%       out_path_design =           '[study_path]\Functional\';
%       out_prefix_design =         'fMRI_[subject_id]_';
%       struct4design.study_path =  'C:\Data\NT10\fMRI\';
%       struct4design.subject_id =  'NT10';
% 
%       % Builds the strings from designs
%       org_path =          str_from_design(struct4design,org_path_design);
%       org_search_str =    str_from_design(struct4design,org_file_design);
%       out_path =          str_from_design(struct4design,out_path_design);
%       out_prefix_str =    str_from_design(struct4design,out_prefix_design);
% 
%       copy_files_recursive(org_search_str,org_path,out_path,...
%           'avoid','MPRAGE','remove_from_name','epi_','add_prefix',out_prefix_str);
%
% SEE: search_dir
%
% 2014-01-07 Foldes
% UPDATES:
% 2014-01-09 Foldes: Added folder prefix

%% DEFAULTS
parms.add_prefix =              [];
parms.add_prefix_from_path =    0;
parms.remove_from_name =        [];
parms.avoid =                   [];
parms.move =                    0;
parms.case_insensitive =        0;
parms.strict =                  0; % UNDOCUMENTED, 1 = search needs a perfect match to pattern, also doesn't do subfolders (see: search_dir)
parms = varargin_extraction(parms,varargin);

%% CODE

% Find original files
files2move = search_dir(org_path,org_search_str,parms.strict,parms.case_insensitive);

% Make output folder if it doesn't exist
if exist(out_path,'dir')~=7
    mkdir(out_path)
end

% Copy each file
for ifile = 1:length(files2move)
    
    [current_file_path,current_file_name,current_file_ext]=fileparts(files2move{ifile});
    
    % only proceed if there is no match to any avoid files
    if isempty(strfind(current_file_name,parms.avoid)) 
        
        % remove prefix from original_file_design
        remove_from_name_start_char = strfind(current_file_name,parms.remove_from_name); % case sensitive, could do lower()
        current_file_name(remove_from_name_start_char:length(parms.remove_from_name)) = [];
        
        %         % remove the original prefix from original_file_design
        %         if parms.remove_org_prefix == 1
        %             end_prefix = min([strfind(original_file_design,'*'), strfind(original_file_design,'.'), length(original_file_design)]);
        %             % org_prefix = original_file_design(1:end_prefix-1);
        %             current_file_name = current_file_name(end_prefix:end); % remove the begining
        %         end
        
        % use dir/path to help name the file
        if parms.add_prefix_from_path > 0
            
            % add a filesep to the end so the search and indexing works easier
            current_file_path_temp = [current_file_path filesep]; 
            % find all fileseps
            filesep_idx = strfind(current_file_path_temp,filesep);
            
            % take the folder name that is # dirs back (# = parms.add_prefix_from_path)
            first_char_idx =    filesep_idx(end-parms.add_prefix_from_path) + 1;
            last_char_idx =     filesep_idx(end-(parms.add_prefix_from_path-1)) - 1;
            folder_prefix = current_file_path_temp(first_char_idx:last_char_idx);
            
            if isempty(current_file_name)
                current_file_name = [folder_prefix]; % don't add that _
            else
                current_file_name = [folder_prefix '_' current_file_name];
            end
        end
        
        % copy with added prefix
        copyfile(files2move{ifile}, ...
            [out_path filesep parms.add_prefix current_file_name current_file_ext]);
        
        % remove original if move flag
        if parms.move == 1
            delete(files2move{ifile});
        end
        
    end % avoid files
end % files
disp([num2str(length(files2move)) ' Files Moved'])