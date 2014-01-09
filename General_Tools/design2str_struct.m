function in_struct = design2str_struct(in_struct)
% Turns fields/members that end in '_design' into strings
% Wrapper for struct_auto_translate.m
%
% WARNINGS:
%   Will overwrite values
%   Requires a strict naming convension
%   Object need properties defined
%
% EXAMPLE:
%   MRI_Info.subject_id =           'NT10'; % used in designs
%   MRI_Info.output_prefix_design = '[subject_id]_';
%   MRI_Info = design2str(MRI_Info);
%   Now, MRI_Info.output_prefix is 'NT10_'
%
% 2014-01-07 Foldes
% UPDATES:
%

suffix_str =            '_design';
translation_str =       'str_from_design(in_struct,in_struct.(current_field))';
required_data_type =    'char';

in_struct = struct_auto_translate(in_struct,suffix_str,required_data_type,translation_str);

