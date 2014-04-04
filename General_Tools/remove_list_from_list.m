function final_list = remove_list_from_list(base_list,removal_list)
% Returns a list that is base_list, but with removal_list removed. Very simple
% works for cells-strings (should b/c uses find_lists_overlap_idx, but not checked 2013-09-12)
%
% 2013-09-12 Foldes
% UPDATES

final_list = base_list;
if ~isempty(removal_list)
    final_list(find_lists_overlap_idx(base_list,removal_list))=[];
end