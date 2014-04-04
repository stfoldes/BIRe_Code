function Function_Screening = Load_Function_Screening(xls_filename,xls_sheet_name)
% Import Functional Evaluation/Screening Data from Spreadsheet
% xls_sheet_name defaults to 'Sheet1'
% Also adds or averages values to get summary data (e.g. strength data)
% Uses class FunctionalEval_Class
% Requires hard coded variable names that relate to the rows in the spreedsheet, but actual row names in spreedsheet are ignored
%
% Also see Database_Report_Field_Value_Table and Script_Report_Functional_Screening for table generation
%
% ***NOTE***
%   XLSREAD IS NOT COMPATIBLE WITH FILES SAVED IN LINUX (LIKELY MAC AS WELL)
%   REMOVE XLSREAD WITH SOMETHING BETTER.
%
% SEE: xls2struct.m (this is newer and should be used in this at a later point 2013-11-04 Foldes) 
%
% 2013-06-28 Randazzo/Foldes
% UPDATES:
% 2013-08-08 Foldes: Added 'subject_type', commented and cleaned
% 2013-09-30 Foldes: Added Injury Age and sensory levels
% 2013-11-04 Foldes: Improved row structure information

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Excel Spreadsheet Row Structure%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('xls_sheet_name') || isempty(xls_sheet_name)
    xls_sheet_name = 'Sheet1';
end

first_column = 4; % Column which the data starts on
first_row = 1; % First Row of data

% Basic Info
irow = 1;
row_names{irow} = 'subject';irow=irow+1;
row_names{irow} = 'session';irow=irow+1;
row_names{irow} = 'date';irow=irow+1;
row_names{irow} = 'OT';irow=irow+1;
row_names{irow} = 'subject_type';irow=irow+1;
row_names{irow} = 'Age';irow=irow+1;
row_names{irow} = 'Gender';irow=irow+1;
row_names{irow} = 'Veteran';irow=irow+1;
row_names{irow} = 'Ethnic';irow=irow+1;
row_names{irow} = 'Height';irow=irow+1;
row_names{irow} = 'Weight';irow=irow+1;
row_names{irow} = 'Injury_Duration';irow=irow+1;
row_names{irow} = 'Injury_Age';irow=irow+1;
row_names{irow} = '';irow=irow+1; % Now are row 14

% Finger Flex
row_names{irow} = 'Finger_Flex_LT_MMT';irow=irow+1;
row_names{irow} = 'Finger_Flex_RT_MMT';irow=irow+1;
row_names{irow} = 'Finger_Flex_RT_Strength_1';irow=irow+1;
row_names{irow} = 'Finger_Flex_RT_Strength_2';irow=irow+1;
row_names{irow} = 'Finger_Flex_RT_Strength_3';irow=irow+1;
row_names{irow} = 'Finger_Flex_RT_Strength';irow=irow+1;
row_names{irow} = 'Finger_Flex_LT_Strength_1';irow=irow+1;
row_names{irow} = 'Finger_Flex_LT_Strength_2';irow=irow+1;
row_names{irow} = 'Finger_Flex_LT_Strength_3';irow=irow+1;
row_names{irow} = 'Finger_Flex_LT_Strength';irow=irow+1;
row_names{irow} = 'Finger_Flex_RT_ROM';irow=irow+1;
row_names{irow} = 'Finger_Flex_LT_ROM';irow=irow+1;
row_names{irow} = '';irow=irow+1;

% Finger Extension
row_names{irow} = 'Finger_Ext_LT_MMT';irow=irow+1;
row_names{irow} = 'Finger_Ext_RT_MMT';irow=irow+1;
row_names{irow} = 'Finger_Ext_RT_Strength_1';irow=irow+1;
row_names{irow} = 'Finger_Ext_RT_Strength_2';irow=irow+1;
row_names{irow} = 'Finger_Ext_RT_Strength_3';irow=irow+1;
row_names{irow} = 'Finger_Ext_RT_Strength';irow=irow+1;
row_names{irow} = 'Finger_Ext_LT_Strength_1';irow=irow+1;
row_names{irow} = 'Finger_Ext_LT_Strength_2';irow=irow+1;
row_names{irow} = 'Finger_Ext_LT_Strength_3';irow=irow+1;
row_names{irow} = 'Finger_Ext_LT_Strength';irow=irow+1;
row_names{irow} = 'Finger_Ext_RT_ROM';irow=irow+1;
row_names{irow} = 'Finger_Ext_LT_ROM';irow=irow+1;
row_names{irow} = '';irow=irow+1;

% Wrist Flex
row_names{irow} = 'Wrist_Flex_LT_MMT';irow=irow+1;
row_names{irow} = 'Wrist_Flex_RT_MMT';irow=irow+1;
row_names{irow} = 'Wrist_Flex_RT_Strength_1';irow=irow+1;
row_names{irow} = 'Wrist_Flex_RT_Strength_2';irow=irow+1;
row_names{irow} = 'Wrist_Flex_RT_Strength_3';irow=irow+1;
row_names{irow} = 'Wrist_Flex_RT_Strength';irow=irow+1;
row_names{irow} = 'Wrist_Flex_LT_Strength_1';irow=irow+1;
row_names{irow} = 'Wrist_Flex_LT_Strength_2';irow=irow+1;
row_names{irow} = 'Wrist_Flex_LT_Strength_3';irow=irow+1;
row_names{irow} = 'Wrist_Flex_LT_Strength';irow=irow+1;
row_names{irow} = 'Wrist_Flex_RT_ROM';irow=irow+1;
row_names{irow} = 'Wrist_Flex_LT_ROM';irow=irow+1;
row_names{irow} = '';irow=irow+1;

% Wrist Ext
row_names{irow} = 'Wrist_Ext_LT_MMT';irow=irow+1;
row_names{irow} = 'Wrist_Ext_RT_MMT';irow=irow+1;
row_names{irow} = 'Wrist_Ext_RT_Strength_1';irow=irow+1;
row_names{irow} = 'Wrist_Ext_RT_Strength_2';irow=irow+1;
row_names{irow} = 'Wrist_Ext_RT_Strength_3';irow=irow+1;
row_names{irow} = 'Wrist_Ext_RT_Strength';irow=irow+1;
row_names{irow} = 'Wrist_Ext_LT_Strength_1';irow=irow+1;
row_names{irow} = 'Wrist_Ext_LT_Strength_2';irow=irow+1;
row_names{irow} = 'Wrist_Ext_LT_Strength_3';irow=irow+1;
row_names{irow} = 'Wrist_Ext_LT_Strength';irow=irow+1;
row_names{irow} = 'Wrist_Ext_RT_ROM';irow=irow+1;
row_names{irow} = 'Wrist_Ext_LT_ROM';irow=irow+1;
row_names{irow} = '';irow=irow+1;

% Elbow Flex
row_names{irow} = 'Elbow_Flex_LT_MMT';irow=irow+1;
row_names{irow} = 'Elbow_Flex_RT_MMT';irow=irow+1;
row_names{irow} = 'Elbow_Flex_RT_Strength_1';irow=irow+1;
row_names{irow} = 'Elbow_Flex_RT_Strength_2';irow=irow+1;
row_names{irow} = 'Elbow_Flex_RT_Strength_3';irow=irow+1;
row_names{irow} = 'Elbow_Flex_RT_Strength';irow=irow+1;
row_names{irow} = 'Elbow_Flex_LT_Strength_1';irow=irow+1;
row_names{irow} = 'Elbow_Flex_LT_Strength_2';irow=irow+1;
row_names{irow} = 'Elbow_Flex_LT_Strength_3';irow=irow+1;
row_names{irow} = 'Elbow_Flex_LT_Strength';irow=irow+1;
row_names{irow} = 'Elbow_Flex_RT_ROM';irow=irow+1;
row_names{irow} = 'Elbow_Flex_LT_ROM';irow=irow+1;
row_names{irow} = '';irow=irow+1;

% Elbow Ext
row_names{irow} = 'Elbow_Ext_LT_MMT';irow=irow+1;
row_names{irow} = 'Elbow_Ext_RT_MMT';irow=irow+1;
row_names{irow} = 'Elbow_Ext_RT_Strength_1';irow=irow+1;
row_names{irow} = 'Elbow_Ext_RT_Strength_2';irow=irow+1;
row_names{irow} = 'Elbow_Ext_RT_Strength_3';irow=irow+1;
row_names{irow} = 'Elbow_Ext_RT_Strength';irow=irow+1;
row_names{irow} = 'Elbow_Ext_LT_Strength_1';irow=irow+1;
row_names{irow} = 'Elbow_Ext_LT_Strength_2';irow=irow+1;
row_names{irow} = 'Elbow_Ext_LT_Strength_3';irow=irow+1;
row_names{irow} = 'Elbow_Ext_LT_Strength';irow=irow+1;
row_names{irow} = 'Elbow_Ext_RT_ROM';irow=irow+1;
row_names{irow} = 'Elbow_Ext_LT_ROM';irow=irow+1;
row_names{irow} = '';irow=irow+1;

% Grip
row_names{irow} = 'Grip_RT_Strength_1';irow=irow+1;
row_names{irow} = 'Grip_RT_Strength_2';irow=irow+1;
row_names{irow} = 'Grip_RT_Strength_3';irow=irow+1;
row_names{irow} = 'Grip_RT_Strength';irow=irow+1;
row_names{irow} = 'Grip_LT_Strength_1';irow=irow+1;
row_names{irow} = 'Grip_LT_Strength_2';irow=irow+1;
row_names{irow} = 'Grip_LT_Strength_3';irow=irow+1;
row_names{irow} = 'Grip_LT_Strength';irow=irow+1;
row_names{irow} = '';irow=irow+1;

% Notes
row_names{irow} = '';irow=irow+1;
row_names{irow} = 'Notes';irow=irow+1;
row_names{irow} = '';irow=irow+1;
row_names{irow} = '';irow=irow+1;

% KVIQ
row_names{irow} = '';irow=irow+1;
row_names{irow} = 'Dominant_Hand';irow=irow+1;
row_names{irow} = '';irow=irow+1;
row_names{irow} = 'Visual_Shoulder_Flex';irow=irow+1;
row_names{irow} = 'Visual_Thumb_Finger';irow=irow+1;
row_names{irow} = 'Visual_Trunk_Flex';irow=irow+1;
row_names{irow} = 'Visual_Hip_Abduction';irow=irow+1;
row_names{irow} = 'Visual_Foot_Tapping';irow=irow+1;
row_names{irow} = '';irow=irow+1;

row_names{irow} = '';irow=irow+1;
row_names{irow} = 'Kinesthetic_Shoulder_Flex';irow=irow+1;
row_names{irow} = 'Kinesthetic_Thumb_Finger';irow=irow+1;
row_names{irow} = 'Kinesthetic_Trunk_Flex';irow=irow+1;
row_names{irow} = 'Kinesthetic_Hip_Abduction';irow=irow+1;
row_names{irow} = 'Kinesthetic_Foot_Tapping';irow=irow+1;
row_names{irow} = '';irowfirst_column=irow+1;
row_names{irow} = '';irow=irow+1;

% Levels of Impairment
row_names{irow} = 'Injury_Level';irow=irow+1;
row_names{irow} = 'ASIA';irow=irow+1;
row_names{irow} = '';irow=irow+1;
row_names{irow} = 'Light_Touch_RT_C6';irow=irow+1;
row_names{irow} = 'Light_Touch_RT_C7';irow=irow+1;
row_names{irow} = 'Light_Touch_RT_C8';irow=irow+1;
row_names{irow} = 'Light_Touch_LT_C6';irow=irow+1;
row_names{irow} = 'Light_Touch_LT_C7';irow=irow+1;
row_names{irow} = 'Light_Touch_LT_C8';irow=irow+1;
row_names{irow} = 'Pin_Prick_RT_C6';irow=irow+1;
row_names{irow} = 'Pin_Prick_RT_C7';irow=irow+1;
row_names{irow} = 'Pin_Prick_RT_C8';irow=irow+1;
row_names{irow} = 'Pin_Prick_LT_C6';irow=irow+1;
row_names{irow} = 'Pin_Prick_LT_C7';irow=irow+1;
row_names{irow} = 'Pin_Prick_LT_C8';irow=irow+1;


%%
%%%%%%%%%%%%%%%%%
%Import the data%
%%%%%%%%%%%%%%%%%

% Defining the Class
Function_Screening=Function_Screening_Class;

% Reading i the Excel file
[~, ~, raw_cell] = xlsread(xls_filename,xls_sheet_name);

entry = 0;
for icol= first_column:size(raw_cell,2)
    if ~isnan(raw_cell{first_row,icol}) % if its a valid column
        entry = entry+1;
        
        %Loop to import each row
        for jrow = 1:size(row_names,2) 
            % row must be valid
            if ~strcmp(row_names{jrow},'')
                Function_Screening(entry).(row_names{jrow}) = raw_cell{jrow+(first_row-1),icol};% offset row number 2013-11-04
            end
        end
    end
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculating Averages and Totals%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mmt_task_base_names = {'Finger_Flex_RT','Finger_Flex_LT','Finger_Ext_RT','Finger_Ext_LT','Wrist_Flex_RT','Wrist_Flex_LT','Wrist_Ext_RT','Wrist_Ext_LT','Elbow_Flex_RT','Elbow_Flex_LT','Elbow_Ext_RT','Elbow_Ext_LT'};

% Manual Muscle Testing Adjustments for Calculations

for immt = 1:length(Function_Screening)
    for itasks = 1:length(mmt_task_base_names)
        if strcmp(Function_Screening(immt).([mmt_task_base_names{itasks},'_MMT']),'2-')
            Function_Screening(immt).([mmt_task_base_names{itasks},'_MMT'])=1.5;
        elseif strcmp(Function_Screening(immt).([mmt_task_base_names{itasks},'_MMT']),'2+')
            Function_Screening(immt).([mmt_task_base_names{itasks},'_MMT'])=2.5;
        elseif strcmp(Function_Screening(immt).([mmt_task_base_names{itasks},'_MMT']),'3+')
            Function_Screening(immt).([mmt_task_base_names{itasks},'_MMT'])=3.5;
        end
    end
end

% Setting the row numbers for the averages and associated tasks

task_base_names = {'Finger_Flex_RT','Finger_Flex_LT','Finger_Ext_RT','Finger_Ext_LT','Wrist_Flex_RT','Wrist_Flex_LT','Wrist_Ext_RT','Wrist_Ext_LT','Elbow_Flex_RT','Elbow_Flex_LT','Elbow_Ext_RT','Elbow_Ext_LT','Grip_RT','Grip_LT'};
num_measures=3; % assumes these measures have 3 measures to average across

for ientry= 1:size(Function_Screening,2)
    % Loop to calculate each average
    for iaverages = 1:length(task_base_names)
        clear measures
        for imeasure = 1:num_measures
            if isnumeric(Function_Screening(ientry).([task_base_names{iaverages},'_Strength_' num2str(imeasure)]))
                measures(imeasure) = Function_Screening(ientry).([task_base_names{iaverages},'_Strength_' num2str(imeasure)]);
            elseif ~strcmp(Function_Screening(ientry).([task_base_names{iaverages},'_Strength_' num2str(imeasure)]),'Error') % for N/A set to 0
                measures(imeasure) = 0;
            end
        end
        if ~strcmp(Function_Screening(ientry).([task_base_names{iaverages},'_Strength_' num2str(imeasure)]),'Error')
            Function_Screening(ientry).([task_base_names{iaverages},'_Strength']) = mean(measures); % Calculates mean
        else
            Function_Screening(ientry).([task_base_names{iaverages},'_Strength']) = 'Error'; % accounts for measurement error
        end
    end
end


% Totaling of KVIQ

task_base_names = {'Visual','Kinesthetic'};

for ientry= 1:size(Function_Screening,2) % Loop through entries
    for itotals = 1:length(task_base_names) % Loop through visual and kinesthetic
        if isnumeric(Function_Screening(ientry).([task_base_names{itotals},'_Shoulder_Flex']))
            Function_Screening(ientry).([task_base_names{itotals},'_total']) = Function_Screening(ientry).([task_base_names{itotals},'_Shoulder_Flex'])+Function_Screening(ientry).([task_base_names{itotals},'_Thumb_Finger'])+Function_Screening(ientry).([task_base_names{itotals},'_Trunk_Flex'])+Function_Screening(ientry).([task_base_names{itotals},'_Hip_Abduction'])+Function_Screening(ientry).([task_base_names{itotals},'_Foot_Tapping']);
        else
            Function_Screening(ientry).([task_base_names{itotals},'_total']) = '-'; % Setting to '-' if not required
        end
    end
    Function_Screening(ientry).KVIQ_total = Function_Screening(ientry).Kinesthetic_total + Function_Screening(ientry).Visual_total; % Calculates total
end

% Hand Sensory Ability
for ientry= 1:size(Function_Screening,2) % Loop through entries
    Function_Screening(ientry).SensoryHand_RT = mean([Function_Screening(ientry).Light_Touch_RT_C6 Function_Screening(ientry).Light_Touch_RT_C7 Function_Screening(ientry).Light_Touch_RT_C8 ...
        Function_Screening(ientry).Pin_Prick_RT_C6 Function_Screening(ientry).Pin_Prick_RT_C7 Function_Screening(ientry).Pin_Prick_RT_C8]);
    Function_Screening(ientry).SensoryHand_LT = mean([Function_Screening(ientry).Light_Touch_LT_C6 Function_Screening(ientry).Light_Touch_LT_C7 Function_Screening(ientry).Light_Touch_LT_C8 ...
        Function_Screening(ientry).Pin_Prick_LT_C6 Function_Screening(ientry).Pin_Prick_LT_C7 Function_Screening(ientry).Pin_Prick_LT_C8]);
end


