% function [minmax_data] = minmax(data,dim)
% Stephen Foldes 01-25-2012
%
% Returns a vector of mins and maxs to quickly show/return max and mins. This is super simple, but quicker and has some smarts for 1D arrays.
% dim: the dimension to look over (can be absent)

function [minmax_data] = minmax(data,dim)

% "dim" not required. this will be smart on 1D arrays.
if ~exist('dim') || isempty(dim)
    if size(data,2)==1
        dim = 1;
    elseif size(data,1)==1
        dim = 2;
    else
        dim = 1;
    end
end

minmax_data(1,:) = min(data,[],dim);
minmax_data(2,:) = max(data,[],dim);

