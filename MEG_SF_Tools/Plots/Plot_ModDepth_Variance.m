function fig_out = Plot_ModDepth_Variance(moddepth,FeatureParms,sensor_key,varargin) % sensors4plot,sensor_grouping_flag,fig_tag
% Plot modulation depth vs. frequency (PSD), showing the variance
% Defaults to left/right senorimotor sensors and all sensors
%
% INPUTS:
%     moddepth = trials x sensors x freq
%     sensor_key = list of sensor-numbers corresponding to 2nd dim of moddepth
%     FeatureParms = see class
%
% OPTIONAL:
%     sensors4plot: 'L','R','LR'('RL') left and/or right sensorimotor areas are options at this point, right and left are default
%                   One day this could be a list of sensor-numbers (related to 306) to plot compared to all,
%                   in fact it could be a cell! the issue is the legend
%
%     sensor_grouping_flag: 1 if the data is already grouped...but that is unlikely as of 2013-07-18
%     fig_tag: tag to add to figures
%
% EXAMPLE:
%     Plot modulation for left sensorimotor vs. all sensors
%     fig=Plot_ModDepth_Variance(Results.moddepth,Results.FeatureParms,Results.Extract.channel_list,'sensors4plot','L');
%
% 2013-06-07 Foldes
% UPDATES:
% 2013-07-18 Foldes: Cleaned up (don't use grouping anymore...probably)
% 2013-08-09 Foldes: MAJOR now uses varargin, Can plot just one set of sensors
% 2013-08-13 Foldes: Other Sensors now dosen't include the ones already plotted (might not be best)
% 2013-09-17 Foldes: fig is possible input now
% 2013-10-23 Foldes: All other sensors changed from mean+-std to 95%

%% DEFAULTS

% Unpack varargin
defaults.sensors4plot='LR'; % default is to do both left and right sensorimotor
defaults.sensor_grouping_flag=0; % sensor data is NOT grouped
defaults.fig_tag = '';
defaults.fig = '';
parms = varargin_extraction(defaults,varargin); % load inputs into default parameters

% group if needed
if (parms.sensor_grouping_flag==1)
    sensorimotor_right_idx = sensors2sensorgroupidx(sensor_key,DEF_MEG_sensors_sensorimotor_right_hemi);
    sensorimotor_left_idx = sensors2sensorgroupidx(sensor_key,DEF_MEG_sensors_sensorimotor_left_hemi);
else
    sensorimotor_right_idx = sensors2chanidx(sensor_key,DEF_MEG_sensors_sensorimotor_right_hemi);
    sensorimotor_left_idx = sensors2chanidx(sensor_key,DEF_MEG_sensors_sensorimotor_left_hemi);
end


%% Plot PSD
if isempty(parms.fig)
    parms.fig=figure;
else
    figure(parms.fig);
end
set(parms.fig,'Tag',parms.fig_tag); hold all
    
legend_text{1} = []; % string to use in a legend
sensor_idx_ploted=[];

% Right Sensorimotor
if strcmpi(parms.sensors4plot,'R')||strcmpi(parms.sensors4plot,'LR')||strcmpi(parms.sensors4plot,'RL')
    Plot_Variance_as_Patch(FeatureParms.actual_freqs,squeeze(mean(moddepth(:,sensorimotor_right_idx,:),1))',...
        'variance_method','maxmin','patch_color','r','fig',parms.fig,'patch_alpha',0.25);
    sensor_idx_ploted = [sensor_idx_ploted sensorimotor_right_idx];
    legend_text{end+1} = 'Right Sensorimotor (max-min)';
end

% Left Sensorimotor
if strcmpi(parms.sensors4plot,'L')||strcmpi(parms.sensors4plot,'LR')||strcmpi(parms.sensors4plot,'RL')
    Plot_Variance_as_Patch(FeatureParms.actual_freqs,squeeze(mean(moddepth(:,sensorimotor_left_idx,:),1))',...
        'variance_method','maxmin','patch_color','g','fig',parms.fig,'patch_alpha',0.25);
    sensor_idx_ploted = [sensor_idx_ploted sensorimotor_left_idx];
    legend_text{end+1} = 'Left Sensorimotor (max-min)';
end

% All Other Sensors
sensor_idx_all_other = 1:size(moddepth,2);
sensor_idx_all_other(sensor_idx_ploted) = []; % remove all ploted already 
Plot_Variance_as_Patch(FeatureParms.actual_freqs,squeeze(mean(moddepth(:,sensor_idx_all_other,:),1))',...
    'variance_method',[.05 .95],'patch_color','k','fig',parms.fig,'patch_alpha',0.6); % STD across all sensor groups

% Right Sensorimotor (plot 95% confid, needs to be here for plot to look good)
if strcmpi(parms.sensors4plot,'R')||strcmpi(parms.sensors4plot,'LR')||strcmpi(parms.sensors4plot,'RL')
    Plot_Variance_as_Patch(FeatureParms.actual_freqs,squeeze(mean(moddepth(:,sensorimotor_right_idx,:),1))',...
        'variance_method',[0 .05],'patch_color','r','fig',parms.fig,'patch_alpha',0.5);
    Plot_Variance_as_Patch(FeatureParms.actual_freqs,squeeze(mean(moddepth(:,sensorimotor_right_idx,:),1))',...
        'variance_method',[.95 1],'patch_color','r','fig',parms.fig,'patch_alpha',0.5);
end

% Left Sensorimotor (plot 95% confid, needs to be here for plot to look good)
if strcmpi(parms.sensors4plot,'L')||strcmpi(parms.sensors4plot,'LR')||strcmpi(parms.sensors4plot,'RL')
    
    Plot_Variance_as_Patch(FeatureParms.actual_freqs,squeeze(mean(moddepth(:,sensorimotor_left_idx,:),1))',...
        'variance_method',[0 .05],'patch_color','g','fig',parms.fig,'patch_alpha',0.5);
    Plot_Variance_as_Patch(FeatureParms.actual_freqs,squeeze(mean(moddepth(:,sensorimotor_left_idx,:),1))',...
        'variance_method',[.95 1],'patch_color','g','fig',parms.fig,'patch_alpha',0.5);
end

plot( [min(FeatureParms.actual_freqs),max(FeatureParms.actual_freqs)],2.92*[1 1],'--k')
plot( [min(FeatureParms.actual_freqs),max(FeatureParms.actual_freqs)],[0 0],'--k')
plot( [min(FeatureParms.actual_freqs),max(FeatureParms.actual_freqs)],2.92*[-1 -1],'--k')
set(gca,'XTick',[round(min(FeatureParms.actual_freqs)):10:round(max(FeatureParms.actual_freqs))])
xlabel('Frequency [Hz]');ylabel('Modulation')
legend_text{end+1} = 'All Other Sensors (95%)'; % make the legend, remove the first empty cell
legend(legend_text{2:end},'location','SouthEast')
% title('Select Freq Range for Topography (lt-mouse=select, ESC=quit, s-button=save figures and quit)')
title('')

Figure_Stretch(2)

if nargout>0
    fig_out = parms.fig;
end
%     drawnow

