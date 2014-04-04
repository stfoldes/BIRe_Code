function overlap_idx = find_lists_overlap_idx(reference_list,list4lookup)
% Return indicies of items in reference_list that match list4lookup
% works for cells-strings
%
% reference_list(overlap_idx) = list4lookup
%
% If this isn't working for you, try switching input order
% (I will say, the numeric method seems backwards and inefficent 2012-08-22)
%
% ***************************************
% ***************************************
%   THIS MAY BE THE SAME AS ismember(), POSSIBLY:
%   [~,overlap_idx] = ismember(list4lookup,reference_list)
% ***************************************
% ***************************************
%
% Foldes [2012-06-07]
% UPDATES
% 2012-11-06 Foldes: Repurposed.
% 2013-07-05 Foldes: Renamed input varibles (it wasn't doing what I thought)
% 2013-08-13 Foldes: Renamed from file_lists_overlap.m
% 2013-08-22 Foldes: Now works for cells-strings
% 2014-03-05 Foldes: Error w/ emptys

overlap_idx = []; % if no matches, you still need an output

if isnumeric(reference_list)
    overlap_per_item=zeros(length(reference_list),1);
    for iref = 1:length(reference_list)
        overlap_per_item(iref)=max(list4lookup==reference_list(iref));
    end
    overlap_idx=find(overlap_per_item==1);
    
elseif iscell(reference_list)
    if iscell(list4lookup)
        for ilookup = 1:length(list4lookup)
            match_flag = strmatch(list4lookup{ilookup},reference_list, 'exact');
            if ~isempty(match_flag) % 2014-03-04 Sometimes you can have empty
                overlap_idx(ilookup)=match_flag;
            end
        end
    else % input not a cell, so only one thing to look up
        overlap_idx=strmatch(list4lookup,reference_list, 'exact');
    end
    
end