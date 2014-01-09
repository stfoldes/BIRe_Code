function logic_list = DB_find(DB,input_field,match_criteria)
% Finds a logic list corresponding to "DB(:)" which have the given field matching the match criteria. 
% Works for structures, classes, and cells
% This performs: (DB(:).input_field == match_criteria) ... if that were possible
%
% Works for string or numaric inputs (Strings are case-sensitive) [changed from insensitve 2013-08-06]
% Also works for any structure that is organized as STUCT(:).FIELD
% Stephen Foldes [2012-09-05]
%
% UPDATES:
% 2012-09-20 Foldes: Now works if DB is a cell array
% 2012-10-02 Foldes: small tweak
% 2013-01-23 Foldes: now works for classes if classdef methods include: function isfield(current_entry,input_field); any(strcmp(properties(current_entry),input_field));
% 2013-08-06 Foldes: No longer case insesitive. This was causing problems.
% 2013-10-03 Foldes: Metadata-->DB

logic_list =[];

for ifile = 1:size(DB,2)
    
    clear current_entry
    if iscell(DB)
        current_entry = cell2mat(DB(ifile));
    else
        current_entry = DB(ifile);
    end
    
    % if this is a field not empty
    if isfield(current_entry,input_field) && ~isempty(current_entry.(input_field)) 
        if ischar(current_entry.(input_field))
            logic_list(ifile) = strcmp(current_entry.(input_field),match_criteria);
        else
            logic_list(ifile) = (current_entry.(input_field)==match_criteria);
        end
    else % either the field doesn't exist or its empty 
        logic_list(ifile) = 0;
    end
end

My change local not the web 
Last change from web

