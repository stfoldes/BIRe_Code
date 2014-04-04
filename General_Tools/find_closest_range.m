% [closest_val, closest_idx] = find_closest_range(to_find,list)
% Find a range that is closest to the the avalible list
%
% to_find = list of numbers to look up in "list"
% list = vector in which to look
%
% EXAMPLE:
% I would like to plot frequencies 20-30, but what frequencies are actually avalible?
%
% freq_avalible = find_closest_range([20:30],FeatureParms.actual_freqs);
%
% 2013-06-26 [Foldes]
% 2013-07-24 Foldes: find_closest_in_list works the same, REDUNDENT

function [closest_val, closest_idx] = find_closest_range(to_find,list)

for ientry = 1:length(to_find)
    [closest_val(ientry), closest_idx(ientry)] = find_closest_in_list(to_find(ientry),list);
end







