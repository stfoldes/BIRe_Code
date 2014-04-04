function obj=build(obj,path_file)
% Build the database from txt file
% path_file defines the global variables MY_PATHS (SEE: PATHS_meg_neurofeedback)
% project file MUST be named [project '_DB.txt']
% Can set up to cheat to its computer specific - Add your own paths at some point
%
% paths.local_base  = local path for data
% paths.server_base = where the data is stored on the server (can be set to local)
% MY_PATHS.db_full_name = full path and name of database file (should be on server)
%
%
% EXAMPLE:
%   [DB,DBbase_location,paths.local,paths.server]=DB_Load('meg_neurofeedback');
%
% 2013-06-11 Foldes
% UPDATES:
% 2013-07-02 Foldes: user name --> computer name
% 2013-08-16 Foldes: Renamed from DB_Load_Database_Cheat
% 2013-09-30 Foldes: Updated to be more robust to different file organization (e.g. Presurgical), can also start a project
% 2013-10-04 Foldes: Metadata--> DB, paths now global

% Generate global paths
eval([path_file ';'])

global MY_PATHS

if isempty(MY_PATHS)
    error('You need PANTS, I mean PATHS.  Run DEF_MEG_paths or something');
end

% try to do this automatically
if ~isfield(MY_PATHS,'db') || isempty(MY_PATHS.db_base)
    MY_PATHS.db_base = [MY_PATHS.server_base];
end

% Get specific paths and load DB
MY_PATHS.db_full_name=[MY_PATHS.db_base filesep MY_PATHS.project '_DB.txt'];

%% check existance
disp(['Loading ' MY_PATHS.db_full_name '...'])
if exist(MY_PATHS.db_full_name)~=2 % no file exists
    
    % try to start manual picking at a good spot
    path2check=MY_PATHS.server_base;    
    MY_PATHS.server_base = uigetdir(path2check,'Database File Not Found --> SELECT PROJECT FOLDER');
    
    [database_name,MY_PATHS.db_base] = uigetfile('*.txt','SELECT EXISTING DATABASE FILE (cancel makes new db, or cancels)',MY_PATHS.server_base);
    if database_name == 0
        MY_PATHS.db_base = uigetdir(MY_PATHS.server,'SELECT FOLDER FOR DATABASE');
        if MY_PATHS.db_base ~= 0
            MY_PATHS.db_full_name=[MY_PATHS.db_base filesep MY_PATHS.project '_DB.txt'];
            if questdlg_YesNo_logic(['Create new project? ' MY_PATHS.db_full_name])
                %DB = DB_Class();
                warning off
                Write_StandardStruct2TXT(obj,MY_PATHS.db_full_name);
                warning on
            end
        end
    else
        MY_PATHS.db_full_name=[MY_PATHS.db_base filesep database_name];
    end
end

%% Load DB from text file
% DB = DB_Class();
obj = Load_StandardStruct_from_TXT(obj,MY_PATHS.db_full_name);

