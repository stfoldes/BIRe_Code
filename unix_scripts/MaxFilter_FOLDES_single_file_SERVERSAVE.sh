#!/bin/csh

# THIS IS A WRAPPER FOR MaxFilter_FOLDES_single_file.sh THAT COPIES THE DATA TO THE SERVER WHEN DONE (takes longer)
#
# input 1 = full file name w/ path (e.g. /mnt/Katz/experiments/meg_neurofeedback/NC01/S01/nc01s01r04.fif)
# input 2 = Temporary save path for processing (e.g. /mnt/D/SSS)
# assumes maxfilter path = /neuro/bin/util/maxfilter
# assumes assumes badchan file = *_prebadchan.txt is same folder as .fif file
#
# EXAMPLE:
# /usr/local/MaxFilter_Run_Code/MaxFilter_FOLDES_single_file_SERVERSAVE.sh /mnt/Katz/experiments/meg_neurofeedback/NC01/S01/nc01s01r04.fif /mnt/D/SSS
#
# Stephen Foldes [2013-02-20]
# UPDATES:
# 2013-02-22 Foldes: Added tSSS and tSSS_trans
# 2013-08-12 Foldes: Added autobadchan.txt transfer

# input 1 = full file name w/ path (assumes badchan file = *_prebadchan.txt)
set CURRENT_FILE_NAME_FULL = $1

# input 2 = Save pathun
set TEMP_STORAGE_PATH = $2

# Split input name
set CURRENT_FILE_NAME = `basename $CURRENT_FILE_NAME_FULL | sed -e 's/\....//'`
set CURRENT_FILE_PATH = `dirname $CURRENT_FILE_NAME_FULL`

#------------------------------------------------------------
# STEP 1-3: MaxFilter 
#------------------------------------------------------------

/usr/local/MaxFilter_Run_Code/MaxFilter_FOLDES_single_file.sh $CURRENT_FILE_NAME_FULL $TEMP_STORAGE_PATH

#------------------------------------------------------------
# STEP 4: Move files to server 
#------------------------------------------------------------

cp ${TEMP_STORAGE_PATH}/${CURRENT_FILE_NAME}_badchans.txt ${CURRENT_FILE_PATH}/${CURRENT_FILE_NAME}_badchans.txt
cp ${TEMP_STORAGE_PATH}/${CURRENT_FILE_NAME}_sss.fif ${CURRENT_FILE_PATH}/${CURRENT_FILE_NAME}_sss.fif
cp ${TEMP_STORAGE_PATH}/${CURRENT_FILE_NAME}_sss_trans.fif ${CURRENT_FILE_PATH}/${CURRENT_FILE_NAME}_sss_trans.fif
cp ${TEMP_STORAGE_PATH}/${CURRENT_FILE_NAME}_tsss.fif ${CURRENT_FILE_PATH}/${CURRENT_FILE_NAME}_tsss.fif
cp ${TEMP_STORAGE_PATH}/${CURRENT_FILE_NAME}_tsss_trans.fif ${CURRENT_FILE_PATH}/${CURRENT_FILE_NAME}_tsss_trans.fif
echo "   Files copied to the server"
