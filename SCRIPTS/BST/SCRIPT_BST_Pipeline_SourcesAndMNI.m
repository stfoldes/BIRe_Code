% Script to go from importing to sources on MNI brain
% 2014-02-07 Foldes
%
% 
% Script generated by Brainstorm v3.1 (15-Jan-2014)
global BST_DB_PATH 
global MY_PATHS

PATHS_meg_neurofeedback;
BST_DB_PATH = '/home/foldes/Data/brainstorm_db/';


RawInfo = DB_MEG_Class;
RawInfo.entry_id =  'DBI05s01r03';
[RawInfo.subject, RawInfo.session, RawInfo.run] = split_data_file_name(RawInfo.entry_id);
RawFile_fullname = [RawInfo(1).file('tsss'),'.fif'];
% Event file name search for it
EventFile_fullname = search_dir(RawInfo(1).file_path,['events_4BSTfromMatlab_' RawInfo.entry_id '*'],...
    'CaseInsensitive',true,'SingleFile',true);


ExpInfo.project =         'Test';
ExpInfo.subject =         'Subject01_copy';
% ExpInfo.group_or_ind =    'group';%'individual';
% ExpInfo.event_name =      'EMG_auto'; % name of stimulus AUTOMATICALLY DEFINED FROM EVENT FILE
% ExpInfo.inverse_method =  'wMNE'; % 'dSPM' % The name of the method used







%% BST SCRIPT

% Must start BST, export something, then my programs take over
if brainstorm('status') == 0 % unless its already open
    brainstorm;
end


% Gather all sFiles incase you want to debug
sFiles_all = [];

% Input files
sFiles = [];
SubjectNames =  {ExpInfo.subject}; % 'Subject01_copy'
RawFiles =      {RawFile_fullname}; % '/home/foldes/Data/MEG/DBI05/S01/dbi05s01r15_tsss.fif'
EventFiles =    {EventFile_fullname};%'/home/foldes/Data/MEG/DBI05/S01/events_4BSTfromMatlab_dbi05s01r05_tsss_trans.mat

% Start a new report
bst_report('Start', sFiles);

%% INITIALIZE

% Process: Create link to raw file
sFiles = bst_process(...
    'CallProcess', 'process_import_data_raw', ...
    sFiles, [], ...
    'subjectname', SubjectNames{1}, ...
    'datafile', {RawFiles{1}, 'FIF'}, ...
    'channelreplace', 1, ...
    'channelalign', 1);
sFiles_all{end+1} = sFiles;

% % Process: Sinusoid removal: 60Hz 120Hz 1180Hz
% sFiles = bst_process(...
%     'CallProcess', 'process_sin_remove', ...
%     sFiles, [], ...
%     'freqlist', [60, 120, 180], ...
%     'sensortypes', 'MEG, EEG', ...
%     'reverse', 1, ...
%     'parallel', 1);
% sFiles_all{end+1} = sFiles;

% % Process: Detect eye blinks
% sFiles = bst_process(...
%     'CallProcess', 'process_evt_detect_eog', ...
%     sFiles, [], ...
%     'channelname', 'EOG062', ...
%     'timewindow', [76, 291.999], ...
%     'eventname', 'blink');
% sFiles_all{end+1} = sFiles;
% 
% % Process: SSP EOG: blink
% sFiles = bst_process(...
%     'CallProcess', 'process_ssp_eog', ...
%     sFiles, [], ...
%     'eventname', 'blink', ...
%     'sensortypes', 'MEG, MEG MAG, MEG GRAD');
% sFiles_all{end+1} = sFiles;
%
% % Process: Detect heartbeats
% sFiles = bst_process(...
%     'CallProcess', 'process_evt_detect_ecg', ...
%     sFiles, [], ...
%     'channelname', 'ECG063', ...1
%     'timewindow', [76, 291.999], ...
%     'eventname', 'cardiac');
% sFiles_all{end+1} = sFiles;
% 
% % Process: SSP ECG: cardiac
% sFiles = bst_process(...
%     'CallProcess', 'process_ssp_ecg', ...
%     sFiles, [], ...
%     'eventname', 'cardiac', ...
%     'sensortypes', 'MEG, MEG MAG, MEG GRAD');
% sFiles_all{end+1} = sFiles;

%% EVENTS

% Process: Events: Read from channel
sFiles = bst_process(...
    'CallProcess', 'process_evt_read', ...
    sFiles, [], ...
    'stimchan', 'STI101', ...
    'trackmode', 1, ...  % Value: detect the changes of channel value
    'zero', 0);
sFiles_all{end+1} = sFiles;

if ~isempty(EventFiles)
    % Process: Events: Import from file
    sFiles = bst_process(...
        'CallProcess', 'process_evt_import', ...
        sFiles, [], ...
        'evtfile', {EventFiles{1}, 'BST'});
    sFiles_all{end+1} = sFiles;
    
    % What if more than one event.label? what if you have the name wrong
    EventStruct_in_File = load(EventFiles{1});
    if length(EventStruct_in_File.events)>1 % more than one, then ask
        
        for ievent = 1:length(EventStruct_in_File.events)
            event_label_list{ievent} = EventStruct_in_File.events(ievent).label;
        end
        
        select_idx = listdlg('PromptString','Choice Event','ListString',event_label_list);
        ExpInfo.event_name = event_label_list{select_idx};
    else
        ExpInfo.event_name = EventStruct_in_File.events(1).label;
    end        
    
end

%% Import MEG/EEG: Events

% have to find the time (this is silly, why not just get in function?)
LinkedFile = load(fullfile(BST_DB_PATH, ExpInfo.project,'data',sFiles.FileName));
sFiles = bst_process(...
    'CallProcess', 'process_import_data_event', ...
    sFiles, [], ...
    'subjectname', SubjectNames{1}, ...
    'condition', 'Move', ...
    'eventname', ExpInfo.event_name, ...
    'timewindow', LinkedFile.Time, ...
    'epochtime', [-0.5 0.5], ...
    'createcond', 1, ...
    'ignoreshort', 1, ...
    'usectfcomp', 1, ...
    'usessp', 1, ...
    'freq', [], ...
    'baseline', []);
sFiles_all{end+1} = sFiles;


%% SOURCE

% Process: Compute noise covariance
sFiles = bst_process(...
    'CallProcess', 'process_noisecov', ...
    sFiles, [], ...
    'baseline', [-0.1, 0], ...
    'dcoffset', 1, ...
    'method', 1, ...  % Full noise covariance matrix
    'copycond', 0, ...
    'copysubj', 0);
sFiles_all{end+1} = sFiles;

% Process: Average: By condscript_new.mition (grand average)
sFiles = bst_process(...
    'CallProcess', 'process_average', ...
    sFiles, [], ...
    'avgtype', 4, ...
    'avg_func', 1, ...  % <HTML>Arithmetic average: <FONT color="#777777">mean(x)</FONT>
    'keepevents', 0);
sFiles_all{end+1} = sFiles;

% Process: Snapshot: Sensors/MRI registration
sFiles = bst_process(...
    'CallProcess', 'process_snapshot', ...
    sFiles, [], ...
    'target', 1, ...  % Sensors/MRI registration
    'modality', 1, ...  % MEG (All)
    'orient', 5, ...  % front
    'time', 0, ...
    'contact_time', [0, 0.1], ...
    'contact_nimage', 12, ...
    'comment', 'MEG/MRI Registration');
sFiles_all{end+1} = sFiles;

% Process: Compute head model
sFiles = bst_process(...
    'CallProcess', 'process_headmodel', ...
    sFiles, [], ...
    'sourcespace', 1, ...
    'meg', 3, ...  % Overlapping spheres
    'eeg', 3, ...  % OpenMEEG BEM
    'ecog', 2, ...  % OpenMEEG BEM
    'seeg', 2, ...
    'openmeeg', struct(...
         'BemSelect', [1, 1, 1], ...
         'BemCond', [1, 0.0125, 1], ...
         'BemNames', {{'Scalp', 'Skull', 'Brain'}}, ...
         'BemFiles', {{}}, ...
         'isAdjoint', 0, ...
         'isAdaptative', 1, ...
         'isSplit', 0, ...
         'SplitLength', 4000));
sFiles_all{end+1} = sFiles;

% Process: Compute sources
sFiles = bst_process(...
    'CallProcess', 'process_inverse', ...
    sFiles, [], ...
    'method', 1, ...  % Minimum norm estimates (wMNE)
    'wmne', struct(...
         'SourceOrient', {{'fixed'}}, ... % 'SourceOrient', {{'free'}}, ...
         'loose', 0.2, ...
         'SNR', 3, ...
         'pca', 1, ...
         'diagnoise', 0, ...
         'regnoise', 1, ...
         'depth', 1, ...
         'weightexp', 0.5, ...
         'weightlimit', 10), ...
    'sensortypes', 'MEG, MEG MAG, MEG GRAD, EEG', ...
    'output', 1);  % Kernel only: shared
sFiles_all{end+1} = sFiles;

% Process: Snapshot: Sources (contact sheet)
sFiles = bst_process(...
    'CallProcess', 'process_snapshot', ...
    sFiles, [], ...
    'target', 9, ...  % Sources (contact sheet)
    'modality', 1, ...  % MEG (All)
    'orient', 3, ...  % top
    'time', 0, ...
    'contact_time', [0, 0.2], ...
    'contact_nimage', 12, ...
    'comment', 'Sources');
sFiles_all{end+1} = sFiles;

% Process: Project on default anatomy
sFiles = bst_process(...
    'CallProcess', 'process_project_sources', ...
    sFiles, [], ...
    'source_abs', 0);
sFiles_all{end+1} = sFiles;

% Save and display report
ReportFile = bst_report('Save', sFiles);
bst_report('Open', ReportFile);

