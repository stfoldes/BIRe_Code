#!/bin/bash

# Script to run SUMA with Foldes-file system
#
# 2012-08-06 (Foldes)
# UPDATES:
# 2012-12-11 Foldes: Updated
# 2014-04-04 Foldes: Path case structure

# --------------------------
# ---ENTER FILE INFO HERE---
# --------------------------

# EXAMPLE: /home/foldes/Data/subjects/NC07/Initial/ => ${SUBJECTS_DIR}/${SUBJECT_ID}/${SESSION_TYPE}/
export SUBJECT_ID=MR01
export SESSION_TYPE=''


# ---------------
# ---Set Paths---
# ---------------
# Set computer specific paths for MRI analysis (Freesurfer and Afni/SUMA)
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
  	(*)   echo "YOU NEED TO SET PATHS FOR THIS COMPUTER. SEE: Set_Paths_FS_ANFI.sh";;
esac

export PATH=$PATH:$FREESURFER_HOME/bin:$FREESURFER_HOME/mni/bin
export PATH=$PATH:$AFNI_HOME


# Subject specific path
export SUBJECT_PATH=${SUBJECTS_DIR}/${SUBJECT_ID}/${SESSION_TYPE}

# ---------------
#---START SUMA---
# ---------------

cd ${SUBJECT_PATH}

afni -niml &

suma -spec ${SUBJECT_PATH}/Freesurfer_Reconstruction/SUMA/${SUBJECT_ID}_both.spec -sv ${SUBJECT_PATH}/Freesurfer_Reconstruction/SUMA/${SUBJECT_ID}_SurfVol+orig.BRIK &


# ---NOTES---
# b, F6
# r supposed to record

