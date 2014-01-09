% Script to run Analysis for fMRI data or pieces of analysis
% 
% Uses SPM for fMRI analysis and Freesurfer for reconstruction
% Can pick and choose which processing to do
%
% Step 1: Converts Raw to DICOM and NIFTI
% Step 2: Freesurfer reconstruction of surface, BEMs, and SUMA. REQUIRES: convert
% Step 3: fMRI analysis with SPM job. REQUIRES: convert, FS (needs a T1)
% Step 4: Convert SPM files to SUMA files. REQUIRES: FS, SPM
%
% Paths are modular
%
% 2014-01-09 [Foldes]
% UPDATES:
%

clear
clc

%% Processing Flags

    Flags.convert =     1; % Step 1: Converts Raw to DICOM and NIFTI
    Flags.FS =          0; % Step 2: Freesurfer reconstruction. REQUIRES: convert
    Flags.SPM =         1; % Step 3: fMRI analysis with SPM job. REQUIRES: convert, FS (needs a T1)
    Flags.SPM2SUMA =    1; % Step 4: Convert SPM files to SUMA files. REQUIRES: FS, SPM

%% PARAMETERS

    MRI_Info = MRI_Info_Class;
    % MRI_Info is a container for all information needed for fMRI processing in this code.
    % MRI_Info can be automatically generated (if left out or left empty).
    % See MRI_Info_Class.m

    MRI_Info.subject_id =           'NC06'; % used in designs
    MRI_Info.spm_job =              'SPM_Batch_Individual_Block_Design.m'; % full path or must be in Matlab path
    MRI_Info.epi_run_list =         'all';

    % Experimental Design Info
    MRI_Info.ExpDef_TR =             2; % TR 'Interscan interval'
    MRI_Info.ExpDef_event_onsets =   [10 30 50 70]; % vector of when conditions/events happen, in scan # (hardcoded, but can be changed)
    MRI_Info.ExpDef_event_duration = 10; % num scans for the event/condition to happen

%% Generic Setup

    % Base Path Design
    MRI_Info.study_path_design =    '/home/foldes/Data/subjects/[subject_id]/Initial/'; % can't be relative path (spm_existfile fail)
    % 'C:\Data\[subject_id]\fMRI\';

    % Relative Path Designs
    MRI_Info.T1_file_design =       '[study_path]/Freesurfer_Reconstruction/SUMA/T1.nii'; % Where is the T1? Blank for GUI
    MRI_Info.epi_path_design =      '[study_path]/NIFTI/'; % Where are the EPI folders? Blank for GUI
    MRI_Info.raw_data_path_design = '[study_path]/Raw_Data/'; % Where are the raw folders? Blank for GUI

    MRI_Info.FS_script =            '/Users/hrnel/Documents/MATLAB/meg_analysis/fMRI_Tools/FreesurferReconstruction_Maxwell.sh';
    MRI_Info.SPM2SUMA_script =      '/Users/hrnel/Documents/MATLAB/meg_analysis/fMRI_Tools/SPM2SUMA_Maxwell.sh';
    
    % Where to move analyized files
    output_path_design =            '[study_path]/FunctionalData/'; % Where should the results go?
    output_prefix_design =          '[subject_id]_'; % What new prefix should the results have?

    % Turn _design into strings
    MRI_Info = design2str_struct(MRI_Info);
    % Automatically sets some standard paths if haven't already
    MRI_Info=fMRI_Prep_Paths(MRI_Info);

%% =======================================================
%  ===PROCESSING==========================================
%  =======================================================

%% STEP 1: Convert Raw Data into NIFTI
if Flags.convert
    % Converts the raw data first to DICOM and then to NIFTI
    % Nice to have: MRI_Info.raw_data_path, MRI_Info.epi_path
    MRI_Info = fMRI_ConvertMRRCdata(MRI_Info);
    % MAKES: NIFTI and DICOM folders
end
%% STEP 2: Construct brain and head surfaces via Freesurfer
if Flags.FS
    % Running Unix function for Freesurfer Reconstruction and SUMA_Spec
    eval(['!' MRI_Info.FS_script ' ' MRI_Info.subject_id ' ' MRI_Info.study_path]);
end
%% STEP 3: Perform SPM on fMRI data
if Flags.SPM
    MRI_Info=SPM_Job_Wrapper(MRI_Info);

    % Copy all 'coregspmT_0001' files in epi_path to output_path
    % avoid MPRAGE, remove 'coregspmT_0001' from the file name, add subject id and name of epi folder
    output_path =       str_from_design(MRI_Info,output_path_design); % Where should the results go?
    output_prefix =     str_from_design(MRI_Info,output_prefix_design); % What new prefix should the results have?
    
    copy_files_recursive('coregspmT_0001.*',MRI_Info.epi_path,output_path,...
        'avoid','MPRAGE','remove_from_name','coregspmT_0001','add_prefix',output_prefix,'add_prefix_from_path',1);
end
%% STEP 4: Convert functional data (via SPM) to SUMA surfaces
if Flags.SPM2SUMA
    %Running Unix function for converting functional SPM data to SUMA ready data
    eval(['!' MRI_Info.SPM2SUMA_script ' ' MRI_Info.subject_id ' ' MRI_Info.study_path]);
end