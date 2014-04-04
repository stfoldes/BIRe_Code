function [file2write_full_name, events] = Export_BSTEvent_File(event_timeS,sample_rate,event_file2write,varargin)
% Writes events.m files for Brainstorm. Used for only ONE event type at a time
%
% INPUT
%   event_timeS         = list of time (in seconds) for markers [1xnum_events] (MUST BE FIF-TIME; THERE IS USUALLY AN OFFSET)
%   sample_rate         = obvious
%   event_file2write    = name and path of event file to write (will prepend "events_4BSTfromMatlab_")
%
% VARARGIN
%     Any of the posible fields of BST's events.
%         label        = str for event name
%         color        = can be empty []
%         epochs       = looks like just a bunch of 1's ( ones(1,length(events.samples)) )
%         samples      = FIF sample number for each event
%         times        = time in seconds
%         reactTimes   = []
%         select       = 1
%
%     Suggested VARARGINs
%         'label'   = str for event name
%         'color'   = R,G,B defaults to BST's choice
%
%  (BST BUG: MUST BE IN THIS ORDER...2012-11-14)
%
% EXAMPLE: 
%
% 2012-11-14 Foldes
% UPDATES:
% 2013-04-15 Foldes: times must be [1xn] size and NOT [nx1] size. BST is dumb. Made this code check and change
% 2013-12-13 Foldes: MAJOR redid

%% Defaults
if ~exist('sample_rate') || isempty(sample_rate)
    sample_rate = 1000;
    warning(['Assuming sampling rate of ' num2str(sample_rate) 'Hz'])
end

%% Filling in event info needed by BST (field order matters) :-(
% This is done clever using varargin_extraction to save tons of code

defaults.label          = 'ExternalMaker';
defaults.color          = [];
defaults.epochs         = ones(1,length(event_timeS));
defaults.samples        = round(reshape(event_timeS,1,[]) * sample_rate); % dimensions matter
defaults.times          = reshape(event_timeS,1,[]); % dimensions matter
defaults.reactTimes     = [];
defaults.select         = 1;

events = varargin_extraction(defaults,varargin);

%% write events to file

time_stamp = datestr(now,'yyyy-mm-dd_HHMM');

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
