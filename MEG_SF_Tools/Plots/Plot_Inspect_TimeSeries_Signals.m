function [Marks,save_flag]=Plot_Inspect_TimeSeries_Signals(timeS,data2plot,varargin)%,premarked_signals,premarked_events,signal_name_list,plot_title,premarked_event_names)
% User interface to look at time series data by channel/signal
% Can navagate through time and channel/signal
% Can select/highlight channels and time points (events)
% Esp. useful for marking bad MEG channels (see Mark_Bad_MEG.m)
%
% BUTTON KEYS - MARKING
%   Lt Mouse = toggle channel as marked or not
%   number keys = select event point in time (1-5 only)
%   DEL = remove closest event (in time) (~ button works too)
%   CTRL+z = undo event removal
%   SHIFT+number key = toggle an event type hidden/visible
%
% BUTTON KEYS - NAVIGATION
%   up/down arrow keys = change channels shown
%   left/right arrow keys = change time shown
%   s = save and finished
%   q = quit without saving
%
% BUTTON KEYS - ADVANCED
%   p = position of closest sensor in helmet
%   +/- = change time resolution
%
% INPUTS:
%     timeS[OPTIONAL] = time in seconds corresponding to time in data
%     data2plot = [time x signals]
%
%     ***VARARGIN***:
%         signal_name_list = cell array of names used to label each signal, all must be unique
%         premarked_signals = list of signal/channel-indicies that should be marked from the get go
%         premarked_events = list of event-indicies (in time) that should be marked from the get go
%                            Can be cell, but only 7 (for now)
%         plot_title = str for title of plot (like file name)
%         window_timeS = 45; % how much time is shown
%         GUI_flag = 1; % turn on/off (1/0) the ability to interact.
%
% OUTPUTS:
%     Marks.signals_idx = list of signal/channel-indicies marked
%     Marks.events_idx = list of event-indicies (in time) marked (cell array)
%     save_flag = 1=good to go, 0=inspection was aborted
%
% HINT:
%     Might want to low pass filter (ex. 30Hz)
%         data2plot=Calc_Filter_Freq_SimpleButter(MEG_data,4,Extract.data_rate,'low');
%           OR
%         clear filter_b filter_a
%         Wn=30/(Extract.data_rate/2);
%         [filter_b,filter_a] = butter(4,Wn,'low'); % 4th order butterworth filter
%         data2plot=filtfilt(filter_b,filter_a,raw_data);
%
% Stephen Foldes 2013-03-28
% UPDATES:
% 2013-04-05 Foldes: Limit on number of channels in now min(num_chan,18)
% 2013-04-17 Foldes: MAJOR Added event interaction, added help
% 2013-04-23 Foldes: Removed PreviousMarks struct input style
% 2013-06-06 Foldes: 'p' = Position of channel in helmet; Message that your at the end of the channel list
% 2013-06-06 Foldes: MAJOR Numbers keys are now used as event markers, can also hide events, event_idx now is a cell array
% 2013-07-29 Foldes: MINOR Event-marker names now an input
% 2013-08-23 Foldes: MINOR Time does not reset to begining when switching channels shown (up/down arrows)
% 2013-08-27 Foldes: MINOR prevent some buttons from killing the switch statement (like enter and page down)
% 2013-10-10 Foldes: Varargin, Added undo option

%% DEFAULTS

defaults.premarked_signals = [];
defaults.premarked_events = [];
defaults.signal_name_list = []; % will fill with numbers
defaults.plot_title = 'UNKNOWN';
defaults.premarked_event_names = [];
defaults.window_timeS = 45; % how much time is shown
defaults.GUI_flag = 1; % turn on/off (1/0) the ability to interact.
parms=varargin_extraction(defaults,varargin);


% data is first entry, not time. Happens if you only put in data
if ~exist('data2plot') || isempty(data2plot)
    data2plot = timeS;
    clear timeS;
end

% Make time axis if not given (1000Hz)
if ~exist('timeS') || isempty(timeS)
    % default of 1000Hz
    timeS=[0:size(data2plot,1)-1]/1000;
end

% signal names
if isempty(parms.signal_name_list)
    for isignal = 1:size(data2plot,2)
        parms.signal_name_list{isignal} = num2str(isignal);
    end
end


% if isempty(parms.premarked_signals)
%     signals_marked_mask=zeros(1,size(data2plot,2));
% else
    signals_marked_mask=zeros(1,size(data2plot,2));
    signals_marked_mask(parms.premarked_signals) = 1;
% end

if isempty(parms.premarked_events)
    events_idx=[];
    event_names{1}=1;
else
    if ~iscell(parms.premarked_events)
        events_idx{1}=parms.premarked_events;
    else
        events_idx=parms.premarked_events;
    end
    for ievent_type = size(events_idx,2) % FOR NOW; event names are just numbers
        event_names{ievent_type}=ievent_type;
    end
end

% Define color list (limited to 7 now)
event_colors = ['g';'r';'b';'m';'y';'k';'c'];
event_hidden = zeros(1,length(event_colors));

%% Plot Interface
try
    load('DEF_Neuromag_chan_names') % load physical sensor names (used for head plots)
end

% PARAMETERS
num_chan2plot = min(size(data2plot,2),18); % Limit to 18 channels at a time (for MEG)
window_timeS=min(parms.window_timeS,max(timeS));
sd_spacing = 4;

current_start_chan_idx=1;
current_startS = min(timeS)-0.1; % can miss stuff at first time point, so move back just a bit
replot_flag = 1;
change_chan_flag = 1;
quit_flag = 0; % not used anymore
save_flag = 0;
line_key = [cellstr(parms.signal_name_list)];
previously_deleted_events.event_type = [];
previously_deleted_events.event_idx = [];

fig=figure;
% set full screen (if you have two screens)
Figure_Stretch('full')
set(fig,'MenuBar','none'); % remove the menues
% fig_head=figure;
disp(' ')

while 1
    if replot_flag == 1 % dont replot for time shifts
        clf(fig);
        % clf(fig_head);
        
        figure(fig);hold all
        % Figure out which channels to plot
        if change_chan_flag
            current_chan_list = current_start_chan_idx:min(current_start_chan_idx+num_chan2plot-1,size(data2plot,2));
            current_line_name_list = line_key(current_chan_list);
        end
        
        % Plot each line, make it red if its marked
        for iline =1:length(current_chan_list)
            current_chan_idx = current_chan_list(iline);
            
            if signals_marked_mask(current_chan_idx)==1 % this is a bad channel, mark red
                current_color = 'r';
            else
                current_color = 'k';
            end
            plot(timeS,zscore(data2plot(:,current_chan_idx))+((iline-1)*sd_spacing),current_color) %'LineWidth',2)
        end
        
        % Plot vertial line for events
        for ievent_type=1:size(events_idx,2)
            if event_hidden(ievent_type)==0 % Only show events that are not-hidden                
                marker_x{ievent_type} = timeS(events_idx{ievent_type});
                marker_y = ones(size(events_idx{ievent_type}))*(length(current_chan_list)*sd_spacing);
                plot(marker_x{ievent_type},marker_y,'.','Color',event_colors(ievent_type),'MarkerSize',30)
                Plot_VerticalMarkers(timeS(events_idx{ievent_type}),'LineWidth',1.75,'Color',event_colors(ievent_type));

                % Show Event names
                if ~isempty(parms.premarked_event_names) %&& length(parms.premarked_event_names)<=ievent_type
                    try
                        first_marker_x_current = marker_x{ievent_type}(find(marker_x{ievent_type}>=current_startS,1,'first'));
                        text(first_marker_x_current,marker_y(1),parms.premarked_event_names{ievent_type},...
                            'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',12);
                    end
                end
            end
        end
        
        
        line_center_list=[1:sd_spacing:num_chan2plot*sd_spacing]-1; % centers of the lines
        
        xlim([current_startS current_startS+(window_timeS)]);
        ylim([-sd_spacing/2 (num_chan2plot+0.5)*sd_spacing])
        xlabel('Time [S]')
        
        title_str = [];
        title_str = [title_str parms.plot_title ' (#Chans=' num2str(sum(signals_marked_mask==1)) ',  #Marks: '];
        if ~isempty(parms.premarked_event_names) %&& length(parms.premarked_event_names)<=ievent_type
            for ievent_type=1:size(events_idx,2)
                title_str = [title_str  parms.premarked_event_names{ievent_type} '=' num2str(length(events_idx{ievent_type})) ', ']; 
            end
        else % no event names, just use color-name
            for ievent_type=1:size(events_idx,2)
                title_str = [title_str  event_colors(ievent_type) '=' num2str(length(events_idx{ievent_type})) ', '];
            end
        end
        title_str = [title_str  ') [press h for help]'];
        title(str4plot(title_str),'FontSize',16)
        
        % turn yaxis into channel names
        set(gca,'YTick',line_center_list,'YTickLabel',current_line_name_list);
        Figure_TightFrame
        
        
    else % only time shifts, don't replot
        xlim([current_startS current_startS+window_timeS]);
        %         % Show Event names DOESNT ERASE OLD ONES, Looks dumb
        %         ~isempty(parms.premarked_event_names) %&& length(parms.premarked_event_names)<=ievent_type
        %             for ievent_type=1:size(events_idx,2)
        %                 if event_hidden(ievent_type)==0 % Only show events that are not-hidden
        %                     try
        %                         first_marker_x_current = marker_x{ievent_type}(find(marker_x{ievent_type}>=current_startS,1,'first'));
        %                         text(first_marker_x_current,marker_y(1),parms.premarked_event_names{ievent_type},...
        %                             'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',10);
        %                     end
        %                 end
        %             end
        %         end % event types
    end
    
    
    % User Interface
    figure(fig);
    % Get out if no GUI 
    if parms.GUI_flag == 0
        save_flag = 0;
        set(fig,'MenuBar','figure'); % Put menu back
        break        
    end
    
    try
        [button_x,button_y,button]=ginput(1); % could do different buttons, but whatever.
    catch % errors if exit figure
        break
    end
    
    if ~isempty(button) % some buttons kick out an empty and will crash a switch
        
        switch button
            %% ***MARK***
            case {1} % Left Mouse =  toggle channel marker
                % find closest channel to y-position
                [~,bad_chan_localidx] = find_closest_in_list(button_y,line_center_list); % which did you select in the few that were shown
                bad_chan_idx = find(strcmp(line_key,current_line_name_list(bad_chan_localidx))); % for all channels
                signals_marked_mask(bad_chan_idx)=signals_marked_mask(bad_chan_idx)==0; % mark as bad or mark as good if clicked twice.
                switch signals_marked_mask(bad_chan_idx)
                    case 1
                        disp([cell2mat(line_key(bad_chan_idx)) ' = MARKED'])
                    case 0
                        disp([cell2mat(line_key(bad_chan_idx)) ' = UN-MARKED'])
                end
                replot_flag = 1;
                change_chan_flag = 0;
                
            case {49 50 51 52 53 54 55} % # = Event in time (event type #)
                % find closest time to x-position
                [~,closest_time_idx] = find_closest_in_list(button_x,timeS);
                
                button_num = button - 48;
                
                %add event to list according to its number
                if size(events_idx,2)<button_num % initialize this event type
                    events_idx{button_num} = closest_time_idx;
                    event_names{button_num}=button_num; % Placeholder for later
                else
                    events_idx{button_num}(end+1) = closest_time_idx;
                end
                replot_flag = 1;
                change_chan_flag = 0;
                
            case {127 96} % DEL button removes closest event marker (or ~)
                % Get all events together (for a party)
                all_events_idx=[];all_events_type=[];
                for ievent_type=1:size(events_idx,2)
                    all_events_idx = [all_events_idx events_idx{ievent_type}];
                    all_events_type= [all_events_type ievent_type*ones(size(events_idx{ievent_type}))];
                end
                
                % Remove the closest event
                [~,closest_time_idx] = find_closest_in_list(button_x,timeS(all_events_idx));
                current_event_type = all_events_type(closest_time_idx);
                closest_time_by_event_type=(events_idx{current_event_type} == all_events_idx(closest_time_idx));
                % keep incase undo
                num_stored_events = length(previously_deleted_events);
                previously_deleted_events(num_stored_events+1).event_type = current_event_type;
                previously_deleted_events(num_stored_events+1).event_idx = events_idx{current_event_type}(closest_time_by_event_type);

                % Delete
                events_idx{current_event_type}(closest_time_by_event_type)=[];
                
                replot_flag = 1;
                change_chan_flag = 0;
                
            case {26} % CTRL+z = UNDO
                num_stored_events = length(previously_deleted_events);
                if num_stored_events>1
                    events_idx{previously_deleted_events(num_stored_events).event_type}(end+1)=previously_deleted_events(num_stored_events).event_idx;
                    previously_deleted_events(num_stored_events) = [];
                end
                
            case {33 64 35 36 37} % SHIFT+Number: Toggle a set of events from being hidden/visible
                if button == 64
                    button_num = 2;
                else
                    button_num = button - 32;
                end
                event_hidden(button_num) = event_hidden(button_num)==0; % toggle
                
                % THOUGHT ABOUT ADDING BAD-SEGMENT MARKING. THIS WORKS FINE, BUT NO WAY TO REMOVE POINTS JUST YET 2013-07-29 Foldes
                %         case {98} % b for bad segment
                %             % Needed for initiation up top...one day
                %             bad_seg_idx=[];
                %             finished_bad_seg_flag = 0; % 1 if need to finish a bad-segment
                %             bad_seg_cnt = 1;
                %
                %             % Must be in pairs (organization: segmentation # x start-stop idx)
                %             bad_seg_idx(bad_seg_cnt,finished_bad_seg_flag+1) = find_closest_in_list_idx(button_x,timeS);
                %             bad_seg_cnt = bad_seg_cnt + finished_bad_seg_flag;
                %             % toggle flag
                %             finished_bad_seg_flag = finished_bad_seg_flag == 0;
                %
                %             replot_flag = 1;
                %             change_chan_flag = 0;
                
                
                %% ***NAVIGATION***
            case 29 % arrow right moves time (50% of viewed time)
                current_startS = min(current_startS+(round(window_timeS*0.5)),max(timeS)-window_timeS);
                replot_flag = 0;
                change_chan_flag = 0;
            case 28 % arrow left moves time
                current_startS = max(current_startS-(round(window_timeS*0.5)),min(timeS));
                replot_flag = 0;
                change_chan_flag = 0;
            case 30 % arrow up moves channel set (reset time too)
                % current_startS = min(timeS);
                if current_start_chan_idx+num_chan2plot<=size(data2plot,2)
                    current_start_chan_idx=current_start_chan_idx+num_chan2plot;
                    replot_flag = 1;
                    change_chan_flag = 1;
                else % Can't move up further
                    current_start_chan_idx=size(data2plot,2);
                    replot_flag = 0;
                    change_chan_flag = 0;
                    % Tell user you've reached the end of the list
                    h_temp=msgbox('Reached End of List','End of List');
                    pause(1)
                    close(h_temp)
                end
            case 31 % arrow down moves channel set (reset time too)
                % current_startS = min(timeS);
                if current_start_chan_idx-num_chan2plot>0
                    current_start_chan_idx=current_start_chan_idx-num_chan2plot;
                    replot_flag = 1;
                    change_chan_flag = 1;
                else
                    current_start_chan_idx=1;
                    replot_flag = 0;
                    change_chan_flag = 0;
                    % Tell user you've reached the end of the list
                    h_temp=msgbox('Reached Begining of List','Begining of List');
                    pause(1)
                    close(h_temp)
                end
                
            case 45 % - zoomout in time
                window_timeS = min(window_timeS + 5,size(data2plot,1)); % Add 5 seconds
                
            case 61 % + zoomin in time
                window_timeS = max(window_timeS - 5,1); % Remove 5 seconds
                
                %% ***FINISHING***
            case 113 % Q for Quit
                quit_flag = 1;
                close(fig);
                break
                
            case {115} % s save and exit
                close(fig);
                % close(fig_head);
                save_flag = 1;
                break
                
            case 27 % ESC
                answer = questdlg('Quit?','Quit?','Save','No Save','Save');
                if strcmp(answer,'No Save')
                    quit_flag = 1;
                    close(fig);
                    break
                else
                    close(fig);
                    % close(fig_head);
                    save_flag = 1;
                    break
                end
                
                %% MISC BUTTONS
            case 104 % h Help Window
                questdlg({'LT Mouse: Mark Channel (toggle)','Number Keys: Mark Event in Time','DEL: Remove closest event marker','L/R Arrows: move time','U/D Arrows: change channel set','+/- Time Resolution','p: sensor position','S: Save and End successfuly','Q: Abort w/o Saving'},...
                    'Help For Inspector','Got It','Got It');
                
            case 112 % p Position of sensor in Helmet
                [~,selected_chan_localidx] = find_closest_in_list(button_y,line_center_list); % which did you select in the few that were shown
                selected_chan_idx = find(strcmp(line_key,current_line_name_list(selected_chan_localidx))); % for all channels
                
                try
                    chan_num =NeuromagCode2ChanNum(line_key(selected_chan_idx));
                    h_temp=figure;hold all
                    Plot_MEG_chan_locations(chan_num,'MarkerType',1,'Color','b','fig',h_temp); % 2013-08-23
                    title(chan_num)
                    Figure_Stretch(0.5,0.5)
                    Figure_TightFrame
                    Figure_Position(0.7,1,h_temp);
                    pause(4)
                    close(h_temp)
                end
                
        end % switch button
    end % bad button if statement
    
end % keep selecting in this batch of channels


%% Outputs

if save_flag
    Marks.signals_idx=find(signals_marked_mask==1);
    Marks.events_idx=events_idx;
else % ABORT
    % Reset to input values if given
    if ~exist('premarked_signals')
        Marks.signals_idx=NaN;
    else
        Marks.signals_idx=parms.premarked_signals;
    end
    if ~exist('events_marks_input')
        Marks.signals_idx=NaN;
    else
        Marks.events_idx=parms.premarked_events;
    end
end

pause(0.01);