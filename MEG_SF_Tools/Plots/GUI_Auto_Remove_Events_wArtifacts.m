function [events_idx,ArtifactParms] = GUI_Auto_Remove_Events_wArtifacts(all_artifact_data,TimeVecs,event_list,cue_guide_type)
% Checks if Events are artifact free. Returns list of events that are
%
% SEE: GUI_Auto_Generate_ArtifactFree_Events.m if you dont have any events to start with.
%
% 1. Select best channels for artifacts
% 2. Adjust detection parameters for thresholding
% 3. Repeat until satisfied
% 4. Manually edit events
%
% INPUTS:
%     artifact_data: [time x chans] of time series data
%     TimeVecs: Standard SF struct, needs .target_code
%     event_list: samples of your ideal events
%     cue_guide_type[OPTIONAL]: indicates weither to make markers for "move" or "rest"
%         For example, for IMAGING intention, you need artifact free "move" events
%         Possible inputs: 'move','rest'
%
% Data to consider
%    all_artifact_data = [processed_data.EMG_data processed_data.ACC_data];
%
% 2013-08-21 Foldes (branche from GUI_Auto_Generate_ArtifactFree_Events)
% UPDATES

% event_list = TrialTransitions(TimeVecs.target_code,ExpDefs.target_code.move);

%% DEFAULTS

if ~exist('cue_guide_type') || isempty(cue_guide_type)
    cue_guide_type = 'rest';
end
% Default parameters for auto detect
switch cue_guide_type
    case 'rest'
        default_thres = 3; % default
        default_pre_offsetS = -1; % Default is 1s AFTER rest cue, i.e. 1s rx time
        default_post_offsetS = 4; % 4s after rest cue
        
    case 'move'
        default_thres = 4; % default
        default_pre_offsetS = 1; % Default is 1s BEFORE move cue
        default_post_offsetS = 1; % 1s after move cue
end


% % go through each rest period and try to mark good times
% trial_start_idx = TrialTransitions(TimeVecs.target_code); % indicies in the 'raw' data (i.e. time series) where target_code changes happen (i.e. trial starting points)
% event_list = find(TimeVecs.target_code(trial_start_idx)==ExpDefs.target_code.(cue_guide_type));
% 
% % Add baseline to the list if it exists [2013-05-20 Foldes]
% if isfield(ExpDefs.target_code,'baseline') && ~isempty(ExpDefs.target_code.baseline)
%     baseline_event_list = find(TimeVecs.target_code(trial_start_idx)==ExpDefs.target_code.baseline);
%     event_list = sort([baseline_event_list;event_list]);
% end



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
    ArtifactParms(ichan).pre_offsetS = default_pre_offsetS;
    ArtifactParms(ichan).post_offsetS = default_post_offsetS;
    
    fig_artifact=figure;hold all
    Figure_Stretch('full')
        
    while 1 % paramter pick loop
        pre_offset = ArtifactParms(ichan).pre_offsetS*TimeVecs.data_rate;
        post_offset = ArtifactParms(ichan).post_offsetS*TimeVecs.data_rate;
        
        clear clean_events_idx
        event_cnt=0;
        current_event_mask = zeros(length(event_list),1);
        for ievent = 1:length(event_list)
            
            %     Artifact
            %         v
            % --------X----------------------------------------------
            %      |---pre---|---post---|   |---pre---|---post---|
            %                ^                        ^
            %              Event(bad)               Event(clean)
           
            % Make the window around the current event
            
            window_start = max((event_list(ievent)-pre_offset)+1,1);
            window_end = min(event_list(ievent)+post_offset,length(artifact_data));
            current_window = window_start:window_end;
            
            % Are there any samples that pass the threshold?
            over_thres = max(artifact_data(current_window)>=ArtifactParms(ichan).thres);
            
            % Threshold NOT crossed
            if over_thres==0
                event_cnt = event_cnt+1;
                clean_events_idx(event_cnt) = event_list(ievent); % redundent, but what ever
                current_event_mask(ievent) = 1;
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
        
        answers=inputdlg_wPosition([0.53; 0.8],{'Thres','Time Before Event','Time After Event'},...
            [num_events_str ' EVENTS. Try new Parameters? (***CANCEL Finishes***)'],...
            4,{num2str(ArtifactParms(ichan).thres) num2str(ArtifactParms(ichan).pre_offsetS) num2str(ArtifactParms(ichan).post_offsetS)});
        
        if isempty(answers) % cancel button
            break
        else
            ArtifactParms(ichan).thres = str2num(answers{1});
            ArtifactParms(ichan).pre_offsetS = str2num(answers{2});
            ArtifactParms(ichan).post_offsetS = str2num(answers{3});
        end
        
    end % loop until user is happy
    close(fig_artifact)
    
    all_event_mask(:,ichan) = current_event_mask;
    
end % each selected channel



%% Now that you picked the best parameters, combine things (DOES NOT SAVE TIME PARAMETERS)
while 1
%     window = ArtifactParms(ichan).windowS*TimeVecs.data_rate;
%     rx_time = ArtifactParms(ichan).rx_timeS*TimeVecs.data_rate;
%     
%     % Time points that are below threshold and are cue_type data
%     clear below_thres_all
%     for ichan = 1:length(signal_list) % for each channel you selected
%         clear artifact_data
%         artifact_data = zscore(all_artifact_data(:,signal_list(ichan)-1));
%         
%         below_thres_all(:,ichan) = artifact_data<ArtifactParms(ichan).thres;
%     end
%     clear below_thres below_thres_and_cue_type
%     below_thres = min(below_thres_all,[],2);
%     below_thres_and_cue_type = below_thres & (TimeVecs.target_code==ExpDefs.target_code.(cue_guide_type));
%     % Add baseline to the list if it exists (for rest only)
%     if strcmp(cue_guide_type,'rest')
%         if isfield(ExpDefs.target_code,'baseline') && ~isempty(ExpDefs.target_code.baseline)
%             below_thres_and_cue_type = below_thres & (TimeVecs.target_code==ExpDefs.target_code.(cue_guide_type) | TimeVecs.target_code==ExpDefs.target_code.baseline);
%         end
%     end
%     
%     clear clean_events_idx
%     event_cnt=0;
%     for ievent = 1:length(event_list)
%         
%         current_start_idx = trial_start_idx(event_list(ievent))+rx_time;
%         current_trial_end = trial_start_idx(event_list(ievent)+1)-1;%-round(window/2);
%         
%         % go thru time finding chunks of time that are big enough
%         while current_start_idx+window < current_trial_end
%             
%             % all points are below threshold
%             if min(below_thres_and_cue_type([current_start_idx+1:current_start_idx+window]))==1
%                 event_cnt=event_cnt+1;
%                 clean_events_idx(event_cnt)=round(current_start_idx+(window/2));
%                 current_start_idx=current_start_idx+window+1; % go in time fast
%             else
%                 current_start_idx=current_start_idx+1;
%             end
%         end
%     end
%     
%     num_events_str = num2str(length(clean_events_idx));
%     

all_around_good_mask = (min(all_event_mask,[],2));
all_around_good_events = event_list(find(all_around_good_mask==1));


%% Edit auto markers

[save_flag,events_idx]= GUI_Edit_Event_Markers([TimeVecs.target_code all_artifact_data],time_zeroedS,all_around_good_events,'Artifact-Free');
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







