% Validate that no additional processing is done in the transformation from sensor space to source space
% Should be inverse [15002 x 306] * sensors [306 x 1] = sources [15002 x 1] --> Surface
%
% 2014-02-04 Foldes
% 2014-02-06 Foldes: Works, finished, validated

clear

global BST_DB_PATH

BST_DB_PATH = '/home/foldes/Data/brainstorm_db/';

ExpInfo.project =         'Test';
ExpInfo.subject =         'Subject01_copy';
ExpInfo.group_or_ind =    'group';%'individual';
ExpInfo.task_name =       '1'; % name of stimulus
ExpInfo.inverse_method =  'wMNE'; % 'dSPM' % The name of the method used

%% Turn BST-Surface into BrainSurface Underlay

[SurfaceFile,SurfaceFile_name] = BST_Load_File(ExpInfo,'surface');

% Make BrainSurface Object
Brain =                 BrainSurface_Class;
Brain =                 copy_fields(SurfaceFile,Brain); % just pass the whole thing
Brain.underlay_file =   SurfaceFile_name;

Brain = Brain.Plot_Underlay;

%% Get avg sensor data from BST-Avg file
AvgFile =           BST_Load_File(ExpInfo,'avg');

target_timeS =      0.042;
% index/sample closest to desired time in seconds
target_time =       find_closest_in_list_idx(target_timeS,AvgFile.Time);
% Sensor data for the given time
SensorData =       	AvgFile.F(:,target_time);

%% Calculate Sources from inverse file
InverseFile =       BST_Load_File(ExpInfo,'inverse');

% Sources = Inverse * Sensors
SourceData =        InverseFile.ImagingKernel * SensorData(InverseFile.GoodChannel,:);

%% Plot Overlay

clear NewOverlay
NewOverlay.Values =     SourceData;
Brain = Brain.Plot_Overlay(NewOverlay,'Amplitude',0.7,'Colormap','jet');

%% Validate verticies (maybe MNI)








