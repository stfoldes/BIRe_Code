% Basic example
%
% 2014-02-18 Foldes

PipeInfo =  BST_Pipeline_Class;
cnt =       0;

cnt = cnt + 1;
PipeInfo(cnt).subject =             'NC01';
PipeInfo(cnt).condition =           'Attempt_Grasp_RT';

% IMPORT
PipeInfo(cnt).FIFFile =             '/home/foldes/Data/MEG/NC01/S01/nc01s01r05_tsss.fif';
PipeInfo(cnt).EventFile =           '/home/foldes/Data/MEG/NC01/S01/events_4BSTfromMatlab_nc01s01r05.mat';

% NEED A PATH THING
PipeInfo(cnt).eventname =           'Trigger_Move'; %[], Always '1' for stim
PipeInfo(cnt).epochtime =           [-0.5 0.5];

% SOURCE
PipeInfo(cnt).noisecov_time =       [-0.1 0];
PipeInfo(cnt).inverse_method =      'wmne';
PipeInfo(cnt).inverse_orientation = 'fixed';


[PipeInfo, sFiles_4debug] = PipeInfo.Run('Source','PostSource');


