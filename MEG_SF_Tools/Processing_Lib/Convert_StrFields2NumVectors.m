% Container = Convert_StrFields2NumVectors(Container);
%
% Will go through an object or structure and try to change strings into vectors of number
% Strings must be numerical, will not effect non-numarical strings
% Will not effect non-string fields
% Works well with Load_StandardStruct_from_TXT when not giving an empty container b/c default is char types
%
% Foldes 2013-02-26
% UPDATES:

function Container = Convert_StrFields2NumVectors(Container)

field_list = fieldnames_all(Container);
for ifield = 1:size(field_list,1)
    current_field = cell2mat(field_list(ifield));
    if ischar(Container.(current_field)) % must be a string
        if ~isempty(str2num(Container.(current_field)))
            Container.(current_field)=str2num(Container.(current_field));
        end
    end
end
