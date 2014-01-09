function Database_Report_Field_Value_Table(database,column_names,match_criteria,table_file_name)
% Generates a table from database info based on specifications set by user
% Can be used for any X.Y type structure or object
%
% column_names = string-cell array of fields/members of column titles
% match_criteria = a way to limit how much of the database to use in table, see Metadata_Find_Entries_By_Criteria.m
%
% EXAMPLE:
%     functional_file = 'C:/Users/hrnel/Documents/test.xlsx';
%     % Runs functional screening database
%     screening = Load_Function_Screening(functional_file);
%
%     table_file_name = 'function_table.txt';
%     column_names = {'subject','session','Grip_RT_Strength'};
%     % Specify inclusion criteria
%     match_criteria.session = 'Baseline';
%     Database_Report_Field_Value_Table(screening,column_names,match_criteria,table_file_name);
%
% Randazzo 2013-07-01
% Updates:
% 2013-08-08 Foldes: Commented and cleaned! Renamed from Report_Database_as_Table

%%
%%%%%%%%%%%%%%
%File Writing%
%%%%%%%%%%%%%%

% Running Metadata_find
% entry_idx = Metadata_find_idx(database,input_field,match_criteria);
entry_idx = Metadata_Find_Entries_By_Criteria(database,match_criteria);

% Opens file
FID = fopen(table_file_name,'w');

% Prints out headings
for iparameters = 1:length(column_names)
    fprintf(FID,'%s\t',column_names{iparameters});
end
fprintf(FID,'\n');

% Prints out entries
for iindex = 1:length(entry_idx)
    for iparameters = 1:length(column_names)
        fprintf(FID,'%s\t ',num2str(database(entry_idx(iindex)).(column_names{iparameters}))); % Prints each value
    end
    fprintf(FID,'\n');
end

fclose(FID);
