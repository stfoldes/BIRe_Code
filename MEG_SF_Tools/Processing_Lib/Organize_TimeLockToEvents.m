% [data_by_event,event_idx_by_trial]=Organize_TimeLockToEvents(data,input_event_idx_vec,pre_event_time,post_event_time)
% Stephen Foldes (2012/02 to replace GetPowerOffline_TimeLockByEvent.m)
%
% Simply aligns data to events. Function will take signals and event index vector and return a cell array of data around each event
% Commonly used with pRT-power data.
% 
% Replaces GetPowerOffline_TimeLockByEvent.m, though it is doesn't have as good temporal resolution (but its like 100 times faster)
%
% ---OUTPUTS---
%   data_by_event{trial}(time x channels x frequencies)
%   event_idx(ievent) = sample that corresponds to where the event happend in the data_by_event cell array for each trial
%
% ---INPUTS---
%   data(samples x signals) = time series data
%   input_event_idx_vec(events x 1) = list event indicies corresponding to the data
%   pre_event_time = samples before the event to include
%   post_event_time = samples after the event to include, limited to next trial
%
% UPDATES
% 2012-03-17 SF: Cleaned up commenting renamed from Calc_TimeLockToEvents
% 2013-12-06 Foldes: Turn from cell into 

function [data_by_event,event_idx_by_trial]=Organize_TimeLockToEvents(data,input_event_idx_vec,pre_event_time,post_event_time,no_cell_flag)

clear data_by_event
for ievent=1:length(input_event_idx_vec)
    
    event_time_idx = input_event_idx_vec(ievent);
    trial_start_sample = event_time_idx-pre_event_time;
    trial_end_sample = event_time_idx+post_event_time; 
    
    if trial_start_sample>0 && trial_end_sample <= size(data,1)%is this a trial valid to analyize in this way?
        data_by_event{ievent}=data(trial_start_sample:trial_end_sample,:,:);
        event_idx_by_trial(ievent)=pre_event_time+1;
    else 
        data_by_event{ievent}=[];
        event_idx_by_trial(ievent)=NaN;
    end % valid trial
   
end %event

%% try to turn it into matrix instead of a cell if possible.

if exist('no_cell_flag') && no_cell_flag == 1
    data_by_event = cell2array(data_by_event);
end