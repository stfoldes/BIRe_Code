% Export_Event_File(events,event_file2write,sample_rate)
% Writes events.m files for Brainstorm
%
% REQUIRED INPUT
% events(#).times = must be a list of time (in seconds) for markers [1xnum_events]
%
% SHOULD HAVE
% event_file2write = name and path of event file to write (will prepend "events_4BSTfromMatlab_")
% events(#).label = str for event name
% sample_rate = defaults to 1000Hz
%
% OPTIONAL
% events(ievent).color = R,G,B defaults to BST's choice
%
%
% ---BST EVENT STRUCTURE---
%  (BST BUG: MUST BE IN THIS ORDER...2012-11-14)
%
% events.
%     .label = str for event name
%     .color = can be empty []
%     .epochs = looks like just a bunch of 1's ( ones(1,length(events.samples)) )
%     .samples = FIF sample number for each event
%     .times = time in seconds
%     .reactTimes = []
%     .select = 1
%
% Stephen Foldes [2012-11-14]
% UPDATES:
% 2013-04-15 Foldes: times must be [1xn] size and NOT [nx1] size. BST is dumb. Made this code check and change

function events = Export_Event_File(events_input,event_file2write,sample_rate)

%% Defaults
    if ~exist('sample_rate') || isempty(sample_rate)
        sample_rate = 1000;
        warning(['Assuming sampling rate of ' num2str(sample_rate) 'Hz'])
    end

%% Filling in event info needed by BST (field order matters) :-(

    for ievent = 1:size(events_input,2)
        % label
        if ~isfield(events_input(ievent),'label') || isempty(events_input(ievent).label)
            events(ievent).label = num2str(ievent);
        else
            events(ievent).label = events_input(ievent).label;
        end
        
        % color
        if ~isfield(events_input(ievent),'color')
            events(ievent).color = [];
        else
            events(ievent).color = events_input(ievent).color;
        end
        
        % epochs
        events(ievent).epochs = ones(1,length(events_input(ievent).times));
        
        if size(events_input(ievent).times,1)<size(events_input(ievent).times,2)
            % samples
            events(ievent).samples = round(events_input(ievent).times * sample_rate);
            % times
            events(ievent).times = events_input(ievent).times;
        else
            % samples
            events(ievent).samples = round(events_input(ievent).times * sample_rate)';
            % times
            events(ievent).times = events_input(ievent).times';
        end
        
        % reactTimes
        events(ievent).reactTimes = [];
        % select
        events(ievent).select = 1;
    end
%% Time Stamp this thing
    time_stamp = datestr(now,'yyyy-mm-dd_HHMM');

%% write events to file

    if ~exist('event_file2write') || isempty(event_file2write)
        event_file2write = ['unnamed_' time_stamp];
    end
    
    [file_path file_name]=fileparts(event_file2write);
    if ~strcmp(file_name(1:6),'events')
        file_name = ['events_4BSTfromMatlab_' file_name];
    end
    file2write_full_name = [file_path filesep file_name];
    
    % save
    save(file2write_full_name,'events','time_stamp');

    disp(['BST Events File Written: ' file2write_full_name])
