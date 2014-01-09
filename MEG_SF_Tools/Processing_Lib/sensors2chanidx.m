% found_sensor_idx = sensors2chanidx(sensors_avalible,sensors_desired)
% Foldes [2012-09-12]
% 
% Finds the indicies that the list of sensors_desired are in the list of sensors_avalible
%
% EXAMPLE
% sensors2chanidx(Extract.channel_list,40)
%
% SEE: find_lists_overlap_idx.m

function found_sensor_idx = sensors2chanidx(sensors_avalible,sensors_desired)

found_sensor_idx=[];
for isensor = sensors_desired
    found_sensor_idx = [found_sensor_idx find(sensors_avalible == isensor)];
end    

% check
% sum((sensors_avalible(found_sensor_idx)./sensors_desired)==1)/length(sensors_desired)
