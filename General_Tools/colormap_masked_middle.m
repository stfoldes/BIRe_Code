function custom_map = colormap_masked_middle(percentile2mask,colormap_name)
% Masks the middle part of a color map
% Like 40%-60% is now all white so the small noise doesn't have a color
%
% Probably need to give actual values
%
% 2013-07-18 Foldes


%% DEFAULTS
% Get current colormap if none is given
if ~exist('colormap_name') || isempty(colormap_name)
    custom_map = colormap;
else
    custom_map = colormap(colormap_name);
end

% mask the middle 10%
if ~exist('percentile2mask') || isempty(percentile2mask)
    percentile2mask = [0.1];
end

% if ~exist('mask_color') || isempty(mask_color)
%     mask_color = [1 1 1];    
% end

%%

num_colors = size(custom_map,1);

idxrange2mask = round(quantile([1:num_colors],[0.5-percentile2mask/2 0.5+percentile2mask/2]));

custom_map(min(idxrange2mask):max(idxrange2mask),:) = ones(diff(idxrange2mask)+1,3);

colormap(custom_map);
