function [value_rgb,values2color_idx] = color_values(values,varargin) %'colormap_name','max_value','min_value'
% Finds the rgb colors for a given set of values
% Normalizes the values and maps them to to the colormap
% If no colormap_name is given, this will use the current figure's colormap
% Can tell it the max/min values to normalize to if there is a scale different
% This code is very simple
%
% INPUTS:
%   values:             1D vector of values to map
%
% VARARGIN:
%   colormap_name:      See colormap.m. EXAMPLE 'jet','gray'
%   max_value:          User defines the max value for the values-vector. 
%                       Used to scale relative to something outside of this function
%   min_value:          User defines the min value for the values-vector. 
%
% OUTPUTS:
%   value_rgb:          [nvalues x 3] 
%   values2color_idx:   [nvalues] indices for were these values fit in the color map
%
% EXAMPLES:
%   
%
% 2014-01-27 Foldes
% UPDATES:
%
 

% colormap_name = parms.activity_color_map;
% values = parms.activity


%% DEFAULTS

parms.max_value =       [];
parms.min_value =       [];
parms.colormap_name =   []; % default to find map from current figure

parms = varargin_extraction(parms,varargin);


% Get current colormap if none is given
if isempty(parms.colormap_name)
    color_map = colormap;
else
    color_map = colormap(parms.colormap_name);
    %close % why does this open a figure?
end
if isempty(parms.max_value)
    parms.max_value = max(values);
end
if isempty(parms.min_value)
    parms.min_value = min(values);
end

%%

% normalize the values 0-1
values_normalized = ( values - parms.min_value)./abs( parms.max_value - parms.min_value );

% find the index for the values in the color map
color_max = max(color_map);
color_min = min(color_map);
values2color_idx = ceil(values_normalized.* (length(color_map)-1))+1;

% get the actual colors
value_rgb = color_map(values2color_idx,:);


