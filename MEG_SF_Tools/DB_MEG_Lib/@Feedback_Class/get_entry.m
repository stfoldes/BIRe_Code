function [entries,entry_idx] = get_entry(DB,varargin)
% This will search the DB-base for files that match the varargin.
% WARNING: SAVE FUNTIONS WILL REQUIRE THE WHOLE DB BE MANIPULATED. 
%     EITHER USE entry_idx OR .update_entry IF YOU WANT TO SAVE THE DB EVENTUALLY
%
% Uses DB_Find_Entries_By_Criteria
%
% VARARGIN OPTIONS:
%     1. List of field-name followed by value; 'field name','search criteria',... just look at the example
%     2. entry_id --> quick way to look up a file based on its unique identifier (entry_id)
%     3. match criteria struct and remove criteria --> Works as a wrapper for DB_Find_Entries_By_Criteria
%     4. only input the database --> GUI to select file which will be parsed to find a match
%     
%
% EXAMPLES:
%     Extract the entry for NC01 RT Grasp Imitate (Open Loop)
%       entry = get(DB,'subject','NC01','run_type','Open_Loop_MEG','run_action','Grasp','run_task_side','Right','run_intention','Imitate');
%     OR
%       entry = get(DB,'nc01s01r03');
%     OR (run_info is subject_action_side_intention order)
%       entry = get(DB,'run_info','NC01_Grasp_Right_Imitate');
%
%     Entry numbers that are subject (NC01 AND Imitate) OR (NC01 AND Attempt)
%       entry_idx_list = get(DB,'subject','NC01','run_intention',{'Imitate','Attempt'})'
%
% SEE: DB_Find_Entries_By_Criteria
%
% 2013-08-15 Foldes
% UPDATES:
% 2013-09-03 Foldes: Now can use a remove_criteria
% 2013-10-03 Foldes: Renamed from Database_Get_Entry, Metadata-->DB


%% 1 Input to function (i.e. DB only) = let the user pick
if nargin==1
    % User selects MEG file to quick check
    [file_name_full, file_path] = uigetfile('*','Select file for base-name look up');
    file_name_full_w_path=[file_path file_name_full];
    [file_path,entry_id,file_type]=fileparts(file_name_full_w_path);
    
    % Look for an entry for this file
    entry_idx = DB_find_idx(DB,'entry_id',entry_id);
    
    
    
%% 2 Inputs to function, 2nd input is = A) a criteria stuct, *OR* B) super-secret entry_id
elseif nargin == 2 %
    
    if ischar(varargin{1})
        entry_idx = DB_find_idx(DB,'entry_id',varargin{1});
    elseif isstruct(varargin{1})
        entry_idx = DB_Find_Entries_By_Criteria(DB,varargin{1});
    end
    
%% 3 or more Inputs to function = A) match criteria AND remove criteria, *OR* B) parse out the varargin w/ "field name","match value"
else
    if isstruct(varargin{1}) && isstruct(varargin{2})
        entry_idx = DB_Find_Entries_By_Criteria(DB,varargin{1},varargin{2});
    else
        % turn varargin into a structure and get field names
        varargin_struct = cell2struct(varargin(2:2:end),varargin(1:2:end),2);
        varar_fields = fieldnames_all(varargin_struct);
        
        % go through each input field and add value
        for ifields = 1:size(varar_fields,1)
            current_field = cell2mat(varar_fields(ifields));
            criteria_struct.(current_field) = varargin_struct.(current_field);
        end
        
        entry_idx = DB_Find_Entries_By_Criteria(DB,criteria_struct);
    end
end


%% Get the entries

if ~isempty(entry_idx)
    for ientry = 1:length(entry_idx)
        entries(ientry) = DB(entry_idx(ientry));
    end
else
    entries=[];
end
