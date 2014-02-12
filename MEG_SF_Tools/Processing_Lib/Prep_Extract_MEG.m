function [Extract,fif_file] = Prep_Extract_MEG(Extract)
% Populates Extract using fif file. Also returns fif info (fiff_setup_read_raw)
% Has guis and stuff to help guide
% Figures out file names, paths, etc., even checks that it exists
% Determines sampling rate from fif file
%
% EXAMPLE OF MINIMUM Extract. struct
%     Extract.full_file_name =  '/home/foldes/Data/MEG/Test/TEST_movementcue_timing_w_photodiode.fif';
%   OR
%     Extract.file_name{1} =    'BMI01s01r011';
%     Extract.file_path =       'C:\Data\MEG\BMI01\20111130\';
%     Extract.file_extension =  []; % assumes .fif, can put whatever
%   OR
%     Extract = []; % if no file info, use gui
%
% OPTIONAL:
%     Extract.decimation_factor:    decimates (downsample)
%     Extract.channel_list:         list MEG sensor numbers to extract
%     ?Extract.filter_stop:         stopband freq [58 62] for 60Hz removal
%     ?Extract.filter_bandpas:      bandpass freq [4 200]
%
% 2014-01-23 Foldes
% UPDATES:
%

% can just put in file name
if ~isstruct(Extract)
    temp = Extract;
    clear Extract
    Extract.full_file_name = temp;
end

% GUI for file if not given
if ~isfield(Extract,'full_file_name') && ~isfield(Extract,'file_name')
    [FileName,PathName] = uigetfile('*.fif','Select file to load','/home/foldes/Data/MEG'); % default for Stephen, but won't hurt anything
    Extract.full_file_name = [PathName filesep FileName];
end

% If full file name doesn't exist, make it, if it does exist, use it
if ~isfield(Extract,'full_file_name')
    Extract.full_file_name = [Extract.file_path filesep Extract.file_name Extract.file_extension];
else % .full_file_name exists, so use it (trumps .file_name, etc)
    [Extract.file_path Extract.file_name Extract.file_extension] = fileparts(Extract.full_file_name);
end

% Check that the file exists, if it doesn't try upper/lower case
Extract.file_name = filename_caseinsensitive(Extract.file_name,Extract.file_path);
% write new spelling to full_file_name
Extract.full_file_name = [Extract.file_path filesep Extract.file_name Extract.file_extension];

if isempty(Extract.full_file_name)
    errordlg(['CAN NOT FIND FILE. CHECK PATHS AND SPELLING'],'Data File Not Found')
end

% Load .FIF parameters
clear fif_file
fif_file = fiff_setup_read_raw(Extract.full_file_name);
Extract.base_sample_rate = fif_file.info.sfreq; % get sampling rate from file 2013-11-21

Extract = populate_field_with_default(Extract,'decimation_factor',1);

Extract.data_rate = Extract.base_sample_rate/Extract.decimation_factor;










