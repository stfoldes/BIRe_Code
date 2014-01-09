% sensorgroupidx = sensors2sensorgroupidx(sensor_group_list,sensor_list);
% 
% Translates a list of sensor numbers (e.g. DEF_MEG_sensors*) into the index of sensor-groups
% Very similar to sensors2chanidx.m, but goes to sensor-groups instead
% This is simple
% sensor_group_list = [] --> defaults to all sensor groups
%
% 2013-03-28 Foldes
% UPDATES:
% 2013-06-10 Foldes: defaults to all sensor-groups

function sensorgroupidx = sensors2sensorgroupidx(sensor_group_list,sensor_list)

if isempty(sensor_group_list)
    load DEF_NeuromagSensorInfo;
    for ichan = 1:306
        sensor_idx2group(ichan) = NeuromagSensorInfo(ichan).sensor_group_num;
    end
    sensor_group_list=unique(sensor_idx2group);
end

sensorgroupidx = find_lists_overlap_idx(sensor_group_list,unique(sensors2sensorgroup(sensor_list)));
