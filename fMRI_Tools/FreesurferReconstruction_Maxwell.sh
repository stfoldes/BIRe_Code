#!/bin/bash

# Performs Freesurfer reconstuction (recon-all), FS->SUMA conversion, and BEM creation of structural MRI taken at MRRC
# EXAMPLE COMMAND: /Users/hrnel/Documents/MATLAB/meg_analysis/unix_scripts/FreesurferReconstruction_Maxwell.sh NC06 /Users/hrnel/Data/NC06/fMRI/Initial
# Input 1 = subject id
# Input 2 = study path, the location for the parent folder of /Freesurfer_Reconstruction
#
# COMPATIBLE WITH fMRI_Script_MASTER_MAXWELL.m, assumes a distinct file structure for easier use EXAMPLE: /Users/hrnel/Data/NC06/fMRI/Initial/Raw_Data
# All Hardcoded Paths for Maxwell (MAC)
#
# REQUIRES: file ./NIFTI/epi_MPRAGE_Siemens_ADNI/epi_MPRAGE_Siemens_ADNI.nii (from fMRI_Script_ConvertMRRCdata.m)
# OUTPUTS: folder ./Freesurfer_Reconstruction/ --includes brain surfaces (e.g. pial)
#
# 2012-07-26 [Foldes/Randazzo]
# UPDATES:
# 2012-08-20 Foldes: Made standardized paths and works with other code, Added BEM
# 2012-11-13 Foldes: Improved for our folder structure. Cleaned up. Add SUMA conversion.
# 2012-11-15 Foldes: Added -neuro to SUMA_Make_Spec_FS
# 2012-11-17 Foldes: @SUMA_Make_Spec_FS doesn't run on my machine, fixed some typos and paths
# 2012-12-10 Foldes: Updated for updated AFNI, using mgz option for @SUMA_Make_Spec_FS (might be for new afni versions only)
# 2013-01-04 Foldes: Updated for MAC (Maxwell)
# 2013-02-05 Randazzo/Foldes: Now a unix function, renamed function
# 2013-02-08 Foldes/Randazzo: Fixed DYLD_FALLBACK_LIBRARY_PATH issue for Matlab
# 2013-02-09 Foldes: ***VERSION 1.0-Maxwell***

# Defines the subject from input 1
# EXAMPLE: /home/foldes/Data/subjects/NC07/Initial/ => ${SUBJECTS_DIR}/${SUBJECT_ID}/${SESSION_TYPE}/
export SUBJECT_ID=$1

# Subject specific path from input 2
export SUBJECT_PATH=$2

# HARD-CODED to look in the Data folder found on the Maxwell hard-drive
export SUBJECTS_DIR=/Users/hrnel/Data

# -------------------------------
# ---Freesurfer Reconstruction---
# -------------------------------

# Defines paths for Maxwell 
# NOTE: Paths might need to be adjusted for different computers (e.g. PERL)

export FREESURFER_HOME=/Applications/freesurfer
export PATH=$PATH:$FREESURFER_HOME/bin:$FREESURFER_HOME/mni/bin
export PERL5LIB=$PERL5LIB:$FREESURFER_HOME/mni/System/Library/Perl/5.8.6

# Running Freesurfer recon-all
cd ${SUBJECTS_DIR}

# Makes a temporary subject directory (which will be moved). Finds MPRAGE in /NIFTI/
recon-all -subject ${SUBJECT_ID}_FS -i ${SUBJECT_PATH}/NIFTI/epi_MPRAGE_Siemens_ADNI/epi_MPRAGE_Siemens_ADNI.nii -autorecon-all

mv ${SUBJECTS_DIR}/${SUBJECT_ID}_FS/ ${SUBJECT_PATH}/Freesurfer_Reconstruction


# -----------------------------
# ---FS->SUMA Transformation---
# -----------------------------

# Defines path for Maxwell 
export PATH=$PATH:~/abin
# Matlab is junk and needs to unset DYLD_LIBRARY_PATH
unset DYLD_LIBRARY_PATH
export DYLD_FALLBACK_LIBRARY_PATH=~/abin

cd ${SUBJECT_PATH}/Freesurfer_Reconstruction
@SUMA_Make_Spec_FS -sid $SUBJECT_ID -neuro -use_mgz

# --------------------------------
# ---BEM Construction (for MEG)---
# --------------------------------

# Prep folder
export ws_dir=${SUBJECT_PATH}/Freesurfer_Reconstruction/bem/watershed
mkdir -p $ws_dir/ws

# This was adapted from mne_watershed_bem
mri_watershed -atlas -useSRAS -surf $ws_dir ${SUBJECT_PATH}/Freesurfer_Reconstruction/SUMA/T1.nii $ws_dir/ws
