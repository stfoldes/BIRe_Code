% idx = max_idx(varargin)
%
% Returns index of max so you don't have to save the outputs of 'max' before using the indices
% For example: x = y(max_idx(z,[],1));
%
% Foldes 2013-03-05
% 

function idx = max_idx(A,B,dim)

if exist('B') && ~isempty(B)
    [~,idx] = max(A,B);
    return
    
elseif ~exist('dim','var')
    if max(size(A))>1
        dim = find(size(A)>1);
    else
        dim = 1; %?
    end
end
[~,idx] = max(A,[],dim);


