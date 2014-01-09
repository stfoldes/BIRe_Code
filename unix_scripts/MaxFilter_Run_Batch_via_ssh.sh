# Batch Running MaxFilter remotly with ssh
# Give list of file names (must be 'nc01s01r* nc01s02r*' format)
# 
# Will take data from server and put *_sss, *_sss_trans, *_tsss, *_tsss_trans data back on the server
# Takes like ~15 minutes each file
# Make sure your bad channels list is on the server in the right place (see matlab)
#
# Must ssh in to Gus's old computer 
# 	Open Terminal
#	ssh gsudre@192.168.1.151
#	enter password (takes a few minutes before it asks, will sometime time out)
# 
# POSSIBLE ERROR: "Writing of the raw data tag failed!"
#	SOLUTION: memory full, delete crap
#
# 2013-02-21 Stephen Foldes
# UPDATES:
# 2013-02-22 Foldes: Small name change
# 2013-03-26 Foldes: Fixed issue with different lengths of subject names.

# ===USER INPUT===
	# export FILE_LIST='nc01s01r06 ns08s01r07'
	export FILE_LIST='dbi05s01r03 dbi05s01r04 dbi05s01r05 dbi05s01r06 dbi05s01r07 dbi05s01r08 dbi05s01r09 dbi05s01r10 dbi05s01r11 dbi05s01r12 dbi05s01r13 dbi05s01r14 dbi05s01r15 dbi05s01r16'

	# Number of characters for the subject ID
	# Neurofeedback = 4, Presurgical = 5
	export NUM_SUBJECT_CHAR=5

	# Path to the data on the server, before subject
	#export SERVER_PATH=/mnt/Katz/experiments/meg_neurofeedback/
	export SERVER_PATH=/mnt/Katz/experiments/ecog_dbi/DBI05/MEG/
# ================


# ---DEFAULT PATH FOR LOCAL STORAGE---
export TEMP_STORAGE_PATH=/mnt/D/SSS/

for ifile in $FILE_LIST
do

	# ---AUTO GENERATE FILE INFO--
	export SUBJECT_ID="$(echo ${ifile[@]:0:${NUM_SUBJECT_CHAR}} | tr '[:lower:]' '[:upper:]')"
	export SESSION_NUM=${ifile[@]:$((NUM_SUBJECT_CHAR + 1)):2}
	export FULL_FIF_PATH=${SERVER_PATH}${SUBJECT_ID}/S${SESSION_NUM}/${ifile}.fif
	echo 'Processing: ' $FULL_FIF_PATH

	# ---RUN MAXFILTER---
	/usr/local/MaxFilter_Run_Code/MaxFilter_FOLDES_single_file_SERVERSAVE.sh $FULL_FIF_PATH $TEMP_STORAGE_PATH
done

