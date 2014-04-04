function [fig, handle_topo, weight_limit] = Plot_MEG_head_plot(sensor_list,weights,varargin)%sensor_type,,weight_limit,display_chan_flag,fig)
% [fig, handle_topo, weight_limit] = Plot_MEG_head_plot(sensor_list,weights,varargin)%sensor_type,,weight_limit,display_chan_flag,fig)
% Plots vector onto the standard 306 channel MEG (could be weights, power, etc.). Requires sensors102.mat
% Nose is up, left is left (and indicated)
%
% INPUTS
%     sensor_list: Sensor numbers corresponding to weights (if you enter [] it assumes the weights are in sensor space already).
%     Can be a cell array of Neuromag Channel Code names (such as from BST .RowNames)
%     Must be related to the 306 (or the cell)
%     weights: vector of weights (to be color) corresponding to the channels listed in sensor_list
% 
% VARARGIN
%     sensor_type: if more than one type of sensor is possible, this will define which one will plot
%         1: Longitudinal Grads, 2: Latitudinal Grads, 3: Magnetometers
%     weight_limit: [min max] values for limiting the colors (so you can compare figures), put [] to let it use the maximum(abs()) to limit colors
%     display_chan_flag: 0[default] = don't display the channel locations,1= put dots where the channels used are, 2= put dots and channel numbers on
%     fig = figure handle
%     contour = 0=pcolor, 1=contourf
%
% SEE: Plot_MEG_chan_locations(DEF_MEG_sensors_sensorimotor_left_hemi,'MarkerType',1,'Color','k'); 
%
% Stephen Foldes [2011-02]
% UPDATES:
% 02-24-11 SF: made sure the colors span zero equally.
% 2012-02-01 SF: Changed name from MEG_head_plot.m, updated function-call-names.
% 2012-08-29 Foldes: no longer needs all inputs to function
% 2012-09-17 Foldes: 'cubic' interpolation changed to 'linear' (should matter much b/c of typical sparsness)
% 2012-11-18 Foldes: Can now have DSP names-cell array for sensor_list
% 2013-02-21 Foldes: DSP2ChanNum.m replaced with NeuromagCode2ChanNum.m
% 2013-07-18 Foldes: returns handle for topo part of figure ( to do colormap(handle_topo,'gray') )
% 2013-10-11 Foldes: MAJOR, varargin
% 2013-12-05 Foldes: contour option

%% DEFAULTS
defaults.sensor_type = 'long';
defaults.weight_limit = [];
defaults.fig = [];
defaults.display_chan_flag=0;
defaults.contour = 0;
parms=varargin_extraction(defaults,varargin);

% turn sensor type into a number (spelling; its a bitch)
switch lower(parms.sensor_type)
    case {1,'lon','long','longitudinal','longitudinals'}
        sensor_type_num = 1;
    case {2,'lat','lati','latitudinal','latitudinals'}
        sensor_type_num = 2;
    case {3,'mag','magn','magnetometer','magnetometers'}
        sensor_type_num = 3;
end

%%
% Translate a cell array of Neuromag Channel Code names into channel numbers
if iscell(sensor_list)
    [sensor_list] = NeuromagCode2ChanNum(sensor_list);
elseif isempty(sensor_list)
    sensor_list = [1:3:306];
end

% Only get sensors of the specified type
% automatically detect what sensor type is used
sensor_type_vec = round(mod(sensor_list,3.001));
% 1: Longitudinal Grads, 2: Latitudinal Grads, 3: Magnetometers
if length(unique(sensor_type_vec))>1 % more than one type of sensor given
    sensor_list = sensor_list(find(sensor_type_vec == sensor_type_num));
else
    sensor_type_num = unique(sensor_type_vec);
end

% sensor-num to sensor-group-num (easier treat it as a group)
sensor_group_list = sensors2sensorgroup(sensor_list);


% put weights onto a list of channels
channel_weight = zeros(102,1);
channel_weight(sensor_group_list)=weights(sensor_type_vec==sensor_type_num);

%% Ploting

if isempty(parms.fig)
    parms.fig=figure;
end
figure(parms.fig);
hold all



% resolution = 100;
% 
% % Load sensor location
% load sensors102.mat
% sensor_loc_x = c102(:,2);
% sensor_loc_y = c102(:,3);
% 
% % Interpolate
% xlin = linspace(min(sensor_loc_x),max(sensor_loc_x),resolution);
% ylin = linspace(min(sensor_loc_y),max(sensor_loc_y),resolution);
% 
% % Make Mesh Grid
% [X, Y] = meshgrid(xlin, ylin);
% Z = griddata(sensor_loc_x, sensor_loc_y, channel_weight, X, Y, 'linear');
% 
% handle_topo = pcolor(X, Y, Z);

[weights_interp,weight_loc] = Calc_MEG_topo(channel_weight,'resolution',100);

if parms.contour == 1
    contourf(weight_loc.x,weight_loc.y, weights_interp);
else
    handle_topo = pcolor(weight_loc.x,weight_loc.y, weights_interp);
    shading interp
end



% to limit the colors
if isempty(parms.weight_limit)
    % to limit the colors to being max(abs())
    parms.weight_limit = [-max(abs(channel_weight)) max(abs(channel_weight))];
end

if min(parms.weight_limit ~= 0)
    caxis(parms.weight_limit);
end



%% Displaying channel locations if desired

if parms.display_chan_flag>0   
    Plot_MEG_chan_locations(sensor_list,'MarkerType',(parms.display_chan_flag-1),'fig',parms.fig); % 2013-08-13
else
    Plot_MEG_Helmet
end

%     text(min(sensor_pos(:,1))-10, mean(sensor_pos(:,2)), 'L', 'FontSize', 16, 'FontWeight', 'bold')
%
switch sensor_type_num
    case 1
        sensor_type_str='Longitudinal Grads';
    case 2
        sensor_type_str='Latitudinal Grads';
    case 3
        sensor_type_str='Magnetometers';
end
title(sensor_type_str)

%Plot_MEG_Helmet(fig);

%     set(gca,'Position',get(gca,'OuterPosition'))
axis tight
axis square
axis off

