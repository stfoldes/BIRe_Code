% [diode_onsetS,diode_offsetS,photodiode_processed]=Calc_Photodiode_Change_FIFtimeS(misc_data,TimeVecs)
% Extract the time(seconds) assocated with a photodiode change (both onset and offset)
% INPUT: photodiode = usually MISC007; timeS = FIF time in seconds (from header)
% Offset marks the start of a video trial
%
% Stephen Foldes (2012-07-06)
% UPDATES:
% 2012-07-09 Foldes: new name
% 2012-10-01 Foldes: now outputs all TimeVecs so you can look at sample_idx, added plot option
% 2012-11-02 Foldes: now more impervious to outliers and if you forgot to turn on the diode
% 2012-11-06 Foldes: new way to calculate changes based off of diff() and not statitics, so no more threshold option (for now)
% 2013-02-09 Foldes: changed a bunch. Is now a lot 'dumber/simpler'. now doesn't need everything packaged in TimeVecs

function [diode_onsetS,diode_offsetS,photodiode_processed]=Calc_Photodiode_Change_FIFtimeS(photodiode,timeS)

% %% Defaults

sample_rate = 1/mean(diff(timeS)); % Get this from the data.

% % % default threshold
% % if ~exist('thres_num_std') || isempty(thres_num_std)
% %     thres_num_std = 1;
% % end
% try
%     sample_rate = Extract.sample_rate;
% catch
%     sample_rate = 1000;
% end
% 
% % if ~exist('plot_flag')
% %     plot_flag = 1;
% % end
% 
% %% Load MISC channels
% [misc_data,timeS] =  Load_MISC_from_FIF(Extract);
% [sti_data] =  Load_STI_from_FIF(Extract);

% if size(misc_data)>2 % new way uses channel 7 (3rd)
%     photodiode = misc_data(:,3);
% else % Old way used channel 1
%     photodiode = misc_data(:,1);
% end

%% Process photodiode

% Low pass filter EMG (30Hz)
clear photodiode_processed filter_b filter_a
Wn=30/(sample_rate/2);
[filter_b,filter_a] = butter(4,Wn,'low'); % 4th order butterworth filter
photodiode_processed=filtfilt(filter_b,filter_a,photodiode);

diode_lp_diff = diff(photodiode_processed);
diode_lp_diff_abs_sort = sort(abs(diode_lp_diff),'descend');
thres = diode_lp_diff_abs_sort(250)/2; % use a threshold that is 1/2 of one of the biggest spikes (not the biggest though)

[diode_up_idx]=TrialTransitions(diode_lp_diff>thres,1000);
[diode_down_idx]=TrialTransitions(diode_lp_diff<-thres,1000);

% remove idx 1 and idx end
diode_up_idx(diode_up_idx == 1)=[];
diode_up_idx(diode_up_idx == length(diode_lp_diff))=[];
diode_down_idx(diode_down_idx == 1)=[];
diode_down_idx(diode_down_idx == length(diode_lp_diff))=[];

% figure;hold all
% plot(timeS(1:end-1),diode_lp_diff,'Color',0*[1 1 1])
% plot([min(timeS) max(timeS)],[thres thres],'r')
% plot([min(timeS) max(timeS)],[-thres -thres],'r')
% plot(timeS(diode_down_idx),diode_lp_diff(diode_down_idx),'r*')
% plot(timeS(diode_up_idx),diode_lp_diff(diode_up_idx),'g*')
% StretchFigure(2)
% 
% figure;hold all
% plot(timeS,(photodiode_processed),'.-','Color',0.8*[1 1 1])
% % plot(timeS,sti_data)
% 
% 
% plot(timeS(diode_up_idx),photodiode_processed(diode_up_idx),'g*')
% plot(timeS(diode_down_idx),photodiode_processed(diode_down_idx),'r*')
% StretchFigure(2)
% legend('Photodiode','Onset','Offset')



%% Photodiode was off...whoops

diode_change_idx = sort(unique([diode_up_idx; diode_down_idx]));

if length(diode_change_idx)==20 || length(diode_change_idx)==40
    diode_onsetS = timeS(diode_up_idx);
    diode_offsetS = timeS(diode_down_idx);
else
    warning('Photodiode is...complicated. Might have been off. Doing best to figure it out.')
    
    window_sizeS = 5.5;
    window_size = floor(window_sizeS*sample_rate);
    
    diode_onset_idx_new = find(diff(diode_change_idx)>window_size);
    
    diode_onsetS = timeS(diode_change_idx(diode_onset_idx_new(1:end)));
    diode_offsetS = timeS(diode_change_idx(diode_onset_idx_new(1:end-1)+1));
end

%% PLOT
    figure;hold all
    plot(timeS,photodiode_processed,'Color',0.4*[1 1 1])
    plot(diode_onsetS,photodiode_processed(find_lists_overlap(timeS,diode_onsetS)),'.g','MarkerSize',25)
    plot(diode_offsetS,photodiode_processed(find_lists_overlap(timeS,diode_offsetS)),'.r','MarkerSize',25)
    legend('Processed Photodiode','Onset','Offset','Location','East')
    xlabel('Time [S]')
    title('AutoDetect Photodiode Events')
    StretchFigure(2)
    
%%

% 
% 
% diode_mean=mean(photodiode_processed);
% [diode_mean, diode_std] = mean_std_wo_outliers(photodiode_processed-diode_mean,0.95);
% 
% TimeVecs.diode_processed = abs( (photodiode_processed)./diode_std )>(thres_num_std);
% 
% [diode_change_idx, min_trial_size, num_trials]=TrialTransitions(TimeVecs.diode_processed);
% 
% diode_offset = TimeVecs.timeS(diode_change_idx(TimeVecs.diode_processed(diode_change_idx)==0));
% diode_onset = TimeVecs.timeS(diode_change_idx(TimeVecs.diode_processed(diode_change_idx)==1));
% 
% if plot_flag
%     figure;hold all
%     plot(TimeVecs.timeS,(abs(photodiode_processed)./diode_std),'Color',0.8*[1 1 1])
%     plot([min(TimeVecs.timeS) max(TimeVecs.timeS)],[thres_num_std thres_num_std],'r')
%     plot(TimeVecs.timeS,TimeVecs.diode_processed,'k','LineWidth',5)
% %     plot(diode_onset,diode_processed_norm(find_lists_overlap(TimeVecs.timeS,diode_onset)),'*g')
% %     plot(diode_offset,diode_processed_norm(find_lists_overlap(TimeVecs.timeS,diode_offset)),'*r')
%     legend('Photodiode','Processed','Onset','Offset')
%     StretchFigure(2)
% end
% 
% %% Photodiode was off...whoops
% 
% if num_trials>21 % should be 21
% 
%     window_sizeS = 6;
%     window_size = floor(window_sizeS*sample_rate);
% 
%     diode_onset_idx_new = find(diff(diode_change_idx)>window_size);
%     
%     diode_onset = TimeVecs.timeS(diode_change_idx(diode_onset_idx_new(1:end)));
%     diode_offset = TimeVecs.timeS(diode_change_idx(diode_onset_idx_new(1:end-1)+1));
% 
%     figure;hold all
%     plot(TimeVecs.timeS,(photodiode-diode_mean)/diode_std,'Color',0.8*[1 1 1])
%     plot(TimeVecs.timeS,Normalize(TimeVecs.diode_processed),'k','LineWidth',5)
%     plot(diode_onset,diode_processed_norm(find_lists_overlap(TimeVecs.timeS,diode_onset)),'*g')
%     plot(diode_offset,diode_processed_norm(find_lists_overlap(TimeVecs.timeS,diode_offset)),'*r')
%     legend('Photodiode','Processed','Onset','Offset')
%     StretchFigure(2)
%     
% end


