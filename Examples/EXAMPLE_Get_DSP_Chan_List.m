% EXAMPLE_Get_DSP_Chan_List
% Foldes 20120910

fif_file = fiff_setup_read_raw([Extract.file_path Extract.file_name{ifile} '.fif']);
DSP_chan_names=fif_file.info.ch_names;

DSP_chan_names_TIMESTAMP = '20120910 Foldes';

save('/home/foldes/Dropbox/SF_Toolbox/meg_analysis/SF_Struct_Lib/DSP_chan_names.mat', 'DSP_chan_names', 'DSP_chan_names_TIMESTAMP');


