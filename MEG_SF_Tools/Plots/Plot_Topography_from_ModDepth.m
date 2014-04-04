function [actual_freqs,fig_head] = Plot_Topography_from_ModDepth(moddepth,sensor_list,FeatureParms,freq_range,fig_tag,mark_best_sensors_flag,best_sensors_possibilties)% User selects frequency range on a PSD-plot which to plot a topography for
% SEE: GUI_Inspect_ModDepth_wTopography.m GUI version
%
% moddepth
% moddepth_by_sensor_set
% sensor_list
% FeatureParms
% freq_range range of frequencies to plot over
% fig_tag[OPTIONAL]
%
% Flags:
%     mark_best_sensors_flag: 1 = put a marker on the topography plot for the max and min sensor locations (must have moddepth_by_sensor_set)
%     best_sensors_possibilties: can give a group of sensors to limit "best" to (***THIS IS NOT SENSOR_GROUP***)
%
% 2013-06-26 Foldes
% UPDATES:
% 2013-06-27 Foldes: added flag options
% 2013-07-18 Foldes: MAJOR new way to group sensors


%% Defaults
if ~exist('fig_tag')
    fig_tag = '';
end

if ~exist('mark_best_sensors_flag') || isempty(mark_best_sensors_flag)
    mark_best_sensors_flag = 0;
end


sensor_group_list = unique(sensors2sensorgroup(sensor_list)); % get sensor set list from sensor_list

%% Plots a head plot for each entry in freq_range
for ifreq_set=1:size(freq_range,1)
    
    %% Figure out frequencies you want    
    freq_min = min(freq_range(ifreq_set,:));
    freq_max = max(freq_range(ifreq_set,:));

    % determine closest frequencies to the choices
    [AnalysisParms.actual_freqs, AnalysisParms.freq_idx] = find_closest_range([freq_min:freq_max],FeatureParms.actual_freqs); 
        
    %% Calc moddepth by location
    [moddepth_by_sensor_set, sensor_group_list] = Calc_ModDepth_Combine_by_Location(moddepth,AnalysisParms.freq_idx,sensor_list);
    
    
    %% Extra Crap for the fancy stuff
    % Define best sensor set to look at (if flagged)
    if ~exist('best_sensors_possibilties') || isempty(best_sensors_possibilties)
        best_sensors_possibilties = sensor_list;
    end
    best_sensor_group_possi=unique(sensors2sensorgroup(best_sensors_possibilties));
    best_group_possi_local_idx = find_lists_overlap_idx(sensor_group_list,best_sensor_group_possi);
    best_group_possi_global=sensor_group_list(best_group_possi_local_idx); 
    
    % Find best sensor set for marking (if flagged), must be after best freq (if flagged)
    clear best_sensor_group_idx
    if mark_best_sensors_flag==1
        
        if min(AnalysisParms.actual_freqs)<40
            best_sensor_group_idx = min_idx(moddepth_by_sensor_set(best_group_possi_local_idx,:));
        else
            best_sensor_group_idx = max_idx(moddepth_by_sensor_set(best_group_possi_local_idx,:));
        end
        best_sensor_group = best_group_possi_global(best_sensor_group_idx); % relative to global sensor sets
        best_sensor=sensorgroup2sensor(best_sensor_group);
    end
    
    
    
    %% Plot Modulation Depth Topography
    
    fig_head=figure;set(fig_head,'Tag',fig_tag);
    figure(fig_head);
    subplot(2,2,[3 4]);hold all
    Plot_MEG_head_plot(sensorgroup2sensor(sensor_group_list,1),moddepth_by_sensor_set,'sensor_type',1,'fig',fig_head);    
    if mark_best_sensors_flag % mark the best sensor location
        %Plot_MEG_chan_locations(best_sensors_possibilties,1,'w',fig_head);
        %Plot_MEG_chan_locations(best_sensor,1,[],fig_head);
        Plot_MEG_chan_locations(best_sensor,'MarkerType',1,'fig',fig_head); % 2013-08-13
    end
    caxis_center%(maxmag([maxmag(get(gca,'CLim')),1]));
    colorbar_with_label('Modulation','EastOutside');
    title('By Sensor Location')
    
    
    % average across trials and frequencies choosen
    clear mod_depth_by_chan
    for ichan = 1:size(moddepth,2)
        mod_depth_by_chan(:,ichan) = mean(mean(moddepth(:,ichan,AnalysisParms.freq_idx),1),3);
    end
    
    subplot(2,2,1);hold all
    Plot_MEG_head_plot(sensor_list,mod_depth_by_chan,'sensor_type',1,'fig',fig_head);

    caxis_center(maxmag([maxmag(get(gca,'CLim')),1]));
    colorbar_with_label('Modulation','EastOutside');
    %         title([fig_tag ' [' num2str(min(AnalysisParms.actual_freqs)) '-' num2str(max(AnalysisParms.actual_freqs)) 'Hz]'])
    
    subplot(2,2,2);hold all
    Plot_MEG_head_plot(sensor_list,mod_depth_by_chan,'sensor_type',2,'fig',fig_head);
    
    
    caxis_center(maxmag([maxmag(get(gca,'CLim')),1]));
    colorbar_with_label('Modulation','EastOutside');
    %title([fig_tag ' [' num2str(min(AnalysisParms.actual_freqs)) '-' num2str(max(AnalysisParms.actual_freqs)) 'Hz]'])
    
    Figure_Stretch(1.25,1.25)
    Figure_Position(0.7,1)
    %     Figure_TightFrame
    title_figure([fig_tag ' [' num2str(min(AnalysisParms.actual_freqs)) '-' num2str(max(AnalysisParms.actual_freqs)) 'Hz]'])

end % freq sets

actual_freqs=AnalysisParms.actual_freqs;
