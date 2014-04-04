function exists_flag = pointer_check(obj,pointer_name,varargin)%location_name,dialog_flag
% Checks if the pointer exists local or server.
% VARARGINS:
%     location_name: 'local' or 'server' SEE: .file_path
%     dialog_flag: 1=ask if you want to overwrite a file when it is there already
%
% pointer_name = 'Preproc.Pointer_prebadchan';
%
% 2013-10-07 Foldes
%

global MY_PATHS

defaults.location_name = 'local';
defaults.dialog_flag = 0;
parms = varargin_extraction(defaults,varargin);



eval(['pointer_link = obj.' pointer_name ';']); % Get pointer
pointer_full_path = [obj.file_path(parms.location_name) filesep pointer_link];

% Check if it already exists
exists_flag = 0;
if (exist(pointer_full_path)==2)
    % It already exists, skip?
    pointer_date = date_file_timestamp(pointer_full_path);
    
    % Ask the user if this should be skipped, but only if you dialog flag
    if (parms.dialog_flag == 1) && (questdlg_YesNo_logic([pointer_name ' already exists from ** ' pointer_date ' **, Proceed?'],'POINTER OVERWRITE?'))
        exists_flag = 0; % pretend it doesn't exist
    else % don't overwrite
        exists_flag = 1;
    end
end