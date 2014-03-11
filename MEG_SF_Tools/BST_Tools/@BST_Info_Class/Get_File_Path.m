function [fullfile_name,localfile_name] = Get_File_Path(obj,file_type)
% Generates the path to files in the brainstorm_db
% File names will be be searched for, so date-stamps aren't a problem
% Multiple file matches will prompt a choice
% file_type: 'inverse','headmodel','average','noisecov','avg', 'surface','t1','mri'
%
% obj.
%       protocol:       BST protocol
%       subject:        Name used in BST protocol
%       group_or_ind:   'individual' or 'group' brain (not all data files will be possible)
%       condition:      Trial name
%       inverse_method: 'wMNE','dSPM' (only needed for 'inverse' type)
%
% EXAMPLE
%     obj = BST_Info_Class;
%     obj.subject =         'Subject01_copy';
%     obj.group_or_ind=     'individual'
%     obj.condition =       '1'; % name of stimulus
%     obj.inverse_method =  'wMNE'; % 'dSPM' % The name of the method used
%
%     Inverse =     BST_Load_File(obj,'inverse');
%     SurfaceFile = BST_Load_File(obj,'surface');
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
% SEE: BrainSurface_Class, bst_memory.m, BST_Load_File, BST_Get_obj_from_Path
% 2014-02-03 Foldes
% UPDATES:
% 2014-02-06 Foldes: Split off, does group
% 2014-02-15 Foldes: Now a class, project -> protocol, using BST functions to get paths, no global path anymore, 
% 2014-02-17 Foldes: obj.eventname

%% Get basic info from BST about the protocol
% THIS IS DONE IN THE CONSTRUCTOR FOR THE CLASS

% % Must start BST first
% if brainstorm('status') == 0 % unless its already open
%     error('BST must be open and pointed to the correct protocol')
% end
% 
% % Basic info from BST
% ProtocolInfo =      bst_get('ProtocolInfo');
% obj.protocol =  ProtocolInfo.Comment;
% 
% obj.protocol_data_path = ProtocolInfo.STUDIES;
% obj.protocol_anat_path = ProtocolInfo.SUBJECTS;

%% Deal with GROUP vs. INDIVIDUAL
% Some file types can't be GROUP
if strcmpi(obj.group_or_ind,'group')
    switch lower(file_type)
        case {'headmodel','average','noisecov','avg'}
            disp([file_type ' is not valid as a GROUP, getting INDIVIDUAL data'])
            obj.group_or_ind = 'individual';
    end
end

% Build the base path. Depends on file type
switch lower(obj.group_or_ind)
    case {'individual','ind'}
        % EXAMPLE: /home/foldes/Data/brainstorm_db/Test/data/Subject01_copy/1/
        data_path = fullfile(obj.protocol_data_path,obj.subject,obj.condition);
        anat_path = fullfile(obj.protocol_anat_path,obj.subject);
        
    case 'group'
        % Group is stored in Group_analysis
        data_path = fullfile(obj.protocol_data_path,'Group_analysis',obj.condition);
        anat_path = fullfile(obj.protocol_anat_path,'@default_subject');
        % anat_path = fullfile(BST_DB_PATH,obj.protocol,'anat',Group_analysis); % It should be this, but its not
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
        switch lower(obj.group_or_ind)
            case {'individual','ind'}
                search_str = ['results_' obj.inverse_method '*'];
            case 'group'
                search_str = ['results_' obj.inverse_method '*' obj.subject '*'];
        end
    case 'headmodel'
        search_str = ['headmodel_surf_*'];
    case 'noisecov'
        search_str = ['noisecov_*'];
    case {'average','avg'}
        if isempty(obj.eventname) % stimulus name can be used
            obj.eventname = '*';
        end
        search_str = ['data_' obj.eventname '_average_*'];
        
        
    case {'t1','mri'}
        search_str = ['subjectimage_T1.mat'];
    case 'surface'
        % This is complicated, it gets the surface name from the inverse file
        
        try % see if you can load the inverse file
            Inverse =       Load_File(obj,'inverse');
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


