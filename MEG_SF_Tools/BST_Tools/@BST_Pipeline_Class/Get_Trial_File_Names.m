function sFiles = Get_Trial_File_Names(obj)
% Find file list of the data_*_trial#.mat format
%     sFiles = Get_Trial_File_Names(obj);
%
% 2014-02-17 Foldes

% Get file info
[StudyInfo, iStudy] = bst_get('StudyWithCondition', fullfile(obj.subject,obj.condition));
if isempty(StudyInfo)
    sFiles = [];
    return;
end

% Get all the data files from conditions
all_data_files = {StudyInfo.Data.FileName}; % 2014-03-25

% Get the trial numbers that are avalible
trials_avalible = [];
for ifiles = 1:length(all_data_files)
    [~,current_file] = fileparts(all_data_files{ifiles});
    if strcmp(current_file(1:end-3),['data_' obj.eventname '_trial']) % MUST BE THIS FORMAT
        trials_avalible = [trials_avalible str2num(current_file(end-2:end))];
    end
end

% if you want all, or didn't specify, use all trials
if isempty(obj.trial_list) || strcmpi(obj.trial_list,'all')
    obj.trial_list = trials_avalible;
end
obj.trial_list = find_lists_overlap_idx(trials_avalible,obj.trial_list);

% Define files for avg
sFiles = all_data_files(obj.trial_list);