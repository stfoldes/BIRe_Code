#!/bin/csh

# Batch wraper for Maxfilter_FOLDES_*
# Works on whole session
#
# input 1 = Session path (e.g. /mnt/Katz/experiments/meg_neurofeedback/NC01/S01)
# input 2 = Save Path (e.g. /mnt/D/SSS)

# Performs: Auto detects bad channels, SSS, and default head position transformation via MaxFilter(v.2.0.21)
# Creates *_sss.fif, *_sss_trans.fif
#
# Stephen Foldes [2013-02-19]
# UPDATES:
# 2013-02-22 Foldes: Small name change

set SESSION_PATH = $1
set SAVE_PATH = $2

set ALL_FULLFILE_LIST = `find ${SESSION_PATH} -name '*.fif' -not -name "*_sss.fif" -print`

foreach file ($ALL_FULLFILE_LIST)
echo $file
	Maxfilter_FOLDES_single_file_SERVERSAVE $file $SAVE_PATH
end

