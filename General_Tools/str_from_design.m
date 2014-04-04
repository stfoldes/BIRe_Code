function str_out = str_from_design(struct_in,design_str)
% Creates a string based on a design which are fields/properties of the struct_in
% This function was made for setting a default path organization
% This way a the organization of paths (or any string) can be 'designed' in a parameter file
% design: [property-name], / or \ will call filesep (SEE: DB_Class.file_path.m)
%
% EXAMPLE:
%       struct_in.subject = 'NS01';
%       struct_in.session = '02';
%       % Computer 1
%       str_from_design(struct_in,'[subject]/S[session]') ==> 'NS01/S02' (or 'NS01\S02')
%       % Computer 2 w/ different structure
%       str_from_design(struct_in,'[subject]/MEG/S[session]') ==> 'NS01/MEG/S02'
%
% 2013-10-04 Foldes
% UPDATES:
%

% Parse out design string
char_cnt=0;
str_out = [];

while char_cnt < length(design_str)
    
    char_cnt=char_cnt+1;
    current_char = design_str(char_cnt);
    
    switch current_char
        case '[' % start of a struct_in.property
            prop_name = [];
            while ~strcmp(design_str(char_cnt+1),']')
                char_cnt=char_cnt+1;
                prop_name = [prop_name design_str(char_cnt)];
            end
            % Add the struct_inect.prop to the path
            eval(['str_out = [str_out ''' num2str(struct_in.(prop_name)) '''];'])
            char_cnt=char_cnt+1; % to get rid of the trailing ]
            
        case {'\' '/'} % make sure file separator is correct
            str_out = [str_out filesep];
            
        otherwise
            str_out = [str_out current_char];
    end
end % while