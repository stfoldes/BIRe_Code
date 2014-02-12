function rgb_value = color_name2rgb(color_name)
% Translates a short color name (e.g. 'r') to rgb
% I can't believe matlab doesn't have this function
%
% 2014-01-27 Foldes

rgb_value = rem(floor((strfind('kbgcrmyw', color_name) - 1) * [0.25 0.5 1]), 2);