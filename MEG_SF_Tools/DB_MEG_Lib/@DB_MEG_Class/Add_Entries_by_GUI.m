function obj = Add_Entries_by_GUI(obj,varargin)
% Add entries into a database by selecting files
% select a bunch of files (of type 'file_ext')
% asks user for info
% Menu only give a list of values that are commonnly used
%
% OPTIONAL INPUTS
%     file_ext = [DEFAULT = '.fif']
%     'props_once_per_folder': properties that only need to be defined once (default = none)
%     'props_skip',{'run_info'}: properties that should be skipped (default = none)
%
%
% for now, write down any mistakes (file name) and Stephen can manually fix w/o problem
% Requires server access
%
% SEE: SCRIPT_Neurofeedback_Database_Entry, DB_Update_Entry
% Not much is specific to MEG data; those two places are marked
%
% 2013-08-23 Foldes
% UPDATES:
% 2013-09-13 Foldes: Now uses menus.
% 2013-10-17 Foldes: Metadata-->DB

global MY_PATHS

defaults.file_ext = '.fif';
defaults.props_once_per_folder=[];
defaults.props_skip=[];
parms = varargin_extraction(defaults,varargin);

%% NONE DATABASE SPECIFIC CODE

% % Get server path
% disp('Loading Database...')
% obj=DB_MEG_Class;
% obj=obj.build('PATHS_meg_neurofeedback'); % also sets global MY_PATHS


% Pick files on server
files = uigetfile(parms.file_ext,'Select Files to Add',MY_PATHS.local_base,...
    'MultiSelect','on');

% % Pick folder on server
% folder = uigetdir(server_path,'Pick Session folder');
% if isequal(folder,0)
%     disp('User selected Cancel')
%     return
% end
% 
% files = dir(folder);
% %files(1:2)=[]; % remove . and ..
% for ifile=length(files):-1:1 % backwards b/c removing
%     [~,~,current_ext]=fileparts(files(ifile).name);
%     if ~strcmpi(current_ext,parms.file_ext)
%         files(ifile)=[]; % remove NONE fif files
%     end
% end

eval(['new_entries =' class(obj) ';']); % make a skeleton of the input's class
props = properties(new_entries);

%% Go through each file
for ifile=1:length(files)
    
    % make an object for this file and auto fill in some stuff
    eval(['current_entry =' class(obj) ';']);

    % ***DATABASE SPECIFIC***
    current_entry.entry_id = files{ifile}(1:end-4); % remove the .fif
    [current_entry.subject, current_entry.session, current_entry.run] = file_name_spliter(current_entry.entry_id);
    % ***********************
    
    % Tell user its a new file
    try;close(h_file);pause(1.5);end
    h_file = msgbox(['FILE==> ' current_entry.entry_id]);
    Figure_Position(0.4,1,h_file)
    
    % check if there is already an entry
    existing_entry = obj.get_entry(current_entry.entry_id);
    if ~isempty(existing_entry)
        if ~questdlg_YesNo_logic(['ENTRY ALREADY FOUND: ' current_entry.entry_id '!!!! Proceed? (YES overwrites)'])
            break
        end
    end
    
    for iprop = 1:length(props)
        current_prop_name = cell2mat(props(iprop));
        
        % Tell me about youself, property.
        flag_prop_empty = isempty(current_entry.(current_prop_name));
        flag_prop_session_only = ~isempty(find_lists_overlap_idx(parms.props_once_per_folder,current_prop_name));
        flag_prop_object = isobject(current_entry.(current_prop_name));
        flag_prop_skip = ~isempty(find_lists_overlap_idx(parms.props_skip,current_prop_name));
        
        % IF prop is session only and needs to be filled in (first time)
        % OR if its empty AND is not an object, but IS NOT a session only prop
        if ( (flag_prop_session_only && ifile == 1) || (flag_prop_empty && ~flag_prop_object && ~flag_prop_session_only) ) ...
                && ~flag_prop_skip
            
            % Options: What are the values that have been used before
            [prop_value_options,option_cnt] = DB_lookup_unique_entries(obj,current_prop_name);
            % okay, theres like tons, don't show them all
            if length(prop_value_options)>15
                option_str = [];
            else % Build cell or string for giving user standard options
                option_cell = []; % for menu
                option_str = []; % for input box
                val_cnt = 0;
                for ival = 1:length(prop_value_options)
                   
                        option_str = [option_str cell2mat(prop_value_options(ival)) ', '];
                    if option_cnt(ival)>2 % Menu only has options that have been used more than 2 times
                        val_cnt=val_cnt+1;
                        option_cell{val_cnt} = cell2mat(prop_value_options(ival));
                    end
                end
                option_cell{end+1}='Leave Blank';
                option_cell{end+1}='Manual Entry';
            end
            % default answer is the last entries (not too useful with menues)
            defAns = {new_entries(end).(current_prop_name)};
            
            manual_entry_flag = 0;
            
            % Too many value options so default to manual entry
            if length(prop_value_options)>15
                manual_entry_flag = 1;
            else
                menu_number = menu([current_prop_name ' [' current_entry.entry_id ']'],option_cell);
            end
            
            % picked Manual Entry from menu, so allow for manual entry
            if menu_number==length(option_cell)
               manual_entry_flag = 1;
            end
            
            
            
            % Manual Entry (b/c too many options or b/c user requested)
            if manual_entry_flag == 1
               answer = inputdlg([current_prop_name ' (' option_str '): '],...
                    ['FOR: ' current_entry.entry_id],...
                    1,defAns);
                
            else % Used menu entry
                % 2nd to last menu option is Leave Blank
                if menu_number==length(option_cell)-1
                    answer{1} = ''; % if not celled, will consider cancelled below
                else
                    answer = option_cell(menu_number);
                end
            end
            
            if ~isempty(answer) % Cancelled
                current_entry.(current_prop_name) = cell2mat(answer);
            else
                return
            end
            
        elseif (flag_prop_session_only && ifile ~= 1)
            % session only, get this info from the previous entry
            current_entry.(current_prop_name)=new_entries(end).(current_prop_name);
        end % prop valid to check
    end % props
    
    % save this to the list
    new_entries(end+1)=current_entry;
    
end % all files
try;close(h_file);pause(1.5);end

%% Check if you like them then move new_entries into obj
for ientry = 2:length(new_entries) % 2 b/c first is blank by def
    satisfied_flag = 0;
    while satisfied_flag==0 % loop until satisfied
        
        % check if there is already an entry (REDUNDENT, already checked)
        existing_entry = obj.get_entry(new_entries(ientry).entry_id);
        if ~isempty(existing_entry)
            msgbox(['ENTRY ALREADY FOUND: ' current_entry.entry_id])
            break
        end
        
        new_entries(ientry)
        switch questdlg_wPosition([],['Accept this for ' new_entries(ientry).entry_id '?'],'Accept?','Yes','No','Skip','Yes');
            case 'Yes'
                satisfied_flag = 1;
                obj(end+1) = new_entries(ientry);
            case 'No'
                satisfied_flag = 0; % DOES NOTHING RIGHT NOW
            case 'Skip'
                satisfied_flag = 1;
        end
    end % satisfied loop
end


%% Write to file
if questdlg_YesNo_logic(['Ready to write ' num2str(length(new_entries)-1) ' new entries to the database? (NO will not write anything to the database)'])
    obj.save_DB;
end



