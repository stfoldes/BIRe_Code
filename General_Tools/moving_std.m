function moving_std_vec = moving_std(data,window_size)

for itime=1+window_size:size(data,1)
    moving_std_vec(itime) = std(data(itime-window_size:itime,:));
end
