% Write_StandardStruct2TXT(Container,file2write);
% Writes a simple structure or object to a TXT file for saving and version control
% Requires standard formating (see below)
% Used with Load_StandardStruct_from_TXT.m
%
% Container = structure or object to write in standard format (see below)
% file2write = full path and name of text file to write
% this will overwrite the previous file
% Vectors of numbers need to be horizontal (e.g. [1 2 3], NOT [1;2;3])
%
% FORMAT:
% 1st line = time stamp
% 2nd line = list of field/property names
% 3rd line = values for each field in the 1st entry
% 4th line = values for each field in the 2nd entry
% etc.
%
% Objects can have sub-objects, such as Metadata.Pointers.data, but only one sub-layer is capable at this time [2013-04-24]
%
% FORMAT EXAMPLE:
% UPDATED: 2013-02-19\n
% Fieldname1|\tFieldname2|\t\n
% Entry1property_value1|\tEntry1property_value2|\t\n
% Entry2property_value1|\tEntry2property_value2|\t\n
%
% EXAMPLE USE:
% Write_StandardStruct2TXT(Metadata,'/home/foldes/Dropbox/Code/MEG_SF_Tools/Databases/Neurofeedback_metadatabase.txt');
%
% 2013-02-26 Foldes
% UPDATES:
% 2013-02-26 Foldes: Branched from 'Metadata_Write_to_TXT.m'
% 2013-04-24 Foldes: LARGE - Now capable of dealing is with a sub-object, like Metadata.Pointers.Hi.
% 2013-07-02 Foldes: Added OPEN_STATUS
% 2013-07-03 Foldes: Added save of a backup (to Database_Backup folder)
% 2013-08-22 Foldes: Works for hidden properties/fields
% 2014-03-13 Foldes: temp --> temp__

function Write_StandardStruct2TXT(Container,file2write)

% Breaking the filename into is components
[file2write_path, file2write_name]=fileparts(file2write);

% Start by saving a backup copy
backup_database_name = [file2write_path filesep 'Database_Backup' filesep file2write_name '_BACKUP_' datestr(now,'yyyy-mm-dd_HHMM') '.txt'];
try
    copyfile(file2write,backup_database_name,'f');
    disp(['***Backed up txt file: ' backup_database_name '***'])
catch
    warning(['***Failed to make backup ' backup_database_name ' (make sure /Database_Backup folder exists'])
end


disp(['***WRITING TXT FILE: ' file2write '***'])

% Opens the text doucment for OVER-writing
file_id = fopen(file2write,'w');

% Write OPEN_STATUS to closed (0)
fprintf(file_id,'OPEN_STATUS = 0\n');

% Write Date/basic info
fprintf(file_id,'UPDATED: %s (by %s)\n',datestr(now,'yyyy-mm-dd HH:MM'),computer_info);

% List of properties that were avalible at the time
org_properties_list = fieldnames_all(Container);

% Deal with sub-objects [2013-04-24]
clear sub_properties_list
cnt=0;
for iprop = size(org_properties_list,1):-1:1 % must go backwards to remove parent properties
    clear temp__
    current_prop_name = cell2mat(org_properties_list(iprop));
    eval(['temp__ = Container(1).' current_prop_name ';'])
    if isobject(temp__)
        current_sub_prop_list =fieldnames_all(temp__);
        
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
properties_list = [org_properties_list; sub_properties_list];



for iprop =1:size(properties_list,1)
    fprintf(file_id,'%s|\t',cell2mat(properties_list(iprop)));
end
fprintf(file_id,'\n');

% Write each property value for each entry
for ientry = 1:size(Container,2)
    for iprop =1:size(properties_list,1)
        property_str = (cell2mat((properties_list(iprop))));
        eval(['fprintf(file_id,''%s|\t'', num2str( Container(ientry).' property_str ' ) );'])
    end
    fprintf(file_id,'\n');
end


fclose(file_id);

disp(['Done'])