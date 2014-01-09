function data = xls2struct(xls_filename,row_names,varargin)% xls_sheet_name,first_column,first_row% Load data from an xls spread sheet into a structure
% function data = xls2struct(xls_filename,row_names,varargin)% xls_sheet_name,first_column,first_row
% XLS sheet needs to be columns = subjects, rows = info
% 
% ***NOTE***
%   XLSREAD IS NOT COMPATIBLE WITH FILES SAVED IN LINUX (LIKELY MAC AS WELL)
%   REMOVE XLSREAD WITH SOMETHING BETTER.
%
% SEE: Load_Function_Screening.m
%
% 2013-11-04 Foldes
% UPDATES
%
% EXAMPLE:
% %% INFO
% xls_filename='/home/foldes/Desktop/SFN2013/fMRI_Cutaneous_vs_Motor.xls';
% xls_sheet_name='Foldes20131101ROI';
% 
% first_column = 4; % Column which the data starts on
% first_row = 2; % First Row of data
% 
% % Basic Info
% irow = 1;
% row_names{irow} = 'subject';irow=irow+1;
% row_names{irow} = 'group';irow=irow+1;
% row_names{irow} = 'handedness';irow=irow+1;
% % Cuteneous
% row_names{irow} = 'cu_peakT';irow=irow+1;
% row_names{irow} = 'cu_meanT';irow=irow+1;
% row_names{irow} = 'cu_stdT';irow=irow+1;
% row_names{irow} = 'cu_p_value';irow=irow+1;
% row_names{irow} = 'cu_peak_loc_x';irow=irow+1;
% row_names{irow} = 'cu_peak_loc_y';irow=irow+1;
% row_names{irow} = 'cu_peak_loc_z';irow=irow+1;
% row_names{irow} = 'cu_cluster_size';irow=irow+1;
% row_names{irow} = 'cu_num_clusters';irow=irow+1;
% row_names{irow} = 'cu_notes';irow=irow+1;
% row_names{irow} = '';irow=irow+1;
% % Imitate
% row_names{irow} = 'im_peakT';irow=irow+1;
% row_names{irow} = 'im_meanT';irow=irow+1;
% row_names{irow} = 'im_stdT';irow=irow+1;
% row_names{irow} = 'im_p_value';irow=irow+1;
% row_names{irow} = 'im_peak_loc_x';irow=irow+1;
% row_names{irow} = 'im_peak_loc_y';irow=irow+1;
% row_names{irow} = 'im_peak_loc_z';irow=irow+1;
% row_names{irow} = 'im_cluster_size';irow=irow+1;
% row_names{irow} = 'im_num_clusters';irow=irow+1;
% row_names{irow} = 'im_notes';irow=irow+1;
% row_names{irow} = '';irow=irow+1; % this might be needed
%
% 
% data = xls2struct(xls_filename,row_names,...
%   'xls_sheet_name',xls_sheet_name,'first_column',first_column,'first_row',first_row);

%% Defaults

defaults.xls_sheet_name =   [];
defaults.first_column =     1;
defaults.first_row =        1;
parms = varargin_extraction(defaults,varargin);

if isempty(parms.xls_sheet_name)
    parms.xls_sheet_name = 'Sheet1';
end


%% Process

% Reading i the Excel file
[~, ~, raw_cell] = xlsread(xls_filename,parms.xls_sheet_name);

% Organize
clear data
entry = 0;
for icol= parms.first_column:size(raw_cell,2)
    if ~isnan(raw_cell{parms.first_row,icol}) % if its a valid column
        entry = entry+1;
        
        %Loop to import each row
        for jrow = 1:size(row_names,2)
            % row must be valid
            if ~strcmp(row_names{jrow},'')
                data(entry).(row_names{jrow}) = raw_cell{jrow+(parms.first_row-1),icol}; % offset row number
            end
        end
    end
end
