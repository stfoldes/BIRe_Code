function [feature_data_by_event,analysis_window_center_time,FeatureParms]=Calc_TimeFreqAnalysis_TimeLocked(raw_data,event_list,pre_event_time,post_event_time,FeatureParms)
% Returns time freq data that is centered around given events.
% This is slow (~7minutes fro 204 sensors) but more efficient than doing spectrum on whole thing
%
% OUTPUT:
%  power [time x chan x freq x event]
%  analysis_window_center_time = time-series-sample index of the center of each of the windows
%
%      pre
%       v
% --------------
% |---Window---|
% --------------
%         --------------
%         |---Window---| EVENT
%         -------------- v
%                 --------------
%                 |---Window---|
%                 --------------
%                         --------------
%                         |---Window---| post
%                         -------------- v
%                                 --------------
%                                 |---Window---|
%                                 --------------
% ----------------------------------------------
% |--------------TIME-LOCK WINDOW--------------|
% ----------------------------------------------
%
% Should pad w/ NaN for unavalible time points so you can still use nanmean, etc.
%
% Foldes 2013-03-01
% UPDATES:
% 2013-07-23 Foldes: Checks if the window doesn't work, saves as a cell.
% 2013-07-25 Foldes: Calc_PSD_PseudoRealTime.m and FeatureParms were changed a bunch, checked to work here.
% 2013-07-26 Foldes: MAJOR Phased out Calc_PSD_PseudoRealTime, so now uses Calc_PSD_TimeLocked


%% SETUP
FeatureParms=Prep_FeatureParms(FeatureParms);

half_window_length = floor(FeatureParms.window_length/2); % used to center analyisis around cue

% samples that make up an analysis window
timelock_window = [(-pre_event_time-half_window_length)+1:(post_event_time+half_window_length)];

%% Calculate


% Make a timing vector for one analysis window
cnt = 0;
clear analysis_window_center_time
for itime=half_window_length:FeatureParms.feature_update_rate:length(timelock_window)-half_window_length
    cnt = cnt+1;
    % go through data as if in real time
    current_raw_data=timelock_window([(itime-half_window_length)+1:(itime+half_window_length)]);
    % sample index of each analysis-point in the analysis kernel...okay, the ideal analysis window
    analysis_window_center_time(cnt) = floor(median(current_raw_data)); % floor added 2013-07-26
end



% Initialize
tic
clear feature_data_by_event
feature_data_by_event=zeros(length(analysis_window_center_time),size(raw_data,2),length(FeatureParms.actual_freqs),length(event_list));

% For each event, do feature calcuation for each window in chunk
for ievent = 1:length(event_list)
    current_event_centers = event_list(ievent) + analysis_window_center_time;
    
    % Only calculate if the window fits in the data
    if min(current_event_centers-half_window_length)>0 && max(current_event_centers+half_window_length)<=size(raw_data,1)
        [feature_data_by_event(:,:,:,ievent),FeatureParms] = Calc_PSD_TimeLocked(raw_data,current_event_centers,FeatureParms);
            else
                warning(['Event window does not work for event #' num2str(ievent) '; Use _cell'])
        %         start_idx = max(current_event_centers(1),half_window_length); % can't be less than half_window_length
        %         end_idx = min(current_event_centers(end),size(raw_data,1)-half_window_length); % can't be bigger than whole data
        %
        %             [feature_data_by_event_cell{ievent},FeatureParms] = Calc_PSD_TimeLocked(raw_data,current_event_centers,FeatureParms);
        %
        %             [feature_data_by_event_cell{ievent}(:,ichan,:),FeatureParms] = Calc_PSD_PseudoRealTime(raw_data(start_idx:end_idx,ichan),[],FeatureParms);
        
    end
    %
end
toc



%% OLD

% tic
% % Initialize
% clear feature_data_by_event
% feature_data_by_event=zeros(length(analysis_window_center_time),size(raw_data,2),length(FeatureParms.actual_freqs),length(event_list));
% % for ievent = 1:length(event_list)
% %     current_time_window = event_list(ievent) + timelock_window;
% %     start_idx = max(current_time_window(1),1); % can't be less than 0
% %     end_idx = min(current_time_window(end),size(raw_data,1)); % can't be bigger than whole data
% %     feature_data_by_event_cell{ievent}=zeros(length([start_idx:end_idx]),size(raw_data,2),length(FeatureParms.actual_freqs));
% % end
%
%
% % Do Shifiting TimeLock thing
% for ievent = 1:length(event_list)
%     current_time_window = event_list(ievent) + timelock_window;
%
%     % Only calculate if the window fits in the data
%     if min(current_time_window)>0 && max(current_time_window)<=size(raw_data,1)
%         for ichan = 1:size(raw_data,2)
%             [feature_data_by_event(:,ichan,:,ievent)] = Calc_PSD_PseudoRealTime(raw_data(current_time_window,ichan),[],FeatureParms);
%         end
%     else
%         warning(['Event window does not work for event #' num2str(ievent) '; Use _cell'])
%         start_idx = max(current_time_window(1),1); % can't be less than 0
%         end_idx = min(current_time_window(end),size(raw_data,1)); % can't be bigger than whole data
%         for ichan = 1:size(raw_data,2)
%             [feature_data_by_event_cell{ievent}(:,ichan,:)] = Calc_PSD_PseudoRealTime(raw_data(start_idx:end_idx,ichan),[],FeatureParms);
%         end
%     end
% end
%
% toc


