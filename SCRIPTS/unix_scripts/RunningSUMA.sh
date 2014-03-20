# Running SUMA
# FOR STEPHEN'S COMPUTER
# 2012-08-06 (Foldes)
#
# UPDATES:
# 2012-12-11 Foldes: Updated

bash

# --------------------------
# ---ENTER FILE INFO HERE---
# --------------------------

# EXAMPLE: /home/foldes/Data/subjects/NC07/Initial/ => ${SUBJECTS_DIR}/${SUBJECT_ID}/${SESSION_TYPE}/
export SUBJECT_ID=NC12
export SESSION_TYPE=''
export SUBJECTS_DIR=/Users/hrnel/Data/
# export SUBJECTS_DIR=/home/foldes/Data/subjects


# ---------------
# ---Set Paths---
# ---------------

# Subject specific path
export SUBJECT_PATH=${SUBJECTS_DIR}/${SUBJECT_ID}/${SESSION_TYPE}

# Program Paths Needed
export PATH=$PATH:/usr/local/afni/

# ---------------
#---START SUMA---
# ---------------

cd ${SUBJECT_PATH}

afni -niml &

suma -spec ${SUBJECT_PATH}/Freesurfer_Reconstruction/SUMA/${SUBJECT_ID}_both.spec -sv ${SUBJECT_PATH}/Freesurfer_Reconstruction/SUMA/${SUBJECT_ID}_SurfVol+orig.BRIK &


# ---NOTES---
# b, F6
# r supposed to record

