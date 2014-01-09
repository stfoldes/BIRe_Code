function [data,FIF_timeS,chan_str_list,Extract] =  Load_from_FIF(Extract,chan_type)
% This code extracts data from FIF files for given chan_type
%   chan_type = 'MEG','STI','MISC','EMG','EOG'
%
% Input can be Extract stucture OR full file name
%
% Scales MEG data by 10^13,
% STI101 is the only STI channel returned currently
% Extract.(full_)file_name can be a single file or a cell of many files to combine (NOT WORKING 2013-12-06)
%
% EXAMPLE OF MINIMUM Extract. struct
%     Extract.full_file_name = '/home/foldes/Data/MEG/Test/TEST_movementcue_timing_w_photodiode.fif';
%   OR
%     Extract.file_name{1}='BMI01s01r011';
%     Extract.file_path='C:\Data\MEG\BMI01\20111130\';
%     Extract.file_extension = []; % assumes .fif, can put whatever
%   OR
%     Extract = []; % if no file info, use gui
%
% OPTIONAL:
%     Extract.decimation_factor:    decimates (downsample)
%     Extract.channel_list:         list MEG sensor numbers to extract
%     Extract.filter_stop:          stopband freq [58 62] for 60Hz removal
%     Extract.filter_bandpas:       bandpass freq [4 200]
%
% OUTPUTS:
%     data [samples x channels]
%     FIF_timeS [samples x 1]: time in seconds
%     chan_str_list [num_chan x 7]: string for channel name (e.g. MEG2641)
%
%
% Stephen Foldes (2013-04-05 branched from 2011-02-23 version)
% UPDATES
% 2013-04-05 Foldes: Consolidated ALL fif extractions into one function
% 2013-04-15 Foldes: Time is not set to a zero-offset
% 2013-10-10 Foldes: Extract.full_file_name added
% 2013-10-21 Foldes: added filtering
% 2013-11-21 Foldes: Now extracts base_sample_rate
% 2013-12-06 Foldes: if no file name, does uigetfile
% 2013-12-06 Foldes: MAJOR, no longer supports multiple files
% 2013-12-18 Foldes: Extract gets more writen too, and is output. minor cleaning


%% Load DATA

data = []; FIF_timeS = [];

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
    current_full_file_name = [Extract.file_path filesep Extract.file_name Extract.file_extension];
else % .full_file_name exists, so use it (trumps .file_name, etc)
    current_full_file_name = Extract.full_file_name;
    [Extract.file_path Extract.file_name Extract.file_extension] = fileparts(current_full_file_name);
end

% Check that the file exists, if it doesn't try upper/lower case
Extract.file_name = filename_caseinsensitive(Extract.file_name,Extract.file_path);
% write new spelling to full_file_name
current_full_file_name = [Extract.file_path filesep Extract.file_name Extract.file_extension];

if ~exist(current_full_file_name)
    errordlg(['CAN NOT FIND FILE: ' current_full_file ' CHECK PATHS AND SPELLING'],'Data File Not Found')
end

% Load .FIF parameters
clear fif_fileExtract.filter_stop
fif_file = fiff_setup_read_raw(current_full_file_name);
Extract.base_sample_rate = fif_file.info.sfreq; % get sampling rate from file 2013-11-21

% Get info about channels that match the given chan_type
chan_cnt = 0; clear chan_idx_list chan_str_list
for ichan = 1:size(fif_file.info.ch_names,2)
    if strcmp(fif_file.info.ch_names{ichan}(1:3),chan_type(1:3))
        chan_cnt = chan_cnt+1;
        chan_idx_list(chan_cnt) = ichan;
        chan_str_list(chan_cnt,:) = fif_file.info.ch_names{ichan};
    end
end

Extract = populate_field_with_default(Extract,'decimation_factor',1);

% For MEG, look to see if channel list is already defined, if so, use it to limit the channels to extract
if strcmpi(chan_type,'MEG')
    Extract = populate_field_with_default(Extract,'channel_list',chan_idx_list);
    chan_idx_list=Extract.channel_list;
end


%% Extract Data and time

disp(['Reading ' chan_type ' data'])
clear temp_raw_file_data FIF_file_time
[temp_raw_file_data, FIF_file_timeS]=fiff_read_raw_segment(fif_file,fif_file.first_samp,fif_file.last_samp,chan_idx_list);

if ~isfield(Extract,'data_rate') && ~isfield(Extract,'base_sample_rate')
    Extract.base_sample_rate=median(diff(FIF_file_timeS)); % 2013-12-16
end
Extract.data_rate = Extract.base_sample_rate/Extract.decimation_factor;

% Each channel type might be treated differently.
switch chan_type
    case 'MEG'
        dfile_data = resample((10^13).*temp_raw_file_data',1,Extract.decimation_factor); % MAKE IT BIGGER!
        
        % Filtering 2013-10-21
        if isfield(Extract,'filter_stop') && ~isempty(Extract.filter_stop)
            dfile_data=Calc_Filter_Freq_SimpleButter(dfile_data,Extract.filter_stop,Extract.data_rate,'stop');
        end
        if isfield(Extract,'filter_bandpas') && ~isempty(Extract.filter_bandpas)
            dfile_data=Calc_Filter_Freq_SimpleButter(dfile_data,Extract.filter_bandpas,Extract.data_rate,'bandpass');
        end
        
    case 'STI'
        dfile_data = temp_raw_file_data(:,1:Extract.decimation_factor:end)'; % Must decimate this way to keep it discrete for triggers
    otherwise
        dfile_data = resample(temp_raw_file_data',1,Extract.decimation_factor);
end

dFIF_file_timeS=resample(FIF_file_timeS,1,Extract.decimation_factor);

% Concatinating Data from multiple files
data = cat(1,data, dfile_data);
FIF_timeS = [FIF_timeS; (dFIF_file_timeS)'];

clear dfile_data dFIF_file_time

% end % Loading Files


% for STI, remove strays, DONT DO FOR CHAN 3
switch chan_type
    case 'STI'
        % B/C OF MEG-PARALLEL PORT, SOME HIGH VALUES ARE SEEN IN TRIAL DATA, THIS REMOVES THE TARGET-CHANGE-ARTIFACT
        data = RemoveStrays(data(:,1));
end



