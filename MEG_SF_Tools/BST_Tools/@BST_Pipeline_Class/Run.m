function [PipeInfo, sFiles_4debug] = Run(PipeInfo,varargin)
% [PipeInfo, sFiles_4debug] = BST_Pipeline(PipeInfo,varargin); 'Import','PreSource','Source','Project2MNI'
%
% Programatically runs BST Script/Pipelines
% Parameters stored in PipeInfo (SEE: BST_Pipeline_Class)
% Loops through all PipeInfo entries
%
% VARARGIN: Is a list of pipelines to loop through
%           MUST be in the correct order
%           'Import':       Inspects .fif, loads events (or event channel), imports to db
%                           Import must be done before anything else (but can be done by hand)
%                           Subject must be created and have a MRI imported (or the template brain)
%           'PreSource':    Builds forward model (Head Model), Average trials
%           'Source':       Calc noise cov, inverse
%           'Project2MNI':  Project to MNI (for now)   
%
% EXAMPLE:
%   Process one data set from FIF all the way to MNI-sources
%
%     PipeInfo =  BST_Pipeline_Class;
%     cnt =       0;
% 
%     cnt = cnt + 1;
%     PipeInfo(cnt).subject =             'NC01';
%     PipeInfo(cnt).condition =           'Attempt_Grasp_RT';
% 
%     % IMPORT
%     PipeInfo(cnt).FIFFile =             '/home/foldes/Data/MEG/NC01/S01/nc01s01r05_tsss.fif';
%     PipeInfo(cnt).EventFile =           '/home/foldes/Data/MEG/NC01/S01/events_4BSTfromMatlab_nc01s01r05.mat';
% 
%     % NEED A PATH THING
%     PipeInfo(cnt).eventname =           'Trigger_Move'; %[], Always '1' for stim
%     PipeInfo(cnt).epochtime =           [-0.5 0.5];
% 
%     % SOURCE
%     PipeInfo(cnt).noisecov_time =       [-0.1 0];
%     PipeInfo(cnt).inverse_method =      'wmne';
%     PipeInfo(cnt).inverse_orientation = 'fixed';
% 
%     [PipeInfo, sFiles_4debug] = PipeInfo.Run('Import','PreSource','Source','Project2MNI');
%
%
% 2014-02-14 Foldes
% UPDATES:
% 2014-02-17 Foldes: Split
% 2014-02-18 Foldes: Modular, obj
% 2014-03-25 Foldes: Small updates, removed if isempty (should be in Class def)


% Gather all sFiles incase you want to debug
sFiles_4debug = [];

for iexp = 1:length(PipeInfo)
    current_PipeInfo = PipeInfo(iexp);
    
    % % Start a new report
    % bst_report('Start', sFiles);
    
    
    for ivar = 1:length(varargin)
        current_pipeline_name = varargin{ivar};
        eval(['[current_PipeInfo, sFiles_4debug] = ' current_pipeline_name '(current_PipeInfo);'])
    end
    
    % % Save and display report
    % ReportFile = bst_report('Save', sFiles);
    % bst_report('Open', ReportFile);
    
end % Big loop


if nargout>0
    sFiles_4debug_out = sFiles_4debug;
end

end % main function

%% ===============================================================================
%  BELOW ARE THE PIPELINE PIECES
%  ===============================================================================
%
%  Pipeline/scripts are generated from Brainstorm v3.1(or 2)
%  All parameters are passed with PipeInfo (SEE: BST_Pipeline_Class)
%  Parameters should be marked in the code below by % <---------PROGRAMATIC
%  Defining sFiles before calling bst_process() is often done different than would
%  be in the BST-generated script
%
%% ===============================================================================


function [PipeInfo, sFiles_4debug] = Import(PipeInfo)
% Runs a pipeline from after importing MRI (by hand) through imported MEG
% Requires BST_Pipeline_Class
% Handles events files
%
% 2014-02-17 Foldes

% Gather all sFiles incase you want to debug
sFiles_4debug = [];

% Input files
sFiles = [];
SubjectNames =  {PipeInfo.subject};
% SubjectNames = {...
%     'MR'};
RawFiles =      {PipeInfo.FIFFile};
% FIFFiles = {...
%     '/home/foldes/Data/MEG/Test/Stimulation/mr06_tsss.fif'};

% FOR EVENTS
EventFiles =    {PipeInfo.EventFile};%'/home/foldes/Data/MEG/DBI05/S01/events_4BSTfromMatlab_dbi05s01r05_tsss_trans.mat

% ---PROCESSING BEGINS---
% For debugging
sFiles_4debug(end+1).process = 'Link Raw';
sFiles_4debug(end).sFiles = sFiles;

% Process: Create link to raw file
sFiles = bst_process(...
    'CallProcess', 'process_import_data_raw', ...
    sFiles, [], ...
    'subjectname', SubjectNames{1}, ...
    'datafile', {RawFiles{1}, 'FIF'}, ...
    'channelreplace', 1, ...
    'channelalign', 1);

% ---Load EVENTS (file or STI101)---

if isempty(PipeInfo.EventFile) || strcmpi(PipeInfo.EventFile,'none') % no events file, load STI101
    
    % Process: Events: Read from channel
    sFiles = bst_process(...
        'CallProcess', 'process_evt_read', ...
        sFiles, [], ...
        'stimchan', 'STI101', ...
        'trackmode', 1, ...  % Value: detect the changes of channel value
        'zero', 0);
    
else % Deal w/ Event file
    
    [~,fif_file_name] = fileparts(PipeInfo.FIFFile);
    
    % Input files
    sFiles = {[PipeInfo.subject filesep '@raw' fif_file_name filesep 'data_0raw_' fif_file_name '.mat']};
    
    % For debugging
    sFiles_4debug(end+1).process = 'Read Events';
    sFiles_4debug(end).sFiles = sFiles;
    
    % Process: Events: Import from file
    sFiles = bst_process(...
        'CallProcess', 'process_evt_import', ...
        sFiles, [], ...
        'evtfile', { EventFiles{1}, 'BST'});
end

% ---IMPORT---
% For debugging
sFiles_4debug(end+1).process = 'Import MEG';
sFiles_4debug(end).sFiles = sFiles;

% GET TIME FROM FILE (using ALL time)
%       Load link file and get the time out of it (could get from fif directly)
LinkFile = load(fullfile(PipeInfo.protocol_data_path,sFiles.FileName));

% list event names:
labels_avalible = {LinkFile.F.events.label};% 2014-03-25

% find if requested is a match
event_match_idx = [];
if ~isempty(PipeInfo.eventname)
    event_match_idx = find_lists_overlap_idx(labels_avalible,PipeInfo.eventname);
end

% match not found or too many matches, use gui
if length(event_match_idx) ~= 1
    event_match_idx = listdlg('ListString',labels_avalible,'SelectionMode','single','PromptString','SELECT event to use');
end
% redefine eventname from list
PipeInfo.eventname = cell2mat(labels_avalible(event_match_idx));

% Check if the files are already there
if ~isempty(PipeInfo.Get_Trial_File_Names)
    if ~questdlg_YesNo_logic('Do you want to continue the import? (Say No)','Files already found!')
        warning('NO NEW FILES IMPORTED')
        return
    end
end
% Process: Import MEG/EEG: Events
sFiles = bst_process(...
    'CallProcess', 'process_import_data_event', ...
    sFiles, [], ...
    'subjectname', SubjectNames{1}, ...
    'condition', PipeInfo.condition, ... 	% <--------- PROGRAMATIC
    'eventname', PipeInfo.eventname, ...  	% <--------- PROGRAMATIC
    'timewindow', LinkFile.Time, ...        % <--------- DEFINED ABOVE
    'epochtime', PipeInfo.epochtime, ...  	% <--------- PROGRAMATIC
    'createcond', 0, ... % NOTE: This must be 0 or 'condition' above will NOT be used
    'ignoreshort', 1, ...
    'usectfcomp', 1, ...
    'usessp', 1, ...
    'freq', [], ...
    'baseline', []);

end % IMPORT

function [PipeInfo, sFiles_4debug] = PreSource(PipeInfo)
% Runs a pipeline from after imported up-to sources
% Averaging and head model
% Requires BST_Pipeline_Class
% Noise Cov, Head Model, Avg, Inverse
%
% 2014-02-17 Foldes

% Gather all sFiles incase you want to debug
sFiles_4debug = [];

% Script generated by Brainstorm v3.1 (15-Jan-2014)

% Input files
sFiles = [];

% ---AVG---
% Find file list of the data_*_trial#.mat format
sFiles = Get_Trial_File_Names(PipeInfo);

% For debugging
sFiles_4debug(end+1).process = 'Avg';
sFiles_4debug(end).sFiles = sFiles;

% Process: Average: By condition (grand average)
sFiles = bst_process(...
    'CallProcess', 'process_average', ...
    sFiles, [], ...
    'avgtype', 4, ...
    'avg_func', 1, ...  % <HTML>Arithmetic average: <FONT color="#777777">mean(x)</FONT>
    'keepevents', 0);

% ---HEAD---

% Find file list of the data_*_trial#.mat format
sFiles = Get_Trial_File_Names(PipeInfo);

% For debugging
sFiles_4debug(end+1).process = 'Head Model';
sFiles_4debug(end).sFiles = sFiles;

% Process: Compute head model
sFiles = bst_process(...
    'CallProcess', 'process_headmodel', ...
    sFiles, [], ...
    'sourcespace', 1, ...
    'meg', 3, ...  % Overlapping spheres
    'eeg', 3, ...  % OpenMEEG BEM
    'ecog', 2, ... % OpenMEEG BEM
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
end % PRESOURCE

function [PipeInfo, sFiles_4debug] = Source(PipeInfo)
% Runs a pipeline from after head model through sources
% Requires BST_Pipeline_Class
% Noise Cov, Head Model, Avg, Inverse
%
% 2014-02-17 Foldes

% Gather all sFiles incase you want to debug
sFiles_4debug = [];

% Script generated by Brainstorm v3.1 (15-Jan-2014)

% Input files
sFiles = [];

% ---NOISE COV---

% Find file list of the data_*_trial#.mat format
sFiles = Get_Trial_File_Names(PipeInfo);

% if isempty(PipeInfo.noisecov_time)
%     PipeInfo.noisecov_time = [-0.1, 0];
% end

% For debugging
sFiles_4debug(end+1).process = 'Noise Cov';
sFiles_4debug(end).sFiles = sFiles;

% Process: Compute noise covariance
sFiles = bst_process(...
    'CallProcess', 'process_noisecov', ...
    sFiles, [], ...
    'baseline', PipeInfo.noisecov_time, ...
    'dcoffset', 1, ...
    'method', 1, ...  % Full noise covariance matrix
    'copycond', 0, ...
    'copysubj', 0);

% ---SOURCE---

% Get file info
[StudyInfo, iStudy] = bst_get('StudyWithCondition', fullfile(PipeInfo.subject,PipeInfo.condition));
% Get all the data files from conditions
sFiles = {StudyInfo.Data(end).FileName}; %  not sure if 'end' or '1'

% For debugging
sFiles_4debug(end+1).process = 'Sources';
sFiles_4debug(end).sFiles = sFiles;

% wmne or dspm methods
if isempty(PipeInfo.inverse_method)
    inverse_options = {'wMNE','dSPM'};
    PipeInfo.inverse_method = cell2mat(inverse_options(listdlg('ListString',inverse_options,'PromptString','NEEDS AN INVERSE METHOD')));
end
switch lower(PipeInfo.inverse_method)
    case ('wmne')
        method_num = 1;
    case ('dspm')
        method_num = 2;
end

% if isempty(PipeInfo.inverse_orientation)
%     PipeInfo.inverse_orientation = 'fixed';
% end
% 
% if isempty(PipeInfo.sensortypes)
%     PipeInfo.sensortypes = 'MEG, MEG MAG, MEG GRAD, EEG';
% end

% Process: Compute sources
sFiles = bst_process(...
    'CallProcess', 'process_inverse', ...
    sFiles, [], ...
    'method', method_num, ...                                       % <---------PROGRAMATIC
    'wmne', struct(... % Minimum norm estimates (wMNE)
    'SourceOrient', {{lower(PipeInfo.inverse_orientation)}}, ...    % <---------PROGRAMATIC ['fixed' or 'free']
    'loose', 0.2, ...
    'SNR', 3, ...
    'pca', 1, ...
    'diagnoise', 0, ...
    'regnoise', 1, ...
    'depth', 1, ...
    'weightexp', 0.5, ...
    'weightlimit', 10), ...
    'sensortypes', upper(PipeInfo.sensortypes), ...                 % <---------PROGRAMATIC  
    'output', 1);  % Kernel only: shared

end % SOURCE

function [PipeInfo, sFiles_4debug] = Project2MNI(PipeInfo)
% This will host all the post_source functions
% Should one day be a flag system or a name of the funtion as a input
%
% 2014-02-17 Foldes

% Gather all sFiles incase you want to debug
sFiles_4debug = [];

% ---Project to MNI---

% Input files
sFiles = {PipeInfo.OverlayFile_str};
% sFiles = {...
%     'link|NC01/Attempt_Grasp_RT/results_wMNE_MEG_GRAD_MEG_MAG_KERNEL_140217_1726.mat|NC01/Attempt_Grasp_RT/data_Trigger_Move_average_140217_1725.mat'};

% For debugging
sFiles_4debug(end+1).process = 'Noise Cov';
sFiles_4debug(end).sFiles = sFiles;

% Process: Project on default anatomy
sFiles = bst_process(...
    'CallProcess', 'process_project_sources', ...
    sFiles, [], ...
    'source_abs', 0);

end % PROJECT2MNI





















