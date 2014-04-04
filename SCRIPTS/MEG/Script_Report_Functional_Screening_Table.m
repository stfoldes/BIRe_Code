% Script to set parameters for the table generator function
% Uses Database_Report_Field_Value_Table and Load_Function_Screening
%
% Randazzo 2013-07-02
% UPDATES:
% 2013-08-08 Foldes: Cleaning (i is not a counter!!!), Scatter plot now a separate function
%%

clear

%% Load Screening Data
% Set where functional database is located
functional_file = '\\192.168.1.4\data\experiments\meg_neurofeedback\Functional_Assessment_Info\Neurofeedback_Function_Screening.xls';
% Runs functional screening database
screening = Load_Function_Screening(functional_file);

%% Make a table
% Set output table name
output_table_name = 'function_table.txt';

% Specify parameters displayed on table
column_names = {'subject','session','Grip_RT_Strength'};

% Specify match criteria based on parameters
match_criteria.session = 'Baseline';

% Compatible with Database_Report_Field_Value_Table
Database_Report_Field_Value_Table(screening,column_names,match_criteria,output_table_name);

% Opens output text file
open(output_table_name)


%% Scatter plot of two fields (must be numbers)
fig = figure;hold all

% Get entries that match the criteria
match_criteria.session = 'Baseline';
match_criteria.subject_type = 'SCI';
clear current_DB
current_DB = screening(Metadata_Find_Entries_By_Criteria(screening,match_criteria));

Database_Plot_Fields_ScatterPlot(current_DB,'Age','Grip_RT_Strength','r',fig);

match_criteria.session = 'Baseline';
match_criteria.subject_type = 'AB';
clear current_DB
current_DB = screening(Metadata_Find_Entries_By_Criteria(screening,match_criteria));

Database_Plot_Fields_ScatterPlot(current_DB,'Age','Grip_RT_Strength','k',fig);

legend('SCI','AB')

%%