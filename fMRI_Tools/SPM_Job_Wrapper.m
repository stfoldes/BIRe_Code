function MRI_Info = SPM_Job_Wrapper(MRI_Info)
% A wrapper to help run a SPM job. Uses MRI_Info_Class
% Requires SPM and an SPM job
% Can leave input blank for GUI form (NOT TESTED YET)
%
% INPUTS: (MRI_Info.)
%   .spm_job:       [OPTIONAL] Name of SPM job file (needs path if not in matlab path). If empty, will use a GUI.
%   .epi_run_list:  [OPTIONAL] Names of epi run-folders (cell-array). Will look through subfolders.
%                   Can be a parent folder, like /NIFTI/, to do all files
%                   If empty, will use a GUI.
%                   'all' will do all valid nii's in the .epi_path folder
%
%   .*              SPM job will need some parameters, make sure they are in MRI_Info (See examples)
%   
% OUTPUTS: (MRI_Info.)
%   .epi_full_file_names:   List of files that were processed (could use for moving)
%
% 1. Figure out which EPI files to process (MRI_Info.epi_run_list)
% 2. Make sure EPI files are valid and not MPRAGE
% 3. Save MRI_Info to Master_Processing_Parameter.mat for SPM job to use
% 4. Run SPM job
% 5. (NOT IN THIS FUNCTION) Copy output files to somewhere convenent
%
% EXAMPLE:
%     MRI_Info = MRI_Info_Class;
%     MRI_Info.subject_id =           'NT10'; % used in designs
%     % Base Path Design
%     MRI_Info.study_path_design =    'C:\Data\[subject_id]\fMRI\';
%     % Relative Path Designs
%     MRI_Info.T1_file_design =       '[study_path]\Freesurfer_Reconstruction\SUMA\T1.nii'; % Where is the T1? Blank for GUI
%     % MRI_Info.epi_path_design =      '[study_path]\NIFTI\'; % Where are the EPI folders? Blank for GUI
%     MRI_Info.epi_path_design =      []; % Where are the EPI folders? Blank for GUI
%     % Experimental Design Info
%     MRI_Info.spm_job =              'SPM_Batch_Individual_Block_Design.m'; % full path or must be in Matlab path
%     MRI_Info.ExpDef_TR =             2; % TR 'Interscan interval'
%     MRI_Info.ExpDef_event_onsets =   [10 30 50 70]; % vector of when conditions/events happen, in scan # (hardcoded, but can be changed)
%     MRI_Info.ExpDef_event_duration = 10; % num scans for the event/condition to happen
%     
%     % turn _design into strings
%     MRI_Info = design2str_struct(MRI_Info); 
%     % Automatically sets some standard paths if haven't already
%     MRI_Info=fMRI_Prep_Paths(MRI_Info);
%
%     MRI_Info = SPM_Job_Wrapper(MRI_Info);
%
%     % Copy files
%     output_path =       str_from_design(MRI_Info,output_path_design); % Where should the results go?
%     output_prefix =     str_from_design(MRI_Info,output_prefix_design); % What new prefix should the results have?
%     copy_files_recursive('epi_*.nii',MRI_Info.epi_path,output_path,...
%         'avoid','MPRAGE','remove_from_name','epi_','add_prefix',output_prefix);
% 
%     OUTPUT
%       coregspmT_0001.img
%       SPM.mat
% Right now this is likely specific to our standard SPM processing
% Might want to consider using a struct instead of a ridged class
%
% 2014-01-07 Foldes [Branched from fMRI_RunFunctionalAnalysis 2012-08-06 Foldes and Randazzo - via Betsy and Tim]
% UPDATES:
%

%% Standard setup

% Sets paths
if ~exist('MRI_Info');MRI_Info = MRI_Info_Class;end
MRI_Info=fMRI_Prep_Paths(MRI_Info); % should this go here?

if isempty(MRI_Info.spm_job)
    [FileName,PathName] = uigetfile('*.m','Select SPM job file (SEE: MRI_Info.spm_job)');
    MRI_Info.spm_job = [PathName filesep FileName];
end

%% Decide on nii files to process

% No runs defined, use a GUI
if isempty(MRI_Info.epi_run_list)
    PathName = uigetdir(MRI_Info.study_path,'Select EPI Folder or Parent Folder (See MRI_Info.epi_run_list)');
    MRI_Info.epi_run_list = PathName;
end

% if 'ALL', then set as epi path
if strcmpi(MRI_Info.epi_run_list,'all')
    MRI_Info.epi_run_list = MRI_Info.epi_path;
end

% Turn into a cell (to standardize format)
if ~iscell(MRI_Info.epi_run_list) % if its not a cell, make it one
    run_name_list{1} = MRI_Info.epi_run_list;
else % already a cell
    run_name_list = MRI_Info.epi_run_list;
end

% Look at all .nii files in subfolders that might be valid
MRI_Info.epi_full_file_names = [];
for irun = 1:length(run_name_list)
    
    % add .epi_path to the list (if its not a dir already)
    if ~isdir(run_name_list{irun})
        run_name_list{irun} = [MRI_Info.epi_path filesep run_name_list{irun}];
    end
    
    all_niis = search_dir(run_name_list{irun},'*.nii'); % is recursive
    
    for inii = 1:length(all_niis)
        % get info about this file
        current_nii_info  = spm_vol(all_niis{inii});
        if isempty(regexp(all_niis{inii},'MPRAGE')) % Don't do for MPRAGE
            if strcmp(current_nii_info(1).descrip,'4D image') % must be this type to pass
                % add it to the list
                MRI_Info.epi_full_file_names{end+1} = all_niis{inii};
            end % 4D type
        end % Dont do for MPRAGE
    end % all niis
end %

%% Create a job-document to run each scan

% List of open inputs
jobfile = {which(MRI_Info.spm_job)};
jobs = repmat(jobfile, 1, 1);
inputs = cell(0, 1);

% RUN THIS FIRST?
spm_jobman('initcfg');

%Cycles through all movements and body parts
for ifile = 1:length(MRI_Info.epi_full_file_names)
    
    current_epi = MRI_Info.epi_full_file_names{ifile};
    [file_path,file_name] = fileparts(current_epi);
    
    % Printing the MRI_Info.epi_full_file_names the program is on
    disp(' ')
    disp('**************************************************************')
    disp(['***' current_epi ' ***'])
    disp('**************************************************************')
    
    exist_path = exist(file_path,'dir');
    %Checking for the file
    if exist_path == 7
        try
            save('Master_Processing_Parameter.mat','MRI_Info','current_epi'); % the spm job which will read in Master_Processing_Parameter.mat
            spm('defaults', 'FMRI');
            spm_jobman('serial',jobs, '', inputs{:});
            
        catch
            warning(['Failure with SPM processing of: ' file_name ' (could be an error with copying the files)'])
        end
    else
        error('Paths are wrong for SPM data')
    end
    
end


%% Copy files
%     output_path =       str_from_design(MRI_Info,output_path_design); % Where should the results go?
%     output_prefix =     str_from_design(MRI_Info,output_prefix_design); % What new prefix should the results have?
% 
%     copy_files_recursive('coregspmT_0001.*',MRI_Info.epi_path,output_path,...
%         'avoid','MPRAGE','remove_from_name','coregspmT_0001','add_prefix',output_prefix,'add_prefix_from_path',1);







