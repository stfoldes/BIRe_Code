% minute_of_day = timestr2minute_of_day(time_str);
% minutes = 547;
% minutes = timestr2minute_of_day('9:10 PM');

function time_str = minutes2timestr(minutes)

HR = floor(minutes/60);
MN = rem(minutes,60);

if HR > 12
    AMPM = 'PM';
else
    AMPM = 'AM';
end

HR = mod(HR,12);

% append '0' if needed
MN_str = num2str(MN);
while length(MN_str)<2
    MN_str=['0' MN_str];
end

time_str = [num2str(HR) ':' MN_str ' ' AMPM];

