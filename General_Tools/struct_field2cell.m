function c = struct_field2cell(S,field_name)
% function c = struct2indexed_cell(S,idx)
% turns the values in field_name within a structure/object array, S, into a cell
% c = S(idx).field_name ...but this won't work
% Only for 1D structs/objects
%
% 2014-01-16 Foldes


for ientry = 1:length(S)
    c{ientry} = S(ientry).(field_name);
end
 