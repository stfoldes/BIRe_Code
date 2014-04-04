% [closest_val, closest_idx] = find_closest_in_list(to_find,list)
% Find closest value in the given list.
%
% to_find = single value (or vector) to look up in list
% list = vector in which to look
%
% 2013-01-30 Foldes
% UPDATES
% 2013-07-02 Foldes: Now works w/ to_find vectors

function [closest_val, closest_idx] = find_closest_in_list(to_find,list)

for ientry = 1:length(to_find)
    [~,closest_idx(ientry)]=min(abs(to_find(ientry)-list));
    closest_val(ientry) = list(closest_idx(ientry));
end