function [missing_list,exist_list,old_list]=DB_Report_Pointer_Check(DB,pointer_name,date_check)
% Output a report on pointer-files. Checks that they exist on the server_path and aren't too old [OPTIONAL]
% Outputs list of entry-indicies that are missing or exist .
% NOTE: entry indicies will be related to the Metdata input...i.e. if you use DB.by_criteria 
%       the indicies will be related to the criteria
% Can check if the pointer files are old using date_check (format = 'yyyy-mm-dd')
%
% EXAMPLE:
%  Find the list of entries whose bad channel files are either nonexistant or are too old (2013-08-20) so you can redo them
%     [DB,DBbase_location,local_path,server_path]=DB_Load('meg_neurofeedback');
% 
%     criteria.run_type = 'Open_Loop_MEG';
%     criteria.run_task_side = 'Left';
%     criteria.run_action = 'Grasp';
%     MeDa_short = DB.by_criteria(criteria);
% 
%     pointer_name = 'prebadchan';
%     [missing_list,exist_list,old_list]=DB_Report_Pointer_Check(MeDa_short,pointer_name,'2013-08-20');
%     needed_list = sort([missing_list old_list]);
% 
%     % An entry that needs to be done
%     MeDa_short(needed_list(ientry));
%
% SEE: DB_Load_Pointer_Data DB_Report_Property_Check DB_Script_AutoFillFields
%
% Foldes 2013-09-04
% UPDATES:
% 2013-10-15 Foldes: Metadata --> DB


if ~exist('date_check') || isempty(date_check)
    date_check = '2011-01-01'; % DEFAULT = begining of time itself
end

date_check_num = datenum(date_check,'yyyy-mm-dd');

% Sort alphabetically by entry_id so you can read it easier
entry_idx_list = 1:length(DB);
for ifile = 1:length(entry_idx_list)
    entry_id_list{ifile}=DB(entry_idx_list(ifile)).entry_id;
end
entry_idx_list=entry_idx_list(sort_idx(entry_id_list));

%%

exist_list = [];
fail_list = [];
old_list = [];
missing_list = [];
% undocumented_list = [];

ientry = 1;
for ientry = 1:length(entry_idx_list)
    
    DB_entry = DB(entry_idx_list(ientry));
%     disp(' ')
%     disp(['==================File #' num2str(ientry) '/' num2str(length(entry_idx_list)) ' | ' DB_entry.entry_id '================='])
    try
        exist_flag = 0;
        old_flag = 0;
        
        %% Check processed_data_for_events
        if ~isempty(DB_entry.Preproc.(['Pointer_' pointer_name])) % Are you written?
            pointer_file_name = DB_entry.Preproc.(['Pointer_' pointer_name]);
            
            % Check if file exists
            if exist([DB_entry.file_path('server') filesep pointer_file_name])==2
                exist_flag = 1;
                exist_list = [exist_list entry_idx_list(ientry)];
                [file_date,file_date_num] = date_file_timestamp([DB_entry.file_path('server') filesep pointer_file_name]);
                % Check that the file isn't too old
                if file_date_num < date_check_num
                    old_flag = 1;
                    old_list = [old_list entry_idx_list(ientry)];
                end
                
            else % file is supposed to exist, but doesn't
                missing_list = [missing_list entry_idx_list(ientry)];
            end
        else % No pointer written to database
            %             pointer_file_name = DB_entry.Preproc.(['Pointer_' pointer_name]);
            %
            %             pointer_file_name = [DB_entry.entry_id '_' pointer_name '.mat'];
            %             if exist([DB_entry.file_path('server') filesep pointer_file_name])==2 % Check if file exist under the name listed
            %                 undocumented_list = [undocumented entry_idx_list(ientry)];
            %             else
            fail_list = [fail_list entry_idx_list(ientry)];
            %             end
        end
        
        if exist_flag
            if old_flag
                fprintf('X-->%s [%s] <---OLD\n',DB_entry.run_info,DB_entry.entry_id);
            else
                fprintf('X-->%s [%s]\n',DB_entry.run_info,DB_entry.entry_id);
            end
        else
            fprintf(' -->%s [%s]\n',DB_entry.run_info,DB_entry.entry_id);
        end
        
    end % try
end % entry

missing_list = sort([missing_list fail_list]); % its missing if it failed

fprintf('Missing Cnt = %i | Exist Cnt = %i (Old Cnt = %i)\n',length(missing_list),length(exist_list),length(old_list))

%% Differnt way to display report

% 
% % Processed
% % disp('---Processed---')
% % disp(' ')
% % clear current_list
% % current_list = exist_list;
% % for ientry = 1:length(current_list)
% %     DB_entry = DB(current_list(ientry));
% %     disp(['OKAY: ' DB_entry.run_info ' ' DB_entry.entry_id])
% % end
% clear current_list
% current_list = fail_list;
% for ientry = 1:length(current_list)
%     DB_entry = DB(current_list(ientry));
%     disp(['FAILED: ' DB_entry.run_info ' ' DB_entry.entry_id])
% end
% clear current_list
% current_list = missing_list;
% for ientry = 1:length(current_list)
%     DB_entry = DB(current_list(ientry));
%     disp(['MISSING FILE: ' DB_entry.run_info ' ' DB_entry.entry_id])
% end
% clear current_list
% current_list = old_list;
% for ientry = 1:length(current_list)
%     DB_entry = DB(current_list(ientry));
%     disp(['OLD: ' DB_entry.run_info ' ' DB_entry.entry_id])
% end
% % clear current_list
% % current_list = undocumented_list;
% % for ientry = 1:length(current_list)
% %     DB_entry = DB(current_list(ientry));
% %     disp(['MISSING IN DB: ' DB_entry.run_info ' ' DB_entry.entry_id])
% % end