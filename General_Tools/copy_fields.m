function struct_to = copy_fields(struct_from,struct_to,varargin)
% Copy fields listed in varargin from 'struct_from' to 'struct_to'
% 'struct_to' can be empty
% If not fields listed, will copy everything.
%
% 2014-01-16 Foldes
% UPDATES:
% 2014-02-04 Foldes: Changed input order, now allows no fields listed

if isempty(struct_to)
    struct_to = [];
end

if isempty(varargin)
    fields2copy = fieldnames(struct_from);
else
    fields2copy = varargin;
end

for ifield = 1:length(fields2copy)
    current_field_name = cell2mat(fields2copy(ifield));
    struct_to.(current_field_name) = struct_from.(current_field_name);
end



