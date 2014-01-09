function in_struct = S2samples_struct(in_struct,sample_rate)
% Turns fields/members that end in S into samples
% Wrapper for struct_auto_translate.m
%
% WARNINGS:
%   Will overwrite values
%   Requires a strict naming convension
%   Object need properties defined
%
% EXAMPLE:
%   FeatureParms = S2samples_struct(FeatureParms,FeatureParms.sample_rate);
%
% 2013-12-06 Foldes
% UPDATES:
% 2014-01-07 Foldes: Now a wrapper

suffix_str =                    'S';
translation_str =               'floor(in_struct.(current_field)*sample_rate)';
required_data_type =            'numeric';
in_struct = struct_auto_translate(in_struct,suffix_str,required_data_type,translation_str,...
    'sample_rate',sample_rate);
