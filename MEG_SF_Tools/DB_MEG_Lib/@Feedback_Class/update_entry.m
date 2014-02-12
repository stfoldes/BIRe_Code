function DB = update_entry(DB,DB_entry)
%
% Puts DB entry back into the larger database object list
% DOES NOT WRITE DATABASE TO TXT FILE (see .save_DB)
% Makes a new entry if there isn't a match
%
% 2013-02-20 Foldes
% UPDATES:
%
% 2013-10-03 Foldes: Ramed from Metadata_Update_Entry Metadata-->DB, fliped inputs


% Look for the entry for this file
entry_idx = DB_find_idx(DB,'entry_id',DB_entry.entry_id);

% Should only be one entry per file
if max(size(entry_idx))>1
    error('Dude, this file entry has multiple entries in DB! That cant be')
end

% If there is no entry, start one
if isempty(entry_idx)
    warning('NO ENTRY FOUND. Making new entry')
    entry_idx = size(DB,2)+1;
end

DB(entry_idx) = DB_entry;



