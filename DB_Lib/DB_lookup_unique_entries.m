function [list,cnt] = Metadata_lookup_unique_entries(metadata,input_field)
% Returns a list off all unique values in a given field
% input_field can be a subfield
% Also returns the count of how many of each value
%
% EXAMPLE: Metadata_lookup_unique_entries(metadata,'subject'); to return all subjects in database
%
% Also works for any structure that is organized as STUCT(:).FIELD
%
% 2012-09-20 Foldes
% UPDATES:
% 2013-09-13 Foldes: now returns count as well
% 2013-09-25 Foldes: Now works for sub-fields, which was annoying
% 2013-09-30 Foldes: What if metadata is empyt?


% Replacing isfield for subfields. Crappy way, but what ever 2013-09-25
field_full_name = ['metadata(1).' input_field];
% dot_idx = strfind(field_full_name,'.');
% parent_strut_name = field_full_name(1:dot_idx(end)-1);
% subfield_name = field_full_name(dot_idx(end)+1:end);
try
    eval([field_full_name ';'])
    valid_field_flag = 1;
catch
    valid_field_flag = 0;
end

if valid_field_flag == 0 %~isfield(parent_strut_name,subfield_name)
    warning([input_field ' is not a field'])
    list = [];
    return
end

file_cnt = 0;all_entries{1}='';
for ifile = 1:size(metadata,2)
    
    % Remove empty
    eval(['empty_flag = isempty(metadata(ifile).' input_field ');'])
    if ~empty_flag
        file_cnt=file_cnt+1;
        eval(['all_entries{file_cnt}=metadata(ifile).' input_field ';'])
    end
end

list = unique(all_entries);

% Count for each unique entry
for ival = 1:length(list)
    cnt(ival) = length(find_lists_overlap_idx(all_entries,list{ival}));
end