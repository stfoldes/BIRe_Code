% [EMG_onsets,EMG_during_rest_mask,rx_time_calculatedS,EMG_thres_SD_move,EMG_thres_SD_rest]=Calc_EMG_Onset_per_Trial(processed_EMG_data,TimeVecs,TrialInfo);
% Uses processed EMG (or any signal) and trial info to make a good guess at event onsets around movement trials
%   and gives a mask for EMG contamination during rest
% Uses a lot of Foldes standard structures.
% Use also for accerometer
%
% EMG_trigger = processed_EMG > EMG_thres_SD_move;
%
% Foldes 2013-02-25
% UPDATES:
% 2013-02-27 Foldes: made sure you can't look back in time or forward in time more than the data allows
% 2013-03-01 Foldes: Increased duration of good window
% 2013-03-06 Foldes: MAJOR - Added EMG_during_rest, now has two thresholds, rx-time representation better.

function [EMG_onsets,EMG_during_rest_mask,rx_time_calculatedS,EMG_thres_SD_move,EMG_thres_SD_rest]=Calc_EMG_Onset_per_Trial(processed_EMG_data,TimeVecs,TrialInfo)

%% Hardcoded parameters
% Look before and after target onset
rx_time_window_moveS = [-0.250 1.75]; % window that is acceptable for an emg onset to occur around a move cue-event

EMG_thres_SD_move = 1.5; % Start with 1.5 STD
EMG_thres_SD_rest = 0.5; % Start with 1.5 STD

%% Organize data around move trial starts
% This is just to make a histogram of rx time
event_idx = TrialInfo.timeseries_trial_start_idx(TrialInfo.move_trial_nums);

% sec -> samples
rx_time_window_move=round(rx_time_window_moveS.*TimeVecs.data_rate);

% Time lock ave
clear data_by_event
event_cnt = 0;
for ievent=1:length(event_idx) % go through event index given
    current_event_idx = event_idx(ievent);
    if (current_event_idx+min(rx_time_window_move)+1 > 0) && (current_event_idx+max(rx_time_window_move) < size(processed_EMG_data,1))
        event_cnt = event_cnt+1;
        data_by_event(:,event_cnt)=processed_EMG_data(current_event_idx+min(rx_time_window_move)+1:current_event_idx+max(rx_time_window_move),:);
    end
end

%% Calc and Plots
hist_fig = figure; hold all
timeseries_fig = figure;hold all;Figure_Stretch(4)
while 1
    
    % EMG detected if over threshold
    EMG_trigger_move = (processed_EMG_data>EMG_thres_SD_move);
    EMG_trigger_rest = (processed_EMG_data>EMG_thres_SD_rest);
    
    % ===EMG onset calculation===
    EMG_onsets =[];
    rx_time_calculatedS =[];
    icnt=0;
    
    % go thru all move trials
    for imove = 1:length(TrialInfo.move_trial_nums)
        % adjust for a rx time
        move_start_idx_w_rx=event_idx(imove)+min(rx_time_window_move);
        
        % make sure your still within the bounds of the data
        if (move_start_idx_w_rx>0) && (event_idx(imove)+max(rx_time_window_move)<size(EMG_trigger_move,1))
            % Find first EMG onset in this window around the movement cue
            EMG_start_from_move = find(EMG_trigger_move(move_start_idx_w_rx:event_idx(imove)+max(rx_time_window_move)),1,'first');
            
            % Capture the onset times
            if ~isempty(EMG_start_from_move)
                icnt=icnt+1;
                EMG_onsets(icnt)=(move_start_idx_w_rx+EMG_start_from_move-1);
                rx_time_calculatedS(icnt)=(EMG_start_from_move+min(rx_time_window_move))/TimeVecs.data_rate;
            end
        end
    end
    % =======================    
 
    % ===EMG During Rest calculation===
    rest_code = unique(TimeVecs.target_code(TrialInfo.timeseries_trial_start_idx(TrialInfo.rest_trial_nums)));
    if max(size(rest_code))>1
        error('Something is wrong with your TrialInfo.rest_trial_nums')
    end
    EMG_during_rest_mask = zeros(size(EMG_trigger_rest));
    EMG_during_rest_mask = EMG_trigger_rest & (TimeVecs.target_code==rest_code);
    % =======================
    

    %===PLOTS====
    figure(hist_fig);hold all
    plot([min(rx_time_window_move)+1:max(rx_time_window_move)]/TimeVecs.data_rate,sum(data_by_event>EMG_thres_SD_move,2)/length(TrialInfo.move_trial_nums))
    xlabel('Time from Cue Onset [S]')
    ylabel('Number of Detections/Num. Move Cues')
    title(['Rx Time = mean [' num2str(mean(rx_time_calculatedS)) char(177) num2str(std(rx_time_calculatedS)) '], median[' num2str(median(rx_time_calculatedS)) ']'])
    set(hist_fig,'Position',[100 28 560 420])

    figure(timeseries_fig);
    clf
    hold all
    plot(TimeVecs.timeS,TimeVecs.target_code,'b')
    plot(TimeVecs.timeS(EMG_onsets),EMG_thres_SD_move.*ones(size(EMG_onsets)),'og','MarkerSize',20,'MarkerFaceColor','g')
    plot(TimeVecs.timeS,zscore(processed_EMG_data),'k')
    plot(TimeVecs.timeS(EMG_trigger_move==1),EMG_thres_SD_move.*EMG_trigger_move(EMG_trigger_move==1),'r.')
    plot(TimeVecs.timeS(EMG_during_rest_mask==1),EMG_thres_SD_rest.*EMG_during_rest_mask(EMG_during_rest_mask==1),'rx','MarkerSize',30)
    xlim([min(TimeVecs.timeS)+50 min(TimeVecs.timeS)+250])
    ylim([-1 6])
    legend({'Target Code','Events Marked','Processed Signal','Detection','Detect during rest'},'Location','NorthWest');
    title([num2str(length(EMG_onsets)) ' Events Marked'])
    xlabel('Time [S]')
    set(gca,'LooseInset',get(gca,'TightInset'));
    
    clear answer
    answer = inputdlg_wPosition([],...
        {['Input new MOVE threshold (xSD): Num Events Detected: ' num2str(length(EMG_onsets)) ', Median RxTime ' num2str(median(rx_time_calculatedS)) 'S, Current Thres: ' num2str(EMG_thres_SD_move) 'SD']...
        ['Input new REST threshold (xSD): Current Thres: ' num2str(EMG_thres_SD_rest) 'SD']},...
        ['Try a New Threshold? [CANCEL accepts current value]'],2);
    if isempty(answer)
        break
    else
        % FOR MOVE
        if isempty(str2num(cell2mat(answer(1)))) % if you accidently pushed OKAY without anything
            EMG_thres_SD_move = EMG_thres_SD_move;
        else
            EMG_thres_SD_move = str2num(cell2mat(answer(1)));
        end
        % FOR REST
        if isempty(str2num(cell2mat(answer(2)))) % if you accidently pushed OKAY without anything
            EMG_thres_SD_rest = EMG_thres_SD_rest;
        else
            EMG_thres_SD_rest = str2num(cell2mat(answer(2)));
        end
    end
end


close(timeseries_fig)
close(hist_fig)

