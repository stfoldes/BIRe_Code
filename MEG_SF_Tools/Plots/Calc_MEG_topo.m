function [weights_interp,weight_loc] = Calc_MEG_topo(weights_by_sensorloc,varargin)
% Interpolate Sensor-loc values
% SEE: Plot_MEG_head_plot
% weights_by_sensorloc: 102 values
%
% VARARGIN:
%   resolution
%
% OUTPUT
%     weights_interp
%     weight_loc.x | .y
%
% 2013-10-25 Foldes
% UPDATES

defaults.resolution = 100;
parms = varargin_extraction(defaults,varargin);

% Load sensor location
load sensors102.mat
sensor_loc_x = c102(:,2);
sensor_loc_y = c102(:,3);

% Interpolate
xlin = linspace(min(sensor_loc_x),max(sensor_loc_x),parms.resolution);
ylin = linspace(min(sensor_loc_y),max(sensor_loc_y),parms.resolution);

% Make Mesh Grid
[X, Y] = meshgrid(xlin, ylin);
Z = griddata(sensor_loc_x, sensor_loc_y, weights_by_sensorloc, X, Y, 'linear');

weight_loc.x = X;
weight_loc.y = Y;
weights_interp = Z;

%% PLOTTING
% 
% figure
% handle_topo = pcolor(weight_loc.x,weight_loc.y, weights_interp);
% shading interp
% axis tight
% axis square
% axis off