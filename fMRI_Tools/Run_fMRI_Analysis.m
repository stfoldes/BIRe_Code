function Run_fMRI_Analysis(MRI_Info,Flags)
% Run Analysis for fMRI data or pieces of analysis
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
% EXAMPLE: SCRIPT_Run_fMRI_Analysis.m
%
% 2014-01-09 [Foldes]
% UPDATES:
% 2014-04-03 Foldes: Prep_Paths in obj

% Turn _design into strings
MRI_Info = design2str_struct(MRI_Info);
% Automatically sets some standard paths if haven't already
MRI_Info=Prep_Paths(MRI_Info);

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
    eval(['!' MRI_Info.FS_script_path ' ' MRI_Info.subject_id ' ' MRI_Info.study_path]);
end
%% STEP 3: Perform SPM on fMRI data
if Flags.SPM
    MRI_Info=SPM_Job_Wrapper(MRI_Info);
    
    % Copy all 'coregspmT_0001' files in epi_path to output_path
    % avoid MPRAGE, remove 'coregspmT_0001' from the file name, add subject id and name of epi folder
    output_path =       str_from_design(MRI_Info,MRI_Info.output_path_design); % Where should the results go?
    output_prefix =     str_from_design(MRI_Info,MRI_Info.output_prefix_design); % What new prefix should the results have?
    
    copy_files_recursive('coregspmT_0001.*',MRI_Info.epi_path,output_path,...
        'avoid','MPRAGE','remove_from_name','coregspmT_0001','add_prefix',output_prefix,'add_prefix_from_path',1);
end
%% STEP 4: Convert functional data (via SPM) to SUMA surfaces
if Flags.SPM2SUMA
    %Running Unix function for converting functional SPM data to SUMA ready data
    eval(['!' MRI_Info.SPM2SUMA_script_path ' ' MRI_Info.subject_id ' ' MRI_Info.study_path]);
end

disp(['***COMPLETE: Run_fMRI_Analysis @ ' datestr(now,'yyyy/mm/dd HH:MM') '***'])


