% Container = Load_StandardStruct_from_TXT(Container[OPTIONAL],file2load);
% Loads object or struct from TXT file into memory
%
% Input 'Containter' can be empty [], but this will assume all property-values are of type char()
%   Use Convert_StrFields2NumVectors.m to help with this
%   (you don't want to do this conversion here b/c you might want a number to be a string)
%
% If input 'Container' is given (which it should be esp. for objects) then
%   this function casts properties as char or double based on the Container's classdef
%   (will try other types, but doesn't seem to work for logical)
%
% Any properties that were changed in Container's classdef will be set to the default (of course)
%   However, if properties are missing from the Containter but are in the txt file they ***WILL BE LOST***
%   Again, if properties are deleted from the classdef, the old properity in txt ***WILL BE LOST***
%   This can be used as a tool to wipe data from a property.
%
% Objects can have sub-objects, such as Metadata.Pointers.data, but only one sub-layer is capable at this time [2013-04-24]
%
% Used with Write_StandardStruct2TXT.m (see for Formating information)
%
% EXAMPLES:
% Metadata=Metadata_Class();
% Metadata = Load_StandardStruct_from_TXT(Metadata,'/home/foldes/Dropbox/Code/MEG_SF_Tools/Databases/Neurofeedback_metadatabase.txt');
%
% Events = Load_StandardStruct_from_TXT([],'Events.txt');
% Events = Convert_StrFields2NumVectors(Events);
%
% 2013-02-19 Foldes
% UPDATES
% 2013-02-21 Foldes: Casts properties as the type defaulted in the classdef, now uses | char
% 2013-02-26 Foldes: Generalized to not be only for metadata. Renamed from 'Metadata_Load_from_TXT'
% 2013-03-06 Foldes: MEDIUM - Now can deal with removals of properties in the class
% 2013-04-24 Foldes: LARGE - Now capable of dealing is with a sub-object, like Metadata.Pointers.Hi.
% 2013-07-02 Foldes: MEDIUM - Added OPEN_STATUS
% 2013-07-05 Foldes: small updates
% 2013-07-08 Foldes: OPEN_STATUS now deals with the case when you don't want to save data back to the database.
% 2013-07-16 Foldes: Removed status check. Now just use working copy for "source" control
% 2013-08-22 Foldes: Works for hidden properties/fields
% 2013-10-04 Foldes: Now works w/o subproperties

function Container = Load_StandardStruct_from_TXT(Container,file2load)

[file2load_path,file2load_name]=fileparts(file2load);

%% Read in txt file
% read file as str
fid=fopen(file2load,'r');
if fid==-1
    error(['Could not read file: ' file2load])
    return
end
whole_file_str=char(fread(fid));
org_str=whole_file_str; % org_str will be used for marking database open
fclose(fid);


% 1st line is the flag for open/unopen file (2013-07-02 Foldes)
clear current_line
current_line = strtok(whole_file_str,sprintf('\n'));
whole_file_str(1:length(current_line)+1)=[];

% **********************************************
% ***REMOVED STATUS CHECK (2013-07-16 Foldes)***
% **********************************************
%
% % If first line has an OPEN_STATUS, then need to deal! (2013-07-02 Foldes)
% status_header = 'OPEN_STATUS = ';
% status_str = current_line(length(status_header)+1:end)';
%
% file_info = dir(file2load);
% file_data_str = datestr(file_info.datenum,'yyyy-mm-dd');
%
% mark_as_owner_flag = 1; % 1 = put users name in database
%
% % if the database is currently open (or just isn't closed)
% if ~strcmp(status_str,'0')
%     switch questdlg(['Database last opened by ' status_str ' on ' file_data_str],['How to open database?'],'Load w/o Saving','Load and Take Ownership','Quit','Load w/o Saving')
%         case 'Quit'
%             warning('Failed to load database')
%             return
%         case 'Load w/o Saving'
%             mark_as_owner_flag = 0;
%         case 'Load and Take Ownership'
%             mark_as_owner_flag = 1;
%             warn_h = warndlg(['YOU MIGHT WANT TO TALK TO ' status_str ' BEFORE SAVING']);
%             pause(1)
%             try
%                 close(warn_h)
%             end
%     end
% end
%
% % Mark that you have the database open
% if mark_as_owner_flag==1
%     % ---Mark that the database is currently open by YOU--- SEE: Metadata_Close_without_Saving.m
%     first_line_length = length(strtok(org_str,sprintf('\n')));
%     org_str(1:first_line_length)=[];% remove first line (and carage return for some reason)
%     org_str = [(['OPEN_STATUS = ' computer_info])'; org_str]; % Add first line
%     % Open a new file to write to
%     open_database_name = [file2load_path filesep file2load_name '_TEMP.txt'];
%     fout = fopen(open_database_name,'w');
%     fwrite(fout, org_str, '*char');
%     fclose(fout);
%     % Copy TEMP COPY to normal
%     copyfile(open_database_name,file2load);
%     delete(open_database_name);% remove open copy
% end

% Remove 2nd line (date)
clear current_line
current_line = strtok(whole_file_str,sprintf('\n'));
whole_file_str(1:length(current_line)+1)=[];

% Get header (3rd Line)
clear current_line
current_line = strtok(whole_file_str,sprintf('\n'));
whole_file_str=whole_file_str(length(current_line)+1:end);

% Get list of properties
clear txt_prop_list
txt_prop_list_w_pipe = regexp(current_line(1:end-1)','|\t','split');
% this keeps the pipe char, remove it
for iprop = 1:length(txt_prop_list_w_pipe)
    txt_prop_list{iprop}=txt_prop_list_w_pipe{iprop}(1:end-1);
end

%% Assign data-types for each property if avalible (e.g. char)
if ~isempty(Container)
    % get a list of the data-types each property is defaulted to be
    default_prop_list = fieldnames_all(Container);
    
    %     % Now deal with sub-properties [2013-04-24]
    %     for iprop = 1:size(default_prop_list,1)
    %         clear temp
    %         current_prop_name = cell2mat(default_prop_list(iprop));
    %         eval(['temp = Container(1).' current_prop_name ';'])
    %         if isobject(temp)
    %             sub_prop_list =properties(temp);
    %
    %             % Add sub properties as PARENT.CHILD to properties list (at the end)
    %             for isub_prop = 1:size(sub_prop_list,1)
    %                 % add in to list (or just add?)
    %                 default_prop_list{end+1}=[current_prop_name '.' cell2mat(sub_prop_list(isub_prop))];
    %             end
    %             % remove parent prop from list
    %             default_prop_list(iprop)=[];
    %         end
    %     end % END - Now deal with sub-properties [2013-04-24]
    
    
    % List of properties that were avalible at the time
    org_properties_list = fieldnames_all(Container);
    
    % Deal with sub-objects [2013-04-24]
    clear sub_properties_list
    cnt=0;
    for iprop = size(org_properties_list,1):-1:1 % must go backwards to remove parent properties
        clear temp
        current_prop_name = cell2mat(org_properties_list(iprop));
        eval(['temp = Container(1).' current_prop_name ';'])
        if isobject(temp)
            current_sub_prop_list =fieldnames_all(temp);
            
            % Add sub properties as PARENT.CHILD to properties list (at the end)
            for isub_prop = 1:size(current_sub_prop_list,1)
                cnt=cnt+1;
                % keep track to add names later
                sub_properties_list{cnt,1}=[current_prop_name '.' cell2mat(current_sub_prop_list(isub_prop))];
            end
            % remove parent prop from list
            org_properties_list(iprop)=[];
        end
    end
    
    % add orgiginal propoerties and sub properties
    if exist('sub_properties_list')
        default_prop_list = [org_properties_list; sub_properties_list];
    else
        default_prop_list = [org_properties_list];
    end
    
    for iprop = 1:size(default_prop_list,1)
        eval(['default_type{iprop} = class(Container(1).' cell2mat(default_prop_list(iprop)) ');']);
    end
    
else % no Container given...can't figure out data types. Force to be strings
    default_prop_list = txt_prop_list;
    for iprop = 1:size(txt_prop_list,2)
        default_type{iprop} = class(char([]));
    end
end

% find matching data type for each property (should match)
old_prop_idx=[]; % list of properties in txt file that no longer exist in the container (I DON'T NEED TO USE THIS)
for iprop = 1:size(txt_prop_list,2)
    txt_type{iprop} = cell2mat( default_type(find(strcmp(txt_prop_list{iprop},default_prop_list))) );
    if isempty(txt_type{iprop})
        old_prop_idx = [old_prop_idx iprop];
    end
end

% display that some old properties will be removed
if ~isempty(old_prop_idx)
    disp(' ')
    disp('***Some properties of saved-txt file were missing from the current Class definition***')
    for iold=1:size(old_prop_idx,2)
        disp(txt_prop_list{old_prop_idx(iold)})
    end
end

%% LOOP through the rest of the data and put it in approprate locations
entry_cnt = 0;
while length(whole_file_str)>1
    entry_cnt =entry_cnt +1;
    
    % Get data from txt
    clear current_line
    current_line = strtok(whole_file_str,sprintf('\n'));
    whole_file_str=whole_file_str(length(current_line)+2:end);
    % clean up txt data
    clear entry_raw
    entry_raw_w_pipe = regexp(current_line(1:end-1)','|\t','split');
    % this keeps the pipe char, remove it
    for iprop = 1:length(entry_raw_w_pipe)
        entry_raw{iprop}=entry_raw_w_pipe{iprop}(1:end-1);
    end
    
    % go through all properties in txt
    for iprop = 1:length(txt_prop_list)
        if strcmp(txt_type{iprop},'char')
            eval(['Container(entry_cnt).' cell2mat(txt_prop_list(iprop)) '=entry_raw{iprop};'])
        elseif strcmp(txt_type{iprop},'double') % do str2num
            eval(['Container(entry_cnt).' cell2mat(txt_prop_list(iprop)) '=str2num(entry_raw{iprop});'])
        elseif isempty(txt_type{iprop})
            % Dont do a thing. This prop has been removed in the new class
        else % UNSUPPORTED TYPE
            try
                eval(['Container(entry_cnt).(cell2mat(txt_prop_list(iprop)))=' txt_type{iprop} '(entry_raw{iprop});'])
            catch
                error('UNSUPPORTED DATA TYPE @Load_StandardStruct_from_TXT')
            end
        end
    end % each property
end

% Copy current database to WORKING (do this at the end so errors won't copy over to the previous working) (2013-07-02)
copyfile(file2load,[file2load_path filesep file2load_name '_WORKING_' computer_info '.txt']);

