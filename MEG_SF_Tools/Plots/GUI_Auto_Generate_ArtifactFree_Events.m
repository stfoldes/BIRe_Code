function [events_idx,ArtifactParms] = GUI_Auto_Generate_ArtifactFree_Events(all_artifact_data,TimeVecs,ExpDefs,cue_guide_type)
% Makes markers that are artifact free, these markers happen within the cue named in cue_guide_type
% Esp for Rest, tries to make as many event markers in the rest (or baseline) cue-times that will fit the parameters and don't have artifacts
% Makes events that are centered in the middle of .windowS
% Returns indices for events
% Can manually edit events also
%
% 1. Select best channels for artifacts
% 2. Auto detect events (based on cue guide type)
% 3. Adjust detection parameters
% 4. Repeat until satisfied
% 5. Manually edit events
%
% INPUTS:
%     artifact_data: [time x chans] of time series data
%     TimeVecs: Standard SF struct, needs .target_code
%     ExpDefs: Standard SF struct
%     cue_guide_type: indicates weither to make markers for "move" or "rest"
%         For example, for IMAGING intention, you need artifact free "move" events
%         Possible inputs: 'move','rest'
%
% Data to consider
%    all_artifact_data = [processed_data.EMG_data processed_data.ACC_data];
%
% This could use an actual GUI!
%
% 2013-04-22 Foldes
% UPDATES
% 2013-04-30 Foldes: added windowS output
% 2013-05-20 Foldes: Uses baseline (i.e. first long break) if exists; updated defaults; Fixed bug w/ cutting off end of trial
% 2013-07-23 Foldes: MAJOR Works for move or rest cues
% 2013-07-30 Foldes: STI_data removed for TimeVecs.target_code
% 2013-08-20 Foldes: Editing Markers now a separate function (GUI_Edit_Event_Markers)

%% DEFAULTS

if ~exist('cue_guide_type') || isempty(cue_guide_type)
    cue_guide_type = 'rest';
end

% go through each rest period and try to mark good times
trial_start_idx = TrialTransitions(TimeVecs.target_code); % indicies in the 'raw' data (i.e. time series) where target_code changes happen (i.e. trial starting points)
trial_nums = find(TimeVecs.target_code(trial_start_idx)==ExpDefs.target_code.(cue_guide_type));

% Add baseline to the list if it exists [2013-05-20 Foldes]
if isfield(ExpDefs.target_code,'baseline') && ~isempty(ExpDefs.target_code.baseline)
    baseline_trial_nums = find(TimeVecs.target_code(trial_start_idx)==ExpDefs.target_code.baseline);
    trial_nums = sort([baseline_trial_nums;trial_nums]);
end

% Default parameters for auto detect
switch cue_guide_type
    case 'rest'
        default_thres = 3; % default
        default_windowS = 3;
        default_rx_timeS = 1;
        
    case 'move'
        default_windowS = 0.9; % should be 1s, but sometimes things get a bit short (0.99 works too)
        default_rx_timeS = 0;
        default_thres = 4; % default
end

%% Pick artifact channels
time_zeroedS = TimeVecs.timeS-min(TimeVecs.timeS); % remove offset in time

Marks.signals_idx = [];
while size(Marks.signals_idx,2) == 0
    [Marks,save_flag]=Plot_Inspect_TimeSeries_Signals(TimeVecs.timeS,[TimeVecs.target_code all_artifact_data],'plot_title',['Artifact-Free:  Select Best Channels then press S']);
end

if save_flag ~=1
    close
    events_idx = NaN;
    return
end % save flag

signal_list = Marks.signals_idx;

%% Auto detect events and let user change parameters after inspection
for ichan = 1:length(signal_list) % for each channel you selected
    clear artifact_data
    artifact_data = zscore(all_artifact_data(:,signal_list(ichan)-1));
    
    % Set defaults initially
    ArtifactParms(ichan).chan = signal_list(ichan);
    ArtifactParms(ichan).thres = default_thres;
    ArtifactParms(ichan).rx_timeS = default_rx_timeS;
    ArtifactParms(ichan).windowS = default_windowS;
    
    fig_artifact=figure;hold all
    Figure_Stretch('full')
    
    while 1
        window = ArtifactParms(ichan).windowS*TimeVecs.data_rate;
        rx_time = ArtifactParms(ichan).rx_timeS*TimeVecs.data_rate;
        
        % Time points that are below threshold and are rest data
        below_thres = artifact_data<ArtifactParms(ichan).thres;
        below_thres_and_cue_type = below_thres & (TimeVecs.target_code==ExpDefs.target_code.(cue_guide_type));
        % Add baseline to the list if it exists (and this is rest)
        if strcmp(cue_guide_type,'rest')
            if isfield(ExpDefs.target_code,'baseline') && ~isempty(ExpDefs.target_code.baseline)
                below_thres_and_cue_type = below_thres & (TimeVecs.target_code==ExpDefs.target_code.(cue_guide_type) | TimeVecs.target_code==ExpDefs.target_code.baseline);
            end
        end
        
        clear clean_events_idx
        event_cnt=0;
        for itrial = 1:length(trial_nums)
            
            % trial_start_idx(#)                                     trial_start_idx(#+1)
            % v                                                      v
            % |-----------------------------------------------------|-
            %       |-- window --|->
            %       ^        ^
            %       |        clean_events_idx (middle of clean window)
            %       rx_time = current_start_idx
            
            current_start_idx = trial_start_idx(trial_nums(itrial))+rx_time;
            current_trial_end = trial_start_idx(trial_nums(itrial)+1)-1;%-round(window/2);
            
            % go thru time finding chunks of time that are big enough
            while current_start_idx+window < current_trial_end
                
                % all points are below threshold
                if min(below_thres_and_cue_type([current_start_idx+1:current_start_idx+window]))==1
                    event_cnt=event_cnt+1;
                    clean_events_idx(event_cnt)=round(current_start_idx+(window/2));
                    current_start_idx=current_start_idx+window+1; % go in time fast
                else
                    current_start_idx=current_start_idx+1;
                end
            end
        end
        
        if ~exist('clean_events_idx') || isempty(clean_events_idx)
            disp('NO EVENTS')
            num_events_str = 'NONE';
            clean_events_idx = [];
        else
            num_events_str = num2str(length(clean_events_idx));
        end
        
        clf(fig_artifact)
        
        % Zoomed in (begining)
        subplot(2,1,1); hold all
        plot(time_zeroedS,artifact_data);
        plot(time_zeroedS(clean_events_idx),ArtifactParms(ichan).thres*ones(size(clean_events_idx)),'.r','MarkerSize',18)
        plot(time_zeroedS,zscore(TimeVecs.target_code)-3,'k');
        xlabel('Time [S]')
        xlim([25 60])
        ylim([-4 size(artifact_data,2)*5])
        title(['Zoomed In (' num_events_str ' Events Found) [NOT INTERACTIVE]]'])
        
        % End of data
        subplot(2,1,2); hold all
        plot(time_zeroedS,artifact_data);
        plot(time_zeroedS(clean_events_idx),ArtifactParms(ichan).thres*ones(size(clean_events_idx)),'.r','MarkerSize',18)
        plot(time_zeroedS,zscore(TimeVecs.target_code)-3,'k');
        xlabel('Time [S]')
        xlim([60 max(time_zeroedS)-20])
        ylim([-4 size(artifact_data,2)*5])
        title(['Zoomed Out (' num_events_str ' Events Found)'])
        
        answers=inputdlg_wPosition([0.51 0.5],{'Thres','Max Marker RateS','Block Start DelayS'},...
            [num_events_str ' EVENTS. Try new Parameters? (***CANCEL Finishes***)'],...
            4,{num2str(ArtifactParms(ichan).thres) num2str(ArtifactParms(ichan).windowS) num2str(ArtifactParms(ichan).rx_timeS)});
        
        if isempty(answers)
            break
        else
            ArtifactParms(ichan).thres = str2num(answers{1});
            ArtifactParms(ichan).windowS = str2num(answers{2});
            ArtifactParms(ichan).rx_timeS = str2num(answers{3});
        end
        
    end % loop until user is happy
    close(fig_artifact)
    
end % each selected channel



%% Now that you picked the best parameters, combine things (DOES NOT SAVE TIME PARAMETERS)
while 1
    window = ArtifactParms(ichan).windowS*TimeVecs.data_rate;
    rx_time = ArtifactParms(ichan).rx_timeS*TimeVecs.data_rate;
    
    % Time points that are below threshold and are cue_type data
    clear below_thres_all
    for ichan = 1:length(signal_list) % for each channel you selected
        clear artifact_data
        artifact_data = zscore(all_artifact_data(:,signal_list(ichan)-1));
        
        below_thres_all(:,ichan) = artifact_data<ArtifactParms(ichan).thres;
    end
    clear below_thres below_thres_and_cue_type
    below_thres = min(below_thres_all,[],2);
    below_thres_and_cue_type = below_thres & (TimeVecs.target_code==ExpDefs.target_code.(cue_guide_type));
    % Add baseline to the list if it exists (for rest only)
    if strcmp(cue_guide_type,'rest')
        if isfield(ExpDefs.target_code,'baseline') && ~isempty(ExpDefs.target_code.baseline)
            below_thres_and_cue_type = below_thres & (TimeVecs.target_code==ExpDefs.target_code.(cue_guide_type) | TimeVecs.target_code==ExpDefs.target_code.baseline);
        end
    end
    
    clear clean_events_idx
    event_cnt=0;
    for itrial = 1:length(trial_nums)
        
        current_start_idx = trial_start_idx(trial_nums(itrial))+rx_time;
        current_trial_end = trial_start_idx(trial_nums(itrial)+1)-1;%-round(window/2);
        
        % go thru time finding chunks of time that are big enough
        while current_start_idx+window < current_trial_end
            
            % all points are below threshold
            if min(below_thres_and_cue_type([current_start_idx+1:current_start_idx+window]))==1
                event_cnt=event_cnt+1;
                clean_events_idx(event_cnt)=round(current_start_idx+(window/2));
                current_start_idx=current_start_idx+window+1; % go in time fast
            else
                current_start_idx=current_start_idx+1;
            end
        end
    end
    
    num_events_str = num2str(length(clean_events_idx));
    
    
    %% Edit auto markers
    
    [save_flag,events_idx]= GUI_Edit_Event_Markers([TimeVecs.target_code all_artifact_data],time_zeroedS,clean_events_idx,'Artifact-Free');
    if save_flag  % Good to go
        break
    end
    
%     hHelp = msgbox('Edit Events> Press S to complete, Q to abort','Edit Events','help');
%     pause(1.5)
%     try; close(hHelp); end
%     clear Marks
%     [Marks,save_flag]=Plot_Inspect_TimeSeries_Signals([TimeVecs.target_code all_artifact_data],time_zeroedS,[],[],clean_events_idx,'Artifact-Free:  Edit Events > S Saves, Q Aborts');
%     
%     %% Check if the user is satisfied
%     
%     if save_flag % Good to go
%         break
%     else % you wanted to abort, why?
%         answer = questdlg_wPosition([],'AutoEvents Aborted, why?','Redo Auto Events?','Abort','Redo','Wrong button','Abort');
%         switch answer
%             case 'Abort'
%                 close
%                 events_idx = NaN;
%                 return
%             case 'Redo'
%                 % It will just go again
%                 close
%             case 'Wrong button' % try again
%                 clear Marks
%                 [Marks,save_flag]=Plot_Inspect_TimeSeries_Signals([TimeVecs.target_code all_artifact_data],time_zeroedS,[],[],clean_events_idx,'Artifact-Free:  Edit Events > S Saves, Q Aborts');
%                 if save_flag
%                     close
%                     break
%                 end
%         end
%     end


    
end % big loop until user is happy

% % RETURN ME
% events_idx=Marks.events_idx{1};







