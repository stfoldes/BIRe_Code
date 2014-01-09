% [closest_idx,closest_val] = find_closest_range_idx(to_find,list)
% FOR INLINING
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

function [closest_idx,closest_val] = find_closest_range_idx(to_find,list)

[closest_val, closest_idx] = find_closest_range(to_find,list);






