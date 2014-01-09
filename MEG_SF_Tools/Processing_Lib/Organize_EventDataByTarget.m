% [data_by_target unique_target_list] = Organize_EventDataByTarget(data_by_event,event_idx,target_code)
% Stephen Foldes (2011/09)
%
% Takes in data that is organized by events (each cell entry is data for an event), the event sample index, and the target information and organizes the data by target type.
% Used well with GetPowerOffline_TimeLockByEvent.m and associated functions
%
% data_by_event{event}(samples x n x m): n and m can be anything, such as channels and frequencies as in GetPowerOffline_TimeLockByEvent.m output
% event_idx(events,1): sample numbers that corrispond to when the event happened
% target_code(samples,1): the target_code information to look up what target occured during the event.
%
% data_by_target{target}(samples x n x m x event)
% unique_target_list = list of the cell-order for data_by_target
%
% UPDATES:
% 2012-02-10 SF: added 'unique_target_list' as output
% 2012-03-17 SF: changed file name from OrgEventDataByTarget.m


function [data_by_target,unique_target_list] = Organize_EventDataByTarget(data_by_event,event_idx,target_code)

% Organize Event Power by Target Type
    unique_target_list = unique(target_code(event_idx));
    num_unique_target_list = size(unique_target_list,1);

    clear data_by_target target_code_by_target event_idx_by_target
    for itarget =1:num_unique_target_list
        target_code_by_target(itarget)=unique_target_list(itarget);
        event_idx_by_target{itarget} = find(target_code(event_idx)==unique_target_list(itarget)); % list of event numbers that share a given target code

        % remove events that are 0 size (GetPowerOffline_TimeLockByEvent doesn't do the first event sometimes b/c can't go back in time)
        clear event_size min_event_size
        event_to_remove=[];
        for ievent = 1:size(event_idx_by_target{itarget},1)
            event_size(ievent) = size(data_by_event{event_idx_by_target{itarget}(ievent)},1);
            if event_size(ievent)==0 
                event_to_remove = [event_to_remove ievent];
            end
        end
        min_event_size = min(event_size(event_size>0)); % remove event that are 0 size (GetPowerOffline_TimeLockByevent doesn't do the first event b/c can't go back in time)
        
        if ~isempty(min_event_size)
            event_idx_by_target{itarget}(event_to_remove)=[];
            
            % initialize
            %data_by_target{itarget} = zeros(min_event_size, size(data_by_event{end},2), size(data_by_event{end},3));
            
            for ievent = 1:size(event_idx_by_target{itarget},1)
                data_by_target{itarget}(:,:,:,ievent)= data_by_event{event_idx_by_target{itarget}(ievent)}(1:min_event_size,:,:);  % data_by_target{target}(time x channel x frequency x event)
            end
            % data_by_target{target}(time x channel x frequency x event)
        end
    end
