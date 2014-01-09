function [save_flag,bad_chan_list,bad_segments] = Mark_Bad_MEG(Extract,prebadchan_file,event_file)
% Inspect and mark bad channels and bad time segments
% Adds a few averaged channels also to help with marking bad time segments
% Takes in files with previous markings if applicable
% e.g. marking bad channels for Maxfilter
% Uses Plot_Inspect_TimeSeries_Signals.m
%
% Will look to see if bad channels or bad time segments are already marked in Stephen's standard format
%     bad channel file = *_prebadchans.txt []
%     bad time segment = *_Events.mat [Events.bad_segments(1,:)=start samples, Events.bad_segments(2,:)=end samples]
%
% ---INPUTS---
%     Currently a lot of info is needed to a) get the MEG data extracted and b) look up old bad-marks
%       Extract: See Load_from_FIF and Prep_Extract_w_DB
%       prebadchan_file: .txt file listing sensor names in Neuromag format, e.g. 0213 0232 1241 (THIS IS THE BADCHAN FILE FOR MAXFILTER)
%       event_file: .mat file of events [Events.bad_segments(1,:)=start samples, Events.bad_segments(2,:)=end samples]
%
% BUTTON KEY:
%     Left Mouse Click = toggle channel as bad or good
%     1 = start of bad time segment
%     2 = end of bad time segment (must match)
%     up/down arrow keys = change channels shown
%     left/right arrow keys = change time shown
%     s = finished w/ saving
%     q = quit without saving
%
% SEE: Batch_Preprocessing_MEG.m
%
% EXAMPLE:
%     prebadchan_file = [DB_entry.file_path(server_path) filesep DB_entry.Preproc.Pointer_prebadchan];
%     event_file = [DB_entry.file_path(server_path) filesep DB_entry.Preproc.Pointer_Events];
%
% 2013-02-20 Foldes
% UPDATES:
% 2013-08-20 Foldes: MAJOR - branch from Mark_Bad_Channels
% 2013-09-03 Foldes: Bug fix

%% Get MEG

% IMPROVEMENTS: Adding STI to show, plot bad channels AND current channels?
[MEG_data,TimeVecs.timeS,MEG_chan_list] = Load_from_FIF(Extract,'MEG');
% Low pass filter (30Hz) ***A BIT SLOW***
disp('CALCULATING: low-pass filter of sensors')
clear photodiode_processed filter_b filter_a
Wn=30/(Extract.data_rate/2);
[filter_b,filter_a] = butter(4,Wn,'low'); % 4th order butterworth filter
MEG_processed=filtfilt(filter_b,filter_a,MEG_data);
clear MEG_data

%***COULD MAKE A GUESS WITH MAHALINOBIS DISTANCE***

%% Get existing bad channels from file

bad_channel_mask=zeros(1,size(MEG_chan_list,1));

% If you have a bad channel file already, load it and use it.
if exist('prebadchan_file') && ~isempty(prebadchan_file) % was this given as an input?
    if exist(prebadchan_file)==2
        bad_chan_name_from_file=load(prebadchan_file);
        
        for ibad = 1:size(bad_chan_name_from_file,2)
            bad_chan_str=['0' num2str(bad_chan_name_from_file(ibad))]; % need to add that zero sometimes
            bad_chan_str=bad_chan_str(end-3:end);
            all_chan_str=MEG_chan_list(:,end-3:end);
            % Boy, this is annoying. I'm just trying to find the indices of overlap
            for ichan = 1:length(all_chan_str)
                if strcmp(bad_chan_str,all_chan_str(ichan,:));
                    bad_channel_mask(ichan)=1;
                    break
                end
            end
        end
    else
        warning(['Can''t load old prebadchan file for some reason (' prebadchan_file ')'])
    end
end

%% Get existing bad segments from file
bad_segments_initial=[];

if exist('event_file') && exist(event_file)==2
    %DB_Load_Pointer_Data
    load(event_file);
    if isfield(Events,'bad_segments') && ~isempty(Events.bad_segments)
        % start with any previous marks
        bad_segments_initial{1} = Events.bad_segments(1,:);
        bad_segments_initial{2} = Events.bad_segments(2,:);
    end
end


%% Add some averages to the plot for helping w/ time segment marking
sensors_LT = [1 10 172];
sensors_RT = [154 157 298];
sensors_front = [52 85 91];
sensors_back = [196 241 244 292];
MEG_plus = [mean(MEG_processed(:,[sensors_back sensors_back+1]),2)...
    mean(MEG_processed(:,[sensors_front sensors_front+1]),2)...
    mean(MEG_processed(:,[sensors_LT sensors_LT+1]),2)...
    mean(MEG_processed(:,[sensors_RT sensors_RT+1]),2)...
    mean(MEG_processed(:,[sensors_back+3 sensors_front+3 sensors_LT+3 sensors_RT+3]),2)...
    MEG_processed];
MEG_chan_list_plus = ['Back   '; 'Front  '; 'LT     '; 'RT     '; 'All MAG'; MEG_chan_list];
num_extra_chans = (size(MEG_plus,2)-size(MEG_processed,2));
prebad_list =[1:num_extra_chans find(bad_channel_mask==1)+num_extra_chans]; % list of channels to mark as 'bad' to start w/ including the averages

%% Plot Interface
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

[Marks,save_flag]=Plot_Inspect_TimeSeries_Signals(TimeVecs.timeS,MEG_plus,...
    'signal_name_list',MEG_chan_list_plus,'premarked_signals',prebad_list,'premarked_events',bad_segments_initial,'plot_title',Extract.file_name);
bad_chan_list = [];
bad_segments = [];
if save_flag
    bad_chan_list = MEG_chan_list(Marks.signals_idx(num_extra_chans+1:end)-num_extra_chans,4:end);
    if max(size(Marks.events_idx)>=2) % isempty
        bad_segments = [sort(Marks.events_idx{1}); sort(Marks.events_idx{2})];
    end
end
