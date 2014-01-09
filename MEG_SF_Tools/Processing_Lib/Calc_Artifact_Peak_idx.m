function [artifact_peak_idx, artifact_peak_clean_idx,ArtifactParms] = Calc_Artifact_Peak_idx(processed_data,sampling_rate,ArtifactParms)
% Finds index of the peak of artifacts (or anything). Esp. for EOG marking for SSP removal
% artifact_peak_idx & artifact_peak_clean_idx are cells for each channel (if more than one channel given)
% Consider preprocessing:
%     processed_data = Calc_Rectify_Smooth(data,sampling_rate);
%     AND zscore
%
% artifact_peak_clean_idx = doesn't mark events that are really big. Important for non-characteristic artifacts like in EOG
%
%     ArtifactParms.thres = 0.5; % STDs from mean to set the threshold
%     ArtifactParms.artifact_max_rateS = 1; % amount of time[S] that the artifact CANNOT repeat (e.g. >2x per second)
%     ArtifactParms.peak_windowS = 0; % amount of time[S] used to find the peak of the artifact
%     ArtifactParms.thres_too_big = 3; % STDs from mean to set as a second threshold that is too big to consider
%     ArtifactParms.settle_down_windowS = 0; % time since last mark that must be below threshold in order to allow for another mark
%
% Foldes 2013-04-08
% UPDATES:
% 2013-04-15 Foldes: Parameters now input, ArtifactParms.peak_windowS=0 --> no peak window
% 2013-10-10 Foldes: added settle_down_windowS
% 2013-12-13 Foldes: Input ArtifactParms 


%% ---PARAMETERS---
if ~exist('ArtifactParms') || isempty(ArtifactParms)
    ArtifactParms.thres = 0.5; % STDs from mean to set the threshold
    ArtifactParms.artifact_max_rateS = 1; % amount of time[S] that the artifact CANNOT repeat (e.g. >2x per second)
    ArtifactParms.peak_windowS = 0; % amount of time[S] used to find the peak of the artifact
    ArtifactParms.thres_too_big = 3; % STDs from mean to set as a second threshold that is too big to consider
    ArtifactParms.settle_down_windowS = 0; % time since last mark that must be below threshold in order to allow for another mark
end

%% ---PROCESSING---

for ichan = 1:size(processed_data,2)
    % Find EOG onsets
    % All points over threshold
    raw_artifact_idx=[];
    while isempty(raw_artifact_idx)
        thres_crossing_data = processed_data(:,ichan)>ArtifactParms.thres;
        raw_artifact_idx = find(thres_crossing_data);
        if isempty(raw_artifact_idx)
            ArtifactParms.thres=input(['Input lower threshold than ' num2str(ArtifactParms.thres) ': ']);
        end
    end
    
    %% Get onsets, first thres crossings
    artifact_max_rate = floor(ArtifactParms.artifact_max_rateS*sampling_rate);
    settle_down_window = floor(ArtifactParms.settle_down_windowS*sampling_rate);
    
    cnt = 0; clear artifact_onset_idx
    cnt = cnt + 1;
    artifact_onset_idx(cnt)=raw_artifact_idx(1);
    for idx=2:length(raw_artifact_idx)
        if (raw_artifact_idx(idx)-artifact_onset_idx(cnt))>artifact_max_rate
            % I'd like the mark this idx b/c it passes the threshold and is sufficenty beyond the last mark
            % But first, lets see if its settled down
            
            % from this idx back to settle_down_window, was the data absent of thres-crossings?
            settled_down_flag = sum(thres_crossing_data(raw_artifact_idx(idx)-settle_down_window:raw_artifact_idx(idx)-1))==0;
            
            if settled_down_flag
                cnt = cnt + 1;
                artifact_onset_idx(cnt)=raw_artifact_idx(idx);
            end
        end
    end
    % artifact_onset_idx = all points that are far enough away in time
    
    %% Find the peak around the given list of onsets (400ms window)
    peak_window = ArtifactParms.peak_windowS*sampling_rate;
    peak_window_half = floor(peak_window/2);
    
    clear artifact_peak_idx_per_chan
    artifact_cnt = 0;
    for idx = 1:length(artifact_onset_idx)
        current_start_idx = max(artifact_onset_idx(idx)-peak_window_half+1,1);
        current_end_idx   = min(artifact_onset_idx(idx)+peak_window_half,length(processed_data));
        
        local_peak_idx = max_idx(processed_data(current_start_idx:current_end_idx));
        
        if peak_window_half>0
            if (local_peak_idx~=(peak_window_half*2)) && local_peak_idx~=1 % If the first or last point is the max, then the artifact is weird and shouldn't be considered
                artifact_cnt = artifact_cnt+1;
                artifact_peak_idx_per_chan(artifact_cnt) = (current_start_idx-1) + local_peak_idx;
            end
        else
            artifact_cnt = artifact_cnt+1;
            artifact_peak_idx_per_chan(artifact_cnt) = (current_start_idx-1);
        end
        
        %     figure;hold all
        %     plot([current_start_idx:artifact_onset_idx(idx)+peak_window_half],processed_data(current_start_idx:artifact_onset_idx(idx)+peak_window_half),'.-')
        %     plot(artifact_peak_idx_per_chan(idx),processed_data(artifact_peak_idx_per_chan(idx)),'r.')
    end
    
    %% Remove huge stuff.
    artifact_peak_clean_idx_per_chan=artifact_peak_idx_per_chan;
    for idx = length(artifact_peak_clean_idx_per_chan):-1:1
        if processed_data(artifact_peak_clean_idx_per_chan(idx))>ArtifactParms.thres_too_big
            artifact_peak_clean_idx_per_chan(idx)=[];
        end
    end
    
    artifact_peak_idx{ichan} = artifact_peak_idx_per_chan;
    artifact_peak_clean_idx{ichan} = artifact_peak_clean_idx_per_chan;
    
end % channel

%% Plot

% timeS=[0:length(processed_data)-1]/sampling_rate;
%
% figure;hold all
% for ichan = 1:size(processed_data,2)
%     subplot(size(processed_data,2),1,ichan);hold all
%
%     plot(timeS,zscore(processed_data(:,ichan)));
%     plot([min(timeS) max(timeS)],ArtifactParms.thres.*[1 1],'r')
%     %plot(timeS(artifact_onset_idx),ArtifactParms.thres.*ones(size(artifact_onset_idx{ichan})),'.g')
%     plot(timeS(artifact_peak_idx{ichan}),ArtifactParms.thres.*ones(size(artifact_peak_idx{ichan})),'.c')
%     plot(timeS(artifact_peak_clean_idx{ichan}),ArtifactParms.thres.*ones(size(artifact_peak_clean_idx{ichan})),'.m')
%     xlabel('Time [S]')
% end
% legend('processed','thres','onset','peak','clean-peak')
% Figure_Stretch(2)






