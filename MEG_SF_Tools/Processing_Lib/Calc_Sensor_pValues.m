% [sig_by_sensor,sig_by_group] = Calc_Sensor_pValues(feature_data_move,feature_data_rest,sensor_list,FeatureParms,freq_range);
% Calculates p-value for each sensor/sensor-group
% Uses ranksum to deal with unequal groups (NOT PAIRED)
%
% ***ASSUMES GIVEN 204 GRADIOMETERS***
%
% SEE: GUI_Inspect_ModDepth_wTopography.m GUI version
%
% feature_data_move
% feature_data_rest
% sensor_list (Extract.chan_list)
% FeatureParms
% freq_range range of frequencies to plot over
%
% 2013-07-01 Foldes
% UPDATES:

function [sig_by_sensor,sig_by_group] = Calc_Sensor_pValues(feature_data_move,feature_data_rest,sensor_list,FeatureParms,freq_range)

%% Defaults

%sensor_group_list = unique(sensors2sensorgroup(sensor_list)); % get sensor group list from sensor_list

%% Plots a head plot for each entry in freq_range
for ifreq_set=1:size(freq_range,1)
    
    freq_min = min(freq_range(ifreq_set,:));
    freq_max = max(freq_range(ifreq_set,:));
    
    % Figure out frequencies you want
    
    % determine closest frequencies to the choices
    [AnalysisParms.actual_freqs, AnalysisParms.freq_idx] = find_closest_range([freq_min:freq_max],FeatureParms.actual_freqs); % 2013-06-26 Foldes
    
    %% ***STATS HERE***
    % Note, the groups are unlikely equal, so must do a method that can handle it.
    for isensor = 1:size(feature_data_move,2)
        sig_by_sensor(isensor) = ranksum(mean(feature_data_move(:,isensor,AnalysisParms.freq_idx),3),mean(feature_data_rest(:,isensor,AnalysisParms.freq_idx),3));
    end
    
    % Combine sensors into sensor groups
    %   take min p value per sensor group ***ASSUMES USING ALL GRADIOMETERS ONLY***
    cnt=0;
    for i=1:2:size(sig_by_sensor,2)
        cnt=cnt+1;
        sig_by_group(cnt) = min(sig_by_sensor(i:i+1));
    end

    % Could combine power first, but this doesn't make sense since you can add noise
    %     sensor_group_move = Calc_Sensor2SensorGroup_Power(feature_data_move,sensor_list);
    %     sensor_group_rest = Calc_Sensor2SensorGroup_Power(feature_data_rest,sensor_list);
    %
    %     for isensor = 1:size(sensor_group_move,2)
    %         sig_by_group(isensor) = ranksum(mean(sensor_group_move(:,isensor,AnalysisParms.freq_idx),3),mean(sensor_group_rest(:,isensor,AnalysisParms.freq_idx),3));
    %     end
    
    
end % freq set



        
        
        
        