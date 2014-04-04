% Script to run Analysis for fMRI data or pieces of analysis
%   SEE: Run_fMRI_Analysis.m
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
% 2014-04-03 Foldes: Clean up, defaults in MRI_Info_Class, etc

clear
clc

%% Processing Flags

Flags.convert =     0; % Step 1: Converts Raw to DICOM and NIFTI
Flags.FS =          0; % Step 2: Freesurfer reconstruction. REQUIRES: convert
Flags.SPM =         1; % Step 3: fMRI analysis with SPM job. REQUIRES: convert, FS (needs a T1)
Flags.SPM2SUMA =    1; % Step 4: Convert SPM files to SUMA files. REQUIRES: FS, SPM

%% PARAMETERS

% MRI_Info is a container for all information needed for fMRI processing in this code.
MRI_Info = MRI_Info_Class;

MRI_Info.subject_id =           'MR01';
% Base Path Design (use [] for accessing MRI_Info property names)
MRI_Info.study_path_design =    '/home/foldes/Data/subjects/[subject_id]/'; % can't be relative path (spm_existfile fail)
%MRI_Info.study_path_design =    '/home/foldes/Data/subjects/[subject_id]/Initial/'; 

MRI_Info.spm_job =              'SPM_Batch_Individual_Block_Design.m'; % full path or must be in Matlab path

% Experimental Design Info
MRI_Info.ExpDef_TR =             2; % TR 'Interscan interval'
MRI_Info.ExpDef_event_onsets =   [10 30 50 70]; % vector of when conditions/events happen, in scan # (hardcoded, but can be changed)
MRI_Info.ExpDef_event_duration = 10; % num scans for the event/condition to happen

MRI_Info.FS_script =            'FreesurferReconstruction.sh'; % Relative paths if in Matlab Path
MRI_Info.SPM2SUMA_script =      'SPM2SUMA.sh';

%% =======================================================
%  ===PROCESSING==========================================
%  =======================================================

Run_fMRI_Analysis(MRI_Info,Flags);

