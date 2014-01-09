% Gets a list of files that need MaxFiltering or Bad Channels Marked
% SEE: MaxFilter_Run_Batch_via_ssh.sh, Mark_Bad_MEG.m
%
% SHOULD RUN SCRIPT_AutoFillFields first, but it takes a long time
% Will display a bunch of stuff
%
% 2013-09-05 Foldes
% UPDATES:
% 2013-09-12 Foldes: now tells which files need marking as well
% 2013-10-17 Foldes: Metadata-->DB

% % Fill in standard stuff to fill in Preproc.bad_chan_list **TAKES A LONG TIME**
% SCRIPT_AutoFillFields;


% clear

clear criteria
criteria.run_type = 'Open_Loop_MEG';
criteria.run_task_side = 'Right';
criteria.run_action = 'Grasp';

% Build database
if ~exist('DB','var')
    DB=DB_MEG_Class;
    DB=DB.build('PATHS_meg_neurofeedback'); % also sets global MY_PATHS
end

% Chooses the approprate entries
DB_short = DB.get_entry(criteria);


% Find entries that have bad channels marked and are fresher than 2013-08-20
pointer_name = 'prebadchan';
% [missing_list,exist_list,old_list]=DB_Report_Pointer_Check(DB_short,pointer_name,'2013-08-20');
[missing_list,exist_list,old_list]=DB_Report_Pointer_Check(DB_short,pointer_name);
marking_good   = sort(remove_list_from_list(exist_list,old_list));
marking_needed = sort([missing_list, old_list]);

% Find entries that DON'T have SSS run.
[incompleted_idx_list,completed_idx_list]=DB_Report_Property_Check(DB_short,'Preproc.bad_chan_list');

% Entries that have bad channels mark (recently) AND don't have SSS already done (using Preproc.bad_chan_list as a proxy)
entries2SSS = incompleted_idx_list(find_lists_overlap_idx(incompleted_idx_list,marking_good));


%% DISPLAY

disp(' ')
disp(['***MARK THESE ' num2str(length(marking_needed)) ' FILES (Mark_Bad_MEG.m)***'])
for ientry = 1:length(marking_needed)
    fprintf('%s ',DB_short(marking_needed(ientry)).entry_id)
end
fprintf('\n')


disp(' ')
disp(['***RUN MAXFILTER ON THESE ' num2str(length(entries2SSS)) ' FILES (MaxFilter_Run_Batch_via_ssh.sh)***'])
for ientry = 1:length(entries2SSS)
    fprintf('%s ',DB_short(entries2SSS(ientry)).entry_id)
end
fprintf('\n')