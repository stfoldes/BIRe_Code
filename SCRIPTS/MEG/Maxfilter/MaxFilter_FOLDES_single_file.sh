#!/bin/csh

# Performs: Auto detects bad channels, SSS, tSSS, and default head position transformation via MaxFilter(v.2.0.21)
# For a single file. For batch wrapers see Maxfilter_Batch_*.sh
# To copy produced files back to the input path (e.g. the server), use wrapper MaxFilter_FOLDES_SERVERSAVE.sh
#
# input 1 = full file name w/ path (e.g. /mnt/Katz/experiments/meg_neurofeedback/NC01/S01/nc01s01r04.fif)
# input 2 = Save path for processing (e.g. /mnt/D/SSS)
# assumes maxfilter path = /neuro/bin/util/maxfilter
# assumes assumes badchan file = *_prebadchan.txt is same folder as .fif file
#
# Creates *_sss.fif, *_sss_trans.fif, *_tsss.fif, *_tsss_trans.fif in SAVE_PATH (i.e. input 2)
#
# EXAMPLE:
# /usr/local/MaxFilter_Run_Code/MaxFilter_FOLDES_single_file.sh /mnt/Katz/experiments/meg_neurofeedback/NC01/S01/nc01s01r04.fif /mnt/D/SSS
#
# Stephen Foldes [2012-10-24]
# Thanks to Erika Laing, Eric Larson, http://imaging.mrc-cbu.cam.ac.uk/meg/maxpreproc
#
# UPDATES:
# 2013-02-19 Foldes: Now takes bad channel file. Updates to coding
# 2013-02-22 Foldes: Added tSSS and tSSS_trans
# 2013-08-12 Foldes: autobadchan.txt no longer deleted

# input 1 = full file name w/ path (assumes badchan file = *_prebadchan.txt)
set CURRENT_FILE_NAME_FULL = $1

# input 2 = Save path
set SAVE_PATH = $2

# Parameters
set HEAD_ORIGIN = "0 0 40" # Could get from a file
set PRE_BAD_CHAN = "" # Should get from a file

# Split input name
set CURRENT_FILE_NAME = `basename $CURRENT_FILE_NAME_FULL | sed -e 's/\....//'`
set CURRENT_FILE_PATH = `dirname $CURRENT_FILE_NAME_FULL`

#------------------------------------------------------------
# STEP 1: Find BadChannels (with first 20 'buffers')
#------------------------------------------------------------
	# ISSUE: ONLY DOES AUTO WITH TRIGGER = 0, WHAT IS MINE?

# Run maxfilter just to find the autobad channels (so you need to look in the verbose output via a tee-type log thingy)
set CALC_BAD_CHAN = `/neuro/bin/util/maxfilter -f ${CURRENT_FILE_NAME_FULL} -o ${SAVE_PATH}/${CURRENT_FILE_NAME}_autobad_log.fif -force -frame head -origin ${HEAD_ORIGIN} -autobad 20 -v | tee ${SAVE_PATH}/${CURRENT_FILE_NAME}_autobad_log.txt | sed -n  '/Static bad channels/p' | cut -f 5- -d ' ' | uniq | xargs printf "%04d "`

# If no bad channels, deal
if ("${CALC_BAD_CHAN}" == "0000") then
	set CALC_BAD_CHAN = ""
endif

# Get Bad Chans from file (if exists)
set PRE_BAD_FILE = ${CURRENT_FILE_PATH}/${CURRENT_FILE_NAME}_prebadchan.txt
set PRE_BAD_CHAN = ""
if ( -e $PRE_BAD_FILE ) then
	set PRE_BAD_CHAN = `cat $PRE_BAD_FILE`
    echo "Forcing bad channels: ${PRE_BAD_CHAN}"
endif

# make command that include calculated bad and pre-determined bad channels
set BAD_CHAN_COMMAND = "-bad $CALC_BAD_CHAN $PRE_BAD_CHAN"

echo "$CALC_BAD_CHAN $PRE_BAD_CHAN" > ${CURRENT_FILE_PATH}/${CURRENT_FILE_NAME}_badchans.txt

# no bad, remove command
if ("$BAD_CHAN_COMMAND" == "-bad  ") set BAD_CHAN_COMMAND = ""

# remove files made for bad chan calcualtions
rm -f ${SAVE_PATH}/${CURRENT_FILE_NAME}_autobad_log.fif
# rm -f ${SAVE_PATH}/${CURRENT_FILE_NAME}_autobad_log.txt

echo "   STEP 1 COMPLETE: Bad Channels found: ${BAD_CHAN_COMMAND}"

#------------------------------------------------------------
# STEP 2: SSS and remove those bad channels (could add temporal extension with e.g. -st 10)
#------------------------------------------------------------
# Run maxfilter with bad channels from before
/neuro/bin/util/maxfilter -f ${CURRENT_FILE_NAME_FULL} -o ${SAVE_PATH}/${CURRENT_FILE_NAME}_sss.fif -force -frame head -origin ${HEAD_ORIGIN} -autobad off ${BAD_CHAN_COMMAND} 
echo "   STEP 2 COMPLETE: SSS"

#------------------------------------------------------------
# STEP 3: Transform SSS into different coordiante frame 
#------------------------------------------------------------
	#(ARE BAD CHANNELS NEEDED AGAIN, does it hurt?)
# Run maxfilter a 3rd time, but transform the sensors to the default
/neuro/bin/util/maxfilter -f ${SAVE_PATH}/${CURRENT_FILE_NAME}_sss.fif -o ${SAVE_PATH}/${CURRENT_FILE_NAME}_sss_trans.fif -force -frame head -origin ${HEAD_ORIGIN} -autobad off -trans default
echo "   STEP 3 COMPLETE: Head Transformation for SSS"

#------------------------------------------------------------
# STEP 4: tSSS
#------------------------------------------------------------
/neuro/bin/util/maxfilter -f ${CURRENT_FILE_NAME_FULL} -o ${SAVE_PATH}/${CURRENT_FILE_NAME}_tsss.fif -force -frame head -origin ${HEAD_ORIGIN} -autobad off ${BAD_CHAN_COMMAND} -st 4
echo "   STEP 4 COMPLETE: tSSS"

#------------------------------------------------------------
# STEP 5: Transform tSSS into different coordiante frame 
#------------------------------------------------------------
# Run maxfilter a 5rd time, but transform the sensors to the default
/neuro/bin/util/maxfilter -f ${SAVE_PATH}/${CURRENT_FILE_NAME}_tsss.fif -o ${SAVE_PATH}/${CURRENT_FILE_NAME}_tsss_trans.fif -force -frame head -origin ${HEAD_ORIGIN} -autobad off -trans default
echo "   STEP 5 COMPLETE: Head Transformation for tSSS"
