% Load BST inverse-data, make a figure, set surface
% 2014-01-31 Foldes
% UPDATES:
% 2014-02-03 Foldes:
clear

% Start BST and go to protocol

%% Load BST info
ExpInfo.subject_id =        'Subject01_copy';
ExpInfo.stim_name =         '1'; % name of stimulus
ExpInfo.inverse_method =    'wMNE'; % 'dSPM' % The name of the method used



%% Load BST data

% Get all the data from inverse file and surface
[Inverse,Inverse_filename] =        BST_Load_File(ExpInfo,'inverse');
[SurfaceFile] =                     BST_Load_File(ExpInfo,'surface');

%% Implant Sensor Data into AvgFile

[AvgFile,~,AvgFile_fullfilename] =  BST_Load_File(ExpInfo,'avg');

% Backup AvgFile
copyfile(AvgFile_fullfilename,fullfile(dir_up(AvgFile_fullfilename),'BackupAvgFile.mat'));

% % Overwrite Avg File
% %   'ChannelFlag','Comment','DataType','Device','Events','History'
% %   'F' [chan x sample],'Time' [1xsamples] (in seconds),'nAvg'
% 
% SensorData =        zeros(306,1);
% SensorData(1:9) =   1;BST_Plot_Overlay(hFig,NewOverlay,'Amplitude',0.5);
% 
% AvgFile.F =     [SensorData SensorData];
% AvgFile.Time =  [0 2];

% Overwrite AvgFile (but save each field as a variable)
save(AvgFile_fullfilename,'-struct','AvgFile');


%% Make a BST Figure
% Must start BST, export something, then my programs take over
if brainstorm('status') == 0 % unless its already open
    brainstorm;
end

if ~exist('hFig') || ~ishandle(hFig)
    % Build string fro view_surface_data.m
    % OverlayFile_str = BST_Build_OverlayFile_str(ExpInfo);
    OverlayFile_str = BST_Build_OverlayFile_str(ExpInfo);
    
    % Open surface plot W/ Overlay
    hFig =  view_surface_data([], OverlayFile_str);
    
    % W/O Overlay (just cortex, but no data options)
    %     hFig = view_surface(Inverse.SurfaceFile);
end

%%

% Get source data from figure (or just calcuate...better check)
% verticies = BST_Get_Scout(atlas_name,roi_name)
%   SurfaceFile.Atlas(3).Scouts.Label
%   SurfaceFile.Atlas(3).Scouts.Vertices
% Count sources above thresh in ROI vertices
%
% How do things move if you smooth?


%% Return backup of AvgFile
% % Backup AvgFile
copyfile(fullfile(dir_up(AvgFile_fullfilename),'BackupAvgFile.mat'),AvgFile_fullfilename);





%% Calculate Source Data

% sensor_num = 1:306;
% sensor_num(3:3:306) = [];
% new_sensor_num = find(sensor_num==43);
%
% SensorData = zeros(204,1);
% SensorData(new_sensor_num) =   1;
% SensorData(new_sensor_num+1) = 1;

SensorData =            zeros(204,1);
SensorData(1:end/2) =   1;

% Apply Imaging Kernel
SourceData = Inverse.ImagingKernel * SensorData;

%%

SourceData = zeros(size(Inverse.ImagingKernel,1),1);
SourceData(100:400) = 1;
% SourceData(200:600) = 1;


%% Set Source data

hFig = BST_Set_Sources(hFig,SourceData);


