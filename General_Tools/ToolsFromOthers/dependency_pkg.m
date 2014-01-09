function Dep_List = dependency_pkg(SRC, DEST, IS_recursive)
% Copies dependent files for the input SRC to the location DEST
% Excludes matlab root files and dosn't copy SRC
%
% INPUTS
%     SRC:  source, can be an m-file or a whole path. If left out, UI for file
%     DEST: destination for copied files. Will make the dir at DEST if needed
%           If left out will make a folder '[SRC_path]_dep_files'
%     IS_recursive: is only used internally for recursion
%
% OUTPUTS
%     Dep_List: cell array of the files that were copied
%
% EXAMPLES
%   dependency_pkg('/home/foldes/Dropbox/Code/MEG_SF_Tools/Batch_and_Script/Photodiode_ParallelPort_Test.m','/home/foldes/Documents/private/');
%
%   % Simplest: dependency_pkg;
% 
% 2011/04/20 Jit Sarkar
% UPDATES:
% 2013-10-11 Foldes: Comment and cleaned, UI and smarts added, renamed from deppkg

%% Input Check
if ~exist('SRC') || isempty(SRC) || ~exist(SRC, 'file')
    warning('Input file/folder does not exist');
    [filename, pathname] = uigetfile('*.m','Select Mfile to copy dependent files for');
    SRC = [pathname filesep filename];
end

if ~exist('IS_recursive','var')
    IS_recursive = false;
end

if ~exist('DEST') || isempty(DEST)
    [pathstr, name] = fileparts(SRC);
    DEST = [pathstr filesep name '_dep_files'];
end

%% SRC is a directory; get files
% will NOT process nested directories, because that can get messy if the
% DEST folder is a subfolder in the SRC, and will take unecessarily long
if isdir(SRC)
    File_List = dir(SRC);
    Dep_List = [];
    for nn = 1:length(File_List)
        if ~File_List(nn).isdir
            file_name = fullfile(SRC,File_List(nn).name);
            Dep_List = [Dep_List; dependency_pkg(file_name,DEST, IS_recursive)]; %#ok<AGROW>
        end
    end
    return
end

%% Find all top-level dependencies for current file
Dep_List = depfun(SRC, '-quiet', '-toponly');

% Determine which dependencies are matlab bundled functions/toolboxes
IN_matlab = strncmp(matlabroot, Dep_List, length(matlabroot));
% Remove them from the list
Dep_List = Dep_List(~IN_matlab);

% First item is always the current file itself
% Only copy the file, if this is a recursive step
Dep_List = [];
if IS_recursive
    if ~isdir(DEST)
        mkdir(DEST);
    end
    copyfile(Dep_List{1},DEST); % <--Copying is happening here
    Dep_List = Dep_List(1);
end

% Loop through reduced dependency list recursively finding all other
% required files
for  nn = 2:length(Dep_List)
    Dep_List = [Dep_List; dependency_pkg(Dep_List{nn},DEST, true)]; %#ok<AGROW>
end



