#!/bin/csh

# Batch wraper for Maxfilter_FOLDES_*
# Works on whole session
#
# input 1 = Session path 
# input 2 = Temporary Save Path (will move files to server or where ever SESSION_PATH is)
#
# EXAMPLE:
			set SESSION_PATH=/mnt/Katz/experiments/meg_neurofeedback/NC01/S01
			export TEMP_STORAGE_PATH=/mnt/D/SSS/
#			/usr/local/MaxFilter_Run_Code/MaxFilter_Batch_Session.sh $SESSION_PATH $TEMP_STORAGE_PATH
#
# DOESN'T WORK AS OF 2014-02-13
#
# Performs: Auto detects bad channels, SSS, and default head position transformation via MaxFilter(v.2.0.21)
# Creates *_sss.fif, *_sss_trans.fif
#
# Stephen Foldes [2013-02-19]
# UPDATES:
# 2013-02-22 Foldes: Small name change

set SESSION_PATH = $1
set TEMP_STORAGE_PATH = $2

set ALL_FULLFILE_LIST = `find ${SESSION_PATH} -name '*.fif' -not -name "*_sss.fif" -print`

foreach file ($ALL_FULLFILE_LIST)
	/usr/local/MaxFilter_Run_Code/MaxFilter_FOLDES_single_file_SERVERSAVE.sh $file $TEMP_STORAGE_PATH
end

