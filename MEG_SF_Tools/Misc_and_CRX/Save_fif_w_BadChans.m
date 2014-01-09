DOES NOT WORK

%[MEG_data,TimeVecs.timeS,MEG_chan_list] = Load_MEG_Sensors_from_FIF(Extract);

% Save FIF File
% 2013-02-18 Foldes
clear

org_fif_full_name= '/home/foldes/Data/MEG/NC01/S01/nc01s01r04.fif';

[org_path, org_name, org_ext]=fileparts(org_fif_full_name);

new_fif_full_name=[org_path filesep org_name '_new' org_ext];
new_fif_info = fiff_setup_read_raw(new_fif_full_name);
new_fif_info.info.bads

% CHECK if file exists
% [status, message] = copyfile([Extract.file_path Extract.file_name{1} '.fif'],new_fif_full_name);

%fiff_constants = fiff_define_constants();

% load original info
org_fif_info = fiff_setup_read_raw(org_fif_full_name);
new_fif_info = org_fif_info;
% Set new varibles
new_fif_info.info.bads = new_fif_info.info.ch_names(1);
% Write new header
[out_fid,cals] = fiff_start_writing_raw(new_fif_full_name,new_fif_info.info);

%% Write raw data to new file (not writen by Foldes)

% Standard global variable
% global FIFF;
% if isempty(FIFF)
   FIFF = fiff_define_constants();
% end

from        = new_fif_info.first_samp;
to          = new_fif_info.last_samp;
quantum_sec = 1;
quantum     = ceil(quantum_sec*new_fif_info.info.sfreq);
%
%   To read the whole file at once set
% quantum     = to - from + 1;
fprintf(1,'Writing...');
first_buffer = true;
for first = from:quantum:to
    last = first+quantum-1;
    if last > to
        last = to;
    end
    data = fiff_read_raw_segment(new_fif_info,first,last);
    
    if first_buffer
        if first > 0
            fiff_write_int(out_fid,FIFF.FIFF_FIRST_SAMPLE,first);
        end
        first_buffer = false;
    end
    fiff_write_raw_buffer(out_fid,data,cals);
end
fprintf(1,'[done]\n');

fiff_finish_writing_raw(out_fid);
fclose(new_fif_info.fid);
