function match_entry_idx = DB_Find_Entries_By_Criteria(DB,match_criteria,remove_criteria)
% This will search the DB-base for files that match the criteria structure.
% File numbers returned satisfy all match-criteria fields BUT NOT remove-criteria fields
%
% Multiple criteria per field are considered multiple posibilities, i.e. all cell entries in one field are ORed, while each field is ANDed
% An empty [] critera will return all entry numbers.
% Useful to loop through differnt files
% See DB_Class for field options
%
% Example:
%   Return all entry indices for NC01 Right Grasp BUT NOT for the Observe condition
%       match_criteria.subject = 'NC01';
%       match_criteria.run_task_side = 'Right';
%       match_criteria.action = 'Grasp';
%       remove_criteria.run_intention = 'Observe';
%
%   match_entry_idx = DB_Find_Entries_By_Criteria(DB,match_criteria,remove_criteria);
%
% SEE: DB.by_criteria, Database_Get_Entry, DB_Class
%
% Stephen Foldes [2012-09-05]
% UPDATES:
% 2012-09-21 Foldes: Fixed to work with mix of cells and non-cells. Switched OR and And around for more efficient/smarter code.
% 2012-10-02 Foldes: An empty critera will return all entry numbers
% 2012-10-03 Foldes: Fixed bug for multi-cell entries
% 2013-09-03 Foldes: Now includes remove-criteria option, cleaned

%% DEFAULTS

% if you don't give a match_criteria, just return ALL entries
if isempty(match_criteria)
    match_entry_idx=1:length(DB);
    return
end

if ~exist('remove_criteria')
    remove_criteria = [];
end

%% Find matches to all match-criteria

% Go through all DB criterias
match_criteria_list = fields(match_criteria);
num_criteria_fields = size(match_criteria_list,1);

for icriteria_field=1:num_criteria_fields
    current_criteria_field_str = char(cell2mat(match_criteria_list(icriteria_field)));
    
    % Mulitiple critera per field within a cell will be ORed
    if iscell(match_criteria.(current_criteria_field_str)) % cells can have more the one entry per criteria field
        
        num_subcriteria_in_this_field = size(match_criteria.(current_criteria_field_str),2);
        clear oring_subcriteria_list
        for isubcriteria=1:num_subcriteria_in_this_field
            oring_subcriteria_list(isubcriteria,:)=DB_find(DB,current_criteria_field_str,match_criteria.(current_criteria_field_str){isubcriteria});
        end
        match_mask(icriteria_field,:)=max(oring_subcriteria_list,[],1);
        
    else % only one critera (criterium?) so just look for that (i.e. no need to OR)
        match_mask(icriteria_field,:)=DB_find(DB,current_criteria_field_str,match_criteria.(current_criteria_field_str));
    end
end

% This is the file that fits the criterias listed
match_entry_idx=find(sum(match_mask,1)==num_criteria_fields);


%% Now remove indicies that are being ask to remove

if ~isempty(remove_criteria)   
    remove_criteria_list = fields(remove_criteria);
    num_criteria_fields = size(remove_criteria_list,1);
    
    for icriteria_field=1:num_criteria_fields
        current_criteria_field_str = char(cell2mat(remove_criteria_list(icriteria_field)));
        
        % Mulitiple critera per field within a cell will be ORed
        if iscell(remove_criteria.(current_criteria_field_str)) % cells can have more the one entry per criteria field
            
            num_subcriteria_in_this_field = size(remove_criteria.(current_criteria_field_str),2);
            clear oring_subcriteria_list
            for isubcriteria=1:num_subcriteria_in_this_field
                oring_subcriteria_list(isubcriteria,:)=DB_find(DB,current_criteria_field_str,remove_criteria.(current_criteria_field_str){isubcriteria});
            end
            remove_mask(icriteria_field,:)=max(oring_subcriteria_list,[],1);
            
        else % only one critera (criterium?) so just look for that (i.e. no need to OR)
            remove_mask(icriteria_field,:)=DB_find(DB,current_criteria_field_str,remove_criteria.(current_criteria_field_str));
        end
    end
    
    % File idx of those that have at least 1 remove criteria match
    remove_entry_idx=find(sum(remove_mask,1)>0);
    
    % Remove files from match list
    match_entry_idx(find_lists_overlap_idx(match_entry_idx,remove_entry_idx)) = [];
    
end % remove


%%

if isempty(match_entry_idx)
    disp('@DB_Find_Files_By_Criteria: NO FILE FITS CRITERIA')
else
    %         disp([num2str(length(match_entry_idx)) ' files fit criteria.'])
end

