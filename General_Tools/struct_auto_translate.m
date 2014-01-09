function in_struct = struct_auto_translate(in_struct,suffix_str,required_data_type,translation_str,varargin)
% Translates all fields/members that end in suffix_str into new members using the method defined in translation_str
% New member name will be original w/o suffix_str.
% Super easy, BUT BE CAREFUL.
% Suggested to make wrappers (SEE: design2str_struct.m, S2samples_struct.m)
% Will try to deal with design dependencies by repeating 10 times before failing
%
% WARNINGS:
%   Will overwrite values
%   Requires a strict naming convension
%   Object need properties defined
%
% INPUTS:
%   in_struct:          input struct which has members ending in suffix_str to translate (structs or objects)
%   suffix_str:         string to match for translation
%   required_data_type: 'char','numeric',etc.
%   translation_str:    string to be used in an eval. See examples
%
% VARARGIN:
%   Any varibles that might be needed for translation_str
%   ...,'variable_name',value,...
%
% EXAMPLES:
%   All design members are translated into strings
%       SEE: design2str_struct.m
%   MRI_Info.subject_id =           'NT10'; % used in designs
%   MRI_Info.output_prefix_design = '[subject_id]_';
% 
%   suffix_str =                    '_design';
%   translation_str =               'str_from_design(in_struct,in_struct.(current_field))';
%   required_data_type =            'char';
%   MRI_Info = struct_auto_translate(MRI_Info,suffix_str,required_data_type,translation_str);
%       Now, MRI_Info.output_prefix is 'NT10_'
%
%   Turn all seconds (ending in S) into samples using sample_rate
%       SEE: S2samples_struct.m
%   FeatureParms.window_lengthS =   1;
%   FeatureParms.sample_rate =      1000;
% 
%   suffix_str =                    'S';
%   translation_str =               'floor(in_struct.(current_field)*sample_rate)';
%   required_data_type =            'numeric';
%   FeatureParms = struct_auto_translate(FeatureParms,suffix_str,required_data_type,translation_str,...
%       'sample_rate',FeatureParms.sample_rate);
%       Now, FeatureParms.window_length is 1000
%
% SEE: design2str_struct.m, S2samples_struct.m 
% 2014-01-07 Foldes
% UPDATES:
%

%% Translate varargins from 'variable_name',value
for ivar = 1:2:length(varargin)
    eval([varargin{ivar} ' = varargin{ivar+1};']);
end

%%

field_list = fieldnames_all(in_struct); % Don't forget to use fieldnames_all for hidden properties

failed_translate = 1;
try_cnt = 10; % try 10 times to translate, else fail

% Repeat translation if there are errors. Takes care of dependencies
while (failed_translate > 0) && (try_cnt>0) 
    try_cnt = try_cnt - 1;
    failed_translate = max(failed_translate-1,0); % repeat for dependencies
    
    for ifield = 1:length(field_list)
        current_field = field_list{ifield};
        
        % Match suffix
        if strcmp(current_field(end-length(suffix_str)+1:end),suffix_str)
            % Match data type
            if isa(in_struct.(current_field),required_data_type)
                try
                    new_field_name = current_field(1:end-length(suffix_str));% remove original suffix
                    % translate
                    eval(['in_struct.(new_field_name) = ' translation_str ';'])
                    
                catch
                    %warning('Design poorly constructed (or dependent on something that does not exist yet)')
                    failed_translate = failed_translate+1;
                    
                end % try
            end % match data type
        end % field name match
    end % field loop
end % failed translate

% tried to fit too many times, fail!
if try_cnt==0
    error(['Design incorrectly constructed. Check: .' current_field])
end




