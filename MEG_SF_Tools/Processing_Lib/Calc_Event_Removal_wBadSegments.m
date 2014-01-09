function Events = Calc_Event_Removal_wBadSegments(Events,sample_rate)
% Remove event markers that overlap w/ bad time segments
% Uses Events.bad_segments from Mark_Bad_MEG
%   Will add some time-offsets to make sure any window-calculation does not include bad segs even if the event doesn't include bad explicitly
%   Uses  Events.parms_* to figure out offset for events to make sure you remove stuff from big windows
%     'pre_offsetS' and 'post_offsetS' will be used directly (SEE: GUI_Auto_Remove_Events_wArtifacts)         
%     'windowS' for centered windowing (SEE: GUI_Auto_Event_Markers)
%     OR uses a default offset of pre=0s, post=0.5s
%
% Must have an Events.Original.X so you don't overwrite the orignal.
%
% 2013-08-20 Foldes
% UPDATES:
% 2013-08-21 Foldes: Added pre/post_offset paramter option
% 2013-08-29 Foldes: MINOR makes sure to copy from Original even if no bad-segs

%% DEFAULTS

% Whoops, no bad segments
if ~isfield(Events,'bad_segments')
    warning('No bad segments found: use Mark_Bad_MEG')
    return
end

% List of event types to check for bad signals
event_names2check = {'ArtifactFreeRest','ArtifactFreeMove','ParallelPort_Move_Good','EMG','ACC','photodiode'};

default_pre_offsetS = 0; % how many seconds of data BEFORE bad-seg should be considered bad
default_post_offsetS = 0.5; % how many seconds of data AFTER bad-seg should be considered bad


%% CALC

% Get all indices that are considered bad
bad_seg_idx = [];
Events.bad_segments = sort(Events.bad_segments,2); % make sure everything is in order
for iseg = 1:size(Events.bad_segments,2)
    bad_seg_idx = [bad_seg_idx Events.bad_segments(1,iseg):Events.bad_segments(2,iseg)];
end
disp([num2str(length(bad_seg_idx)/sample_rate) 'S of bad data'])

% Go through all event types
clear event_names all_events
event_cnt = 0;
for ievent = 1:size(event_names2check,2)
    pre_offset=[];
    post_offset=[];
    
    % Does the event even exist?
    if isfield(Events.Original,(event_names2check{ievent})) && max(isnan(Events.Original.(event_names2check{ievent})))~=1
        
        % Try to get parameters to help with removal timing
        if isfield(Events.Original,(['parms_' event_names2check{ievent}]))
            % Have pre/post_offsetS
            if isfield(Events.Original.(['parms_' event_names2check{ievent}]),'pre_offsetS')
                offset_name = 'pre_offsetS';
                % Sometimes there are multiple offset sizes (like if there are 2 channels used to make marks), choose max
                for ioffset=1:length(Events.Original.(['parms_' event_names2check{ievent}]))
                    all_offsets(ioffset) = Events.Original.(['parms_' event_names2check{ievent}])(ioffset).(offset_name);
                end
                pre_offsetS = max(all_offsets);
                pre_offset = round(pre_offsetS*sample_rate); % round b/c original offset will have a round
                
                offset_name = 'post_offsetS';
                % Sometimes there are multiple offset sizes (like if there are 2 channels used to make marks), choose max
                for ioffset=1:length(Events.Original.(['parms_' event_names2check{ievent}]))
                    all_offsets(ioffset) = Events.Original.(['parms_' event_names2check{ievent}])(ioffset).(offset_name);
                end
                post_offsetS = max(all_offsets);
                post_offset = round(post_offsetS*sample_rate); % round b/c original offset will have a round
                
                
            % FOR CENTERED WINDOWS (eg. windowS from GUI_Auto_ArtifactFree_Markers.m)
            elseif isfield(Events.Original.(['parms_' event_names2check{ievent}]),'windowS') % FROM: GUI_Auto_ArtifactFree_Markers.m
                window_name = 'windowS';
                %             % windowS and peak_windowS are possible parameters that are centered windows
                %             elseif isfield(Events.Original.(['parms_' event_names2check{ievent}]),'windowS') || isfield(Events.Original.(['parms_' event_names2check{ievent}]),'peak_windowS')
                %                 if isfield(Events.Original.(['parms_' event_names2check{ievent}]),'windowS') % FROM: GUI_Auto_ArtifactFree_Markers.m
                %                     window_name = 'windowS';
                %                 elseif isfield(Events.Original.(['parms_' event_names2check{ievent}]),'peak_windowS') % FROM: GUI_Auto_Event_Markers.m
                %                     window_name = 'peak_windowS';
                %                 end
                
                % Sometimes there are multiple window sizes (like if there are 2 channels used to make marks), choose max
                for iwindow=1:length(Events.Original.(['parms_' event_names2check{ievent}]))
                    all_windows(iwindow) = Events.Original.(['parms_' event_names2check{ievent}])(iwindow).(window_name);
                end
                window_offsetS = max(all_windows);
                window_offset = round(window_offsetS*sample_rate); % round b/c original window will have a round
                % window is centered
                pre_offset = round(window_offset/2);
                post_offset = round(window_offset/2);
            end
        end
        
        % No parameters, use defaults
        if isempty(pre_offset) || isempty(post_offset)
            pre_offset = round(default_pre_offsetS*sample_rate);
            post_offset = round(default_post_offsetS*sample_rate);
        end
        
        % all samples that are considered bad w/ offsets added
        bad_seg_idx = [];
        for iseg = 1:size(Events.bad_segments,2)
            bad_seg_idx = [bad_seg_idx Events.bad_segments(1,iseg)-pre_offset:Events.bad_segments(2,iseg)+post_offset];
        end
        
        % Find samples that are in events and in the bad seg list
        if ~isempty(bad_seg_idx)
            
            % Try to use original if there is one
            %             if isfield(Events.Original,(event_names2check{ievent}))
            events2check = Events.Original.(event_names2check{ievent});
            %             else
            %                 msgbox([event_names2check{ievent} ' Does not have an original'])
            %                 events2check = Events.(event_names2check{ievent});
            %             end
            
            bad_events_idx = (find_lists_overlap_idx(events2check,bad_seg_idx));
            
            % Remove bad stuff
            events2check(bad_events_idx)=[];
            Events.(event_names2check{ievent}) = events2check; % keep original
            
            disp(['*** ' num2str(length(bad_events_idx)) '/' num2str(length(events2check)) ' Events Removed from ' event_names2check{ievent} ' ***'])
        else % no overlap, so copy from Original to base
            Events.(event_names2check{ievent}) = Events.Original.(event_names2check{ievent}); % keep original
        end
    end % does the event even exist?
end % all event types

disp(' ')


