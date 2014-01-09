function [incompleted_idx_list,completed_idx_list]=DB_Report_Property_Check(DB,property_name)
% Output a report on which entries have completed a given processing or have info filled in
% Outputs list of entry-indicies that are filled or not filled (to be used in a results analysis)
% NOTE: entry indicies will be related to the Metdata input...i.e. if you use DB.by_criteria 
%       the indicies will be related to the criteria
%
% EXAMPLE:
%   Check if you've run Mark_Events.m on all Right Grasp Attempt runs
%
%   [DB,DBbase_location,local_path,server_path]=DB_Load('meg_neurofeedback');
%   clear match_criteria
%   match_criteria.run_task_side = 'Right';
%   match_criteria.run_action = 'Grasp';
%   match_criteria.run_intention = 'Attempt';
%   match_criteria.run_type = 'Open_Loop_MEG';
% 
%   property_name = 'Preproc.Pointer_Events';
%   DB_Report_Property_Check(DB.by_criteria(match_criteria),property_name);
%
% Foldes 2013-02-27
% UPDATES:
% 2013-03-02 Foldes: now returns DB index of complete and incomplete entries
% 2013-03-06 Foldes: now report is alphabetical ordered
% 2013-08-07 Foldes: Uses DB.run_info
% 2013-09-03 Foldes: Removed criteria_struct input, use DB.by_criteria
% 2013-10-08 Foldes: Metadata-->DB

if isempty(DB)
    warning('NO ENTRIES')
end

% Sort alphabetically by entry_id so you can read it easier
entry_idx = 1:length(DB);
for ifile = 1:length(entry_idx)
    entry_id_list{ifile}=DB(entry_idx(ifile)).entry_id;
end

entry_idx=entry_idx(sort_idx(entry_id_list));

%% Check matches
empty_cnt = 0;full_cnt = 0;
completed_idx_list=[];incompleted_idx_list=[];
fprintf([property_name ':\n'])
for ientry = 1:length(entry_idx)
    clear DB_entry
    DB_entry = DB(entry_idx(ientry));
    
    eval(['empty_flag = ~isempty(DB_entry.' property_name ');'])
    
    if empty_flag
        fprintf('X-->%s [%s]\n',DB_entry.run_info,DB_entry.entry_id);
        full_cnt = full_cnt+1;
        completed_idx_list=[completed_idx_list entry_idx(ientry)];
    else
        fprintf(' -->%s [%s]\n',DB_entry.run_info,DB_entry.entry_id);
        empty_cnt = empty_cnt+1;
        incompleted_idx_list=[incompleted_idx_list entry_idx(ientry)];
    end
end
fprintf('Empty Cnt = %i | Full Cnt = %i\n',empty_cnt,full_cnt)