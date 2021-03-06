function [data_out,fullfile_name] = Load_File(obj,file_type)
%
%   NOTE: THIS MIGHT NOT BE BEST WAY TO DO THIS
%           E.G. SurfaceFile LOADS DIFFERENT IF USING bst_memory
%
% Loads BST data from files within the BST_db
% Generates the path to files in the brainstorm_db
% File names will be be searched for, so date-stamps aren't a problem
% Multiple file matches will prompt a choice
% Needs global BST_DB_PATH
%
% obj.
%       protocol:       BST protocol
%       subject:        Name used in BST protocol
%       group_or_ind:  'individual' or 'group' brain (not all data files will be possible)
%       task_name:      Trial name
%       inverse_method: 'wMNE','dSPM' (only needed for 'inverse' type)
%
% file_type: 'inverse','headmodel','average','noisecov','avg', 'surface','t1'
%
% EXAMPLE
%     global BST_DB_PATH
%     BST_DB_PATH = '/home/foldes/Data/brainstorm_db/';
% 
%     obj.protocol =        'Test';
%     obj.subject =         'Subject01_copy';
%     obj.group_or_ind=     'individual'
%     obj.task_name =       '1'; % name of stimulus
%     obj.inverse_method =  'wMNE'; % 'dSPM' % The name of the method used
%
%     Inverse =     Load_File(obj,'inverse');
%     SurfaceFile = Load_File(obj,'surface');
% 
%     % Plot brain, quick
%     BrainSurface.Faces =    SurfaceFile.Faces;
%     BrainSurface.Vertices = SurfaceFile.Vertices;
%     parms.Color =           .7*[1 1 1]; % light grey % pinkish [0.9 0.62 0.46];%
%     parms.Alpha =           .2;
%     % Color for each face of the brain surface
%     BrainSurface.VerticesColor = repmat(parms.Color, [size(BrainSurface.Vertices, 1) 1]);
%     % Plot
%     trisurf(BrainSurface.Faces, BrainSurface.Vertices(:,1), BrainSurface.Vertices(:,2), BrainSurface.Vertices(:,3), ...
%         'FaceVertexCData', BrainSurface.VerticesColor, ...
%         'FaceColor', 'interp', ...
%         'FaceVertexAlphaData', parms.Alpha*ones( size(BrainSurface.Vertices,1), 1 ), ...
%         'Tag', 'brain');
%
% EXAMPLE FILE FORMAT: 
%     /home/foldes/Data/brainstorm_db/Test/data/Subject01_copy/1/results_wMNE_MEG_GRAD_KERNEL_140124_1807.mat
%
% SEE: BrainSurface_Class, bst_memory.m
% 2014-02-03 Foldes
% UPDATES:
% 2014-02-06 Foldes: Move path makers out

[fullfile_name,localfile_name] = Get_File_Path(obj,file_type);

% Load file contents into a struct
data_out = load(fullfile_name);


