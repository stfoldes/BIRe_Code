function [obj,idx] = sort_enteries(obj,property_str,sort_mode)
% Returns a sorted database which is sorted by property name
%
% 'ascend'Ascending order (default)
% 'descend'Descending order
% 
% 2013-10-08 Foldes
% UPDATES:


if ~exist('sort_mode') || isempty(sort_mode)
    sort_mode = 'ascend';
end

% Sort alphabetically by entry_id so you can read it easier
for ientry = 1:length(obj)
    eval(['all_prop_vals{ientry}=obj(ientry).' property_str ';'])
end

% Sort can't use mode with cells, lazy Matlab
ascending_order = sort_idx(all_prop_vals);

switch sort_mode
    case 'ascend'
        idx = ascending_order;
    case 'descend'
        idx = ascending_order(end:-1:1);
end

obj=obj(idx);


