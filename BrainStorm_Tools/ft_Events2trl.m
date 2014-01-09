% Turn events list into cfg output for fieldtrip
% 2013-11-21 Foldes'

% window_lengthS = AnalysisParms.window_lengthS_move;
% window_length = window_lengthS*Extract.data_rate;
% event_idx = AnalysisParms.events_move;
% cfg = ft_Events2trl(cfg,event_idx,window_length);

function cfg = ft_Events2trl(cfg,event_idx,window_length)
% cfg.trl(*) = [begsample endsample offset code];
% ex(1,:) = [26058 26557 500 3]
%     ==> Trial 1 = samples [26058:26557] where the first sample is 500 samples BEFORE a cue of code 3

half_window_length = floor(window_length/2); % used to center analyisis around cue
cfg.trl=[];
for ievent = 1:length(event_idx)
    current_event_idx = event_idx(ievent);
    % note: NO way to prevent too big of a window
    % cfg.trl(*) = [begsample endsample offset code];
    % Don't think I care about offset or code, I can deal with that myself
    cfg.trl(ievent,:) = [current_event_idx-half_window_length current_event_idx+half_window_length 0 0];
end