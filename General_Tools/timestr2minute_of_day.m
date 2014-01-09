% minute_of_day = timestr2minute_of_day(time_str)
% Converts a time into the minutes of the day (to do time math)
%
% Example:
% time_str='9:00 PM';
%
% Foldes [2012-09-28]

function minute_of_day = timestr2minute_of_day(time_str)

[Y, M, D, H, MN, S] = datevec(time_str);

minute_of_day = (H*60)+MN;


