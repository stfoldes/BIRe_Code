#!/bin/bash

# Prepares functional data from SPM for SUMA display using mri_convert and SurfGen
# EXAMPLE COMMAND:  /Users/hrnel/Documents/MATLAB/meg_analysis/unix_scripts/SPM2SUMA_Maxwell NC06 /Users/hrnel/Data/NC06/fMRI/Initial
# Input 1 = subject id
# Input 2 = study path, the location for the parent folder of /Freesurfer_Reconstruction and /FunctionalData/ (where the SPM output files live when running Run_fMRI_Analysis.m)
#
# Assumes you already ran @SUMA_Make_Spec_FS on the anatomical (see FreesurferReconstruction)
# WORKS WITH Run_fMRI_Analysis.m, assumes a distinct file structure for easier use EXAMPLE: /Users/hrnel/Data/NC06/fMRI/Initial/
# Uses computer name to define paths
#
# REQUIRES: SUMA .spec files and .img files from SPM functional analysis
# OUTPUTS: SUMA surfaces and compatible .nii functional data in study_path/FunctionalData

# 2012-08-07 [Randazzo/Foldes]
# UPDATES:
# 2012-02-05 Foldes/Randazzo: Made into unix function, renamed from Prepare4SUMA
# 2013-02-08 Foldes/Randazzo: Fixed DYLD_FALLBACK_LIBRARY_PATH issue for Matlab
# 2013-02-09 Foldes: ***VERSION 1.0-Maxwell***
# 2014-04-03 Foldes: ***VERSION 1.1*** Defines paths by computer name


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

# ------------------------
# ---Convert IMG to NII---
# ------------------------

# Changing directory to the functional directory
cd ${2}/FunctionalData

#Performing mri_convert from ANALYZE to NIFTI for each functional file
for f in $( ls *.img )
do
mri_convert -i ${f%.*}.img -o ${f%.*}.nii -it analyze4d -ot nii
done

# --------------------
# ---3D Vol to Surf---
# --------------------

# Matlab is junk and needs to unset DYLD_LIBRARY_PATH
unset DYLD_LIBRARY_PATH
export DYLD_FALLBACK_LIBRARY_PATH=$AFNI_HOME

# Changing directory to the functional directory
cd ${2}/FunctionalData

#Performing 3dVol2Surf for each functional nifti file
for f in $( ls *.nii )
do
3dVol2Surf -spec ${2}/Freesurfer_Reconstruction/SUMA/$1_rh.spec -surf_A rh.smoothwm -surf_B rh.pial -sv $f -map_func ave -out_niml rh.$f.niml.dset -grid_parent $f
3dVol2Surf -spec ${2}/Freesurfer_Reconstruction/SUMA/$1_lh.spec -surf_A lh.smoothwm -surf_B lh.pial -sv $f -map_func ave -out_niml lh.$f.niml.dset -grid_parent $f
done
