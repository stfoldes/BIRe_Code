function [events_idx,ArtifactParms,best_chan] = GUI_Auto_Event_Markers(artifact_data,timeS,cue_data,input_parms)
% Auto detects events in time series data (basically threshold crossing)
%
% Returns indices for events
% Esp. useful for detecting artifacts like eye blinks
% Can manually edit events also
%
% 1. Select best channel 
% 2. Auto detect events
% 3. Adjust detection parameters
% 4. Repeat until satisfied
% 5. Manually edit events
%
% INPUTS:
%     artifact_data             = [time x chans] of time series data
%     timeS                     = [time x 1] of time in seconds
%     cue_data[OPTIONAL]        = [time x 1] an extra signal to look at (like a trigger) For plotting only, usually TimeVecs.target_code
%     input_parms[OPTIONAL]   = string that helps start the detection parameters off
% 
% This could use an actual GUI!
%
% 2013-04-18 Foldes
% UPDATES:
% 2013-04-23 Foldes: Changed some looks
% 2013-07-23 Foldes: ArtifactParms now output
% 2013-08-20 Foldes: Editing Markers now a separate function (GUI_Edit_Event_Markers)
% 2013-10-10 Foldes: added settle_down_windowS

%% DEFAULTS

if ~exist('input_parms') || isempty(input_parms)
    input_parms = 'unknown';
end

% if you are an artifact parms structure use it.
if isstruct(input_parms)==1
    ArtifactParms = input_parms;
    artifact_type=[];
else
    artifact_type = input_parms;
end
    

data_rate=floor(1/median(diff(timeS))); % Caclculate data rate

time_zeroedS = timeS-min(timeS); % remove offset in time

if ~exist('cue_data') || isempty(cue_data)
    cue_data = zeros(size(artifact_data,1),1);
end


%% ===BIG LOOP=========================================
while 1 % Big loop to keep going until user is happy
    
%% Choose channel to use (if more than one given)
    if size(artifact_data,2)>1
        % hHelp = msgbox('Select Best Channel then press S','Select Channel','help');
        % pause(2)
        % close(hHelp)
        
        Marks.signals_idx = [];
        while size(Marks.signals_idx,2) == 0
            [Marks,save_flag]=Plot_Inspect_TimeSeries_Signals(timeS,[cue_data artifact_data],'plot_title',[artifact_type ':  Select Best Channel for then press S (save)']);
        end
        
        if save_flag~=1 % ABORTED
            close
            events_idx=NaN;
            best_chan=NaN;
            ArtifactParms.thres=NaN;
            ArtifactParms.artifact_max_rateS    = NaN;
            ArtifactParms.settle_down_windowS   = NaN;
            ArtifactParms.peak_windowS          = NaN;
            ArtifactParms.thres_too_big         = NaN;
            return
        end
        
        % use only one channel of data
        best_chan = Marks.signals_idx-1;
        %if save_flag
        artifact_data=artifact_data(:,best_chan);
        %end
    end
    
%%
    % ***CALL NEW GUI HERE ONE DAY***
    
%% Choose auto event marker parameters (via plot and input box)
    
    % Guess at parameters (switch-function below)
    if ~isempty(artifact_type) % artifact_type will be empty if you already have Parms input
        ArtifactParms=Select_Default_Artifact_Parameters(artifact_type);
    end
    
    fig_artifact=figure;hold all
    Figure_Stretch('full')
    
    clear artifact_events_idx
    while 1
        [~,artifact_events_idx,ArtifactParms] = Calc_Artifact_Peak_idx(zscore(artifact_data),data_rate,ArtifactParms);
        num_events_str =num2str(length(cell2mat(artifact_events_idx)));
        
        clf(fig_artifact)
        
        % Zoomed in (begining)
        subplot(2,1,1); hold all
        for ichan = 1:size(artifact_data,2)
            plot(time_zeroedS,(4*(ichan-1))+zscore(artifact_data(:,ichan)));
        end
        for ichan = 1:size(artifact_data,2)
            plot(time_zeroedS(artifact_events_idx{ichan}),(4*(ichan-1)+ArtifactParms.thres).*ones(size(artifact_events_idx{ichan})),'.r','MarkerSize',18)
        end
        plot(time_zeroedS,zscore(cue_data)-4,'k');
        xlabel('Time [S]')
        xlim([time_zeroedS(1) (time_zeroedS(1)+(max(time_zeroedS)*0.2))]) % xlim = 00%:20%
        ylim([-5 size(artifact_data,2)*4])
        title(['Zoomed In (' num_events_str ' Events Found) [NOT INTERACTIVE]'])
        
        % End of data
        subplot(2,1,2); hold all
        for ichan = 1:size(artifact_data,2)
            plot(time_zeroedS,(4*(ichan-1))+zscore(artifact_data(:,ichan)));
        end
        for ichan = 1:size(artifact_data,2)
            plot(time_zeroedS(artifact_events_idx{ichan}),(4*(ichan-1)+ArtifactParms.thres).*ones(size(artifact_events_idx{ichan})),'.r')
        end
        plot(time_zeroedS,zscore(cue_data)-4,'k');
        xlabel('Time [S]')
        xlim([(time_zeroedS(1)+(max(time_zeroedS)*0.2)) max(time_zeroedS)]) % xlim = 20%:100%
        ylim([-5 size(artifact_data,2)*4])
        title(['Zoomed Out (' num_events_str ' Events Found)'])
        
        answers=inputdlg({'Threshold','Max rate of events [S]','Min time needed below threshold [S]','Window duration for finding a peak [S]','Too big Thres'},...
            [num_events_str ' EVENTS. Try new Parameters? (***CANCEL Finishes***)'],...
            4,{num2str(ArtifactParms.thres) num2str(ArtifactParms.artifact_max_rateS) num2str(ArtifactParms.settle_down_windowS) num2str(ArtifactParms.peak_windowS) num2str(ArtifactParms.thres_too_big)});
        
        if isempty(answers)
            break
        else
            ArtifactParms.thres               = str2num(answers{1});
            ArtifactParms.artifact_max_rateS  = str2num(answers{2});
            ArtifactParms.settle_down_windowS = str2num(answers{3}); % Min time needed below threshold [S]
            ArtifactParms.peak_windowS        = str2num(answers{4});
            ArtifactParms.thres_too_big       = str2num(answers{5});
        end
        
    end
    close(fig_artifact)

    
%% Edit auto markers
    [save_flag,events_idx]= GUI_Edit_Event_Markers([cue_data artifact_data],timeS,cell2mat(artifact_events_idx),artifact_type);
    events_idx = sort(events_idx); % SORT
    if save_flag~=0  % 0=redo, 
        break
    end

%     hHelp = msgbox('Edit Events> Press S to complete, Q to abort','Edit Events','help');
%     pause(1.5)
%     try; close(hHelp); end
%     clear Marks
%     [Marks,save_flag]=Plot_Inspect_TimeSeries_Signals([cue_data artifact_data],timeS,[],[],cell2mat(artifact_events_idx),[artifact_type ':  Edit Events > S Saves, Q Aborts']);
%     
% %% Check if the user is satisfied
%     
%     if save_flag % Good to go
%         break
%     else % you wanted to abort, why?
%         answer = questdlg_wPosition([],'AutoEvents Aborted, why?','Redo Auto Events?','Abort','Redo','Wrong button','Abort');
%         switch answer
%             case 'Abort'
%                 close
%                 events_idx=NaN;
%                 return
%             case 'Redo'
%                 % It will just go again
%                 close
%             case 'Wrong button' % try again
%                 clear Marks
%                 [Marks,save_flag]=Plot_Inspect_TimeSeries_Signals([cue_data artifact_data],timeS,[],cell2mat(artifact_events_idx),'Edit Events > S Saves, Q Aborts');
%                 if save_flag
%                     close
%                     break
%                 end
%         end
%     end
%     
end % big loop until user is happy

%% ===BIG LOOP END=====================================

% RETURN ME
% events_idx=Marks.events_idx{1};
artifact_max_rateS=ArtifactParms.artifact_max_rateS;




function ArtifactParms=Select_Default_Artifact_Parameters(artifact_type)
% Just a code saver (mover)

switch artifact_type
        
    case {'blink','EOG'} % Blinks
        ArtifactParms.thres=2; % STDs from mean to set the threshold
        ArtifactParms.artifact_max_rateS = 2; % amount of time[S] that the artifact CANNOT repeat (e.g. >2x per second)
        ArtifactParms.peak_windowS = 0.4; % amount of time[S] used to find the peak of the artifact
        ArtifactParms.thres_too_big = 10; % STDs from mean to set as a second threshold that is too big to consider
        ArtifactParms.settle_down_windowS = 0.1; % time since last mark that must be below threshold in order to allow for another mark
        
    case {'ECG','cardiac'}
        ArtifactParms.thres=1; % STDs from mean to set the threshold
        ArtifactParms.artifact_max_rateS = 1; % amount of time[S] that the artifact CANNOT repeat (e.g. >2x per second)
        ArtifactParms.peak_windowS = 0.4; % amount of time[S] used to find the peak of the artifact
        ArtifactParms.thres_too_big = 3; % STDs from mean to set as a second threshold that is too big to consider
        ArtifactParms.settle_down_windowS = 0.1; % time since last mark that must be below threshold in order to allow for another mark

    case {'ACC','acc'}
        ArtifactParms.thres=2; % STDs from mean to set the threshold
        ArtifactParms.artifact_max_rateS = 0.75; % amount of time[S] that the artifact CANNOT repeat (e.g. >2x per second)
        ArtifactParms.peak_windowS = 0; % amount of time[S] used to find the peak of the artifact
        ArtifactParms.thres_too_big = 20; % STDs from mean to set as a second threshold that is too big to consider
        ArtifactParms.settle_down_windowS = 0; % time since last mark that must be below threshold in order to allow for another mark

    case {'EMG'}
        ArtifactParms.thres=2; % STDs from mean to set the threshold
        ArtifactParms.artifact_max_rateS = 0.75; % amount of time[S] that the artifact CANNOT repeat (e.g. >2x per second)
        ArtifactParms.peak_windowS = 0; % amount of time[S] used to find the peak of the artifact
        ArtifactParms.thres_too_big = 20; % STDs from mean to set as a second threshold that is too big to consider
        ArtifactParms.settle_down_windowS = 0; % time since last mark that must be below threshold in order to allow for another mark

    case {'photodiode','MISC'}
        ArtifactParms.thres=0.5; % STDs from mean to set the threshold
        ArtifactParms.artifact_max_rateS = 10; % amount of time[S] that the artifact CANNOT repeat (e.g. >2x per second)
        ArtifactParms.peak_windowS = 0; % amount of time[S] used to find the peak of the artifact
        ArtifactParms.thres_too_big = 20; % STDs from mean to set as a second threshold that is too big to consider
        ArtifactParms.settle_down_windowS = 0.1; % time since last mark that must be below threshold in order to allow for another mark

    otherwise % DEFAULT
        ArtifactParms.thres=0; % STDs from mean to set the threshold
        ArtifactParms.artifact_max_rateS = 0.5; % amount of time[S] that the artifact CANNOT repeat (e.g. >2x per second)
        ArtifactParms.peak_windowS = 0; % amount of time[S] used to find the peak of the artifact
        ArtifactParms.thres_too_big = 3; % STDs from mean to set as a second threshold that is too big to consider
        ArtifactParms.settle_down_windowS = 0; % time since last mark that must be below threshold in order to allow for another mark
end



