% [org_data,org_idx,unique_types]=Organize_ByTypeAndTrial(data,type_data,trial_start_end_idx)
% Stephen Foldes (2011-03-07 OrganizeBytypeAndTrial.m)
%
% Oranizes input data by type and by trial. Uses cells so trials don't have to be the same size.
% org_data{type}{trial}
%
% INPUTS
% data = (samples x channels)
% type_data = (samples x type-dimension) cue information
% trial_start_end_idx = (trials x 2) vector of trial starting points (:,1) and ending points (:,2) (can be locked to what ever you want)
%                       if [], the finds the transitions from type_data
%
% OUTPUTS
% org_data{trial,type}(time x channel x freq bands)
%
% UPDATES
% 2011-04-20 SF: now allows input data to be 2 or 3-D (for time series or power data). Set default trial start end index
% 2012-02-10 SF: Changed name from OrganizeBytypeAndTrial.m
% 2012-03-17 SF: Changed name from Org_*.m

function [org_data,org_idx,unique_types]=Organize_ByTypeAndTrial(data,type_data,trial_start_end_idx)

    unique_types=unique(type_data,'rows');
    num_unique_types=size(unique_types,1);

    % if no start-end index given, find it from type_data
    if isempty(trial_start_end_idx)
        trial_change_idx=TrialTransitions(type_data);
        trial_start_end_idx=[trial_change_idx(1:end-1) trial_change_idx(2:end)-1];
        trial_start_end_idx((trial_start_end_idx(:,2) == size(data,1)-1),2)=size(data,1); % you need to make sure the last index is perserved
    end
    
%% Organize Data by trial and type
    trial_cnt=zeros(num_unique_types,1);
    clear org_data
    for itrial=1:size(trial_start_end_idx,1)-1

        clear current_type*
        for itype=1:num_unique_types
            current_type_vec(itype)=sum(type_data(trial_start_end_idx(itrial,1),:) == unique_types(itype,:))==size(unique_types,2);
        end
        current_type=find(current_type_vec==1);
        
        trial_cnt(current_type)=trial_cnt(current_type)+1;
        
        % Cell organized: {Trial,type}(time x channel)
        if size(size(data),2)==2 % for 2D raw data
            org_data{current_type}{trial_cnt(current_type)}=data(trial_start_end_idx(itrial,1):trial_start_end_idx(itrial,2),:);
        elseif size(size(data),2)==3 % for 3D raw data (such as power data with samples x channels x freq bands
            org_data{current_type}{trial_cnt(current_type)}=data(trial_start_end_idx(itrial,1):trial_start_end_idx(itrial,2),:,:);
        end
        
        org_idx{current_type}{trial_cnt(current_type)}=trial_start_end_idx(itrial,:);
        
    end
    