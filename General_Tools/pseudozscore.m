% [pzscore_data]=pseudozscore(data,mu,sigma);
% Computes zscore based on given mu and sigma
% 
% Foldes (c. 2012/04)


function [pzscore_data]=pseudozscore(data,mu,sigma)

% dim = find(size(data) ~= 1, 1);
% if isempty(dim), dim = 1; end

% Compute data's mean and sd, and standardize it
% mu = mean(data,dim);
% sigma = std(data,flag,dim);
% sigma0 = sigma;
% sigma0(sigma0==0) = 1;



pzscore_data = bsxfun(@minus,data, mu);
pzscore_data = bsxfun(@rdivide, pzscore_data, sigma);





















