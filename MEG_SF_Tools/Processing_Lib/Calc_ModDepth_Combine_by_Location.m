function [moddepth_by_location_freqband,sensor_group_list]=Calc_ModDepth_Combine_by_Location(moddepth,freq_idx_4grouping,sensor_list)
% Combines modulation by sensor-location
%   Takes the sensor with the max-mag as the representative sensor for the group
%   To calc maxmag, it first avg trials, then avg across freq band given in freq_idx_4grouping
%
%   freq_idx_4grouping =
%       EXAMPLES: 
%           freq_idx_4grouping = [DEF_freq_bands('beta');DEF_freq_bands('gamma')];
%           OR
%           [~, freq_idx_4grouping] = find_closest_range([min(freq_range),max(freq_range)],FeatureParms.actual_freqs); % determine closest frequencies to the choices
%
% SEE: Calc_ModDepth.m, Results_MEG_ModDepth
%
% 2013-07-18 Foldes
% UPDATES:


% Get General Sensor Grouping Info
load DEF_NeuromagSensorInfo;
for ichan = 1:length(sensor_list)
    sensor_idx2group(ichan) = NeuromagSensorInfo(sensor_list(ichan)).sensor_group_num;
end
sensor_group_list=unique(sensor_idx2group);

% sensor_group_data = [sensor_group x freq_band]
sensor_group_data = zeros(length(sensor_group_list),size(freq_idx_4grouping,1));


% go thru each freq set
for ifreq_set = 1:size(freq_idx_4grouping,1)
    
    current_freq_idx=[min(freq_idx_4grouping(ifreq_set,:)):max(freq_idx_4grouping(ifreq_set,:))];
    
    % Avg across freq band and trial
    sensor_data = squeeze(mean(mean(moddepth(:,:,current_freq_idx),3),1));
    % Combine sensor groups using the given method name
    
    for igroup = 1:length(sensor_group_list)
        data = sensor_data( sensor_idx2group==sensor_group_list(igroup) );
        %         % if all are NaN
        %         if min(isnan(data))==1
            
        sensor_group_data(igroup,ifreq_set) = data(max_idx(abs(data)));
    end
    %         Plot_MEG_head_plot(sensor_group_data,1,sort([1:3:306]));
    %         caxis_center(4)
    %         colorbar
    %         title('Avg trials, Avg freq band <1s')
end

moddepth_by_location_freqband = sensor_group_data;