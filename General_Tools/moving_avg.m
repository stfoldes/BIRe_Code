% moving_avg_vec = moving_avg(data,window_size)
% Stephen Foldes (2011)
%
% Just simply takes the moving average of a 1 or 2D vector

function moving_avg_vec = moving_avg(data,window_size)

for itime=1+window_size:size(data,1)
    moving_avg_vec(itime,:) = mean(data(itime-window_size:itime,:));
end

