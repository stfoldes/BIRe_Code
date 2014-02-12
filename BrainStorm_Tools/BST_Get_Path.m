function [fullfile_name,localfile_name] = BST_Get_Path(ExpInfo,file_type)
% Generates the path to files in the brainstorm_db
% File names will be be searched for, so date-stamps aren't a problem
% Multiple file matches will prompt a choice
% Needs global BST_DB_PATH
%
% Call also use BST_Get_ExpInfo_from_Path
%
% ExpInfo.
%       project:        BST project
%       subject:        Name used in BST project
%       group_or_ind:   'individual' or 'group' brain (not all data files will be possible)
%       task_name:      Trial name
%       inverse_method: 'wMNE','dSPM' (only needed for 'inverse' type)
%
% file_type: 'inverse','headmodel','average','noisecov','avg', 'surface','t1','mri'
%
% EXAMPLE
%     global BST_DB_PATH
%     BST_DB_PATH = '/home/foldes/Data/brainstorm_db/';
%
%     ExpInfo.project =         'Test';
%     ExpInfo.subject =         'Subject01_copy';
%     ExpInfo.group_or_ind=     'individual'
%     ExpInfo.task_name =       '1'; % name of stimulus
%     ExpInfo.inverse_method =  'wMNE'; % 'dSPM' % The name of the method used
%
%     Inverse =     BST_Load_File(ExpInfo,'inverse');
%     SurfaceFile = BST_Load_File(ExpInfo,'surface');
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
% SEE: BrainSurface_Class, bst_memory.m, BST_Load_File, BST_Get_ExpInfo_from_Path
% 2014-02-03 Foldes
% UPDATES:
% 2014-02-06 Foldes: Split off, does group

global BST_DB_PATH

%% Deal with GROUP vs. INDIVIDUAL
% Some file types can't be GROUP
if strcmpi(ExpInfo.group_or_ind,'group')
    switch lower(file_type)
        case {'headmodel','average','noisecov','avg'}
            disp([file_type ' is not valid as a GROUP, getting INDIVIDUAL data'])
            ExpInfo.group_or_ind = 'individual';
    end
end

% Build the base path. Depends on file type
switch lower(ExpInfo.group_or_ind)
    case {'individual','ind'}
        
        % EXAMPLE: /home/foldes/Data/brainstorm_db/Test/data/Subject01_copy/1/
        data_path = fullfile(BST_DB_PATH,ExpInfo.project,'data',ExpInfo.subject,ExpInfo.task_name);
        anat_path = fullfile(BST_DB_PATH,ExpInfo.project,'anat',ExpInfo.subject);
        
    case 'group'
        % Group is stored in Group_analysis
        data_path = fullfile(BST_DB_PATH,ExpInfo.project,'data','Group_analysis',ExpInfo.task_name);
        anat_path = fullfile(BST_DB_PATH,ExpInfo.project,'anat','@default_subject');
        % anat_path = fullfile(BST_DB_PATH,ExpInfo.project,'anat',Group_analysis); % It should be this, but its not
end

%% Pick base path based on file type

switch lower(file_type)
    case {'inverse','headmodel','average','noisecov','avg'}
        base_path = data_path;
    case {'surface','t1','mri'}
        base_path = anat_path;
end


%% Determine file name needed for searching
switch lower(file_type)
    case 'inverse'
        switch lower(ExpInfo.group_or_ind)
            case {'individual','ind'}
                search_str = ['results_' ExpInfo.inverse_method '*'];
            case 'group'
                search_str = ['results_' ExpInfo.inverse_method '*' ExpInfo.subject '*'];
        end
    case 'headmodel'
        search_str = ['headmodel_surf_*'];
    case 'noisecov'
        search_str = ['noisecov_*'];
    case {'average','avg'}
        search_str = ['data_' ExpInfo.task_name '_average_*'];
        
        
    case {'t1','mri'}
        search_str = ['subjectimage_T1.mat'];
    case 'surface'
        % This is complicated, it gets the surface name from the inverse file
        
        try % see if you can load the inverse file
            Inverse =       BST_Load_File(ExpInfo,'inverse');
            search_str =    Inverse.SurfaceFile;
            disp('Loading SurfaceFile from InverseFile')
        catch
            search_str =    'tess_cortex_pial_low.mat';
            disp(['Loading SurfaceFile ' search_str ' (*NOT FROM INVERSE*)'])
        end
        
end

% Search for file, limit to 1 file
fullfile_name = search_dir(base_path,search_str,'SingleFile',true);

%% Outputs

if isempty(fullfile_name)
    disp(['NO FILE FOUND: ' file_type])
    localfile_name = [];
else
    [~,localfile_name] = fileparts(fullfile_name);
end

% % Load file contents into a struct
% data_out = load(fullfile_name);


