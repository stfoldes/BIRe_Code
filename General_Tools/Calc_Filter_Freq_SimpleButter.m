% data_filtered=Calc_Filter_Freq_SimpleButter(data,freq,data_rate,filter_type[OPTIONAL]);
% Does a 4th order butterworth filter with filtfilt, simple
%
% freq = Hz, can be [1 5]
% filter_type[OPTIONAL] = 'low','high','bandpass','stop'
%     filter_type empty or not included will default to 'bandpass' or 'low' depending on size of freq
% Foldes 2013-04-24
% UPDATES
% 2013-07-03 Foldes: data must be double!

function data_filtered=Calc_Filter_Freq_SimpleButter(data,freq,data_rate,filter_type)

if ~exist('filter_type') || isempty(filter_type)
    if length(freq)>1
        filter_type = 'bandpass';
    else
        filter_type = 'low';
    end
end

clear filter_b filter_a
Wn=freq/(data_rate/2);
[filter_b,filter_a] = butter(4,Wn,filter_type); % 4th order butterworth filter
data_filtered=filtfilt(filter_b,filter_a,double(data));
