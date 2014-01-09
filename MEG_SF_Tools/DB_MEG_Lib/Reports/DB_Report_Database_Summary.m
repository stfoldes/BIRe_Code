% Metadata_Report_Database_Summary(Metadata,level[OPTION],output_file[OPTIONAL]);
% 
% Write a summary of what data is in the database Metadata
%   "Metadata" can be the whole data base or a subset (see an example below)
% "level" input [optional] is: 
%     'subject' - displays all subject in database
%     'session' - display all subjects and their session numbers
%     'run'[default] -  displays subjects, sessions, and run information
%     This requires a hierarchical structure of 
%       subject
%           session
%               run
% output_file [OPTIONAL]: file (w/ path) to store this report. 
%   If empty or missing this will just print to screen
% 
% EXAMPLE 1:
% Write to file all subject, session, and run information to a file
% server_path = '/home/foldes/Desktop/Katz/experiments/meg_neurofeedback/';
% metadatabase_location=[server_path filesep 'Neurofeedback_metadatabase.txt'];
% % Load Metadata from text file
% Metadata = Metadata_Class();
% Metadata = Load_StandardStruct_from_TXT(Metadata,metadatabase_location);
% Metadata_Report_Database_Summary(Metadata,'run',[metadatabase_location '_REPORT.txt'])
%
% EXAMPLE 2:
%   Give a summary of data from subject NS06
%   Metadata_Report_Database_Summary(Metadata(Metadata_find_idx(Metadata,'subject','NS06')));
% 
% Foldes [2012-09-24]
% UPDATES:
% 2013-02-27 Foldes: Now writes to file, works with Metadata_Class, renamed from Metadata_disp_summary. (Major overhaul)

function Metadata_Report_Database_Summary(Metadata,level,output_file)

% default level of 'run' (i.e. deepest)
if ~exist('level') || isempty(level)
    level = 'run';
end

if exist('output_file') && ~isempty(output_file)
    output_fileID=fopen(output_file,'w');
else
    output_fileID = 1;
end

%%

fprintf(output_fileID,'Report Time Stamp: %s\n',datestr(now,'yyyy-mm-dd'));

% Show date of most recent entry
date_list = Metadata_lookup_unique_entries(Metadata,'date');
[~,date_max_idx]=max(datenum(cell2mat(date_list'),'yyyymmdd'));
fprintf(output_fileID,['Most recent session: ' date_list{date_max_idx}(1:4) '-' date_list{date_max_idx}(5:6) '-' date_list{date_max_idx}(7:8) '\n\n']);

% Find all subject ids
subject_list = Metadata_lookup_unique_entries(Metadata,'subject');

for isubject = 1:length(subject_list)
    
    % Looking for sessions per subject
    entry_list = Metadata_find_idx(Metadata,'subject',subject_list{isubject});
    fprintf(output_fileID,[subject_list{isubject} '\n']);
    
    if ~strcmp(level,'subject') % if you're asking for something deeper than subject
        
        % get all sessions for this subject, but only show unique entries
        clear session_list_by_subject_all
        for ientry = 1:length(entry_list)
            session_list_by_subject_all{ientry} = Metadata(entry_list(ientry)).session;
        end
        session_list_by_subject=unique(session_list_by_subject_all);
        
        for isession=1:size(session_list_by_subject,2)
            fprintf(output_fileID,['     S' session_list_by_subject{isession} '\n']);
            
            if ~strcmp(level,'session') % if you're asking for something deeper than session
                metadata_criteria_struct.subject = subject_list{isubject};
                metadata_criteria_struct.session = session_list_by_subject{isession};
                run_list = Metadata_Find_Entries_By_Criteria(Metadata,metadata_criteria_struct);
                
                for irun = 1:length(run_list)
                    fprintf(output_fileID,['          R' num2str(Metadata(run_list(irun)).run) ': ' Metadata(run_list(irun)).run_type ' [' Metadata(run_list(irun)).run_action ' ' Metadata(run_list(irun)).run_intention ' ' Metadata(run_list(irun)).run_task_side ']\n']);
                end
                
            end % disp subject and session only
            
        end % go thru sessions
        
    end % disp subject only
    
end

if exist('output_file') && ~isempty(output_file)
    fclose(output_fileID);
    open(output_file);
    disp(['Wrote summary report--> ' output_file])
end

