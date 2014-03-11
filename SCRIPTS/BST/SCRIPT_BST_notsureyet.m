% Validate that no additional processing is done in the transformation from sensor space to source space
% Should be inverse [15002 x 306] * sensors [306 x 1] = sources [15002 x 1] --> Surface
%
% 2014-02-04 Foldes
% 2014-02-06 Foldes: Works, finished, validated
% 2014-02-15 Foldes: Now w/ class, checked for running

clear

BST_Info =                  BST_Info_Class;
BST_Info.subject =          'NC01'; % BST_Info.List('subjects')
BST_Info.condition =        'Attempt_Grasp_RT'; % name of stimulus

BST_Info.group_or_ind =     'individual'; % 'group'
BST_Info.inverse_method =   'wMNE'; % 'dSPM' % The name of the method used


%% Get avg sensor data from BST-Avg file
AvgFile =           BST_Info.Load_File('avg');

target_timeS =      .160;
% index/sample closest to desired time in seconds
target_time =       find_closest_in_list_idx(target_timeS,AvgFile.Time);
% Sensor data for the given time
SensorData =       	AvgFile.F(:,target_time);

%% Calculate Sources from inverse file
InverseFile =       BST_Info.Load_File('inverse');

% Sources = Inverse * Sensors
SourceData =        InverseFile.ImagingKernel * SensorData(InverseFile.GoodChannel,:);

%% Now we have a new sources to plot

% make discrete for now
%SourceData = SourceData>quantile(SourceData,0.75);

% Pop up that inverse surface
% Open surface plot W/ Overlay
hFig =  view_surface_data([], BST_Info.OverlayFile_str);

NewOverlay.Values = SourceData;
% NewOverlay.hFig =   hFig;
% NewOverlay.hPatch = TessInfo.hPatch; % <-- put this in the plot

BST_Plot_Overlay(hFig,NewOverlay,'Amplitude',0.5);


%% QUESTIONS
%{
If i mess w/ just the data will it be easy to 'mess' back up, like by moving the time?
Would it be better to overwrite the avg file like was doing before?

%}


% 
% %% Plot Overlay
% 
% clear NewOverlay
% NewOverlay.Values =     SourceData;
% Brain = Brain.Plot_Overlay(NewOverlay,'Amplitude',0.5,'Colormap','jet');
% 
% %% Validate verticies (maybe MNI)





