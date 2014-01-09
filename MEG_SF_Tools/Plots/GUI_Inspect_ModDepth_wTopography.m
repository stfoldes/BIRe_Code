function fig_psd=GUI_Inspect_ModDepth_wTopography(fig_psd,feature_data_move,feature_data_rest,sensor_list,FeatureParms,varargin)%p_thres,fig_tag)
%function fig_psd=GUI_Inspect_ModDepth_wTopography(fig_psd,feature_data_move,feature_data_rest,sensor_list,FeatureParms,varargin)%p_thres,fig_tag)
% User selects frequency range on a PSD-plot which to plot a topography for
% SEE: Plot_Topography_from_ModDepth.m for non-GUI version (this was fancy, but too fancy, removed from here for now)
%
% feature_data_move
% feature_data_rest
% sensor_list
% FeatureParms
% p_thres
% fig_tag
%
% MUST PLOT PSD FIRST
%    fig_psd=Plot_ModDepth_Variance(moddepth_by_sensor_set,FeatureParms,sensor_list,sensor_grouping_flag,fig_tag);
%
% 2013-06-07 Foldes
% UPDATES:
% 2013-06-26 Foldes: Non-GUI guts removed for separate function, now this is just a wrapper.
% 2013-07-01 Foldes: MAJOR now takes in feature data instead of mod data, also does stats toporgaphy as well
% 2013-07-18 Foldes: MAJOR Moddepth calc updated
% 2013-10-24 Foldes: UPDATE

defaults.fig_tag    = '';
defaults.p_thres    = 0.05;
defaults.mod_method = 'T'; % See: Calc_ModDepth
parms = varargin_extraction(defaults,varargin);

msg_h = msgbox({'* PSD plot is now interactive *' 'left mouse = select, esc = end'}, 'Select freqs for topo');
Figure_Position(0.55,1,msg_h);

moddepth= Calc_ModDepth(feature_data_move,feature_data_rest,defaults.mod_method);

%% Topography Plots for selected frequencies

loop_flag =1;
while loop_flag
    
    % User selects frequency range from figure (if no range is given as input)
    % Select point on PSD figure
    figure(fig_psd);hold all
    clear mouse_x
    try
        [mouse_x,mouse_y,button_pressed]=ginput(1); % Assumes x axis is frequency [Hz]
    catch
        break
    end
    if isempty(button_pressed) || (button_pressed~=1 && button_pressed~=115) % any button BUT 's'
        break
    end
    if button_pressed==115 % An 's' button will save all the figures and quit
        Save_Fig_wTag(fig_tag)
        break
    end
    freq_ideal(1) = find_closest_in_list(mouse_x,FeatureParms.actual_freqs);
    % plot first click
    Plot_VerticalMarkers(freq_ideal(1),'Color','r','LineWidth',1.5);
    
    
    [mouse_x(2),mouse_y,button_pressed]=ginput(1); % Assumes x axis is frequency [Hz]
    if isempty(button_pressed) || (button_pressed~=1 && button_pressed~=115) % any button BUT 's'
        break
    end
    if button_pressed==115 % An 's' button will save all the figures and quit
        Save_Fig_wTag(fig_tag)
        break
    end
    freq_ideal(2) = find_closest_in_list(mouse_x(2),FeatureParms.actual_freqs);
    Plot_VerticalMarkers(freq_ideal(2),'Color','r','LineWidth',1.5);
	Plot_Block_Patch(freq_ideal);
    
    
    %% Mod Calculations
    
    % determine closest frequencies to the choices (already done, but what ever)
    [freq_range, freq_range_idx] = find_closest_range([min(freq_ideal) max(freq_ideal)],FeatureParms.actual_freqs); 
    
    % Get a stats-mask
    mod_depth_by_chan = Calc_Sensor_Masked_by_pValue(moddepth,feature_data_move,feature_data_rest,sensor_list,FeatureParms,freq_range,parms.p_thres);
    
    % Calc moddepth by location
    [moddepth_by_sensor_set_masked, sensor_group_list] = Calc_ModDepth_Combine_by_Location(mod_depth_by_chan,freq_range_idx,sensor_list);
    
    %% TOPO Plot 
    fig_head=figure;%set(fig_head,'Tag',fig_tag);
    figure(fig_head);
    subplot(2,2,[3 4]);hold all
    Plot_MEG_head_plot(sensorgroup2sensor(sensor_group_list,1),moddepth_by_sensor_set_masked,'fig',fig_head);
    colormap_masked_middle(.05);
    title(['Grouped Sensors: p-value<' num2str(parms.p_thres)])
    
    % average across trials and frequencies choosen
    clear mod_depth_by_chan
    for ichan = 1:size(moddepth,2)
        mod_depth_by_chan(:,ichan) = mean(mean(moddepth(:,ichan,freq_range_idx),1),3);
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
    title_figure([parms.fig_tag ' [' num2str(min(freq_range)) '-' num2str(max(freq_range)) 'Hz]'])

    
    
    
%     actual_freqs=Plot_Topography_from_ModDepth(moddepth,sensor_list,FeatureParms,freq_range,parms.fig_tag);
%     
%     figure(fig_psd)
%     plot([min(actual_freqs) max(actual_freqs)],[0 0],'.-k','MarkerSize',20,'LineWidth',2);
    
    
end % loop

try
    close(msg_h)
end
