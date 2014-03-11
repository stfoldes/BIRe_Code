function m = struct_field2mat(S,field_name)
% WRAPPER FOR struct_fields2mat
% function c = struct2indexed_cell(S,idx)
% turns the values in field_name within a structure/object array, S, into a cell
% c = S(idx).field_name ...but this won't work
% Only for 1D structs/objects
%
% 2014-01-16 Foldes
% UPDATES:
% 2014-02-24 Foldes: The fliping of c was wrong, do you need it?


c = struct_field2cell(S,field_name);

% if size(c,1)<size(c,2)
%     % flip if 1x#
%     m = cell2mat(c');
% else
    m = cell2mat(c);
% end

