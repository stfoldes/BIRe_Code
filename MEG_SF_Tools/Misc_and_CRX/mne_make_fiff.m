function mne_replace_ICA(infile,outfile,ica_meg_data)
%
% function mne_ex_read_write_raw(infile,outfile);
%
% Read and write raw data in 60-sec blocks
%

%
%   Copyright 2007
%
%   Matti Hamalainen
%   Athinoula A. Martinos Center for Biomedical Imaging
%   Massachusetts General Hospital
%   Charlestown, MA, USA
%
%   No part of this program may be photocopied, reproduced,
%   or translated to another program language without the
%   prior written consent of the author.
%
%   $Id: mne_ex_read_write_raw.m 2628 2009-04-27 21:17:31Z msh $
%
%

MEG_chs=31:303;
global FIFF;
if isempty(FIFF)
   FIFF = fiff_define_constants();
end

clear MNE_raw
%
me = 'MNE:mne_ex_read_write_raw';
%
%if nargin ~= 2
%    error(me,'Incorrect number of arguments');
%end
%
%   Setup for reading the raw data
%
try
    raw = fiff_setup_read_raw(infile);
catch
    error(me,'%s',mne_omit_first_line(lasterr));
end

for i = 1:length(MEG_chs)
    for j = MEG_chs
        if isequal(MNE_raw_info.ch_names(i,:),raw.info.ch_names{j})
            outord(i)=j;
            
        end
        
        
    end
end


%raw.info.projs = [];
%
%   Set up pick list: MEG + STI 014 - bad channels
%
%
want_meg   = true;
want_eeg   = true;
want_stim  = true;
include{1} = 'STI 014';
try
    picks = fiff_pick_types(raw.info,want_meg,want_eeg,want_stim,include,raw.info.bads);
catch
    %
    %   Failure: Try MEG + STI101 + STI201 + STI301 - bad channels instead
    %
    include{1} = 'STI101';
    include{2} = 'STI201';
    include{3} = 'STI301';
    try
        picks = fiff_pick_types(raw.info,want_meg,want_eeg,want_stim,include,raw.info.bads);
    catch
        error(me,'%s (channel list may need modification)',mne_omit_first_line(lasterr));
    end
end
    picks=1:raw.info.nchan;  %AG added
%
[outfid,cals] = fiff_start_writing_raw(outfile,raw.info,picks);
%
%   Set up the reading parameters
%
from        = raw.first_samp;
to          = raw.last_samp;
quantum_sec = 10;
quantum     = ceil(quantum_sec*raw.info.sfreq);
%
%   To read the whole file at once set
%
%quantum     = to - from + 1;
%
%
%   Read and write all the data
%
first_buffer = true;
for first = from:quantum:to
    last = first+quantum-1;
    if last > to
        last = to;
    end
    try
        [ data, times ] = fiff_read_raw_segment(raw,first,last,picks);
    catch
        fclose(raw.fid);
        fclose(outfid);
        error(me,'%s',mne_omit_first_line(lasterr));
    end
    %
    %   You can add your own miracle here
    %
    fprintf(1,'Writing...');
    for i = 1:273

        if corr(data(outord(i),:)',ica_meg_data(i,(first+1):(last+1))') <0
            ica_meg_data(i,(first+1):(last+1))=-ica_meg_data(i,(first+1):(last+1));
        end

    end
    
    data(outord,:)=ica_meg_data(:,(first+1):(last+1));
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
% quit
