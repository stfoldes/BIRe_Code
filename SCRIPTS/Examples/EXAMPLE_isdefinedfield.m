% EXAMPLE_isdefinedfield
% Stephen Foldes [2012-09-05]
%
% is not a field OR is empty (then make and fill the field)
%
% I want to make a function to do this, but haven't figured it out yet

~( ~isfield(Neurofeedback_metadata(ifile),subject_field_list(ifield)) || isempty(Neurofeedback_metadata(ifile).(char(cell2mat(subject_field_list(ifield))))) )