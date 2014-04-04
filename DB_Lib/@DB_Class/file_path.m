function [path] = file_path(obj,location_name)
% Builds the folder path of entries entry
%
% location_name = 'local' or 'server' (only options) [DEFAULT = 'local']
% Needs global MY_PATHS (SEE: DEF_MEG_paths)
%
% EXAMPLE:
%     DB.get('run_info','NC01_Grasp_Right_Imagine').file_path('local')
%
% Foldes 2013-08-16
% UPDATES:
% 2013-10-04 Foldes: added path_design, paths now global
% 2013-10-10 Foldes: str_from_design now separate function

global MY_PATHS

%% Set up


% Default location is local
if ~exist('location_name') || isempty(location_name)
    location_name = 'local';
end

% Defined by location name
base_path = MY_PATHS.([location_name '_base']);
path_design_str = MY_PATHS.([location_name '_path_design']);

obj_name_str= 'DB_entry'; % for path generation (no need to be a variable)

%% Build Path

for ientry = 1:length(obj) % for each entry
    clear DB_entry
    DB_entry = obj(ientry);
    
%     path_from_base{ientry} = parse_path_design_str(path_design_str,DB_entry);
    path_from_base{ientry} = str_from_design(DB_entry,path_design_str);
    path{ientry} = [base_path filesep path_from_base{ientry} filesep];
end

if max(size(path))==1
    path_from_base = cell2mat(path_from_base);
    path = cell2mat(path);
end


%% ============================================================================
% function path_from_base = parse_path_design_str(path_design_str,obj)
% % Parses a string to include object.properties into a path
% % NS01/S01 --> '[subject]/S[session]'
% %
% % path_design: [] enclose property call. / or \ will call filesep (SEE: DB_Class.file_path.m)
% %
% % 2013-10-04 Foldes
% % UPDATES:
% %
% 
% % Parse out path_design string
% char_cnt=0;
% path_from_base = [];
% 
% while char_cnt < length(path_design_str)
%     
%     char_cnt=char_cnt+1;
%     current_char = path_design_str(char_cnt);
%     
%     switch current_char
%         case '[' % start of a obj.property
%             prop_name = [];
%             while ~strcmp(path_design_str(char_cnt+1),']')
%                 char_cnt=char_cnt+1;
%                 prop_name = [prop_name path_design_str(char_cnt)];
%             end
%             % Add the object.prop to the path
%             eval(['path_from_base = [path_from_base ''' obj.(prop_name) '''];'])
%             char_cnt=char_cnt+1; % to get rid of the trailing ]
%             
%         case {'\' '/'} % make sure file separator is correct
%             path_from_base = [path_from_base filesep];
%             
%         otherwise
%             path_from_base = [path_from_base current_char];
%     end
%     
% end % while


% A DIFFERENT WAY TO DO IT
%     % Generate a string from the path_design cell array
%     path_from_base = [];
%     for ipart=1:length(path_design)
%         clear part2print
%         % check if first char is a ., then its a property of the object
%         if strcmp(path_design{ipart}(1),'.')
%             part2print = [obj_name path_design{ipart}];
%         else % current part is NOT a property
%             part2print = path_design{ipart};
%         end
%         eval(['path_from_base = [path_from_base sprintf(''%s'', ' part2print ')];'])
%     end