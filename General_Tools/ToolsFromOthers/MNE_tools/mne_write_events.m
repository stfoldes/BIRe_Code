function mne_write_events(filename,eventlist)
%
% mne_write_events(filename,eventlist)
%
% Write an event list into a fif file
%

%
%   Copyright 2008
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
%
%   $Id: mne_write_events.m 2628 2009-04-27 21:17:31Z msh $
%   
%   Revision 1.2  2008/10/31 13:07:05  msh
%   Added mne_make_combined_event_file function
%
%   Revision 1.1  2008/06/16 17:27:50  msh
%   Added mne_read_events and mne_write_events functions
%
%
global FIFF;
if isempty(FIFF)
    FIFF = fiff_define_constants();
end

me='MNE:mne_write_events';

eventlist = reshape(eventlist',prod(size(eventlist)),1);
%
%   Start writing...
%
fid  = fiff_start_file(filename);

fiff_start_block(fid,FIFF.FIFFB_MNE_EVENTS);
    fiff_write_int(fid,FIFF.FIFF_MNE_EVENT_LIST,eventlist);
fiff_end_block(fid,FIFF.FIFFB_MNE_EVENTS);

fiff_end_file(fid);
