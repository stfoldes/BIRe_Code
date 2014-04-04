% logic_flag = isequal_except_fields(Struct1,Struct2,fields_not_compared)
% Stephen Foldes [2012-09-06]
%
% Compares two structures. It will disregard "fields_not_compared".
% fields_not_compared can be cell array of strings
%
% if fields_not_compared is not given or is empty this will just do a normal struct compare

function logic_flag = isequal_except_fields(Struct1,Struct2,fields_not_compared)

if ~exist('fields_not_compared') || isempty(fields_not_compared)
    fields_not_compared='';
end

if isfield(Struct1,fields_not_compared)
    Struct1_wo_fields = rmfield(Struct1,fields_not_compared);
else
    Struct1_wo_fields = Struct1;
end

if isfield(Struct2,fields_not_compared)
    Struct2_wo_fields = rmfield(Struct2,fields_not_compared);
else
    Struct2_wo_fields = Struct2;
end

logic_flag = isequal(Struct1_wo_fields,Struct2_wo_fields);



