function c = struct_field2cell(S,field_name)
% c = struct_field2cell(S,field_name);
% turns the values in field_name within a structure/object array, S, into a cell
% c = S(idx).field_name ...but this won't work
% Only for 1D structs/objects
%
% 2014-01-16 Foldes
% UPDATES:
% 2014-02-24 Foldes: Now uses eval so field_name can be sub-struct (i.e. include .)
% 2014-03-05 Foldes: if input S is empty, returns []

c = [];
for ientry = 1:length(S)
    if iscell(S)
        eval(['c{ientry} = S{ientry}.' field_name ';'])
    else
        eval(['c{ientry} = S(ientry).' field_name ';'])
    end
end

if isempty(cell2mat(c)) % 2014-03-05
    c = [];
end