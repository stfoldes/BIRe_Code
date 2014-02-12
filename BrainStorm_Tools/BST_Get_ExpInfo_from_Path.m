function [ExpInfo] = BST_Get_ExpInfo_from_File(file)

%  NEVER MIND, BST FILES DON'T HAVE PROJECT NAMES...REDIC

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

% 2014-02-06 Foldes: 

global BST_DB_PATH

% remove db path if needed
if strfind(file,BST_DB_PATH)>0
    file = file(length(BST_DB_PATH):end);
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

switch lower(file_type)
    case {'inverse','headmodel','average','noisecov','avg'}
        base_path = data_path;
    case {'surface','t1','mri'}
        base_path = anat_path;
end


% Determine file name needed for searching
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
            warning(['Loading SurfaceFile ' search_str ' (*NOT FROM INVERSE*)'])
        end
        
end

% Search for file, limit to 1 file
fullfile_name = search_dir(base_path,search_str,'SingleFile',true);

[~,localfile_name] =    fileparts(fullfile_name);

% % Load file contents into a struct
% data_out = load(fullfile_name);


