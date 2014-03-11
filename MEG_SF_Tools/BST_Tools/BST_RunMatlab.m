% Pre-processing > Run Matlab Command
% http://neuroimage.usc.edu/brainstorm/Tutorials/TutUserProcess

% Avalible Variables (whos)
%
%   Data            15002x1001            120136016  double              
%   TimeVector          1x1001                 8008  double                   
%   sProcess            1x1                    6556  struct     
%   sInput              1x1               120149890  struct    
%       |- iStudy:       12
%       |- iItem:        1
%       |- FileName:     'Group_analysis/Attempt_Grasp_RT/results_wMNE_MEG_GRAD_MEG_MAG_KERNEL_140218_1510_NC01.mat'
%       |- FileType:     'results'
%       |- Comment:      'NC01/MN: MEG ALL(Constr)'
%       |- Condition:    'Attempt_Grasp_RT'
%       |- SubjectFile:  'Group_analysis/brainstormsubject.mat'
%       |- SubjectName:  'Group_analysis'
%       |- DataFile:     'NC01/Attempt_Grasp_RT/data_Trigger_Move_average_140217_1740.mat'
%       |- ChannelFile:  []
%       |- ChannelTypes: []
%       |- Measure:      []
%       |- ChannelFlag:  [316x1 double]
%       |- nAvg:         1
%       |- A:            [15002x1001 double]
%       |- TimeVector:   [1x1001 double]

%% Stealing sInput from BST
%  Not elegent

% whos
% disp_struct(sInput)

% Move sInput to the base workspace
assignin('base', 'sInput', sInput);

% % (why is this hard?)
% FileName = 'Group_analysis/Attempt_Grasp_RT/results_wMNE_MEG_GRAD_MEG_MAG_KERNEL_140218_1510_NC01.mat';
% % FileName = 'NC01/Attempt_Grasp_RT/data_Trigger_Move_average_140217_1740.mat';
% % This should work, doesn't
% [sInput, nSignals, iRows] = bst_process('LoadInputFile', FileName);
% sInput = bst_get('AnyFile', FileName);

%% 


% Open surface plot W/ Overlay
hFig =  view_surface_data([], sInput.FileName);
% hFig =  view_surface_data([], BST_Info.OverlayFile_str);
