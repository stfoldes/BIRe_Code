function [freq_idx,actual_freqs] = freq2idx(freq_range,freq_list)
% Returns indicies in freq_list that are closest to the valuse in freq_range
%
% freq_range: [min_freq:max_freq], or [min_freq max_freq] or 'beta' (corresponding to DEG_freq_bands)
% freq_list = FeatureParms.actual_freqs (pretty much always)
%
% EXAMPLE:
% feature_data_move(:,:,freq2idx('beta',FeatureParms.actual_freqs));
%
% 2013-07-16 Foldes
% UPDATES:


% can use freq band names
if ischar(freq_range)
    freq_range = minmax(DEF_freq_bands(freq_range));
end

% turn [begining, end] format into a vector
if length(freq_range)<=2
    freq_range = [min(freq_range):max(freq_range)];
end

% determine closest frequencies to the choices
[actual_freqs, freq_idx] = find_closest_range(freq_range,freq_list);

