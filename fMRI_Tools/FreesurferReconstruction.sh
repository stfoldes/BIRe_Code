#!/bin/bash

# Performs Freesurfer reconstuction (recon-all), FS->SUMA conversion, and BEM creation of structural MRI taken at MRRC
# EXAMPLE COMMAND: /Users/hrnel/Documents/MATLAB/meg_analysis/unix_scripts/FreesurferReconstruction.sh NC06 /Users/hrnel/Data/NC06/fMRI/Initial
# Input 1 = subject id
# Input 2 = study path, the location for the parent folder of /Freesurfer_Reconstruction
#
# SEE: Run_fMRI_Analysis.m for pre-processing
# FS and ANFI paths must be set for each computer (SEE script)
# Can be run via Matlab
#
# REQUIRES: 
# 	./NIFTI/ folder (via fMRI_ConvertMRRCdata.m)
# 	./NIFTI/epi_MPRAGE_Siemens_ADNI/epi_MPRAGE_Siemens_ADNI.nii
# 	
# OUTPUTS: folder ./Freesurfer_Reconstruction/ --includes brain surfaces (e.g. pial)
#
# 2012-07-26 [Foldes/Randazzo]
# UPDATES:
# 2013-02-08 Foldes/Randazzo: Fixed DYLD_FALLBACK_LIBRARY_PATH issue for Matlab
# 2013-02-09 Foldes: ***VERSION 1.0-Maxwell***
# 2014-04-03 Foldes: ***VERSION 1.1*** Defines paths by computer name

# Defines the subject from input 1
# EXAMPLE: /home/foldes/Data/subjects/NC07/Initial/ => ${SUBJECTS_DIR}/${SUBJECT_ID}/${SESSION_TYPE}/
export SUBJECT_ID=$1

# Subject specific path from input 2
export SUBJECT_PATH=$2


# GET COMPUTER SPECIFIC PATHS
# NOTE: Paths might need to be adjusted for different computers (e.g. PERL)
case $HOSTNAME in
  	(FoldesPC)
  	echo "FoldesPC"
  	export SUBJECTS_DIR=/home/foldes/Data/subjects
	export FREESURFER_HOME=/usr/local/freesurfer
	export AFNI_HOME=/usr/local/afni/
	export PERL5LIB=$PERL5LIB:$FREESURFER_HOME/mni/lib/perl5/5.8.5
	;;
	  
  	(maxwell.hrnel.pitt.edu) 
  	echo "Maxwell"
  	export SUBJECTS_DIR=/Users/hrnel/Data
	export FREESURFER_HOME=/Applications/freesurfer
	export AFNI_HOME=~/abin
	export PERL5LIB=$PERL5LIB:$FREESURFER_HOME/mni/System/Library/Perl/5.8.6
  	;;
  	(*)   echo "YOU NEED TO SET PATHS";;
esac

export PATH=$PATH:$FREESURFER_HOME/bin:$FREESURFER_HOME/mni/bin
export PATH=$PATH:$AFNI_HOME

# -------------------------------
# ---Freesurfer Reconstruction---
# -------------------------------

# Running Freesurfer recon-all
cd ${SUBJECTS_DIR}

# Makes a temporary subject directory (which will be moved). Finds MPRAGE in /NIFTI/
recon-all -subject ${SUBJECT_ID}_FS -i ${SUBJECT_PATH}/NIFTI/epi_MPRAGE_Siemens_ADNI/epi_MPRAGE_Siemens_ADNI.nii -autorecon-all

mv ${SUBJECTS_DIR}/${SUBJECT_ID}_FS/ ${SUBJECT_PATH}/Freesurfer_Reconstruction

# -----------------------------
# ---FS->SUMA Transformation---
# -----------------------------

# Matlab is junk and needs to unset DYLD_LIBRARY_PATH
unset DYLD_LIBRARY_PATH
export DYLD_FALLBACK_LIBRARY_PATH=$AFNI_HOME

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
