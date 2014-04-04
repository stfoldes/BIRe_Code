function logic_list = DB_find(DB,input_field,match_criteria,varargin)
% Finds a logic list corresponding to "DB(:)" which have the given field matching the match criteria. 
% Works for structures, classes, and cells
% This performs: (DB(:).input_field == match_criteria) ... if that were possible
%
% String inputs can use wildcards (*) and the following options
% VARARGIN
%   Strict:             1 = search needs a perfect match to pattern [DEFAULT = 0]
%   CaseInsensitive:    1 = search is not sensitive to case [DEFAULT = 0, case sensitive]
%
% Also works for any structure that is organized as STUCT(:).FIELD
%
% SEE: search_dir.m
%
% Stephen Foldes [2012-09-05]
% UPDATES:
% 2012-09-20 Foldes: Now works if DB is a cell array
% 2012-10-02 Foldes: small tweak
% 2013-01-23 Foldes: now works for classes if classdef methods include: function isfield(current_entry,input_field); any(strcmp(properties(current_entry),input_field));
% 2013-08-06 Foldes: No longer case insesitive. This was causing problems.
% 2013-10-03 Foldes: Metadata-->DB
% 2014-02-17 Foldes: Now uses regexp for string/chars

parms.Strict =          false;
parms.CaseInsensitive = false;
parms = varargin_extraction(parms,varargin);


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
            % This is a str, so use a regexp
            % See search_dir.m
            
            % Create the regular expression
            beginstr='('; endstr=')';
            
            if parms.Strict; beginstr=['^' beginstr];
                endstr=[endstr '$'];
            end
            
            if ~parms.CaseInsensitive;
                beginstr = ['(?-i)' beginstr];
            end
            
            regexpstr=[beginstr strrep(regexptranslate('wildcard', match_criteria), pathsep, [endstr '|' beginstr]) endstr];
            
            % Search
            search_result = regexp(current_entry.(input_field),regexpstr);
            if isempty(search_result)
                logic_list(ifile) = 0;
            else
                logic_list(ifile) = search_result;
            end
            
            % OLD 2014-02-17
            % logic_list(ifile) = strcmp(current_entry.(input_field),match_criteria);
            
        else
            logic_list(ifile) = (current_entry.(input_field)==match_criteria);
        end
    else % either the field doesn't exist or its empty 
        logic_list(ifile) = 0;
    end
end
