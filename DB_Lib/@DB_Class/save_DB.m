function save_DB(obj,database_location)
% Writes DB Object to a TXT file for saving and version control
% database_location is OPTIONAL, defaults to MY_PATHS.db_full_name
%
% SEE: build.m
% Also saves a backup copy
% Vectors of numbers need to be horizontal (e.g. [1 2 3], NOT [1;2;3])
% NOTE: Might need to update DB before (e.g. update_entry)
% 
% Used with Load_StandardStruct_from_TXT or build
%
% EXAMPLE:
%     DB.save_DB
%     DB.save_DB('/home/foldes/Dropbox/Code/MEG_SF_Tools/Databases/Neurofeedback_DBbase.txt');
%
% FORMAT:
% UPDATED: 2013-02-19\n
% Property_name1|\tProperty_name2|\t\n
% Entry1property_value1|\tEntry1property_value2|\t\n
% Entry2property_value1|\tEntry2property_value2|\t\n
%
% 2013-02-19 Foldes
% UPDATES:
% 2013-02-21 Foldes: Added | character to deal with arrays of numbers (such as bad_chan_mask)
% 2013-02-26 Foldes: now uses a function for writing, copies backup to local (svn over server)
% 2013-07-02 Foldes: MAJOR - Uses WORKING copy method to see if someone tampered with the file while you were working. NEEDS MERGE
% 2013-07-03 Foldes/Randazzo: bug fix
% 2013-07-30 Foldes: what if you write twice w/o loading again, then there is no working copy, so don't delete it ever...I guess?
% 2013-08-07 Foldes: Now saves WORKING so if you don't reload the database after writing you don't have conflicts
% 2013-10-05 Foldes: Metadata-->DB, renamed from Metadata_Write2TXT

global MY_PATHS

if ~exist('database_location') || isempty(database_location)
    database_location = MY_PATHS.db_full_name;
end

% Breaking the DB file into is components
[database_location_path, database_location_name, database_location_ext]=fileparts(database_location);

% read file as str
fid=fopen(database_location,'r');
if fid==-1
    error(['Could not read file: ' database_location])
    return
end
org_str=char(fread(fid));
fclose(fid);

% read file as str
working_database_name = [database_location_path filesep database_location_name '_WORKING_' computer_info '.txt'];
fid=fopen(working_database_name,'r');
if fid==-1
    error(['Could not read file: ' working_database_name])
    return
end
working_str=char(fread(fid));
fclose(fid);

% Could see if you are the OPEN_STATUS
%   for example, you might have opened w/o ownership, so you should be warned again that you don't own it

%% Go through each line and compare

line_num = 0;
missmatch_lines = [];mismatch_cnt = 0;
while ~isempty(org_str) && ~isempty(working_str)
    
    clear org_current_line
    org_current_line = strtok(org_str,sprintf('\n'));
    org_str(1:length(org_current_line)+1)=[];
    
    clear working_current_line
    working_current_line = strtok(working_str,sprintf('\n'));
    working_str(1:length(working_current_line)+1)=[];
    
    line_num = line_num + 1;
    
    % if they don't match, mark it down
    if ~strcmp(org_current_line,working_current_line)
        missmatch_lines = [missmatch_lines line_num];
        mismatch_cnt = mismatch_cnt+1;
        mismatch_org{mismatch_cnt} = org_current_line';
        mismatch_working{mismatch_cnt} = working_current_line';
    end
end

%% No one messed up the orginial
if mismatch_cnt==0
    safe2save = 1;
    Write_StandardStruct2TXT(obj,database_location);
    
    % Copy current database to WORKING (do this at the end so errors won't copy over to the previous working)
    copyfile(database_location,working_database_name);

    %     % Saving the back-up file
    %     try
    %         previous_dir = pwd;
    %         current_functions_dir = fileparts(mfilename('fullpath'));
    %         cd(current_functions_dir);
    %         cd ..
    %         cd Databases/
    %         target_dir = pwd;
    %         cd(previous_dir);
    %         copyfile(database_location,[target_dir filesep database_location_name '_BACKUP.txt'],'f');
    %     end
else
    
    %% ---Some one messed up the original database!---
    
    warning('The original database was tampered with! Saving WORKING copy')
    Write_StandardStruct2TXT(obj,working_database_name);
    
    % Copy original just to be safe
    copyfile(database_location,[database_location_path filesep database_location_name '_CONFLICTED_' datestr(now,'yyyy-mm-dd_HHMM') '.txt'],'f');
    
    inspect_loop = 1;
    while inspect_loop == 1
        switch questdlg('Inspect the problem?','Conflict writing database to file','Merge the databases','Overwrite with mine (NOT RECOMMENDED)','Just give up and cry (RECOMMENDED)','Just give up and cry (RECOMMENDED)')
            case 'Merge the databases'
                warning('Merge Does not work')
                % show all mismatches
                for imis = 1:mismatch_cnt
                    disp(['ORIGINAL--> ' mismatch_org{imis}])
                    disp(['YOURS-----> ' mismatch_working{imis}])
                    disp(' ')
                    switch questdlg('Which to write to the databases?','MERGE','ORIGINAL','YOURS','ORIGINAL');
                        case 'ORIGINAL'
                            
                        case 'YOURS'
                    end
                    
                    % accept merge?
                    
                    %inspect_loop = 0;
                end
                
            case 'Overwrite with mine (NOT RECOMMENDED)'
                switch questdlg('Are you sure you want to overwrite with your copy?','Seriously?','Yes, overwrite with mine','Just Kidding','Just Kidding')
                    case 'Yes, overwrite with mine'
                        inspect_loop = 0;
                        warning('OVERWRITING ORIGINAL DATA FILE (better talk to Stephen)')
                        Write_StandardStruct2TXT(obj,database_location);
                        
                        % Copy current database to WORKING (do this at the end so errors won't copy over to the previous working)
                        copyfile(database_location,working_database_name);
                end
            case 'Just give up and cry (RECOMMENDED)'
                inspect_loop = 0;
                warning('NO NEW DATA SAVED TO FILE (Sorry about your troubles)')
        end
    end % user interface loop
end % some mismatches found


