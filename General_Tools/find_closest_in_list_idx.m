% [closest_idx,closest_val] = find_closest_in_list_idx(to_find,list)
% SAME AS find_closest_in_list.m BUT WITH INDEX FIRST OUTPUT
% Find closest value in the given list.
%
% to_find = single value to look up in list
% list = vector in which to look
%
% 2013-01-30 [Foldes]

function [closest_idx,closest_val] = find_closest_in_list_idx(to_find,list)

[closest_val, closest_idx] = find_closest_in_list(to_find,list);
