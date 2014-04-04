% processed_data = Calc_Rectify_Smooth(raw_data,sample_rate,differential_flag[OPTIONAL]);
%
% Standard processing for timeseries data before finding simple onsets, like EMG or EOG
% Rectify, LP filter, Remove moving mean, Moving average [TAKES 36s]
% Noncausal filtering. Hardcoded some times (appropriate)
% differential_flag[OPTIONAL]: 1 = does a diff() first. Important for looking at Acc and EMG
%   NOTE: to get ECG from EMG do not use this flag
%
% Stephen Foldes [02/2011 - Redone: 2012-10-01]
% UPDATES:
% 2013-04-08 Foldes: Replaced from Calc_Processed_EMG.m. Now removes manditory diff() done for MEG-EMG. Cleaned everything up also

function [processed_data] = Calc_Rectify_Smooth(raw_data,sample_rate,differential_flag)

disp('***BE PATIENT, This can take a while***')

% diff for EMG (from MEG, EMG is funny, so a diff is needed)
if exist('differential_flag') && (differential_flag == 1)
    diff_data=diff(raw_data);
    diff_data = [zeros(1,size(diff_data,2)); diff_data]; %append zeros
    raw_data = diff_data;
end

% Rectify
rec_data=abs(raw_data);

% Low pass filter (40Hz)
clear LP_data filter_b filter_a
Wn=40/(sample_rate/2);
[filter_b,filter_a] = butter(4,Wn,'low'); % 8th order butterworth filter
LP_data=filtfilt(filter_b,filter_a,rec_data);

% Moving mean removal w/ large window [THIS IS VERY SLOW, Maybe could HP filter]]
moving_zscore_window_sizeS=3; % 3s window to remove mean from (NONCAUSAL)
moving_zscore_window_size=moving_zscore_window_sizeS*sample_rate;
moving_zscore_window_size_half = floor(moving_zscore_window_size/2);

mean_removed_data=zeros(size(LP_data));
for ichan = 1:size(LP_data,2)
    for itime=1+moving_zscore_window_size_half:size(LP_data,1)-moving_zscore_window_size_half
        current_mean=mean(LP_data(itime-moving_zscore_window_size_half:itime+moving_zscore_window_size_half,ichan));
        mean_removed_data(itime,ichan) = (LP_data(itime,ichan)-current_mean);
    end
end

% Moving average w/ small window (takes a bit) (NONCAUSAL)
avg_window_sizeS=0.100; %100ms
avg_window_size=avg_window_sizeS*sample_rate; % not much difference at 100
avg_window_size_half = floor(avg_window_size/2);

smoothed_data=zeros(size(mean_removed_data));
for ichan = 1:size(mean_removed_data,2)
    for itime=1+avg_window_size_half:size(mean_removed_data,1)-avg_window_size_half
        smoothed_data(itime,ichan)=mean(mean_removed_data(itime-avg_window_size_half:itime+avg_window_size_half,ichan));
    end
end

processed_data = single(zscore(abs(smoothed_data)));

%% Plot

% figure;hold all
% for ichan = 1:size(raw_data,2)
%     subplot(size(raw_data,2),1,ichan);hold all
%     plot(zscore(raw_data(:,ichan)));
%     plot(zscore(rec_data(:,ichan)));
%     plot(zscore(LP_data(:,ichan)));
%     plot(zscore(mean_removed_data(:,ichan)));
%     plot(processed_data(:,ichan),'LineWidth',3);
%     
%     xlabel('Time [samples]')
%     legend('raw','rec_data','LP_data','mean_removed_data','processed')
%     xlim([1 20000])
% end
% Figure_Stretch(2)