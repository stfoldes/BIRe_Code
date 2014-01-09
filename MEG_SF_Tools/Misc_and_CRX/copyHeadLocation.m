function copyHeadLocation(fromFile,toFile,newFile)
%
% function copyHeadLocation(fromFile,toFile,newFile)
% Copies the head location from one FIF file (fromFile) to another (toFile), 
% which is usually an empty room file, so that we can run Maxfilter on it.
% The file is written to newFile to avoid overwriting the old file.

global FIFF;
if isempty(FIFF)
   FIFF = fiff_define_constants();
end

rawHead = fiff_setup_read_raw(fromFile);
raw = fiff_setup_read_raw(toFile);
raw.info.dev_head_t = rawHead.info.dev_head_t;
    
[outfid,cals] = fiff_start_writing_raw(newFile,raw.info);
from        = raw.first_samp;
to          = raw.last_samp;
quantum_sec = 1;
quantum     = ceil(quantum_sec*raw.info.sfreq);
%
%   To read the whole file at once set
%
% quantum     = to - from + 1;

first_buffer = true;
for first = from:quantum:to
    last = first+quantum-1;
    if last > to
        last = to;
    end
    data = fiff_read_raw_segment(raw,first,last);
    
    fprintf(1,'Writing...');
    if first_buffer
       if first > 0
	  fiff_write_int(outfid,FIFF.FIFF_FIRST_SAMPLE,first);
       end
       first_buffer = false;
    end
    fiff_write_raw_buffer(outfid,data,cals);
    fprintf(1,'[done]\n');
end

fiff_finish_writing_raw(outfid);
fclose(raw.fid);
