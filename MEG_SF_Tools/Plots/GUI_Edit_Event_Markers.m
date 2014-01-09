function [save_flag,events_idx]= GUI_Edit_Event_Markers(data,timeS,org_events,marker_name)
% Edit events with a GUI
%
% SEE: GUI_Auto_Event_*
%
% 2013-08-20 Foldes

% timeS = time_zeroedS;
% data = [TimeVecs.target_code all_artifact_data];
% org_events = clean_events_idx;
% marker_name = 'Artifact-Free';

if ~exist('marker_name') || isempty(marker_name)
    marker_name = 'Unknown';
end

%% Edit auto markers
hHelp = msgbox('Edit Events> Press S to complete, Q to abort','Edit Events','help');
clear Marks
[Marks,save_flag]=Plot_Inspect_TimeSeries_Signals(timeS,data,'premarked_events',org_events,'plot_title',[marker_name ':  Edit Events > S Saves, Q Aborts']);
try; close(hHelp); end

%% Check if the user is satisfied

if save_flag ~= 1% you wanted to abort, why?
    answer = questdlg('Aborted, why?','Redo?','Abort','Redo','Wrong button','Abort');
    switch answer
        case 'Abort'
            close
            events_idx = NaN;
            save_flag = -1; % an abort code
        case 'Redo'
            % It will just go again
            close
        case 'Wrong button' % try again
            clear Marks
            [Marks,save_flag]=Plot_Inspect_TimeSeries_Signals(timeS,[cue data],'premarked_events',org_events,'plot_title',[marker_name ':  Edit Events > S Saves, Q Aborts']);
            if save_flag
                close
            end
    end
end


if save_flag==1
    if iscell(Marks.events_idx) && max(size(Marks.events_idx))==1
        events_idx=sort(Marks.events_idx{1});
    else
        events_idx=sort(Marks.events_idx);
    end
else
    events_idx=[];
end
