% Validate that no additional processing is done in the transformation from sensor space to source space
% Should be inverse [15002 x 306] * sensors [306 x 1] = sources [15002 x 1] --> Surface
%
% 2014-02-04 Foldes
% 2014-02-06 Foldes: Works, finished, validated
% 2014-02-15 Foldes: Now w/ class, checked for running

clear

BST_Info =                  BST_Info_Class;
BST_Info.subject =          'NC01'; % BST_Info.List('subjects')
BST_Info.group_or_ind =     'individual'; % 'group'
BST_Info.condition =        'Trigger_Block_Start'; % name of stimulus
BST_Info.inverse_method =   'wMNE'; % 'dSPM' % The name of the method used

%% Turn BST-Surface into BrainSurface Underlay

[SurfaceFile,SurfaceFile_name] = BST_Info.Load_File('surface');

% Make BrainSurface Object
Brain =                 BrainSurface_Class;
Brain =                 copy_fields(SurfaceFile,Brain); % just pass the whole thing
Brain.underlay_file =   SurfaceFile_name;

Brain = Brain.Plot_Underlay;

%% Get avg sensor data from BST-Avg file
AvgFile =           BST_Info.Load_File('avg');

target_timeS =      3;
% index/sample closest to desired time in seconds
target_time =       find_closest_in_list_idx(target_timeS,AvgFile.Time);
% Sensor data for the given time
SensorData =       	AvgFile.F(:,target_time);

%% Calculate Sources from inverse file
InverseFile =       BST_Info.Load_File('inverse');

% Sources = Inverse * Sensors
SourceData =        InverseFile.ImagingKernel * SensorData(InverseFile.GoodChannel,:);

%% Plot Overlay

clear NewOverlay
NewOverlay.Values =     SourceData;
Brain = Brain.Plot_Overlay(NewOverlay,'Amplitude',0.7,'Colormap','jet');

%% Validate verticies (maybe MNI)








