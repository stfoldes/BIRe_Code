% Plot_Topography_Stats(feature_data_move,feature_data_rest,sensor_list,FeatureParms,freq_range,fig_tag);
% User selects frequency range on a PSD-plot which to plot a p-value topography for
% ***ASSUMES GIVEN 204 GRADIOMETERS***
%
% SEE: GUI_Inspect_ModDepth_wTopography.m GUI version
%
% feature_data_move
% feature_data_rest
% sensor_list (Extract.chan_list)
% FeatureParms
% freq_range range of frequencies to plot over
% fig_tag[OPTIONAL]
%
%
% 2013-07-01 Foldes
% UPDATES:
% 2013-07-15 Foldes: Bug fix

function [sig_by_sensor,sig_by_group,fig_head] = Plot_Topography_Stats(feature_data_move,feature_data_rest,sensor_list,FeatureParms,freq_range,fig_tag)

%% Defaults
if ~exist('fig_tag')
    fig_tag = '';
end

sensor_group_list = unique(sensors2sensorgroup(sensor_list)); % get sensor group list from sensor_list

%% Plots a head plot for each entry in freq_range
for ifreq_set=1:size(freq_range,1)
    
    % Calc
    [sig_by_sensor,sig_by_group] = Calc_Sensor_pValues(feature_data_move,feature_data_rest,sensor_list,FeatureParms,freq_range(ifreq_set,:));   

    %% PLOT
    
    fig_head=figure;set(fig_head,'Tag',fig_tag);
    figure(fig_head);
    hold all
    Plot_MEG_head_plot(log10(sig_by_group),1,sensorgroup2sensor(sensor_group_list,1),[],[],fig_head);
    % Set colors to be 0.05 to smaller
    colorbar_with_label('log10(p)','EastOutside');
    current_caxis =caxis;
    caxis([current_caxis(1) log10(.05)])
    colormap('gray')
    
    %Figure_Stretch(1.25,1.25)
    Figure_Position(0.7,1)
    
    % Plot sensor locations
    %     current_sensor_group = find(sig_by_group<0.05);
    %     Plot_MEG_chan_locations(sensorgroup2sensor(current_sensor_group)',0,[],fig_head);Plot_MEG_Helmet(fig_head);
    %     % current_pos = sensorgroup2pos(current_sensor_group);
    %     % plot(mean(current_pos(:,1)),mean(current_pos(:,2)),'.r')
    %     % current_sensor_group = find(sig_by_group<p_thres);
    %     % Plot_MEG_chan_locations(sensorgroup2sensor(current_sensor_group)',0,'r',fig_head);Plot_MEG_Helmet(fig_head);
    
    % Figure out frequencies you want (for figure title only)
    freq_min = min(freq_range(ifreq_set,:));
    freq_max = max(freq_range(ifreq_set,:));   
    % determine closest frequencies to the choices
    [AnalysisParms.actual_freqs, AnalysisParms.freq_idx] = find_closest_range([freq_min:freq_max],FeatureParms.actual_freqs);
    
    title([fig_tag ' [' num2str(min(AnalysisParms.actual_freqs)) '-' num2str(max(AnalysisParms.actual_freqs)) 'Hz] Sensor Significance at p<0.05'])
    
end % freq set