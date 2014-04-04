function link_str = OverlayFile_str(obj)
% Just FIND the OverlayFile input string for view_surface_data.m
% link must already in db to use
% EXAMPLE: link|Subject01_copy/1/results_wMNE_MEG_GRAD_KERNEL_140124_1807.mat|Subject01_copy/1/data_1_average_140128_1525.mat
%
% SEE: 
% 2014-02-03 Foldes
% UPDATES:
% 2014-02-15 Foldes: object
% 2014-02-17 Foldes: This was redone to use BST functions


% Get BST info about this subject and condition
StudyInfo = bst_get('StudyWithCondition', [obj.subject filesep obj.condition]) ;
if isempty(StudyInfo)
    link_str = [];
    warning('YOU MIGHT HAVE SPELLED SOMETHING WRONG')
    return;
end

% stimulus name can be used to narrow down search
if isempty(obj.eventname) 
    obj.eventname = '*';
end

% Search through Results for all entries with 'average'
matching_results_idx = DB_find_idx(StudyInfo.Result,'FileName',['*' obj.eventname '_average*']);

if length(matching_results_idx)>1
    error('More than one AVG file found. This is not supported yet. But is easy')
end

link_str = StudyInfo.Result(matching_results_idx).FileName;

% OLD WAY; THIS WAS BUILDING THE LINK MANUALLY
% % Search for file (ASSUMES ONLY ONE FILE THAT MATCH THIS CRITERA; easy to update later)
% inverse_fullfile = cell2mat(search_dir(fullfile(obj.protocol_data_path,obj.subject,obj.condition),['results_' obj.inverse_method '*']));
% [~,inverse_file] = fileparts(inverse_fullfile); % get just the file name
%     
% % StudyInfo.Result(matching_results_idx).FileName
% % Search for file (ASSUMES ONLY ONE FILE THAT MATCH THIS CRITERA; easy to update later)
% average_fullfile = cell2mat(search_dir(fullfile(obj.protocol_data_path,obj.subject,obj.condition),['data_' obj.condition '_average_' '*']));
% [~,average_file] = fileparts(average_fullfile); % get just the file name
% 
% % Construct the text that goes in the OverlayFile input of view_surface_data.m
% link_str =   ['link|' ...
%     obj.subject filesep obj.condition filesep inverse_file '.mat|' ...
%     obj.subject filesep obj.condition filesep average_file '.mat'];
