% idx = min_idx(varargin)
%
% Returns index of min so you don't have to save the outputs of 'min' before using the indices
% For example: x = y(min_idx(z,[],1));
%
% Foldes 2013-05-23
% 

function idx = min_idx(A,B,dim)

if exist('B') && ~isempty(B)
    [~,idx] = min(A,B);
    return
    
elseif ~exist('dim','var')
    if max(size(A))>1
        dim = find(size(A)>1);
    else
        dim = 1; %?
    end
end
[~,idx] = min(A,[],dim);


