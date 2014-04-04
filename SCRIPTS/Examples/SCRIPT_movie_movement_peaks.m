% Calculates movement from video
% Also use GUIs to help mark peaks and troughs
% 2013-12-13 Foldes
clear
video_file = '/home/foldes/Documents/Ankle_right_CRX.avi';
[video_movement,frame_timeS] = Calc_Movement_from_Video(video_file,[1:2]);
pc_choice = 1;

data_rate = 1/median(diff(frame_timeS));

freqs = 2; % Hz LP filter
event_windowS = 1;


% bandpass filter to given range (TAXING)clear filter_b filter_a
Wn=freqs/(data_rate/2);
[filter_b,filter_a] = butter(4,Wn,'low'); % 4th order butterworth filter
movement_filt=filtfilt(filter_b,filter_a,video_movement(:,pc_choice));

% figure;hold all
% plot(frame_timeS,zscore(video_movement))
% plot(frame_timeS,zscore(movement_filt),'r')

% Starting Parameters
ArtifactParms.thres                 = 1; % STDs from mean to set the threshold
ArtifactParms.artifact_max_rateS    = 1; % amount of time[S] that the artifact CANNOT repeat (e.g. >2x per second)
ArtifactParms.settle_down_windowS   = 0; % time since last mark that must be below threshold in order to allow for another mark
ArtifactParms.peak_windowS          = 1; % amount of time[S] used to find the peak of the artifact
ArtifactParms.thres_too_big         = 5; % STDs from mean to set as a second threshold that is too big to consider

% Find Peaks
[Events.peak,Events.peak_parms]= GUI_Auto_Event_Markers(movement_filt,frame_timeS,[],ArtifactParms);        

% Find Troughs (-PC)
[Events.trough,Events.trough_parms]= GUI_Auto_Event_Markers(-movement_filt,frame_timeS,[],ArtifactParms);        

%%
% events_list = Events.peak;
plot_percentage = .4;


% PLOTING VIDEO W/ PC
video_Obj = VideoReader(video_file);

fig = figure;hold all
Figure_Stretch(2,2)
for iframe = 1:floor(video_Obj.NumberOfFrames*plot_percentage)
    clf(fig);hold all
    
    subplot(2,1,1);
    frame_raw = imresize(read(video_Obj,iframe),1/5,'nearest');
    imshow(frame_raw)
    % pause(1/video_Obj.FrameRate) % too slow
    
    subplot(2,1,2);hold all
    plot(frame_timeS,movement_filt,'.-')
    plot(frame_timeS(Events.peak),movement_filt(Events.peak),'.g','MarkerSize',40)
    plot(frame_timeS(Events.trough),movement_filt(Events.trough),'.b','MarkerSize',40)
    plot(frame_timeS(iframe),movement_filt(iframe),'.r','MarkerSize',50)
    xlabel('Time [S]');ylabel('PC')
    drawnow
end
close(fig)







