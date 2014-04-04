function movement = Calc_Movement_from_Video(video_file,plot_flag)
% Extracts movement from a video using PCA
% Used for time-locking and kinematics
% Takes ~1min/20s of video at 640x480 resolution
% Some ploting functions are include
%
% INPUTS:
%   video_file[OPTIONAL]        = path and file name of a video. If left out or blank, uses a GUI
%   plot_flag[OPTIONAL]         = 1: plots the video w/ the the PC [DEFAULT 0 - no plot]
%
% PARAMETERS IN FILE (could be varargin if you want)
%   parms.downsample_factor     = how much to downsample video [DEFAULT 1/10]
%   parms.pc_num                = which PC to use [DEFAULT 1]
%
% EXAMPLE: movement = Calc_Movement_from_Video('/home/foldes/Documents/Ankle_right_CRX.avi',1);
%
% 2013-12-12 Foldes


%% Initialize
% GUI if no video file is given
if ~exist('video_file') || isempty(video_file)
    video_file = uigetfile('*.*','Select video file to extract movement from')
end
    
if ~exist('plot_flag') || isempty(plot_flag)
    plot_flag = 0;
end

% How much to downsample
parms.downsample_factor = 1/10;
% Which PC to use
parms.pc_num = 1;


%% Process Video
video_Obj = VideoReader(video_file);

%tic % ~1min for 20sec [640 x 480]

% Initialize [frames x pixels]
vid_1D = zeros(video_Obj.NumberOfFrames,(video_Obj.Height*parms.downsample_factor)*(video_Obj.Width*parms.downsample_factor));

for iframe = 1:video_Obj.NumberOfFrames
    
    % resize
    frame_small = imresize(read(video_Obj,iframe),parms.downsample_factor,'nearest');
    % figure;imshow(frame_small)
    
    % make grey scale
    frame_small_gray = rgb2gray(frame_small);
    % figure;imshow(frame_small_gray)
    
    % make flat (1D)plot_flag
    frame_small_gray_flat = reshape(frame_small_gray,1,[]);
    
    % turn from uint8 to double, transpose
    vid_1D(iframe,:) = double(frame_small_gray_flat');
end
%toc

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
% % time of each frame
% frame_timeS = (0:video_Obj.NumberOfFrames-1).*(1/video_Obj.FrameRate);
% 
% num_pcs4plot = 4;
% figure;hold all
% for ipc = 1:num_pcs4plot
%     subplot(num_pcs4plot,1,ipc)
%     plot(frame_timeS,score(:,ipc))
%     ylabel(['PC #' num2str(ipc)])
% end
% xlabel('Time [S]')

% Pick your PC (could use GUI, see: Plot_Inspect_TimeSeries_Signals(frame_timeS,score(:,1:10)) )
pc_z = zscore(score(:,parms.pc_num));

%% Can do some classification

% thresed_pc = pc_z>=0;
% pc_up_thru_thres_idx = find(diff(thresed_pc)>0==1)+1; % +1 b/c of diff() offset
% 
% figure;hold all
% plot(frame_timeS,pc_z,'.-')
% plot(frame_timeS,thresed_pc,'r.-')
% plot(frame_timeS(pc_up_thru_thres_idx),ones(length(pc_up_thru_thres_idx),1),'g*')

%% Plot Video w/ PC

if plot_flag == 1
    
    fig = figure;hold all
    Figure_Stretch(2,2)
    for iframe = 1:video_Obj.NumberOfFrames
        clf(fig);hold all
        
        subplot(2,1,1);
        frame_raw = imresize(read(video_Obj,iframe),parms.downsample_factor,'nearest');
        imshow(frame_raw)
        % pause(1/video_Obj.FrameRate) % too slow
        
        subplot(2,1,2);hold all
        plot(frame_timeS,pc_z,'.-')
        plot(frame_timeS(iframe),pc_z(iframe,parms.pc_num),'.r','MarkerSize',50)
        xlabel('Time [S]');ylabel('PC')
        drawnow
    end
    
end

%% Output definitions

movement = pc_z;

