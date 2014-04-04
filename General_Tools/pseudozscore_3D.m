% [pzscore_data]=pseudozscore_3D(data,mu,sigma)
% Stephen Foldes (2012-04-03)

% Should make do reshape for multi dim


function [pzscore_data]=pseudozscore_3D(data,mu,sigma)

for i=1:size(mu,1)
    for j=1:size(mu,2)
        pzscore_data(:,i,j) = bsxfun(@minus,data(:,i,j), mu(i,j));
        pzscore_data(:,i,j) = bsxfun(@rdivide, pzscore_data(:,i,j), sigma(i,j));
    end
end




















