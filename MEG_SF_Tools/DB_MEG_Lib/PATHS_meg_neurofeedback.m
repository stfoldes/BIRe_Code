function PATHS_meg_neurofeedback
% Sets up GLOBAL paths for a particular project and computer
% 
% server and local paths defined
% server path can be set to local if you just want to be local
%
% paths usually go to the most parent folder (base), like /home/foldes/Data/MEG/
%
% path_design describes how the folders are organized after base path
%
% EXAMPLE:
%   Normal folder: /home/foldes/Data/MEG/NS01/S01/*.*
%   base = /home/foldes/Data/MEG/
%   post-base = NS01/S01 --> '[subject]/S[session]'
%
% path_design: [] enclose property call. / or \ will call filesep (SEE: DB_Class.file_path.m)
%
% MY_PATHS.db is an optional path, defaults to MY_PATHS.server_base in load
%
% SEE: DB_Class.file_path.m
%
% 2013-08-22 Foldes
% UPDATES:
% 2013-10-03 Foldes: made a struct to keep things clean
% 2013-10-04 Foldes: Added path_designs, now global
% 2013-10-05 Foldes: Renamed from DEF_MEG_PATHS. Now includes project name


clearvars -global MY_PATHS

global MY_PATHS

MY_PATHS.project = 'meg_neurofeedback';

% Get user info
computer_name = computer_info;
% Set up Base paths
switch computer_name
    case 'FoldesPC'
        %disp(['hello ' computer_name])
        MY_PATHS.local_base = '/home/foldes/Data/MEG/';
        MY_PATHS.local_path_design='[subject]/S[session]'; % eg. NS01/S01
        
        MY_PATHS.server_base = ['/home/foldes/Desktop/Katz/experiments/' MY_PATHS.project];
        MY_PATHS.server_path_design='[subject]/S[session]'; % eg. NS01/S01
        
%         MY_PATHS.local_MRI_base = '/home/foldes/Data/subjects/';
%         MY_PATHS.local_MRI_path_design='[subject]/Initial/Freesurfer_Reconstruction/mri'; % eg. NS01/Initial/Freesurfer_Reconstruction/mri
        
        % MY_PATHS.db = MY_PATHS.server_base; % OPTIONAL
    case {'meg','Mike-PC'}
        MY_PATHS.local_base = 'C:\Data\';
        MY_PATHS.local_path_design='[subject]/S[session]'; % eg. NS01/S01
        
        MY_PATHS.server_base = ['Z:\experiments\' MY_PATHS.project];
        MY_PATHS.server_path_design='[subject]/S[session]'; % eg. NS01/S01
        
        
        %% ---ADD MORE OPTIONS HERE---
    otherwise
        error(['No paths found for ' computer_name ': ADD TO DEF_MEG_paths.m'])
end


