function [video_movement,frame_timeS] = Calc_Movement_from_Video(video_file,pc_nums,video_timeS)
% Extracts movement from a video using PCA
% Used for time-locking and kinematics
% Takes ~1min/20s of video at 640x480 resolution
% Some ploting functions are include
%
% INPUTS:
%   video_file[OPTIONAL]        = path and file name of a video. If left out or blank, uses a GUI
%   pc_nums[OPTIONAL]           = which PC to use [DEFAULT 1]
%   video_timeS[OPTIONAL]       = [start-time end-time] time range in seconds to assess movement over
%
% PARAMETERS IN FILE (could be varargin if you want)
%   parms.downsample_factor     = how much to downsample video [DEFAULT 1/10]
%
% OUTPUTS:
%   video_movement              = kinematics (i.e. PC) by frame [frames x 1]
%   frame_timeS                 = time [S] for each frame
%
% EXAMPLE: [video_movement,frame_timeS] = Calc_Movement_from_Video('/home/foldes/Documents/Ankle_right_CRX.avi',0.25);
%
% TO DO:
%     Allow for specifying time
%
% 2013-12-13 Foldes
% UPDATES:
%

%% Initialize
% GUI if no video file is given
if ~exist('video_file') || isempty(video_file)
    [FileName,PathName]= uigetfile('*.*','Select video file to extract movement from');
    video_file = [PathName filesep FileName];
end

% How much to downsample
parms.downsample_factor = 1/10;

%% Process Video
video_Obj = VideoReader(video_file);

% Define time to use (default to all)
if ~exist('video_timeS') || isempty(video_timeS)
    video_timeS = [0 video_Obj.Duration];
end
% frames to consider for PCA. Limited to NumberOfFrames
video_time_frames = (min(video_timeS)*video_Obj.FrameRate)+1 : min(max(video_timeS)*video_Obj.FrameRate,video_Obj.NumberOfFrames);
num_frames = length(video_time_frames);


% tic % ~1min for 20sec [640 x 480]

% Initialize [frames x pixels]
vid_1D = zeros(num_frames,(video_Obj.Height*parms.downsample_factor)*(video_Obj.Width*parms.downsample_factor));

for iframe = 1:num_frames
    current_raw_frame = video_time_frames(iframe);
    
    % resize
    frame_small = imresize(read(video_Obj,current_raw_frame),parms.downsample_factor,'nearest');
    % figure;imshow(frame_small)
    
    % make grey scale
    frame_small_gray = rgb2gray(frame_small);
    % figure;imshow(frame_small_gray)
    
    % make flat (1D)plot_percentage
    frame_small_gray_flat = reshape(frame_small_gray,1,[]);
    
    % turn from uint8 to double, transpose
    vid_1D(iframe,:) = double(frame_small_gray_flat');
end
% toc

%% Do PCA

[coef,score,latent]=princomp(vid_1D);

%% =====Ploting functions========

% % portion of var explained by each pc
% contribution = (latent)./sum(latent);
% contribution_cumsum = cumsum(contribution);
% figure
% plot(contribution_cumsum,'LineWidth',3)
% % axis_lim(1,'y')
% ylabel('% accounted for');xlabel('PC #')

%% Show top PCs
%
% time of each frame
frame_timeS = (video_time_frames-1).*(1/video_Obj.FrameRate); % -1 to start from 0

% pcs4plot = [1:6];
% figure;hold all
% for ipc = 1:length(pcs4plot)
%     current_pc = pcs4plot(ipc);
%     subplot(length(pcs4plot),1,ipc)
%     plot(frame_timeS,score(:,current_pc))
%     ylabel(['PC #' num2str(current_pc)])
% end
% xlabel('Time [S]')


% Pick your PC (could use GUI, see: Plot_Inspect_TimeSeries_Signals(frame_timeS,score(:,1:10)) )
num_pcs4plot = length(pc_nums);
video_movement = zscore(score(:,pc_nums));

%% Plot Video w/ PC
plot_percentage = 1;

fig = figure;hold all
Figure_Stretch(2,2)
for iframe = 1:floor(num_frames*plot_percentage)
    current_raw_frame = video_time_frames(iframe);
    
    if ishandle(fig) == 0  % figure was closed, break
        break
    end
    clf(fig);hold all
    
    subplot(num_pcs4plot+2,1,[1 2]);
    frame_raw = imresize(read(video_Obj,current_raw_frame),parms.downsample_factor,'nearest');
    imshow(frame_raw)
    % pause(1/video_Obj.FrameRate) % too slow
    
    for ipc = 1:num_pcs4plot
        subplot(num_pcs4plot+2,1,ipc+2);hold all
        plot(frame_timeS,video_movement(:,ipc),'.-')
        plot(frame_timeS(iframe),video_movement(iframe,ipc),'.r','MarkerSize',50)
        xlabel('Time [S]');ylabel(['PC #' num2str(pc_nums(ipc))])
    end
    
    drawnow
end
% close(fig)


