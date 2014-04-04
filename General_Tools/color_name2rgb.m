function rgb_value = color_name2rgb(color_name)
% Translates a short color name (e.g. 'r') to rgb
% I can't believe matlab doesn't have this function
% Will pass through RGB
%
% 2014-01-27 Foldes
% UPDATES:
% 2014-02-19 Foldes: Now passes RGB through

if ischar(color_name)
    rgb_value = rem(floor((strfind('kbgcrmyw', color_name) - 1) * [0.25 0.5 1]), 2);
elseif isnumeric(color_name) %&& (length(color_name) == 3)
    rgb_value = color_name;
else
    error('color_name is not a letter nor RGB')
end