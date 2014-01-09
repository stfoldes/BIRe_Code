% idx = sort_idx(A,dim[OPTIONAL],mode[OPTIONAL]);
%
% Returns index of sort so you don't have to save the outputs of 'sort' before using the indices
% For example: x = y(sort_idx(z));
%
% Stephen Foldes 2012-10-07
% UPDATES:
% 2013-03-06 Foldes: now works with cell-strings or single inputs

function idx = sort_idx(A,dim,mode)

if nargin<2
    [~,idx] = sort(A);
    return
end

if ~exist('dim','var')
    if max(size(A))>1
        dim = find(size(A)>1);
    else
        dim = 1; %?
    end
end

if ~exist('mode','var')
    mode = 'ascend';
end  

[~,idx] = sort(A,dim,mode);


