% Mean and STD without outlines
%
% Foldes [2012-11-02]

function [mu_new, std_new] = mean_std_wo_outliers(x,quantile_thres)

if ~exist('quantile_thres') || isempty(quantile_thres)
    quantile_thres = 0.99;
end

if quantile_thres == 0
    quantile_thres = 1;
end

%%
mu = mean(x);

new_x = x;
too_big_idx = find(abs(x-mu)>quantile(abs(x-mu),quantile_thres));
for i = 1:length(too_big_idx)
   new_x(too_big_idx(i)) = new_x(too_big_idx(i)-1);
end

% figure;hold all
% plot(x)
% plot(new_x)

mu_new = mean(new_x);
std_new = std(new_x);

