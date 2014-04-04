function idx = DB_find_idx(DB,input_field,match_criteria)
% SEE DB_find.
% This just gives the indice instead of a binary list
%
% Stephen Foldes [2012-09-05]
% UPDATES:
% 2013-10-03 Foldes: Metadata-->DB


idx = find(DB_find(DB,input_field,match_criteria)==1);
