# EXAMPLE CODE: Set computer specific paths for MRI analysis
# Specifically, Freesurfer and Afni/SUMA
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
